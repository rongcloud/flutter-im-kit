import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';
import 'package:provider/provider.dart';

class RCKVoiceMessageBubble extends RCKMessageBubble {
  RCKVoiceMessageBubble({
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
    RCIMIWVoiceMessage voiceMessage = message as RCIMIWVoiceMessage;
    final bool isMe = message.direction == RCIMIWMessageDirection.send;

    // 使用配置中的语音样式
    final voiceStyleConfig = config?.voiceStyleConfig;

    return Consumer<RCKAudioPlayerProvider>(builder: (context, provider, child) {
      final bool isPlaying =
          provider.currentPlayingMessageId ==
              message.messageId.toString() &&
          provider.state == RCKAudioPlayerState.playing;

      String iconName;
      if (voiceStyleConfig?.customPlayingIconPath != null &&
          voiceStyleConfig?.customNotPlayingIconPath != null) {
        // 使用自定义图标
        iconName = isPlaying
            ? voiceStyleConfig!.customPlayingIconPath!
            : voiceStyleConfig!.customNotPlayingIconPath!;
      } else {
        // 使用默认图标
        iconName = isPlaying
            ? (isMe ? 'voice_playing_send.gif' : 'voice_playing_receive.gif')
            : isMe
                ? RCKThemeProvider().themeIcon.voiceMessageSend ?? ''
                : RCKThemeProvider().themeIcon.voiceMessage1 ?? '';
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            ImageUtil.getImageWidget(
              iconName,
              height: voiceStyleConfig?.iconSize ?? 20.0,
              color: isPlaying
                  ? voiceStyleConfig?.playingColor ??
                      RCKThemeProvider().themeColor.textPrimary
                  : voiceStyleConfig?.notPlayingColor ??
                      RCKThemeProvider().themeColor.textPrimary,
            ),
          // 计算文字实际宽度
          Builder(
            builder: (context) {
              final textSpan = TextSpan(
                text: "${voiceMessage.duration}''",
                style: voiceStyleConfig?.durationTextStyle ??
                    TextStyle(
                        color: isMe
                            ? RCKThemeProvider().themeColor.textInverse
                            : RCKThemeProvider().themeColor.textPrimary,
                        fontSize: kBubbleVoiceDurationFontSize),
              );
              final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
                maxLines: 1,
              )..layout();

              // 文字宽度加上左右padding
              final minWidth =
                  textPainter.width + (kBubbleVoiceDurationPadding * 2);

              // 计算目标宽度
              final targetWidth = _calculateVoiceBubbleWidth(
                voiceMessage.duration ?? 0,
                MediaQuery.of(context).size.width / 2, // 最大宽度为屏幕宽度的一半
                minWidth,
              );

              return Container(
                width: targetWidth + kBubbleVoiceDurationPadding,
                padding: const EdgeInsets.symmetric(
                    horizontal: kBubbleVoiceDurationPadding),
                child: Text(
                  "${voiceMessage.duration}''",
                  maxLines: 1,
                  textAlign: isMe ? TextAlign.right : TextAlign.left,
                  style: voiceStyleConfig?.durationTextStyle ??
                      TextStyle(
                          color: isMe
                              ? RCKThemeProvider().themeColor.textInverse
                              : RCKThemeProvider().themeColor.textPrimary,
                          fontSize: kBubbleVoiceDurationFontSize),
                ),
              );
            },
          ),
          if (isMe)
            ImageUtil.getImageWidget(
              iconName,
              height: voiceStyleConfig?.iconSize ?? 20.0,
              color: isPlaying
                  ? voiceStyleConfig?.playingColor ??
                      RCKThemeProvider().themeColor.bgRegular
                  : voiceStyleConfig?.notPlayingColor ??
                      RCKThemeProvider().themeColor.bgRegular,
            ),
        ],
      );
    });
  }

  @override
  void onBubbleTap(BuildContext context) {
    RCIMIWVoiceMessage voiceMessage = message as RCIMIWVoiceMessage;

    context.read<RCKAudioPlayerProvider>().playVoiceMessage(voiceMessage, context);
  }

  double _calculateVoiceBubbleWidth(
      int duration, double maxAvailableWidth, double minWidth) {
    const int minDuration = 5;
    const int maxDuration = 60;

    // 直接使用全部可用宽度
    final double maxWidth = maxAvailableWidth;

    if (duration <= minDuration) {
      return minWidth;
    } else if (duration >= maxDuration) {
      return maxWidth;
    } else {
      // 在最小和最大宽度之间按比例计算
      double ratio = (duration - minDuration) / (maxDuration - minDuration);
      return minWidth + (maxWidth - minWidth) * ratio;
    }
  }
}
