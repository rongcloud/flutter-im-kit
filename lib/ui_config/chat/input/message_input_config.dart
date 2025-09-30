import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// 输入框旁边的功能按钮配置
class RCKInputButtonConfig {
  /// 按钮图标
  final Widget? icon;

  /// 激活状态下的按钮图标
  final Widget? activeIcon;

  /// 按钮尺寸
  final double size;

  /// 按钮之间的距离
  final double spacing;

  /// 按钮颜色
  final Color? color;

  /// 激活状态下按钮颜色
  final Color? activeColor;

  /// 按钮是否可见
  final bool visible;

  const RCKInputButtonConfig({
    this.icon,
    this.activeIcon,
    this.size = kInputFieldIconSize,
    this.spacing = kInputFieldButtonSpace,
    this.color,
    this.activeColor,
    this.visible = true,
  });

  RCKInputButtonConfig copyWith({
    Widget? icon,
    Widget? activeIcon,
    double? size,
    double? spacing,
    Color? color,
    Color? activeColor,
    bool? visible,
  }) {
    return RCKInputButtonConfig(
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      size: size ?? this.size,
      spacing: spacing ?? this.spacing,
      color: color ?? this.color,
      activeColor: activeColor ?? this.activeColor,
      visible: visible ?? this.visible,
    );
  }
}

/// 消息输入组件的主要配置类
class RCKMessageInputConfig {
  /// 输入框配置
  final RCKInputFieldConfig inputFieldConfig;

  /// 左侧按钮配置（默认是语音/键盘切换按钮）
  final RCKInputButtonConfig leftButtonConfig;

  /// 右侧按钮配置列表（默认是表情和更多按钮）
  final List<RCKInputButtonConfig> rightButtonsConfig;

  /// 顶部按钮配置列表（可选）
  final List<RCKInputButtonConfig> topButtonsConfig;

  /// 底部按钮配置列表（可选）
  final List<RCKInputButtonConfig> bottomButtonsConfig;

  /// 表情面板配置
  final RCKEmojiConfig emojiConfig;

  /// 语音录制配置
  final RCKVoiceRecordConfig voiceRecordConfig;

  /// 整个输入区域的内边距
  final EdgeInsets padding;

  /// 输入框与按钮之间的间距
  final double spacing;

  /// 输入组件的背景色
  final Color? backgroundColor;

  /// 顶部分隔线颜色
  final Color? dividerColor;

  /// 引用消息预览区域的配置
  final RCKQuotePreviewConfig quotePreviewConfig;

  /// 扩展菜单配置
  final RCKExtensionMenuConfig? extensionMenuConfig;

  RCKMessageInputConfig({
    RCKInputFieldConfig? inputFieldConfig,
    this.leftButtonConfig = const RCKInputButtonConfig(),
    this.rightButtonsConfig = const <RCKInputButtonConfig>[],
    this.topButtonsConfig = const <RCKInputButtonConfig>[],
    this.bottomButtonsConfig = const <RCKInputButtonConfig>[],
    this.emojiConfig = const RCKEmojiConfig(),
    this.voiceRecordConfig = const RCKVoiceRecordConfig(),
    this.padding = const EdgeInsets.symmetric(vertical: 6.0),
    this.spacing = 10.0,
    Color? backgroundColor,
    this.dividerColor,
    this.quotePreviewConfig = const RCKQuotePreviewConfig(),
    this.extensionMenuConfig,
  })  : backgroundColor = backgroundColor ??
            (RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
                ? RCKThemeProvider().themeColor.bgAuxiliary1
                : const Color(0xFF1D1D1D)),
        inputFieldConfig = inputFieldConfig ?? RCKInputFieldConfig();

  /// 创建一个新的配置实例并合并更改
  RCKMessageInputConfig copyWith({
    RCKInputFieldConfig? inputFieldConfig,
    RCKInputButtonConfig? leftButtonConfig,
    List<RCKInputButtonConfig>? rightButtonsConfig,
    List<RCKInputButtonConfig>? topButtonsConfig,
    List<RCKInputButtonConfig>? bottomButtonsConfig,
    RCKEmojiConfig? emojiConfig,
    RCKVoiceRecordConfig? voiceRecordConfig,
    EdgeInsets? padding,
    double? spacing,
    Color? backgroundColor,
    Color? dividerColor,
    RCKQuotePreviewConfig? quotePreviewConfig,
    RCKExtensionMenuConfig? extensionMenuConfig,
  }) {
    return RCKMessageInputConfig(
      inputFieldConfig: inputFieldConfig ?? this.inputFieldConfig,
      leftButtonConfig: leftButtonConfig ?? this.leftButtonConfig,
      rightButtonsConfig: rightButtonsConfig ?? this.rightButtonsConfig,
      topButtonsConfig: topButtonsConfig ?? this.topButtonsConfig,
      bottomButtonsConfig: bottomButtonsConfig ?? this.bottomButtonsConfig,
      emojiConfig: emojiConfig ?? this.emojiConfig,
      voiceRecordConfig: voiceRecordConfig ?? this.voiceRecordConfig,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      quotePreviewConfig: quotePreviewConfig ?? this.quotePreviewConfig,
      extensionMenuConfig: extensionMenuConfig ?? this.extensionMenuConfig,
    );
  }
}

/// 引用消息预览区域配置
class RCKQuotePreviewConfig {
  /// 背景色
  final Color? backgroundColor;

  /// 内边距
  final EdgeInsets? padding;

  /// 文本样式
  final TextStyle? textStyle;

  /// 关闭按钮图标
  final Icon? closeIcon;

  const RCKQuotePreviewConfig({
    this.backgroundColor,
    this.padding,
    this.textStyle,
    this.closeIcon,
  });

  RCKQuotePreviewConfig copyWith({
    Color? backgroundColor,
    EdgeInsets? padding,
    TextStyle? textStyle,
    Icon? closeIcon,
  }) {
    return RCKQuotePreviewConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      closeIcon: closeIcon ?? this.closeIcon,
    );
  }
}
