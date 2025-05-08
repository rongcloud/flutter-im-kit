import 'package:flutter/material.dart';

import '../../../rongcloud_im_kit.dart';

/// 扩展菜单项配置
class RCKExtensionMenuItemConfig {
  /// 菜单项标题
  final String title;

  /// 菜单项图标
  final Widget icon;

  /// 点击回调
  final VoidCallback? onTap;

  /// 图标大小
  final double iconSize;

  /// 标题样式
  final TextStyle? titleStyle;

  RCKExtensionMenuItemConfig({
    required this.title,
    required this.icon,
    this.onTap,
    this.iconSize = kInputExtentionIconSize,
    this.titleStyle,
  });
}

/// 扩展菜单配置
class RCKExtensionMenuConfig {
  /// 菜单项列表
  final List<RCKExtensionMenuItemConfig> items;

  /// 每页展示的项目数量
  final int itemsPerPage;

  /// 每行显示的项目数量
  final int crossAxisCount;

  /// 菜单背景颜色
  final Color? backgroundColor;

  /// 行间距
  final double mainAxisSpacing;

  /// 列间距
  final double crossAxisSpacing;

  /// 内边距
  final EdgeInsets padding;

  /// 页面指示器选中颜色
  final Color indicatorSelectedColor;

  /// 页面指示器未选中颜色
  final Color indicatorUnselectedColor;

  /// 菜单高度
  final double height;

  const RCKExtensionMenuConfig({
    this.items = const [],
    this.itemsPerPage = 8,
    this.crossAxisCount = 4,
    this.backgroundColor,
    this.mainAxisSpacing = kInputExtentionItemSpaceV,
    this.crossAxisSpacing = kInputExtentionItemSpaceH,
    this.padding = const EdgeInsets.only(
        top: kInputExtentionPanelPaddingTop,
        left: kInputExtentionPanelPaddingH,
        right: kInputExtentionPanelPaddingH,
        bottom: kInputExtentionPanelPaddingBottom),
    this.indicatorSelectedColor = const Color(0xFF999999),
    this.indicatorUnselectedColor = const Color(0xFFD8D8D8),
    this.height = kInputExtentionHeight,
  });
}
