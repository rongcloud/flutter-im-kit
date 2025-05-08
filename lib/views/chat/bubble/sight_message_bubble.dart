import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';
import 'package:provider/provider.dart';

class RCKSightMessageBubble extends RCKMessageBubble {
  RCKSightMessageBubble({
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

  String _getProgressKey(int? messageId) => 'sight_${messageId ?? 0}';

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    RCIMIWSightMessage sightMessage = message as RCIMIWSightMessage;
    final progressKey = _getProgressKey(sightMessage.messageId);

    // 使用配置的视频样式
    final sightConfig = config?.sightStyleConfig;
    final maxWidth = sightConfig?.maxWidth ?? 100;
    final maxHeight = sightConfig?.maxHeight ?? 180;
    final playButtonSize = sightConfig?.playButtonSize ?? 40;
    final playButtonColor = sightConfig?.playButtonColor ??
        RCKThemeProvider().themeColor.bgAuxiliary1;
    final sightDownloaded =
        sightMessage.local != null && sightMessage.local!.isNotEmpty;

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                  config?.imageStyleConfig.borderRadius ?? 8.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: ImageUtil.getImageWidget(
                  "",
                  thumbnailBase64String: sightMessage.thumbnailBase64String,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Consumer<RCKDownloadProgressProvider>(
                builder: (context, provider, child) {
              double progress = provider.getProgress(progressKey).value;
              final isDownloading = progress > 0 && progress < 1;
              final customPlayButtonIconPath =
                  sightConfig?.customPlayButtonIconPath ??
                      (sightDownloaded
                          ? 'sight_play.png'
                          : isDownloading
                              ? 'sight_downloading.png'
                              : 'sight_download.png');

              return Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ImageUtil.getImageWidget(
                    customPlayButtonIconPath,
                    width: playButtonSize,
                    height: playButtonSize,
                  ),
                  if (isDownloading)
                    SizedBox(
                      width: playButtonSize * 0.75,
                      height: playButtonSize * 0.75,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        color: playButtonColor,
                      ),
                    )
                ],
              );
            }),
          ],
        );
      },
    );
  }

  @override
  void onBubbleTap(BuildContext context) {
    RCIMIWMediaMessage sightMessage = message as RCIMIWMediaMessage;
    final progressKey = _getProgressKey(sightMessage.messageId);
    final provider = context.read<RCKDownloadProgressProvider>();

    if (sightMessage.local == null || sightMessage.local!.isEmpty) {
      double progress = provider.getProgress(progressKey).value;
      if (progress > 0 && progress < 1) {
        context.read<RCKChatProvider>().cancelDownloadMediaMessage(
          sightMessage,
          downloadCancel: (message) {
            provider.reset(progressKey); // 下载取消，重置进度
          },
        );
      } else {
        context.read<RCKChatProvider>().downloadMediaMessage(
          sightMessage,
          downloaded: (code, message) {
            provider.reset(progressKey);
            // 下载完成后打开播放器
            if (code == 0) {
              sightMessage.local = message?.local ?? '';
              context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
              final chatProvider = context.read<RCKChatProvider>();
              chatProvider.saveScrollOffset();
              Navigator.pushNamed(context, '/video_player_page', arguments: {
                'currentIndex': 0,
                'videos': [sightMessage],
              }).then((value) {
                chatProvider.jumpToScrollOffset();
              });
            }
          },
          downloading: (message, progress) {
            provider.updateProgress(
                progressKey, (progress ?? 0) / 100); // 转换进度为0-1
          },
        );
      }
    } else {
      context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
      context.read<RCKVoiceRecordProvider>().cancelRecord();
      final chatProvider = context.read<RCKChatProvider>();
      chatProvider.saveScrollOffset();
      Navigator.pushNamed(context, '/video_player_page', arguments: {
        'currentIndex': 0,
        'videos': [sightMessage],
      }).then((value) {
        chatProvider.jumpToScrollOffset();
      });
    }
  }
}
