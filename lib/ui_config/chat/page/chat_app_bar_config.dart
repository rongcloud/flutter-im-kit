import 'package:flutter/material.dart';
// import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

// 聊天界面AppBar相关字体大小常量
const double kChatLeadingFontSize = 16.0;
const double kChatTitleFontSize = 18.0;
const double kChatActionFontSize = 16.0;
const double kChatAppBarHeight = 56.0;

/// 聊天页面AppBar配置类
class RCKChatAppBarConfig {
  /// AppBar 高度
  final double height;

  /// 内边距
  final EdgeInsets padding;

  /// 是否居中标题
  final bool centerTitle;

  /// 是否自动添加返回按钮
  final bool automaticallyImplyLeading;

  /// 背景配置
  final RCKBackgroundConfig backgroundConfig;

  /// 左侧区域配置
  final RCKLeadingConfig leadingConfig;

  /// 标题配置
  final RCKChatTitleConfig titleConfig;

  /// 右侧操作按钮配置
  final RCKActionsConfig actionsConfig;

  const RCKChatAppBarConfig({
    this.height = kChatAppBarHeight,
    this.padding = EdgeInsets.zero,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.backgroundConfig = const RCKBackgroundConfig(),
    this.leadingConfig = const RCKLeadingConfig(),
    this.titleConfig = const RCKChatTitleConfig(),
    this.actionsConfig = const RCKActionsConfig(),
  });
}

/// 背景配置
class RCKBackgroundConfig {
  /// 背景颜色
  final Color? color;

  /// 背景图片
  final DecorationImage? image;

  /// 背景渐变
  final Gradient? gradient;

  /// 边框
  final BoxBorder? border;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  const RCKBackgroundConfig({
    this.color,
    this.image,
    this.gradient,
    this.border,
    this.borderRadius,
    this.boxShadow,
  });
}

/// 左侧区域配置
class RCKLeadingConfig {
  /// 图标
  final Widget? icon;

  /// 文本
  final String? text;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标与文本间距
  final double spacing;

  /// 内边距
  final EdgeInsets padding;

  const RCKLeadingConfig({
    this.icon,
    this.text,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    this.spacing = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });
}

/// 标题配置
class RCKChatTitleConfig {
  /// 标题文本
  final String? text;

  /// 文本样式
  final TextStyle textStyle;

  /// 前缀图标
  final Widget? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 图标与文本间距
  final double spacing;

  /// 对齐方式
  final MainAxisAlignment alignment;

  /// 内边距
  final EdgeInsets padding;

  const RCKChatTitleConfig({
    this.text,
    this.textStyle = const TextStyle(
      fontSize: kChatTitleFontSize,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.prefixIcon,
    this.suffixIcon,
    this.spacing = 4.0,
    this.alignment = MainAxisAlignment.center,
    this.padding = EdgeInsets.zero,
  });
}

/// 右侧操作按钮配置
class RCKActionsConfig {
  /// 操作按钮列表
  final List<RCKActionItem> items;

  /// 按钮间距
  final double spacing;

  /// 内边距
  final EdgeInsets padding;

  const RCKActionsConfig({
    this.items = const [],
    this.spacing = 8.0,
    this.padding = const EdgeInsets.only(right: 16.0),
  });
}

/// 操作按钮项配置
class RCKActionItem {
  /// 图标
  final Widget icon;

  /// 文本
  final String? text;

  /// 文本样式
  final TextStyle? textStyle;

  /// 图标与文本间距
  final double spacing;

  /// 内边距
  final EdgeInsets padding;

  RCKActionItem({
    required this.icon,
    this.text,
    TextStyle? textStyle,
    this.spacing = 4.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
  }) : textStyle = textStyle ??
            const TextStyle(
              fontSize: kChatActionFontSize,
              color: Colors.black,
            );
}
