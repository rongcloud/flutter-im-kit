import 'package:flutter/material.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:rongcloud_im_kit/ui_config/chat/bubble/bubble_config.dart';
import 'package:rongcloud_im_kit/views/chat/bubble/message_bubble.dart';

/// 消息点击回调
typedef MessageTapCallback = void Function(
    RCIMIWMessage message, BuildContext context);

/// 消息双击回调
typedef MessageDoubleTapCallback = void Function(
    RCIMIWMessage message, BuildContext context);

/// 消息长按回调
/// 返回true表示使用自定义处理，false表示使用默认处理
typedef MessageLongPressCallback = bool Function(
    RCIMIWMessage message, BuildContext context);

/// 消息侧滑回调
typedef MessageSwipeCallback = void Function(
    RCIMIWMessage message, BuildContext context, SwipeDirection direction);

typedef CustomChatItemBubbleBuilder = RCKMessageBubble Function(
    {required RCIMIWMessage message,
    bool? showTime,
    RCKBubbleConfig? config,
    required BuildContext context});

/// 侧滑方向
enum SwipeDirection { left, right }
