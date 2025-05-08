import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class RCKTextMessageBubble extends RCKMessageBubble {
  RCKTextMessageBubble({
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
    final String messageText = message is RCIMIWTextMessage
        ? (message as RCIMIWTextMessage).text ?? ""
        : message.toJson().toString();

    // 使用配置的文本和链接样式
    final textStyleConfig = config?.textStyleConfig;
    final linkStyleConfig = config?.linkStyleConfig;

    final textStyle = (message.direction == RCIMIWMessageDirection.send)
        ? textStyleConfig?.senderTextStyle
        : textStyleConfig?.receiverTextStyle;

    final linkStyle = (message.direction == RCIMIWMessageDirection.send)
        ? linkStyleConfig?.senderTextStyle
        : linkStyleConfig?.receiverTextStyle;

    // 如果设置了行间距，使用 RichText 包装 TextSpan
    if (textStyleConfig?.lineSpacing != null) {
      return Linkify(
        onOpen: _onOpen,
        text: messageText,
        options: const LinkifyOptions(humanize: false),
        style: textStyle ?? const TextStyle(color: Colors.black, fontSize: 16),
        linkStyle: linkStyle?.copyWith(
              decoration: linkStyleConfig?.showUnderline ?? false
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: linkStyle.color ?? Colors.blue,
            ) ??
            TextStyle(
              color: Colors.blue,
              fontSize: textStyle?.fontSize,
              decoration: TextDecoration.underline,
              decorationColor: linkStyle?.color ?? Colors.blue,
            ),
        textAlign: TextAlign.start,
        strutStyle: StrutStyle(
          height: textStyleConfig!.lineSpacing!,
          forceStrutHeight: true,
        ),
      );
    }

    return Linkify(
      onOpen: _onOpen,
      text: messageText,
      options: const LinkifyOptions(humanize: false),
      style: textStyle ?? const TextStyle(color: Colors.black, fontSize: 16),
      linkStyle: linkStyle?.copyWith(
              decoration: linkStyleConfig?.showUnderline ?? false
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: linkStyle.color ?? Colors.blue) ??
          TextStyle(
              color: Colors.blue,
              fontSize: textStyle?.fontSize,
              decoration: TextDecoration.underline,
              decorationColor: linkStyle?.color ?? Colors.blue),
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
