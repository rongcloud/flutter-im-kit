import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/utils/rotate_widget.dart';

typedef LastMessageBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKLastMessageConfig config);

class LastMessageWidget extends StatelessWidget {
  final RCIMIWConversation conversation;
  final RCKLastMessageConfig config;

  LastMessageWidget({
    super.key,
    required this.conversation,
    RCKLastMessageConfig? config,
  }) : config = config ?? RCKLastMessageConfig();

  @override
  Widget build(BuildContext context) {
    // 判断是否是草稿
    if (conversation.draft?.isNotEmpty ?? false) {
      return Row(
        children: [
          ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.edit ?? '',
              color: RCKThemeProvider().themeColor.notice,
              width: kConvoItemIconSize,
              height: kConvoItemIconSize),
          const SizedBox(width: kConvoItemIconPadding),
          Flexible(
            fit: FlexFit.loose,
            child: RichText(
              maxLines: config.maxLines,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: config.fontSize,
                  color: config.color,
                  fontWeight: config.fontWeight,
                ),
                children: [
                  TextSpan(text: conversation.draft),
                ],
              ),
            ),
          )
        ],
      );
    }

    // 处理最后一条消息
    String messageText = '';
    // 消息发送状态
    RCIMIWSentStatus? sentStatus = conversation.lastMessage?.sentStatus;
    bool isSending = sentStatus == RCIMIWSentStatus.sending;
    bool isFail = sentStatus == RCIMIWSentStatus.failed;

    if (conversation.lastMessage != null) {
      final message = conversation.lastMessage;

      // 文本消息直接显示内容
      if (message is RCIMIWTextMessage) {
        messageText = message.text ?? '';
      }
      // 图片消息
      else if (message is RCIMIWImageMessage) {
        messageText = '[图片]';
      }
      // 语音消息
      else if (message is RCIMIWVoiceMessage) {
        messageText = '[语音]';
      }
      // 表情消息
      else if (message is RCIMIWGIFMessage) {
        messageText = '[表情]';
      }
      // 位置消息
      else if (message is RCIMIWLocationMessage) {
        messageText = '[位置]';
      }
      // 文件消息
      else if (message is RCIMIWFileMessage) {
        messageText = '[文件]';
      }
      // 小视频消息
      else if (message is RCIMIWSightMessage) {
        messageText = '[视频]';
      }
      // 其他类型消息
      else {
        // 使用自定义类型文本或默认提示
        messageText = config.getTypeText(message.runtimeType);
      }
    }

    return Row(children: [
      if (isSending || isFail)
        Padding(
          padding: const EdgeInsets.only(right: kConvoItemIconPadding),
          child: isSending
              ? const RotatingImage(
                  imagePath: 'messageSending.png',
                  size: kConvoItemIconSize,
                )
              : ImageUtil.getImageWidget('messageSendFail.png',
                  color: RCKThemeProvider().themeColor.notice,
                  width: kConvoItemIconSize,
                  height: kConvoItemIconSize),
        ),
      Flexible(
        fit: FlexFit.loose,
        child: Text(
          messageText,
          style: TextStyle(
            fontSize: config.fontSize,
            color: config.color,
            fontWeight: config.fontWeight,
          ),
          maxLines: config.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
