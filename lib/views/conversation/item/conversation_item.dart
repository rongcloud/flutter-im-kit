import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/utils/popup.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

typedef ItemBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKItemConfig config);
typedef ItemOnTap = void Function(
    BuildContext context, RCIMIWConversation conversation, int index);
typedef ItemOnLongPress = void Function(
    BuildContext context, RCIMIWConversation conversation, int index);

class ConversationItem extends StatefulWidget {
  final RCIMIWConversation conversation;
  final int index;
  final RCKConvoConfig config;
  final AvatarBuilder? avatarBuilder;
  final TitleBuilder? titleBuilder;
  final LastMessageBuilder? lastMessageBuilder;
  final TimeBuilder? timeBuilder;
  final UnreadBadgeBuilder? unreadBadgeBuilder;
  final ItemOnTap? onTap;
  final ItemOnLongPress? onLongPress;

  const ConversationItem({
    super.key,
    required this.conversation,
    required this.index,
    required this.config,
    this.avatarBuilder,
    this.titleBuilder,
    this.lastMessageBuilder,
    this.timeBuilder,
    this.unreadBadgeBuilder,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  RCKChatProfileInfo? customInfo;

  @override
  void initState() {
    super.initState();
    _fetchCustomInfo();
  }

  @override
  void didUpdateWidget(ConversationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果会话变了，重新获取用户信息
    if (oldWidget.conversation.targetId != widget.conversation.targetId) {
      _fetchCustomInfo();
    }
  }

  // 异步获取用户信息
  Future<void> _fetchCustomInfo() async {
    if (context.read<RCKEngineProvider>().customInfoProvider == null) return;
    customInfo = await Future.value(context
        .read<RCKEngineProvider>()
        .customInfoProvider!(conversation: widget.conversation));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemConfig = widget.config.itemConfig;
    final slidableConfig = widget.config.slidableConfig;
    final muteIconConfig = widget.config.muteIconConfig;
    final layoutConfig = widget.config.layoutConfig;
    final unreadWidth = (widget.conversation.unreadCount ?? 0) > 99
        ? widget.config.unreadBadgeConfig.width
        : (widget.conversation.unreadCount ?? 0) > 9
            ? widget.config.unreadBadgeConfig.width * 0.7
            : widget.config.unreadBadgeConfig.width / 2;

    final isLongPress = context.select(
        (RCKConvoProvider provider) => provider.longPressIndex == widget.index);
    final isTop = widget.conversation.top ?? false;

    // 构建内容部分
    Widget content = Column(
      children: [
        Container(
          height: itemConfig.height,
          padding: itemConfig.padding,
          color: isLongPress
              ? RCKThemeProvider().themeColor.bgLongPress
              : isTop
                  ? itemConfig.pinnedBackgroundColor ??
                      RCKThemeProvider().themeColor.bgTop
                  : itemConfig.backgroundColor ??
                      (RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
                          ? RCKThemeProvider().themeColor.bgAuxiliary1
                          : RCKThemeProvider().themeColor.bgRegular),
          child: InkWell(
            onTap: () => _handleTap(context),
            onLongPress: () => _handleLongPress(context),
            child: Row(
              children: [
                // 头像部分 - 按照布局配置来确定位置
                if (layoutConfig.avatarPosition == ItemElementPosition.left)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 使用自定义构建器或默认组件
                      widget.avatarBuilder != null
                          ? widget.avatarBuilder!(context, widget.conversation,
                              widget.config.avatarConfig)
                          : AvatarWidget(
                              conversation: widget.conversation,
                              config: widget.config.avatarConfig,
                              customInfo: customInfo,
                            ),

                      // 未读消息角标 - 如果位置是头像右上角
                      if (widget.config.unreadBadgeConfig.position ==
                              BadgePosition.avatarTopRight &&
                          (widget.conversation.unreadCount ?? 0) > 0)
                        Positioned(
                          right: (widget.config.avatarConfig.badgeOffset?.dx ??
                                  0) -
                              (unreadWidth / 2),
                          top: (widget.config.avatarConfig.badgeOffset?.dy ??
                                  0) -
                              (widget.config.unreadBadgeConfig.height / 2),
                          child: widget.unreadBadgeBuilder != null
                              ? widget.unreadBadgeBuilder!(
                                  context,
                                  widget.conversation,
                                  widget.config.unreadBadgeConfig)
                              : UnreadBadgeWidget(
                                  conversation: widget.conversation,
                                  config: widget.config.unreadBadgeConfig,
                                ),
                        ),

                      // 免打扰图标 - 如果位置是头像右上角
                      if (muteIconConfig.show &&
                          widget.conversation.notificationLevel ==
                              RCIMIWPushNotificationLevel.blocked &&
                          muteIconConfig.position ==
                              MuteIconPosition.avatarTopRight)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: ImageUtil.getImageWidget(muteIconConfig.icon,
                              width: muteIconConfig.size,
                              height: muteIconConfig.size,
                              color: muteIconConfig.color),
                        ),
                    ],
                  ),

                SizedBox(width: layoutConfig.horizontalSpacing),

                // 中间内容区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          // 免打扰图标 - 如果位置是标题前缀
                          if (muteIconConfig.show &&
                              widget.conversation.notificationLevel ==
                                  RCIMIWPushNotificationLevel.blocked &&
                              muteIconConfig.position ==
                                  MuteIconPosition.titlePrefix)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: layoutConfig.horizontalSpacing / 2),
                              child: ImageUtil.getImageWidget(
                                  muteIconConfig.icon,
                                  width: muteIconConfig.size,
                                  height: muteIconConfig.size,
                                  color: muteIconConfig.color),
                            ),

                          widget.titleBuilder != null
                              ? widget.titleBuilder!(
                                  context,
                                  widget.conversation,
                                  widget.config.titleConfig)
                              : TitleWidget(
                                  conversation: widget.conversation,
                                  config: widget.config.titleConfig,
                                  customInfo: customInfo,
                                ),

                          // 免打扰图标 - 如果位置是标题后缀
                          if (muteIconConfig.show &&
                              widget.conversation.notificationLevel ==
                                  RCIMIWPushNotificationLevel.blocked &&
                              muteIconConfig.position ==
                                  MuteIconPosition.titleSuffix)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: layoutConfig.horizontalSpacing / 2),
                              child: ImageUtil.getImageWidget(
                                  muteIconConfig.icon,
                                  width: muteIconConfig.size,
                                  height: muteIconConfig.size,
                                  color: muteIconConfig.color),
                            ),
                        ],
                      ),

