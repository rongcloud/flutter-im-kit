import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../rongcloud_im_kit.dart';
import '../../../utils/file_util.dart';

class RCKFileMessageBubble extends RCKMessageBubble {
  RCKFileMessageBubble({
    super.key,
    required super.message,
    super.showTime,
    super.alignment,
    super.withoutBubble,
    super.config,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onSwipe,
  });

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    final isMe = message.direction == RCIMIWMessageDirection.send;

    // 使用配置的文件样式
    final fileStyleConfig = config?.fileStyleConfig;
    final containerWidth = fileStyleConfig?.containerWidth ?? 181;
    final containerHeight = fileStyleConfig?.containerHeight ?? 64;
    final iconSize = fileStyleConfig?.iconSize ?? 40;
    final fileNameStyle = isMe
        ? fileStyleConfig?.fileNameStyle
            .copyWith(color: RCKThemeProvider().themeColor.textInverse)
        : fileStyleConfig?.fileNameStyle ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
    final fileSizeStyle = isMe
        ? fileStyleConfig?.fileSizeStyle
            .copyWith(color: RCKThemeProvider().themeColor.textInverse)
        : fileStyleConfig?.fileSizeStyle ??
            const TextStyle(fontSize: 12, color: Colors.grey);
    final fileIconPath = fileStyleConfig?.customFileIconPath ??
        RCKThemeProvider().themeIcon.file ??
        "";

    final bgColor = isMe
        ? RCKThemeProvider().themeColor.bgAuxiliary2
        : RCKThemeProvider().themeColor.bgAuxiliary1;
    final iconColor = isMe
        ? RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
            ? bubbleFileIconColorMe
            : bubbleFileIconColorMeDark.withValues(alpha: .7)
        : RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
            ? bubbleFileIconColorOther
            : bubbleFileIconColorOtherDark.withValues(alpha: .7);

    if (message is RCIMIWFileMessage) {
      final fileMessage = message as RCIMIWFileMessage;

      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6.0),
        ),
        width: containerWidth,
        height: containerHeight,
        child: Row(children: [
          const SizedBox(width: 10),
          ImageUtil.getImageWidget(fileIconPath,
              fit: BoxFit.contain,
              width: iconSize,
              height: iconSize,
              color: iconColor),
          Container(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: containerWidth - iconSize - 40,
                  child: Text(
                    "${fileMessage.name}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: fileNameStyle,
                  ),
                ),
                Text(
                  FileUtil.formatFileSize(fileMessage.size ?? 0),
                  style: fileSizeStyle,
                )
              ],
            ),
          )
        ]),
      );
    }
    return Container();
  }

  @override
  void onBubbleTap(BuildContext context) {
    context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
    context.read<RCKVoiceRecordProvider>().cancelRecord();
    final chatProvider = context.read<RCKChatProvider>();
    chatProvider.saveScrollOffset();
    Navigator.pushNamed(context, '/file_preview', arguments: {
      'fileMessage': message as RCIMIWFileMessage,
      'chatProvider': context.read<RCKChatProvider>(),
    }).then((value) {
      chatProvider.jumpToScrollOffset();
    });
  }
}
