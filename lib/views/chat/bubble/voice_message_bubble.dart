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
    super.onAppendBubbleTap,
    super.onAppendBubbleLongPress,
  });

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    RCIMIWVoiceMessage voiceMessage = message as RCIMIWVoiceMessage;
    final bool isMe = message.direction == RCIMIWMessageDirection.send;

    // 使用配置中的语音样式
    final voiceStyleConfig = config?.voiceStyleConfig;

    return Consumer<RCKAudioPlayerProvider>(
        builder: (context, provider, child) {
      final bool isPlaying =
          provider.currentPlayingMessageId == message.messageId.toString() &&
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

  /// 将消息列表滚动到底部（仅当当前语音消息是列表最后一条时）
  void autoScrollIfLast(BuildContext context) {
    final provider = context.read<RCKChatProvider>();
    final msgs = provider.messages;
    final int? curId = (message as RCIMIWVoiceMessage).messageId;
    if (curId != null && msgs.isNotEmpty && msgs.last.messageId == curId) {
      provider.messageListScrollToBottom();
    }
  }

  /// 使用父类提供的扩展点，在主气泡下方追加“语音转文字”气泡
  /// 仅显示文字与边框：当该消息处于可见列表且已有转写文本时展示
  @override
  Widget? buildAppendBubble(BuildContext context) {
    final RCIMIWVoiceMessage voiceMessage = message as RCIMIWVoiceMessage;
    final int? id = voiceMessage.messageId;

    final chatProvider = context.read<RCKChatProvider>();
    final bool isVisible =
        chatProvider.speechToTextMessageIdsVisible.contains(id);

    final String text = voiceMessage.speechToTextInfo?.text ?? '';
    final bool isConverting = voiceMessage.speechToTextInfo?.status ==
        RCIMIWSpeechToTextStatus.converting;
    final bool isFailed = voiceMessage.speechToTextInfo?.status ==
            RCIMIWSpeechToTextStatus.failed &&
        isVisible;

    if (isFailed) {
      return Container(
        margin: const EdgeInsets.only(top: 6.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
              color: RCKThemeProvider().themeColor.textAuxiliary ?? Colors.grey,
              width: 0.5),
          borderRadius: BorderRadius.circular(6),
          color: RCKThemeProvider().themeColor.bgAuxiliary1 ?? Colors.grey,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ImageUtil.getImageWidget(
                RCKThemeProvider().themeIcon.attention ?? '',
                width: 14,
                height: 14,
                color: RCKThemeProvider().themeColor.textAuxiliary),
            const SizedBox(width: 5),
            Text(
              "语音转换失败",
              style: TextStyle(
                  color: RCKThemeProvider().themeColor.textAuxiliary ??
                      Colors.grey,
                  fontSize: 14,
                  height: 1.35),
            ),
          ],
        ),
      );
    }

    if (isConverting) {
      return _SttConvertingIndicator(
        onFirstFrame: () => autoScrollIfLast(context),
      );
    }

    if (id == null) return null;

    if (!isVisible) {
      return null;
    }

    final bool isShown =
        chatProvider.speechToTextMessageIdsHasShown.contains(id);
    final bool isMe = message.direction == RCIMIWMessageDirection.send;
    final Alignment alignment =
        isMe ? Alignment.centerRight : Alignment.centerLeft;

    if (!isShown) {
      return _SttAppendBubbleAnimated(
        text: text,
        borderColor: RCKThemeProvider().themeColor.textAuxiliary ?? Colors.grey,
        textColor: RCKThemeProvider().themeColor.textPrimary ?? Colors.black,
        bgColor: RCKThemeProvider().themeColor.bgAuxiliary1 ?? Colors.grey,
        onShown: () => chatProvider.addSpeechToTextMessageIdHasShown(id),
        alignment: alignment,
        messageId: id,
      );
    }

    return _SttAppendBubblePlain(
      text: text,
      borderColor: RCKThemeProvider().themeColor.textAuxiliary ?? Colors.grey,
      textColor: RCKThemeProvider().themeColor.textPrimary ?? Colors.black,
      bgColor: RCKThemeProvider().themeColor.bgAuxiliary1 ?? Colors.grey,
      alignment: alignment,
    );
  }

  @override
  void onBubbleTap(BuildContext context) {
    RCIMIWVoiceMessage voiceMessage = message as RCIMIWVoiceMessage;

    context
        .read<RCKAudioPlayerProvider>()
        .playVoiceMessage(voiceMessage, context);
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

class _SttAppendBubblePlain extends StatelessWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final Alignment alignment;
  final Color bgColor;
  const _SttAppendBubblePlain({
    required this.text,
    required this.borderColor,
    required this.textColor,
    required this.alignment,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(top: 6.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(6),
          color: bgColor,
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.35),
        ),
      ),
    );
  }
}

