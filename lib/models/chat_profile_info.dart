import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

class RCKChatProfileInfo {
  final String id; // 用户或群组ID
  final String name; // 名称
  final String avatar; // 头像URL
  final bool isGroup; // 是否为群组
  final String extraInfo; // 额外信息

  // 构造函数
  RCKChatProfileInfo({
    required this.id,
    required this.name,
    required this.avatar,
    this.isGroup = false,
    this.extraInfo = '',
  });
}

typedef CustomInfoProvider = Future<RCKChatProfileInfo> Function(
    {RCIMIWMessage? message, RCIMIWConversation? conversation});
