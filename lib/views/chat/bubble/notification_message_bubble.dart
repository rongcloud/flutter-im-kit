import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';

class RCKUnknownMessageBubble extends RCKMessageBubble {
  RCKUnknownMessageBubble({
    super.key,
    required super.message,
    super.showTime = false,
    super.alignment = Alignment.center,
    super.withoutBubble = true,
    super.config,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onSwipe,
  });

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text("当前版本暂不支持查看此消息"),
    );
  }
}
