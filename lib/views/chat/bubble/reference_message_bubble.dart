import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class RCKReferenceMessageBubble extends RCKMessageBubble {
  RCKReferenceMessageBubble({
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
    final refMsg = (message as RCIMIWReferenceMessage).referenceMessage;

    // 使用工具函数获取引用消息内容
    String referenceContent = getReferenceMessageContent(refMsg);

    final String messageText = (message as RCIMIWReferenceMessage).text ?? "";

    if (refName == null || refName.isEmpty) {
      refName = refMsg?.senderUserId;
    }

    final isMe = message.direction == RCIMIWMessageDirection.send;

    // 使用配置的引用和文本样式
    final refConfig = config?.referenceStyleConfig;
    final textConfig = config?.textStyleConfig;
    final linkConfig = config?.linkStyleConfig;

    final backgroundColor = refConfig?.backgroundColor;
    final refTextStyle = refConfig?.textStyle ??
        TextStyle(
            color: isMe
                ? RCKThemeProvider().themeColor.textInverse
                : RCKThemeProvider().themeColor.textSecondary,
            fontSize: kBubbleRefTextFontSize);
    final padding = refConfig?.padding ?? const EdgeInsets.all(8.0);
    final spacingToContent =
        refConfig?.spacingToContent ?? kBubbleRefTextPadding;

    final textStyle =
        isMe ? textConfig?.senderTextStyle : textConfig?.receiverTextStyle;

    final linkStyle =
        isMe ? linkConfig?.senderTextStyle : linkConfig?.receiverTextStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: padding,
          margin: EdgeInsets.only(
              bottom: spacingToContent, right: spacingToContent),
          color: backgroundColor,
          child: Text(
            "| 回复 $refName：$referenceContent",
            style: refTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Linkify(
          onOpen: _onOpen,
          text: messageText,
          options: const LinkifyOptions(humanize: false),
          style:
              textStyle ?? const TextStyle(color: Colors.black, fontSize: 16),
          linkStyle: linkStyle?.copyWith(
                  decoration: linkConfig?.showUnderline ?? false
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: linkStyle.color ?? Colors.blue) ??
              TextStyle(
                  color: Colors.blue,
                  fontSize: textStyle?.fontSize,
                  decoration: TextDecoration.underline,
                  decorationColor: linkStyle?.color ?? Colors.blue),
        )
      ],
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    Uri uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $link';
    }
  }
}
