import 'package:flutter/material.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

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

/// 侧滑方向
enum SwipeDirection { left, right }