                      SizedBox(height: layoutConfig.verticalSpacingContent),

                      // 最后一条消息行
                      Row(
                        children: [
                          // 免打扰图标 - 如果位置是消息前缀
                          if (muteIconConfig.show &&
                              widget.conversation.notificationLevel ==
                                  RCIMIWPushNotificationLevel.blocked &&
                              muteIconConfig.position ==
                                  MuteIconPosition.messagePrefix)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: layoutConfig.horizontalSpacing / 2),
                              child: ImageUtil.getImageWidget(
                                  muteIconConfig.icon,
                                  width: muteIconConfig.size,
                                  height: muteIconConfig.size,
                                  color: muteIconConfig.color),
                            ),

                          // 最后一条消息
                          Expanded(
                            child: widget.lastMessageBuilder != null
                                ? widget.lastMessageBuilder!(
                                    context,
                                    widget.conversation,
                                    widget.config.lastMessageConfig)
                                : LastMessageWidget(
                                    conversation: widget.conversation,
                                    config: widget.config.lastMessageConfig,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: layoutConfig.horizontalSpacing),

                // 右侧区域
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 时间
                    widget.timeBuilder != null
                        ? widget.timeBuilder!(context, widget.conversation,
                            widget.config.timeConfig)
                        : TimeWidget(
                            conversation: widget.conversation,
                            config: widget.config.timeConfig,
                          ),

                    SizedBox(height: layoutConfig.verticalSpacingEnd),

                    // 未读消息角标(如果位置是单元格右侧)
                    if (widget.config.unreadBadgeConfig.position ==
                            BadgePosition.itemRight &&
                        (widget.conversation.unreadCount ?? 0) > 0)
                      widget.unreadBadgeBuilder != null
                          ? widget.unreadBadgeBuilder!(
                              context,
                              widget.conversation,
                              widget.config.unreadBadgeConfig)
                          : UnreadBadgeWidget(
                              conversation: widget.conversation,
                              config: widget.config.unreadBadgeConfig,
                            ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 单元格间距
        if (itemConfig.cellSpacing > 0)
          SizedBox(height: itemConfig.cellSpacing),
      ],
    );

