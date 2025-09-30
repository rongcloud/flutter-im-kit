import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import '../../../utils/time_util.dart';

typedef TimeBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKTimeConfig config);

class TimeWidget extends StatelessWidget {
  final RCIMIWConversation conversation;
  final RCKTimeConfig config;

  TimeWidget({
    super.key,
    required this.conversation,
    RCKTimeConfig? config,
  }) : config = config ?? RCKTimeConfig();

  @override
  Widget build(BuildContext context) {
    // 获取消息时间戳
    int timestamp = conversation.lastMessage?.sentTime ?? 0;

    // 格式化时间
    String formattedTime = config.formatter != null
        ? config.formatter!(timestamp)
        : TimeUtil.conversationFormatTime(timestamp);

    return Text(
      formattedTime,
      style: TextStyle(
        fontSize: config.fontSize,
        color: config.color,
        fontWeight: config.fontWeight,
      ),
    );
  }
}
