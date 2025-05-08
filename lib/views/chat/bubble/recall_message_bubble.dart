import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

class RCKRecallMessageBubble extends RCKMessageBubble {
  RCKRecallMessageBubble(
      {super.key,
      required super.message,
      super.showTime,
      super.alignment,
      super.withoutBubble,
      super.config});

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    String operationString = "";
    operationString = "$refName 撤回了一条消息";

    return Text(
      operationString,
      style: TextStyle(
        color: RCKThemeProvider().themeColor.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