class _SttConvertingIndicator extends StatefulWidget {
  const _SttConvertingIndicator({required this.onFirstFrame});

  final VoidCallback onFirstFrame;

  @override
  State<_SttConvertingIndicator> createState() =>
      _SttConvertingIndicatorState();
}

class _SttConvertingIndicatorState extends State<_SttConvertingIndicator> {
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasTriggered) return;
      _hasTriggered = true;
      widget.onFirstFrame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      child: ImageUtil.getImageWidget(
        'speech_loading.png',
        height: 5,
        width: 30,
      ),
    );
  }
}

class _SttAppendBubbleAnimated extends StatefulWidget {
  final String text;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onShown;
  final Alignment alignment;
  final int messageId;
  final Color bgColor;
  const _SttAppendBubbleAnimated({
    required this.text,
    required this.borderColor,
    required this.textColor,
    required this.onShown,
    required this.alignment,
    required this.messageId,
    required this.bgColor,
  });

  @override
  State<_SttAppendBubbleAnimated> createState() =>
      _SttAppendBubbleAnimatedState();
}

class _SttAppendBubbleAnimatedState extends State<_SttAppendBubbleAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heightFactor; // 0 -> 1 in 0.2s
  late final Animation<double> _widthFactor; // 0 -> 1 in next 0.3s
  bool _hasAutoScrolledDuringAnimation = false;
  bool _hasAutoScrolledOnComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    );
    _widthFactor = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.addListener(_autoScrollIfLast);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_hasAutoScrolledOnComplete) {
          _hasAutoScrolledOnComplete = true;
          _scrollToBottomIfLast();
        }
        widget.onShown();
      }
    });
    // 开始动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.removeListener(_autoScrollIfLast);
    _controller.dispose();
    super.dispose();
  }

  void _autoScrollIfLast() {
    if (!mounted || _hasAutoScrolledDuringAnimation) return;
    if (_scrollToBottomIfLast()) {
      _hasAutoScrolledDuringAnimation = true;
    }
  }

  bool _scrollToBottomIfLast() {
    final provider = context.read<RCKChatProvider>();
    final msgs = provider.messages;
    if (msgs.isNotEmpty && msgs.last.messageId == widget.messageId) {
      provider.messageListScrollToBottom();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // 第一阶段：高度从 0 -> 1；第二阶段：宽度从边缘向中心 0 -> 1
          final double widthFraction = _widthFactor.value.clamp(0.0, 1.0);
          final double heightFraction = _heightFactor.value.clamp(0.0, 1.0);
          final bool fromRight = widget.alignment.x > 0;

          return Align(
            alignment: widget.alignment,
            child: ClipRect(
              clipper: _EdgeWidthHeightClipper(
                widthFraction: widthFraction > 0 ? widthFraction : 0.001,
                heightFraction: heightFraction,
                fromRight: fromRight,
              ),
              child: Align(
                alignment: fromRight ? Alignment.topRight : Alignment.topLeft,
                heightFactor: heightFraction,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.borderColor, width: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    color: widget.bgColor,
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        color: widget.textColor, fontSize: 14, height: 1.35),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EdgeWidthHeightClipper extends CustomClipper<Rect> {
  final double widthFraction;
  final double heightFraction;
  final bool fromRight;

  _EdgeWidthHeightClipper({
    required this.widthFraction,
    required this.heightFraction,
    required this.fromRight,
  });

  @override
  Rect getClip(Size size) {
    final double w = (size.width * widthFraction).clamp(0.0, size.width);
    final double h = (size.height * heightFraction).clamp(0.0, size.height);
    final double left = fromRight ? (size.width - w) : 0.0;
    return Rect.fromLTWH(left, 0.0, w, h);
  }

  @override
  bool shouldReclip(covariant _EdgeWidthHeightClipper oldClipper) {
    return oldClipper.widthFraction != widthFraction ||
        oldClipper.heightFraction != heightFraction ||
        oldClipper.fromRight != fromRight;
  }
}
