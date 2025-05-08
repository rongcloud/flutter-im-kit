import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

// 头像形状枚举
enum AvatarShape {
  circle, // 圆形
  rectangle, // 矩形
  roundedRect, // 圆角矩形
}

/// 头像配置
class RCKAvatarConfig {
  /// 头像形状
  final AvatarShape shape;

  /// 头像尺寸 (32-64dp之间)
  final double size;

  /// 圆角大小 (当形状为roundedRect时有效)
  final double borderRadius;

  /// 头像边框颜色
  final Color? borderColor;

  /// 头像边框宽度
  final double? borderWidth;

  /// 头像背景色
  final Color? backgroundColor;

  /// 头像右上角未读消息的位置偏移
  final Offset? badgeOffset;

  const RCKAvatarConfig({
    this.shape = AvatarShape.circle,
    this.size = avatarHeight,
    this.borderRadius = 8.0,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.badgeOffset = const Offset(5, 6),
  });

  /// 获取有效尺寸 (32-64范围内)
  double get effectiveSize => size.clamp(32.0, 64.0);
}

/// 昵称/标题配置
class RCKConvoTitleConfig {
  /// 字体大小
  final double fontSize;

  /// 字体颜色
  final Color? color;

  /// 字体粗细
  final FontWeight fontWeight;

  /// 文本最大行数
  final int maxLines;

  /// 是否显示在标题后附加内容
  final bool showSuffix;

  /// 标题后缀图标
  final IconData? suffixIcon;

  /// 标题后缀文本
  final String? suffixText;

  /// 标题后缀文本样式
  final TextStyle? suffixTextStyle;

  const RCKConvoTitleConfig({
    this.fontSize = convoTitleFontSize,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.maxLines = 1,
    this.showSuffix = false,
    this.suffixIcon,
    this.suffixText,
    this.suffixTextStyle,
  });
}

/// 最后一条消息配置
class RCKLastMessageConfig {
  /// 字体大小
  final double fontSize;

  /// 字体颜色
  final Color color;

  /// 字体粗细
  final FontWeight fontWeight;

  /// 最大行数
  final int maxLines;

  /// 自定义消息类型显示文本
  final Map<Type, String>? customTypeText;

  RCKLastMessageConfig({
    this.fontSize = convoLastFontSize,
    Color? color,
    this.fontWeight = FontWeight.normal,
    this.maxLines = 1,
    this.customTypeText,
  }) : color = color ??
            RCKThemeProvider().themeColor.textSecondary ??
            const Color(0xFF999999);

  /// 获取消息类型对应的显示文本
  String getTypeText(Type messageType) {
    if (customTypeText != null && customTypeText!.containsKey(messageType)) {
      return customTypeText![messageType]!;
    }

    // 默认消息类型文本映射
    const defaultTypeText = {
      'RCIMIWImageMessage': '[图片]',
      'RCIMIWVoiceMessage': '[语音]',
      'RCIMIWLocationMessage': '[位置]',
      'RCIMIWFileMessage': '[文件]',
      'RCIMIWSightMessage': '[视频]',
      'RCIMIWGIFMessage': '[表情]',
      'RCIMIWRecallNotificationMessage': '[撤回消息]',
    };

    final typeName = messageType.toString();
    return defaultTypeText[typeName] ?? '[未知消息]';
  }
}

/// 时间配置
class RCKTimeConfig {
  /// 字体大小
  final double fontSize;

  /// 字体颜色
  final Color color;

  /// 字体粗细
  final FontWeight fontWeight;

  /// 时间格式化器
  final String Function(int timestamp)? formatter;

  RCKTimeConfig({
    Color? color,
    this.fontSize = convoAuxiliaryFontSize,
    this.fontWeight = FontWeight.normal,
    this.formatter,
  }) : color = color ??
            RCKThemeProvider().themeColor.textAuxiliary ??
            const Color(0xFFCCCCCC);
}

/// 未读消息角标配置
class RCKUnreadBadgeConfig {
  /// 背景颜色
  final Color backgroundColor;

  /// 免打扰背景颜色
  final Color muteBackgroundColor;

  /// 文字颜色
  final Color textColor;

  /// 字体大小
  final double fontSize;

  /// 显示位置 (头像右上角或单元格右侧)
  final BadgePosition position;

  /// 角标宽
  final double width;

  /// 角标高
  final double height;

  /// 超过99的显示文本
  final String overflowText;

  RCKUnreadBadgeConfig({
    Color? backgroundColor,
    Color? muteBackgroundColor,
    this.textColor = convoItemTextColor,
    this.fontSize = convoUnreadFontSize,
    this.position = BadgePosition.itemRight,
    this.width = 42.0,
    this.height = 21.0,
    this.overflowText = '99+',
  })  : backgroundColor = backgroundColor ??
            RCKThemeProvider().themeColor.notice ??
            const Color(0xFFFF0000),
        muteBackgroundColor = muteBackgroundColor ??
            RCKThemeProvider().themeColor.textAuxiliary ??
            const Color(0xFFE3F2FD);
}