    // 如果启用侧滑功能，包装在Slidable中
    if (slidableConfig.enabled && slidableConfig.effectiveActions.isNotEmpty) {
      return Slidable(
        key: Key(widget.conversation.targetId ?? '${widget.index}'),
        endActionPane: ActionPane(
          extentRatio: slidableConfig.extentRatio(context),
          motion: const ScrollMotion(),
          children: _buildSlidableActions(context),
        ),
        child: content,
      );
    } else {
      return content;
    }
  }

  List<Widget> _buildSlidableActions(BuildContext context) {
    final actions = <Widget>[];
    final effectiveActions = widget.config.slidableConfig.effectiveActions;

    final bool conversationIsPinned = widget.conversation.top ?? false;
    final bool conversationIsDisturbed =
        widget.conversation.notificationLevel ==
            RCIMIWPushNotificationLevel.blocked;

    for (var action in effectiveActions) {
      var actionPath = action.iconPath;
      if (action.actionType == SlidableActionType.pin && conversationIsPinned) {
        actionPath = action.undoIconPath ?? '';
      }
      if (action.actionType == SlidableActionType.mute &&
          conversationIsDisturbed) {
        actionPath = action.undoIconPath ?? '';
      }
      actions.add(
        CustomSlidableAction(
          onPressed: (actionContext) =>
              _handleSlidableAction(context, action.actionType),
          backgroundColor: action.backgroundColor,
          foregroundColor: action.foregroundColor,
          autoClose: action.autoClose,
          child: ImageUtil.getImageWidget(actionPath,
              width: slideItemIconSize,
              height: slideItemIconSize,
              color: action.foregroundColor),
        ),
      );
    }

    return actions;
  }

  void _handleSlidableAction(
      BuildContext context, SlidableActionType actionType) {
    final provider = context.read<RCKConvoProvider>();

    switch (actionType) {
      case SlidableActionType.pin:
        provider.pinConversation(widget.index);
        break;
      case SlidableActionType.delete:
        provider.removeConversation(widget.index);
        break;
      case SlidableActionType.mute:
        provider.blockConversation(widget.index);
        break;
      case SlidableActionType.custom:
        // 自定义操作可通过外部回调处理
        break;
    }
  }

  void _handleTap(BuildContext context) {
    RCIMWrapperPlatform.instance.writeLog('ConversationItem ontap', '', 0,
        'targetId: ${widget.conversation.targetId} widget.onTap: ${widget.onTap}');
    if (widget.onTap != null) {
      widget.onTap!(context, widget.conversation, widget.index);
      return;
    }

    // 默认行为

    context.read<RCKConvoProvider>().selectConversation(widget.conversation);
    Navigator.pushNamed(context, '/chat', arguments: {
      'conversation': widget.conversation,
      'config': widget.config,
    }).then((value) {
      if (context.mounted) {
        context.read<RCKConvoProvider>().popConversation();
        context
            .read<RCKMessageInputProvider>()
            .setInputType(RCIMIWMessageInputType.text);
      }
    });
  }

  void _handleLongPress(BuildContext context) {
    RCIMWrapperPlatform.instance.writeLog('ConversationItem onLongPress', '', 0,
        'targetId: ${widget.conversation.targetId} widget.onLongPress: ${widget.onLongPress}');
    final provider = context.read<RCKConvoProvider>();
    if (provider.isLongPressing) {
      return;
    }
    provider.setLongPressIndex(widget.index);
    if (widget.onLongPress != null) {
      widget.onLongPress!(context, widget.conversation, widget.index);
      return;
    }
    showPopupMenu(context, PopupType.convo,
            isPin: widget.conversation.top,
            isMute: widget.conversation.notificationLevel ==
                RCIMIWPushNotificationLevel.blocked)
        .then((value) {
      provider.resetLongPressIndex();
      if (value == 'pin') {
        provider.pinConversation(widget.index);
      } else if (value == 'mute') {
        provider.blockConversation(widget.index);
      } else if (value == 'delete') {
        provider.removeConversation(widget.index);
      }
    });
  }
}
