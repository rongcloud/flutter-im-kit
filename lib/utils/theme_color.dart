import 'package:flutter/material.dart';

class RCKThemeColor {
  // 主色
  final Color? primary;
  // 头像背景色
  final Color? avatarPurple;
  final Color? avatarCyan;
  final Color? avatarGreen;
  final Color? avatarBlue;
  final Color? avatarBrickRed;
  final Color? avatarYellow;

  // 文字色
  final Color? textPrimary;
  final Color? textInverse;
  final Color? textSecondary;
  final Color? textAuxiliary;

  // 背景色
  final Color? bgRegular;
  final Color? bgAuxiliary1;
  final Color? bgAuxiliary2;
  final Color? bgTop;
  final Color? bgLongPress;
  final Color? bgCover;
  final Color? bgTip;
  final Color? bgQuoteExit;
  // 功能色
  final Color? success;
  final Color? notice;
  final Color? link;
  final Color? outline;

  const RCKThemeColor({
    this.primary,
    this.avatarPurple,
    this.avatarCyan,
    this.avatarGreen,
    this.avatarBlue,
    this.avatarBrickRed,
    this.avatarYellow,
    this.textPrimary,
    this.textInverse,
    this.textSecondary,
    this.textAuxiliary,
    this.bgRegular,
    this.bgAuxiliary1,
    this.bgAuxiliary2,
    this.bgTop,
    this.bgLongPress,
    this.bgCover,
    this.bgTip,
    this.bgQuoteExit,
    this.success,
    this.notice,
    this.link,
    this.outline,
  });

  static const RCKThemeColor light = RCKThemeColor(
    primary: Color(0xFF0166FE), // 主色（品牌色）
    avatarPurple: Color(0xFFD55252), // 头像背景色 - 紫色
    avatarCyan: Color(0xFF4AB6D7), // 头像背景色 - 青色
    avatarGreen: Color(0xFF59CA73), // 头像背景色 - 绿色
    avatarBlue: Color(0xFF4679FF), // 头像背景色 - 蓝色
    avatarBrickRed: Color(0xFFBF51D5), // 头像背景色 - 砖红色
    avatarYellow: Color(0xFFF1B03E), // 头像背景色 - 黄色
    textPrimary: Color(0xFF000000), // 文字色 - 主要
    textInverse: Color(0xFFFFFFFF), // 文字色 - 反白
    textSecondary: Color(0xFF838383), // 文字色 - 次要
    textAuxiliary: Color(0xFFC1C1C1), // 文字色 - 辅助&提示
    bgRegular: Color(0xFFF2F2F2), // 背景色 - 常规
    bgAuxiliary1: Color(0xFFFFFFFF), // 背景色 - 辅助1
    bgAuxiliary2: Color(0xFF4679FF), // 背景色 - 辅助2
    bgTop: Color(0xFFEFF1F7), // 背景色 - 置顶
    bgLongPress: Color(0xFFDBE0EF), // 背景色 - 长按 & 选中
    bgCover: Color(0x80000000), // 背景色 - 遮照 50%
    bgTip: Color(0xFFDEDEDE), // 背景色 - 引用消息预览
    bgQuoteExit: Color(0xFFC8C8C8), // 背景色 - 引用消息预览
    success: Color(0xFF51E174), // 功能色 - 成功
    notice: Color(0xFFE44C43), // 功能色 - 红色
    link: Color(0xFF4679FF), // 功能色 - 链接
    outline: Color(0xFFE4E4E4), // 功能色 - 描边
  );

