import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

typedef AvatarBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKAvatarConfig config);

class AvatarWidget extends StatelessWidget {
  final RCIMIWConversation conversation;
  final RCKAvatarConfig config;
  final RCKChatProfileInfo? customInfo;

  const AvatarWidget({
    super.key,
    required this.conversation,
    this.config = const RCKAvatarConfig(),
    this.customInfo,
  });

  @override
  Widget build(BuildContext context) {
    // 默认头像图片
    Widget defaultAvatar =
        ImageUtil.getImageWidget('avatar_default_single.png');

    // 根据会话类型选择头像
    Widget avatarImage;

    if (conversation.conversationType == RCIMIWConversationType.private) {
      // 单聊默认头像
      avatarImage = ImageUtil.getImageWidget('avatar_default_single.png');
    } else if (conversation.conversationType == RCIMIWConversationType.group) {
      // 群聊默认头像
      avatarImage = ImageUtil.getImageWidget('avatar_default_group.png');
    } else if (conversation.conversationType == RCIMIWConversationType.system) {
      // 系统消息默认头像
      avatarImage = ImageUtil.getImageWidget('avatar_default_system.png');
    } else {
      // 其他类型使用通用默认头像
      avatarImage = defaultAvatar;
    }

    if (customInfo != null && customInfo!.avatar.isNotEmpty) {
      avatarImage = ImageUtil.getImageWidget(customInfo!.avatar);
    }

    // 应用配置的样式
    return Container(
      width: config.effectiveSize,
      height: config.effectiveSize,
      decoration: BoxDecoration(
        shape: config.shape == AvatarShape.rectangle
            ? BoxShape.rectangle
            : BoxShape.circle,
        borderRadius: config.shape == AvatarShape.roundedRect
            ? BorderRadius.circular(config.borderRadius)
            : null,
        color: config.backgroundColor,
        border: config.borderColor != null && config.borderWidth != null
            ? Border.all(color: config.borderColor!, width: config.borderWidth!)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarImage,
    );
  }
}
