import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// AppBar 配置类
class RCKConvoAppBarConfig {
  /// AppBar 高度
  final double height;

  /// 内边距
  final EdgeInsets padding;

  /// 是否居中标题
  final bool centerTitle;

  /// 是否自动添加返回按钮
  final bool automaticallyImplyLeading;

  /// 背景配置
  final BackgroundConfig backgroundConfig;

  /// 左侧区域配置
  final LeadingConfig leadingConfig;

  /// 标题区域配置
  final AppbarTitleConfig titleConfig;

  /// 右侧操作区域配置
  final ActionsConfig actionsConfig;

  RCKConvoAppBarConfig({
    this.height = appbarHeight,
    this.padding = EdgeInsets.zero,
    // 将标题默认居中
    this.centerTitle = false,
    this.automaticallyImplyLeading = false,
    this.backgroundConfig = const BackgroundConfig(),
    this.leadingConfig = const LeadingConfig(),
    AppbarTitleConfig? titleConfig,
    this.actionsConfig = const ActionsConfig(),
  }) : titleConfig = titleConfig ?? AppbarTitleConfig();
}

/// 背景配置
class BackgroundConfig {
  /// 背景颜色
  final Color? color;

  /// 背景图片
  final DecorationImage? image;

  /// 背景渐变色
  final Gradient? gradient;

  /// 边框
  final BoxBorder? border;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  const BackgroundConfig({
    this.color,
    this.image,
    this.gradient,
    this.border,
    this.borderRadius,
    this.boxShadow,
  });
}

/// 左侧区域配置
class LeadingConfig {
  /// 图标
  final Widget? icon;

  /// 文本
  final String? text;

  /// 文本样式
  final TextStyle textStyle;

  /// 文本截断方式
  final TextOverflow textOverflow;

  /// 元素间距
  final double spacing;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 内边距
  final EdgeInsets padding;

  /// 最大宽度
  final double maxWidth;

  const LeadingConfig({
    this.icon,
    this.text,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    this.textOverflow = TextOverflow.ellipsis,
    this.spacing = 4.0,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.maxWidth = 120.0,
  });
}

/// 标题区域配置
class AppbarTitleConfig {
  /// 标题文本
  final String text;

  /// 标题样式
  final TextStyle? textStyle;

  /// 文本截断方式
  final TextOverflow textOverflow;

  /// 前缀图标
  final Widget? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 元素间距
  final double spacing;

  /// 内边距
  final EdgeInsets padding;

  /// 最大宽度
  final double maxWidth;

  /// 对齐方式
  final MainAxisAlignment alignment;

  AppbarTitleConfig({
    this.text = 'Chats',
    TextStyle? textStyle,
    this.textOverflow = TextOverflow.ellipsis,
    this.prefixIcon,
    this.suffixIcon,
    this.spacing = 0.0,
    this.padding =
        const EdgeInsets.only(left: 26 - NavigationToolbar.kMiddleSpacing),
    this.maxWidth = double.infinity,
    this.alignment = MainAxisAlignment.center,
  }) : textStyle = textStyle ??
            TextStyle(
              fontSize: appbarFontSize,
              fontWeight: appbarFontWeight,
              color: RCKThemeProvider().themeColor.textPrimary,
            );
}

/// 操作区域配置
class ActionsConfig {
  /// 操作项列表
  final List<ActionItem> items;

  /// 操作项间距
  final double spacing;

  /// 内边距
  final EdgeInsets padding;

  /// 最大宽度
  final double maxWidth;

  /// 对齐方式
  final MainAxisAlignment alignment;

  const ActionsConfig({
    this.items = const [],
    this.spacing = 8.0,
    this.padding = const EdgeInsets.only(right: 16.0),
    this.maxWidth = 200.0,
    this.alignment = MainAxisAlignment.end,
  });
}

/// 操作项
class ActionItem {
  /// 图标
  final Widget icon;

  /// 文本
  final String? text;

  /// 文本样式
  final TextStyle textStyle;

  /// 文本截断方式
  final TextOverflow textOverflow;

  /// 元素间距
  final double spacing;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 内边距
  final EdgeInsets padding;

  const ActionItem({
    required this.icon,
    this.text,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    this.textOverflow = TextOverflow.ellipsis,
    this.spacing = 4.0,
    this.onPressed,
    this.padding = EdgeInsets.zero,
  });
}
