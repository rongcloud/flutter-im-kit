import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../rongcloud_im_kit.dart';

class VoiceRecordButton extends StatefulWidget {
  /// 语音按钮配置
  final RCKVoiceRecordConfig config;

  const VoiceRecordButton({
    super.key,
    this.config = const RCKVoiceRecordConfig(),
  });

  @override
  VoiceRecordButtonState createState() => VoiceRecordButtonState();
}

class VoiceRecordButtonState extends State<VoiceRecordButton> {
  bool _isInButton = true;
  Offset? _buttonPosition;
  Size? _buttonSize;

  bool _onRequestPermission = false;

  bool _inPermissionPointerUp = false;

  bool _isPointInButtonArea(Offset point) {
    if (_buttonPosition == null || _buttonSize == null) return false;
    final Rect buttonRect = Rect.fromLTWH(
      0,
      MediaQuery.of(context).size.height - kVoiceRecordingBackgroundHeight,
      MediaQuery.of(context).size.width,
      kVoiceRecordingBackgroundHeight,
    );
    return buttonRect.contains(point);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RCKVoiceRecordProvider>(
      builder: (context, provider, child) {
        bool isRecording =
            provider.voiceSendingType != RCIMIWMessageVoiceSendingType.notStart;

        // 使用默认实现
        return Listener(
          onPointerDown: (PointerDownEvent event) async {
            // 检查麦克风权限
            _onRequestPermission = true;
            final status = await Permission.microphone.request();
            _onRequestPermission = false;
            if (_inPermissionPointerUp) {
              _inPermissionPointerUp = false;
              return;
            }
            if (status.isGranted && context.mounted) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              _buttonPosition = box.localToGlobal(Offset.zero);
              _buttonSize = box.size;
              _isInButton = true;
              provider.startRecord(context);
            } else {
              // 权限被拒绝，显示提示
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('提示'),
                    content: const Text('需要麦克风权限才能录制语音'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('确定')),
                    ],
                  ),
                );
              }
            }
          },
          onPointerMove: (PointerMoveEvent event) {
            if (_onRequestPermission) {
              return;
            }
            bool isInside = _isPointInButtonArea(event.position);
            if (_isInButton != isInside) {
              _isInButton = isInside;
              if (isInside) {
                provider.resumeRecord();
              } else {
                provider.pauseRecord();
              }
            }
          },
          onPointerUp: (PointerUpEvent event) async {
            if (_onRequestPermission) {
              _inPermissionPointerUp = true;
              return;
            }
            if (_isInButton) {
              await provider.finishRecord(context);
            } else {
              provider.cancelRecord();
            }
          },
          child: Container(
            height: kInputFieldMinHeight - 2 * kInputFieldContentPaddingV,
            decoration: BoxDecoration(
              color: isRecording
                  ? widget.config.pressedBackgroundColor
                  : widget.config.backgroundColor ??
                      RCKThemeProvider().themeColor.bgAuxiliary2,
              borderRadius: BorderRadius.circular(widget.config.borderRadius),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageUtil.getImageWidget(
                    RCKThemeProvider().themeIcon.audio ?? '',
                    width: kInputFieldVoiceIconSize,
                    height: kInputFieldVoiceIconSize,
                    color: Colors.white),
                const SizedBox(width: kInputFieldVoiceSpace),
                Text(
                  isRecording
                      ? (_isInButton
                          ? widget.config.recordingText
                          : widget.config.cancelText)
                      : widget.config.defaultText,
                  style: isRecording
                      ? (_isInButton
                          ? widget.config.recordingTextStyle
                          : widget.config.cancelTextStyle)
                      : widget.config.defaultTextStyle ??
                          TextStyle(
                            color: Colors.white,
                            fontSize: kInputFieldVoiceFontSize,
                          ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
