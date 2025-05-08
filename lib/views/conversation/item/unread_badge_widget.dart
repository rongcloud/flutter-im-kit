import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

typedef UnreadBadgeBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKUnreadBadgeConfig config);

class UnreadBadgeWidget extends StatelessWidget {
  final RCIMIWConversation conversation;
  final RCKUnreadBadgeConfig config;

  UnreadBadgeWidget({
    super.key,
    required this.conversation,
    RCKUnreadBadgeConfig? config,
  }) : config = config ?? RCKUnreadBadgeConfig();

  @override
  Widget build(BuildContext context) {
    // 如果未读数为0，不显示
    int? unreadCount = conversation.unreadCount;
    if (unreadCount == null || unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    // 免打扰状态下只显示红点
    bool isBlockNotification =
        conversation.notificationLevel == RCIMIWPushNotificationLevel.blocked;

    // 正常显示未读数
    String badgeText =
        unreadCount > 99 ? config.overflowText : unreadCount.toString();

    final double width = unreadCount > 99
        ? config.width
        : unreadCount > 9
            ? config.width * 0.7
            : config.width / 2;

    return SizedBox(
        width: width,
        height: config.height,
        child: Center(
            child: Container(
          decoration: BoxDecoration(
            color: isBlockNotification
                ? config.muteBackgroundColor
                : config.backgroundColor,
            borderRadius: BorderRadius.circular(config.height / 2),
          ),
          alignment: Alignment.center,
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: config.fontSize,
              color: config.textColor,
              fontWeight: convoUnreadFontWeight,
            ),
            textAlign: TextAlign.center,
          ),
        )));
  }
}
