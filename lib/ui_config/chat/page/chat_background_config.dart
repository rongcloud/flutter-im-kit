import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// 聊天页面背景配置
class RCKChatBackgroundConfig {
  /// 背景颜色，当没有设置背景图片时使用
  final Color? backgroundColor;

  /// 非安全区域背景颜色
  final Color? safeAreaColor;

  /// 背景图片（本地资源）
  final ImageProvider? backgroundImage;

  /// 背景图片网络URL
  final String? backgroundImageUrl;

  /// 图片适配方式
  final BoxFit imageFitMode;

  /// 是否重复平铺图片
  final ImageRepeat imageRepeat;

  RCKChatBackgroundConfig({
    Color? backgroundColor,
    Color? safeAreaColor,
    this.backgroundImage,
    this.backgroundImageUrl,
    this.imageFitMode = BoxFit.cover,
    this.imageRepeat = ImageRepeat.noRepeat,
  })  : backgroundColor =
            backgroundColor ?? RCKThemeProvider().themeColor.bgRegular,
        safeAreaColor = safeAreaColor ??
            (RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
                ? RCKThemeProvider().themeColor.bgAuxiliary1
                : const Color(0xFF1D1D1D));

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKChatBackgroundConfig copyWith({
    Color? backgroundColor,
    ImageProvider? backgroundImage,
    String? backgroundImageUrl,
    BoxFit? imageFitMode,
    ImageRepeat? imageRepeat,
  }) {
    return RCKChatBackgroundConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      imageFitMode: imageFitMode ?? this.imageFitMode,
      imageRepeat: imageRepeat ?? this.imageRepeat,
    );
  }
}
