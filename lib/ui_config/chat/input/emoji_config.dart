import 'package:flutter/material.dart';

import '../../../rongcloud_im_kit.dart';

/// 表情面板配置
class RCKEmojiConfig {
  /// 背景颜色
  final Color? backgroundColor;

  /// 面板高度
  final double height;

  /// 行数
  final int rowCount;

  /// 列数
  final int columnCount;

  /// 表情大小
  final double emojiSize;

  /// 行间距
  final double rowSpacing;

  /// 列间距
  final double columnSpacing;

  /// 内边距
  final EdgeInsets padding;

  /// 页面指示器配置
  final RCKEmojiPageIndicatorConfig pageIndicatorConfig;

  /// 删除按钮图标
  final Widget deleteIcon;

  /// 发送按钮配置
  final RCKEmojiSendButtonConfig sendButtonConfig;

  /// 自定义表情列表
  final List<String>? customEmojis;

  const RCKEmojiConfig({
    this.backgroundColor,
    this.height = kInputExtentionHeight,
    this.rowCount = 3,
    this.columnCount = 8,
    this.emojiSize = 24.0,
    this.rowSpacing = 10.0,
    this.columnSpacing = 5.0,
    this.padding = const EdgeInsets.all(15.0),
    this.pageIndicatorConfig = const RCKEmojiPageIndicatorConfig(),
    this.deleteIcon =
        const Icon(Icons.backspace, color: Color(0xFF666666), size: 24),
    this.sendButtonConfig = const RCKEmojiSendButtonConfig(),
    this.customEmojis,
  });

  RCKEmojiConfig copyWith({
    Color? backgroundColor,
    double? height,
    int? rowCount,
    int? columnCount,
    double? emojiSize,
    double? rowSpacing,
    double? columnSpacing,
    EdgeInsets? padding,
    RCKEmojiPageIndicatorConfig? pageIndicatorConfig,
    Widget? deleteIcon,
    RCKEmojiSendButtonConfig? sendButtonConfig,
    List<String>? customEmojis,
  }) {
    return RCKEmojiConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      rowCount: rowCount ?? this.rowCount,
      columnCount: columnCount ?? this.columnCount,
      emojiSize: emojiSize ?? this.emojiSize,
      rowSpacing: rowSpacing ?? this.rowSpacing,
      columnSpacing: columnSpacing ?? this.columnSpacing,
      padding: padding ?? this.padding,
      pageIndicatorConfig: pageIndicatorConfig ?? this.pageIndicatorConfig,
      deleteIcon: deleteIcon ?? this.deleteIcon,
      sendButtonConfig: sendButtonConfig ?? this.sendButtonConfig,
      customEmojis: customEmojis ?? this.customEmojis,
    );
  }
}

/// 表情页面指示器配置
class RCKEmojiPageIndicatorConfig {
  /// 激活状态的颜色
  final Color? activeColor;

  /// 非激活状态的颜色
  final Color? inactiveColor;

  /// 指示器大小
  final double size;

  /// 指示器间距
  final double spacing;

  /// 与底部的距离
  final double bottomPadding;

  const RCKEmojiPageIndicatorConfig({
    this.activeColor,
    this.inactiveColor,
    this.size = 8.0,
    this.spacing = 4.0,
    this.bottomPadding = 10.0,
  });

  RCKEmojiPageIndicatorConfig copyWith({
    Color? activeColor,
    Color? inactiveColor,
    double? size,
    double? spacing,
    double? bottomPadding,
  }) {
    return RCKEmojiPageIndicatorConfig(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      size: size ?? this.size,
      spacing: spacing ?? this.spacing,
      bottomPadding: bottomPadding ?? this.bottomPadding,
    );
  }
}

/// 表情面板发送按钮配置
class RCKEmojiSendButtonConfig {
  /// 按钮文本
  final String text;

  /// 按钮宽度
  final double width;

  /// 按钮高度
  final double height;

  /// 按钮背景色
  final Color backgroundColor;

  /// 文本样式
  final TextStyle textStyle;

  /// 按钮圆角
  final double borderRadius;

  /// 按钮位置
  final EmojiSendButtonPosition position;

  /// 按钮边距
  final EdgeInsets margin;

  const RCKEmojiSendButtonConfig({
    this.text = '发送',
    this.width = 60.0,
    this.height = 35.0,
    this.backgroundColor = Colors.blue,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    this.borderRadius = 8.0,
    this.position = EmojiSendButtonPosition.bottomRight,
    this.margin = const EdgeInsets.only(right: 15.0, bottom: 0.0),
  });

  RCKEmojiSendButtonConfig copyWith({
    String? text,
    double? width,
    double? height,
    Color? backgroundColor,
    TextStyle? textStyle,
    double? borderRadius,
    EmojiSendButtonPosition? position,
    EdgeInsets? margin,
  }) {
    return RCKEmojiSendButtonConfig(
      text: text ?? this.text,
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      position: position ?? this.position,
      margin: margin ?? this.margin,
    );
  }
}

/// 表情面板发送按钮位置
enum EmojiSendButtonPosition {
  bottomRight,
  bottomLeft,
  topRight,
  topLeft,
}