/// 角标显示位置
enum BadgePosition {
  avatarTopRight, // 头像右上角
  itemRight, // 单元格右侧
}

/// 免打扰图标配置
class RCKMuteIconConfig {
  /// 是否显示免打扰图标
  final bool show;

  /// 图标数据
  final String icon;

  /// 图标大小
  final double size;

  /// 图标颜色
  final Color color;

  /// 图标位置
  final MuteIconPosition position;

  RCKMuteIconConfig({
    this.show = true,
    String? icon,
    this.size = 16.0,
    Color? color,
    this.position = MuteIconPosition.titleSuffix,
  })  : color = color = color ??
            RCKThemeProvider().themeColor.textAuxiliary ??
            const Color(0xFFCCCCCC),
        icon = icon ?? RCKThemeProvider().themeIcon.doNotDisturb1 ?? '';
}

/// 免打扰图标位置
enum MuteIconPosition {
  titleSuffix, // 标题后缀
  titlePrefix, // 标题前缀
  avatarTopRight, // 头像右上角
  messagePrefix, // 消息前缀
}

/// 单元格配置
class RCKItemConfig {
  /// 单元格高度
  final double height;

  /// 背景颜色
  final Color? backgroundColor;

  /// 置顶背景颜色
  final Color? pinnedBackgroundColor;

  /// 分割线颜色
  final Color? dividerColor;

  /// 分割线左边距
  final double dividerIndent;

  /// 分割线右边距
  final double dividerEndIndent;

  /// 分割线高度
  final double dividerHeight;

  /// 单元格内边距
  final EdgeInsets padding;

  /// 单元格之间的间距
  final double cellSpacing;

  const RCKItemConfig({
    this.height = 76.0,
    this.backgroundColor,
    this.pinnedBackgroundColor,
    this.dividerColor,
    this.dividerIndent = 0.0,
    this.dividerEndIndent = 0.0,
    this.dividerHeight = 1.0,
    this.padding = const EdgeInsets.symmetric(
        vertical: itemVerticalPadding, horizontal: itemHorizontalPadding),
    this.cellSpacing = 0.0,
  }) ;
}

/// 元素布局配置
class RCKLayoutConfig {
  /// 头像位置
  final ItemElementPosition avatarPosition;

  /// 标题位置
  final ItemElementPosition titlePosition;

  /// 消息位置
  final ItemElementPosition messagePosition;

  /// 时间位置
  final ItemElementPosition timePosition;

  /// 未读消息位置
  final ItemElementPosition unreadPosition;

  /// 元素间水平间距
  final double horizontalSpacing;

  /// 尾部元素间垂直间距
  final double verticalSpacingEnd;

  /// 标题和内容元素间垂直间距
  final double verticalSpacingContent;

  const RCKLayoutConfig({
    this.avatarPosition = ItemElementPosition.left,
    this.titlePosition = ItemElementPosition.topRight,
    this.messagePosition = ItemElementPosition.bottomRight,
    this.timePosition = ItemElementPosition.topRightCorner,
    this.unreadPosition = ItemElementPosition.avatarTopRight,
    this.horizontalSpacing = 16.0,
    this.verticalSpacingEnd = 8.0,
    this.verticalSpacingContent = 4.0,
  });
}

/// 元素位置枚举
enum ItemElementPosition {
  left, // 左侧
  right, // 右侧
  topLeft, // 左上
  topRight, // 右上
  bottomLeft, // 左下
  bottomRight, // 右下
  center, // 居中
  topRightCorner, // 右上角
  bottomRightCorner, // 右下角
  avatarTopRight, // 头像右上角
}

/// 侧滑操作配置
class RCKSlidableConfig {
  /// 是否启用侧滑
  final bool enabled;

  /// 侧滑按钮
  final List<RCKSlidableActionConfig> actions;

  RCKSlidableConfig({
    this.enabled = true,
    List<RCKSlidableActionConfig>? actions,
  }) : actions = actions ??
            [
              RCKSlidableActionConfig.pin(),
              RCKSlidableActionConfig.delete(),
              // SlidableActionConfig.mute()
            ];

  /// 获取有效的侧滑按钮数量（限制在1-3个之间）
  List<RCKSlidableActionConfig> get effectiveActions {
    if (actions.isEmpty) {
      return const [];
    }
    if (actions.length > 3) {
      return actions.sublist(0, 3);
    }
    return actions;
  }

