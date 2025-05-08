import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// 文本样式配置
class RCKTextStyleConfig {
  /// 发送方文本字体样式
  final TextStyle? senderTextStyle;

  /// 接收方文本字体样式
  final TextStyle? receiverTextStyle;

  /// 文本行间距
  final double? lineSpacing;

  /// 构造函数
  RCKTextStyleConfig({
    TextStyle? senderTextStyle,
    TextStyle? receiverTextStyle,
    this.lineSpacing,
  })  : senderTextStyle = senderTextStyle ??
            TextStyle(
                color: RCKThemeProvider().themeColor.textInverse,
                fontSize: kBubbleTextFontSize),
        receiverTextStyle = receiverTextStyle ??
            TextStyle(
                color: RCKThemeProvider().themeColor.textPrimary,
                fontSize: kBubbleTextFontSize);

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKTextStyleConfig copyWith({
    TextStyle? senderTextStyle,
    TextStyle? receiverTextStyle,
    double? lineSpacing,
  }) {
    return RCKTextStyleConfig(
      senderTextStyle: senderTextStyle ?? this.senderTextStyle,
      receiverTextStyle: receiverTextStyle ?? this.receiverTextStyle,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }
}

/// 链接样式配置
class RCKLinkStyleConfig {
  /// 发送方文本字体样式
  final TextStyle? senderTextStyle;

  /// 接收方文本字体样式
  final TextStyle? receiverTextStyle;

  /// 是否显示下划线
  final bool showUnderline;

  /// 构造函数
  RCKLinkStyleConfig({
    TextStyle? senderTextStyle,
    TextStyle? receiverTextStyle,
    this.showUnderline = true,
  })  : senderTextStyle = senderTextStyle ??
            TextStyle(
                color: RCKThemeProvider().themeColor.textInverse,
                fontSize: kBubbleTextFontSize),
        receiverTextStyle = receiverTextStyle ??
            TextStyle(
                color: RCKThemeProvider().themeColor.textPrimary,
                fontSize: kBubbleTextFontSize);

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKLinkStyleConfig copyWith({
    TextStyle? senderTextStyle,
    TextStyle? receiverTextStyle,
    bool? showUnderline,
  }) {
    return RCKLinkStyleConfig(
      senderTextStyle: senderTextStyle ?? this.senderTextStyle,
      receiverTextStyle: receiverTextStyle ?? this.receiverTextStyle,
      showUnderline: showUnderline ?? this.showUnderline,
    );
  }
}

/// 图片样式配置
class RCKImageStyleConfig {
  /// 图片适应方式
  final BoxFit fit;

  /// 最大宽度
  final double? maxWidth;

  /// 最大高度
  final double? maxHeight;

  /// 缩放比例
  final double scale;

  /// 圆角半径
  final double borderRadius;