  static const RCKThemeColor dark = RCKThemeColor(
    primary: Color(0xFF0047FF), // 品牌色 主色
    avatarPurple: Color(0xFFBF51D5), // 头像背景色 - 紫色
    avatarCyan: Color(0xFF4AB6D7), // 头像背景色 - 青色
    avatarGreen: Color(0xFF59CA73), // 头像背景色 - 绿色
    avatarBlue: Color(0xFF4679FF), // 头像背景色 - 蓝色
    avatarBrickRed: Color(0xFFD55252), // 头像背景色 - 砖红色
    avatarYellow: Color(0xFFF1B03E), // 头像背景色 - 黄色
    textPrimary: Color(0xFFFFFFFE), // 文字色 - 主要 (#FFFFFE)
    textInverse: Color(0xFF0D0D0D), // 文字色 - 反色 (#0D0D0D)
    textSecondary: Color(0xFFD0D0D0), // 文字色 - 次要 (#D0D0D0)
    textAuxiliary: Color(0xFFC1C1C1), // 文字色 - 辅助&提示
    bgRegular: Color(0xFF3D3D3D), // 背景色 - 常规 (#0D0D0D)
    bgAuxiliary1: Color(0xFF2B2B2B), // 背景色 - 辅助1
    bgAuxiliary2: Color(0xFF608DFF), // 背景色 - 辅助2
    bgTop: Color(0xFF1D1D1D), // 底部输入框背景 (#1D1D1D)
    bgLongPress: Color(0xFF2B2B2B), // 长按 & 选中（预设为辅助1颜色）
    bgCover: Color(0x80000000), // 遮照 (#000000 50%)
    bgTip: Color(0xFF4F4F4F), // 背景色 - 引用消息预览
    bgQuoteExit: Color(0xFFC8C8C8), // 背景色 - 引用消息预览
    success: Color(0xFF46E75B), // 功能色 - 成功
    notice: Color(0xFFFD4C4C), // 功能色 - 提示
    link: Color(0xFF608DFF), // 功能色 - 链接
    outline: Color(0xFFE4E4E4), // 功能色 - 描边（保持一致）
  );

  // copyWith 方法
  RCKThemeColor copyWith({
    Color? primary,
    Color? avatarPurple,
    Color? avatarCyan,
    Color? avatarGreen,
    Color? avatarBlue,
    Color? avatarBrickRed,
    Color? avatarYellow,
    Color? textPrimary,
    Color? textInverse,
    Color? textSecondary,
    Color? textAuxiliary,
    Color? bgRegular,
    Color? bgAuxiliary1,
    Color? bgAuxiliary2,
    Color? bgTop,
    Color? bgLongPress,
    Color? bgCover,
    Color? bgTip,
    Color? bgQuoteExit,
    Color? success,
    Color? notice,
    Color? link,
    Color? outline,
  }) {
    return RCKThemeColor(
      primary: primary ?? this.primary,
      avatarPurple: avatarPurple ?? this.avatarPurple,
      avatarCyan: avatarCyan ?? this.avatarCyan,
      avatarGreen: avatarGreen ?? this.avatarGreen,
      avatarBlue: avatarBlue ?? this.avatarBlue,
      avatarBrickRed: avatarBrickRed ?? this.avatarBrickRed,
      avatarYellow: avatarYellow ?? this.avatarYellow,
      textPrimary: textPrimary ?? this.textPrimary,
      textInverse: textInverse ?? this.textInverse,
      textSecondary: textSecondary ?? this.textSecondary,
      textAuxiliary: textAuxiliary ?? this.textAuxiliary,
      bgRegular: bgRegular ?? this.bgRegular,
      bgAuxiliary1: bgAuxiliary1 ?? this.bgAuxiliary1,
      bgAuxiliary2: bgAuxiliary2 ?? this.bgAuxiliary2,
      bgTop: bgTop ?? this.bgTop,
      bgLongPress: bgLongPress ?? this.bgLongPress,
      bgCover: bgCover ?? this.bgCover,
      bgTip: bgTip ?? this.bgTip,
      bgQuoteExit: bgQuoteExit ?? this.bgQuoteExit,
      success: success ?? this.success,
      notice: notice ?? this.notice,
      link: link ?? this.link,
      outline: outline ?? this.outline,
    );
  }
}