  /// 获取有效的侧滑按钮数量（限制在1-3个之间）
  double extentRatio(BuildContext context) {
    if (actions.isEmpty) {
      return 0;
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final actionWidth = actions.length * slideItemSize;
    return actionWidth / screenWidth;
  }
}

/// 侧滑按钮配置
class RCKSlidableActionConfig {
  /// 按钮文本
  final String label;

  /// 按钮图标路径
  final String iconPath;

  /// 取消动作图标路径
  final String? undoIconPath;

  /// 背景颜色
  final Color backgroundColor;

  /// 前景颜色
  final Color foregroundColor;

  /// 动作类型
  final SlidableActionType actionType;

  /// 自动关闭
  final bool autoClose;

  const RCKSlidableActionConfig({
    required String? iconPath,
    required this.backgroundColor,
    this.undoIconPath,
    this.label = '',
    this.foregroundColor = Colors.white,
    required this.actionType,
    this.autoClose = true,
  }) : iconPath = iconPath ?? '';

  // 预定义的置顶操作
  RCKSlidableActionConfig.pin()
      : label = '置顶',
        iconPath = RCKThemeProvider().themeIcon.pin ?? '',
        undoIconPath = RCKThemeProvider().themeIcon.unpin ?? '',
        backgroundColor =
            RCKThemeProvider().themeColor.bgAuxiliary2 ?? Colors.blue,
        foregroundColor = Colors.white,
        actionType = SlidableActionType.pin,
        autoClose = true;

  // 预定义的删除操作
  RCKSlidableActionConfig.delete()
      : label = '删除',
        iconPath = RCKThemeProvider().themeIcon.delete ?? '',
        undoIconPath = '',
        backgroundColor = RCKThemeProvider().themeColor.notice ?? Colors.red,
        foregroundColor = Colors.white,
        actionType = SlidableActionType.delete,
        autoClose = true;

  // 预定义的免打扰操作
  RCKSlidableActionConfig.mute()
      : label = '免打扰',
        iconPath = RCKThemeProvider().themeIcon.doNotDisturb1 ?? '',
        undoIconPath = RCKThemeProvider().themeIcon.allowNotification ?? '',
        backgroundColor = RCKThemeProvider().themeColor.success ?? Colors.green,
        foregroundColor = Colors.white,
        actionType = SlidableActionType.mute,
        autoClose = true;
}

/// 侧滑按钮类型
enum SlidableActionType {
  pin, // 置顶
  delete, // 删除
  mute, // 免打扰
  custom, // 自定义
}

/// 列表配置
class RCKListConfig {
  /// 是否显示搜索框
  final bool showSearchBar;

  /// 空列表提示文本
  final String emptyText;

  /// 是否支持下拉刷新
  final bool enablePullToRefresh;

  /// 分页大小
  final int pageSize;

  /// 背景颜色
  final Color? backgroundColor;

  const RCKListConfig({
    this.showSearchBar = false,
    this.emptyText = '暂无消息',
    this.enablePullToRefresh = true,
    this.pageSize = 20,
    this.backgroundColor,
  });
}

/// 会话列表整体配置
class RCKConvoConfig {
  final RCKConvoAppBarConfig appBarConfig;
  final RCKItemConfig itemConfig;
  final RCKAvatarConfig avatarConfig;
  final RCKConvoTitleConfig titleConfig;
  final RCKLastMessageConfig lastMessageConfig;
  final RCKTimeConfig timeConfig;
  final RCKUnreadBadgeConfig unreadBadgeConfig;
  final RCKSlidableConfig slidableConfig;
  final RCKListConfig listConfig;
  final RCKMuteIconConfig muteIconConfig;
  final RCKLayoutConfig layoutConfig;

  RCKConvoConfig({
    RCKConvoAppBarConfig? appBarConfig,
    this.avatarConfig = const RCKAvatarConfig(),
    this.titleConfig = const RCKConvoTitleConfig(),
    RCKLastMessageConfig? lastMessageConfig,
    RCKTimeConfig? timeConfig,
    RCKUnreadBadgeConfig? unreadBadgeConfig,
    RCKItemConfig? itemConfig,
    RCKSlidableConfig? slidableConfig,
    this.listConfig = const RCKListConfig(),
    RCKMuteIconConfig? muteIconConfig,
    this.layoutConfig = const RCKLayoutConfig(),
  })  : appBarConfig = appBarConfig ?? RCKConvoAppBarConfig(),
        itemConfig = itemConfig ?? const RCKItemConfig(),
        unreadBadgeConfig = unreadBadgeConfig ?? RCKUnreadBadgeConfig(),
        timeConfig = timeConfig ?? RCKTimeConfig(),
        lastMessageConfig = lastMessageConfig ?? RCKLastMessageConfig(),
        muteIconConfig = muteIconConfig ?? RCKMuteIconConfig(),
        slidableConfig = slidableConfig ?? RCKSlidableConfig();
}