  /// 构造函数
  const RCKImageStyleConfig({
    this.fit = BoxFit.contain,
    this.maxWidth = 200,
    this.maxHeight = 200,
    this.scale = 1.0,
    this.borderRadius = 6.0,
  });

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKImageStyleConfig copyWith({
    BoxFit? fit,
    double? maxWidth,
    double? maxHeight,
    double? scale,
    double? borderRadius,
  }) {
    return RCKImageStyleConfig(
      fit: fit ?? this.fit,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      scale: scale ?? this.scale,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

/// 语音消息样式配置
class RCKVoiceStyleConfig {
  /// 播放图标尺寸
  final double iconSize;

  /// 播放中图标颜色
  final Color? playingColor;

  /// 未播放图标颜色
  final Color? notPlayingColor;

  /// 自定义已播放图标路径
  final String? customPlayingIconPath;

  /// 自定义未播放图标路径
  final String? customNotPlayingIconPath;

  /// 时长文本样式
  final TextStyle? durationTextStyle;

  /// 构造函数
  const RCKVoiceStyleConfig({
    this.iconSize = kBubbleVoiceIconSize,
    this.playingColor,
    this.notPlayingColor,
    this.customPlayingIconPath,
    this.customNotPlayingIconPath,
    this.durationTextStyle,
  });

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKVoiceStyleConfig copyWith({
    double? iconSize,
    Color? playingColor,
    Color? notPlayingColor,
    String? customPlayingIconPath,
    String? customNotPlayingIconPath,
    TextStyle? durationTextStyle,
  }) {
    return RCKVoiceStyleConfig(
      iconSize: iconSize ?? this.iconSize,
      playingColor: playingColor ?? this.playingColor,
      notPlayingColor: notPlayingColor ?? this.notPlayingColor,
      customPlayingIconPath:
          customPlayingIconPath ?? this.customPlayingIconPath,
      customNotPlayingIconPath:
          customNotPlayingIconPath ?? this.customNotPlayingIconPath,
      durationTextStyle: durationTextStyle ?? this.durationTextStyle,
    );
  }
}

/// 文件消息样式配置
class RCKFileStyleConfig {
  /// 文件图标尺寸
  final double iconSize;

  /// 文件名样式
  final TextStyle fileNameStyle;

  /// 文件大小样式
  final TextStyle fileSizeStyle;

  /// 自定义文件图标路径
  final String? customFileIconPath;

  /// 容器宽度
  final double containerWidth;

  /// 容器高度
  final double containerHeight;

  /// 构造函数
  RCKFileStyleConfig({
    this.iconSize = kBubbleFileIconSize,
    TextStyle? fileNameStyle,
    TextStyle? fileSizeStyle,
    this.customFileIconPath,
    this.containerWidth = kBubbleFileWidth,
    this.containerHeight = kBubbleFileHeight,
  })  : fileNameStyle = fileNameStyle ??
            TextStyle(
                fontSize: kBubbleFileNameFontSize,
                color: RCKThemeProvider().themeColor.textPrimary),
        fileSizeStyle = fileSizeStyle ??
            TextStyle(
                fontSize: kBubbleFileSizeFontSize,
                color: RCKThemeProvider().themeColor.textAuxiliary);

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKFileStyleConfig copyWith({
    double? iconSize,
    TextStyle? fileNameStyle,
    TextStyle? fileSizeStyle,
    String? customFileIconPath,
    double? containerWidth,
    double? containerHeight,
  }) {
    return RCKFileStyleConfig(
      iconSize: iconSize ?? this.iconSize,
      fileNameStyle: fileNameStyle ?? this.fileNameStyle,
      fileSizeStyle: fileSizeStyle ?? this.fileSizeStyle,
      customFileIconPath: customFileIconPath ?? this.customFileIconPath,
      containerWidth: containerWidth ?? this.containerWidth,
      containerHeight: containerHeight ?? this.containerHeight,
    );
  }
}

/// 视频消息样式配置
class RCKSightStyleConfig {
  /// 缩略图最大宽度
  final double? maxWidth;

  /// 缩略图最大高度
  final double? maxHeight;

  /// 播放按钮大小
  final double playButtonSize;

  /// 播放按钮颜色
  final Color? playButtonColor;

  /// 自定义播放按钮图标路径
  final String? customPlayButtonIconPath;

  /// 构造函数
  const RCKSightStyleConfig({
    this.maxWidth,
    this.maxHeight,
    this.playButtonSize = kBubbleSightIconSize,
    this.playButtonColor,
    this.customPlayButtonIconPath,
  });

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKSightStyleConfig copyWith({
    double? maxWidth,
    double? maxHeight,
    double? playButtonSize,
    Color? playButtonColor,
    String? customPlayButtonIconPath,
  }) {
    return RCKSightStyleConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      playButtonSize: playButtonSize ?? this.playButtonSize,
      playButtonColor: playButtonColor ?? this.playButtonColor,
      customPlayButtonIconPath:
          customPlayButtonIconPath ?? this.customPlayButtonIconPath,
    );
  }
}

/// 引用消息样式配置
class RCKReferenceStyleConfig {
  /// 引用内容背景色
  final Color? backgroundColor;

  /// 引用内容文本样式
  final TextStyle? textStyle;

  /// 引用内容边距
  final EdgeInsets padding;

  /// 引用内容与主内容的间距
  final double spacingToContent;

  /// 构造函数
  const RCKReferenceStyleConfig({
    this.backgroundColor,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.spacingToContent = kBubbleRefTextPadding,
  });

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKReferenceStyleConfig copyWith({
    Color? backgroundColor,
    TextStyle? textStyle,
    EdgeInsets? padding,
    double? spacingToContent,
  }) {
    return RCKReferenceStyleConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      spacingToContent: spacingToContent ?? this.spacingToContent,
    );
  }
}
