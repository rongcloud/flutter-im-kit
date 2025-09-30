import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/utils/popup.dart';
import 'package:rongcloud_im_kit/utils/rotate_widget.dart';
import '../../../utils/time_util.dart';
import 'message_callbacks.dart';
import 'file_message_bubble.dart';
import 'reference_message_bubble.dart';
import 'sight_message_bubble.dart';
import 'text_message_bubble.dart';
import 'notification_message_bubble.dart';
import 'voice_message_bubble.dart';
import 'image_message_bubble.dart';
import 'recall_message_bubble.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

abstract class RCKMessageBubble extends StatefulWidget {
  final RCIMIWMessage message;
  final bool showTime;
  final Alignment? alignment;
  final bool? withoutBubble;
  final bool? withoutName;
  final RCKBubbleConfig? config;
  final GlobalKey _anchorKey;

  // 添加事件回调属性
  final MessageTapCallback? onTap;
  final MessageDoubleTapCallback? onDoubleTap;
  final MessageLongPressCallback? onLongPress;
  final MessageSwipeCallback? onSwipe;
  final MessageTapCallback? onAppendBubbleTap;
  final MessageLongPressCallback? onAppendBubbleLongPress;

  RCKMessageBubble({
    super.key,
    required this.message,
    this.showTime = false, // 默认不显示时间
    this.alignment,
    this.withoutBubble,
    this.withoutName,
    this.config, // 新增：气泡配置参数
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipe,
    this.onAppendBubbleTap,
    this.onAppendBubbleLongPress,
  }) : _anchorKey = GlobalKey();

  factory RCKMessageBubble.create({
    required BuildContext context,
    required RCIMIWMessage message,
    bool showTime = false,
    RCKBubbleConfig? config, // 新增：气泡配置参数
    Map<RCIMIWMessageType, CustomChatItemBubbleBuilder>?
        customChatItemBubbleBuilders,
    MessageTapCallback? onTap,
    MessageDoubleTapCallback? onDoubleTap,
    MessageLongPressCallback? onLongPress,
    MessageSwipeCallback? onSwipe,
    MessageTapCallback? onAppendBubbleTap,
    MessageLongPressCallback? onAppendBubbleLongPress,
  }) {
    RCKMessageBubble bubble;

    if (customChatItemBubbleBuilders != null &&
        customChatItemBubbleBuilders.containsKey(message.messageType)) {
      bubble = customChatItemBubbleBuilders[message.messageType]!(
          message: message,
          showTime: showTime,
          config: config,
          context: context);
    } else {
      switch (message.messageType) {
        case RCIMIWMessageType.text:
          bubble = RCKTextMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.unknown:
          bubble = RCKUnknownMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.voice:
          bubble = RCKVoiceMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe,
              onAppendBubbleTap: onAppendBubbleTap,
              onAppendBubbleLongPress: onAppendBubbleLongPress);
          break;
        case RCIMIWMessageType.image:
        case RCIMIWMessageType.gif:
          bubble = RCKImageMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.sight:
          bubble = RCKSightMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.file:
          bubble = RCKFileMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.reference:
          bubble = RCKReferenceMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe);
          break;
        case RCIMIWMessageType.recall:
          bubble = RCKRecallMessageBubble(
            message: message,
            showTime: showTime,
            config: config,
          );
          break;
        // 在这里添加其他消息类型的实现
        default:
          bubble = RCKTextMessageBubble(
              message: message,
              showTime: showTime,
              config: config,
              onTap: onTap,
              onDoubleTap: onDoubleTap,
              onLongPress: onLongPress,
              onSwipe: onSwipe); // 默认使用文本消息气泡
      }
    }

    return bubble;
  }

  // 子类需要实现的内容构建方法
  Widget buildMessageContent(BuildContext context, String? refName);

  // 子类可重写的气泡点击事件处理方法
  void onBubbleTap(BuildContext context) {}

  /// 子类可重写：构建显示在主气泡下方的“追加气泡/附加面板”。
  ///
  /// 返回 null 表示不展示。父类会统一处理头像缩进、对齐、多选与侧滑等外层布局，
  /// 子类仅需返回自身内容容器（可自行决定背景、圆角、内边距等样式）。
  /// 例如：语音消息可在此返回“语音转文字”的附加面板。
  Widget? buildAppendBubble(BuildContext context) => null;

  @override
  State<RCKMessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<RCKMessageBubble> {
  RCKChatProfileInfo? customBubbleInfo;
  String? refName;

  @override
  void initState() {
    super.initState();
    _fetchCustomInfo();
  }

  @override
  void didUpdateWidget(RCKMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.messageId != widget.message.messageId) {
      _fetchCustomInfo();
    }
  }

  Future<void> _fetchCustomInfo() async {
    final customInfoProvider =
        context.read<RCKEngineProvider>().customInfoProvider;
    if (customInfoProvider != null) {
      customBubbleInfo = await customInfoProvider(message: widget.message);
      if (widget.message is RCIMIWReferenceMessage) {
        final refMsg =
            (widget.message as RCIMIWReferenceMessage).referenceMessage;
        if (refMsg != null && mounted && context.mounted) {
          refName = (await customInfoProvider(message: refMsg)).name;
        }
      }
      if (widget.message is RCIMIWRecallNotificationMessage) {
        if ((widget.message as RCIMIWRecallNotificationMessage).admin ??
            false) {
          refName = '管理员';
        } else {
          if (mounted && context.mounted) {
            final currentUserId =
                context.read<RCKEngineProvider>().currentUserId;
            if (widget.message.senderUserId == currentUserId) {
              refName = '你';
            } else {
              refName =
                  (await customInfoProvider(message: widget.message)).name;
            }
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 是否为原生自定义/媒体类消息（这些消息走简化渲染路径）
  bool _isNativeCustomOrMediaMessage() {
    return widget.message.messageType == RCIMIWMessageType.nativeCustom ||
        widget.message.messageType == RCIMIWMessageType.nativeCustomMedia;
  }

  /// 构建原生自定义/媒体消息的容器，带额外垂直间距并居中对齐
  Widget _buildNativeCustomOrMedia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kBubblePaddingVertical * 2),
      child: Align(
        alignment: widget.alignment ?? Alignment.center,
        child: widget.buildMessageContent(context, refName),
      ),
    );
  }

  /// 是否开启多选：受聊天的多选状态与消息类型影响（撤回消息禁用多选）
  bool _isMultiSelectEnabled(RCKChatProvider chatProvider) {
    bool isMultiSelect = chatProvider.multiSelectMode;
    if (widget.message.messageType == RCIMIWMessageType.recall) {
      isMultiSelect = false;
    }
    return isMultiSelect;
  }

  /// 当前消息是否由自己发送（影响对齐与状态指示器显示）
  bool _isMessageFromMe() {
    return widget.message.direction == RCIMIWMessageDirection.send;
  }

  /// 获取有效的气泡配置；未传入时返回默认配置
  RCKBubbleConfig _effectiveConfig() {
    return widget.config ?? RCKBubbleConfig();
  }

  /// 计算气泡内容最大宽度：屏宽*比例 - 头像宽度 - 2*内边距
  double _bubbleMaxWidth(
      BuildContext context, EdgeInsetsGeometry bubblePadding) {
    return MediaQuery.of(context).size.width * kBubbleWidthRatio -
        kBubbleAvatarSize -
        2 * bubblePadding.horizontal;
  }

  /// 构建消息状态指示器：仅对我方非撤回消息显示发送中/失败图标
  Widget? _buildStatusIndicator(bool isMe, EdgeInsetsGeometry bubblePadding) {
    if (!isMe || widget.message.messageType == RCIMIWMessageType.recall) {
      return null;
    }
    if (widget.message.sentStatus == RCIMIWSentStatus.sending) {
      return Padding(
        padding: EdgeInsets.only(
            right: kBubbleStatusPadding, top: bubblePadding.vertical / 2),
        child: const RotatingImage(
          imagePath: 'messageSending.png',
          size: kBubbleStatusSize,
        ),
      );
    } else if (widget.message.sentStatus == RCIMIWSentStatus.failed) {
      return Padding(
        padding: EdgeInsets.only(
            right: kBubbleStatusPadding, top: bubblePadding.vertical / 2),
        child: GestureDetector(
          onTap: () => _handleRetry(context),
          child: ImageUtil.getImageWidget('messageSendFail.png',
              width: kBubbleStatusSize, height: kBubbleStatusSize),
        ),
      );
    }
    return null;
  }

  /// 是否默认不显示气泡背景：图片/GIF/小视频/文件消息通常隐藏气泡
  bool _defaultWithoutBubble() {
    return widget.message.messageType == RCIMIWMessageType.image ||
        widget.message.messageType == RCIMIWMessageType.gif ||
        widget.message.messageType == RCIMIWMessageType.sight ||
        widget.message.messageType == RCIMIWMessageType.file;
  }

  /// 是否默认不显示发送者名称：未知/撤回消息不显示
  bool _defaultWithoutName() {
    return widget.message.messageType == RCIMIWMessageType.unknown ||
        widget.message.messageType == RCIMIWMessageType.recall;
  }

  /// 默认对齐方式：未知/撤回居中，其余根据消息方向左/右对齐
  Alignment _defaultAlignment(bool isMe) {
    if (widget.message.messageType == RCIMIWMessageType.unknown ||
        widget.message.messageType == RCIMIWMessageType.recall) {
      return Alignment.center;
    }
    return isMe ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// 默认主轴对齐：未知/撤回居中，其余根据消息方向开始/结束
  MainAxisAlignment _defaultMainAxisAlignment(bool isMe) {
    if (widget.message.messageType == RCIMIWMessageType.unknown ||
        widget.message.messageType == RCIMIWMessageType.recall) {
      return MainAxisAlignment.center;
    }
    return isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// 默认交叉轴对齐：未知/撤回居中，其余根据消息方向开始/结束
  CrossAxisAlignment _defaultCrossAxisAlignment(bool isMe) {
    if (widget.message.messageType == RCIMIWMessageType.unknown ||
        widget.message.messageType == RCIMIWMessageType.recall) {
      return CrossAxisAlignment.center;
    }
    return isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  /// 构建头像组件：优先使用自定义头像，缺省时展示默认头像
  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kBubbleAvatarPadding),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(kBubbleAvatarSize / 2),
          child: ImageUtil.getImageWidget(
              (customBubbleInfo?.avatar ?? '').isNotEmpty
                  ? customBubbleInfo?.avatar ?? ''
                  : 'avatar_default_single.png',
              width: kBubbleAvatarSize,
              height: kBubbleAvatarSize)),
    );
  }

  /// 是否需要显示发送者名称：仅群聊显示，单聊不显示
  bool _hasSenderName() {
    return widget.message.conversationType == RCIMIWConversationType.group;
  }

  /// 构建气泡主体：可选名称 + 状态指示器 + 内容容器（含点击事件）
  Widget _buildBubbleCore({
    required bool haveName,
    required bool withoutName,
    required CrossAxisAlignment crossAxisAlignment,
    required Widget? statusIndicator,
    required double bubbleMaxWidth,
    required RCKBubbleConfig effectiveConfig,
    required EdgeInsetsGeometry bubblePadding,
    required bool withoutBubble,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        haveName && !withoutName
            ? SizedBox(
                height: kBubbleNameFontSize + 6,
                child: ((customBubbleInfo?.name.isNotEmpty ?? false) ||
                        (customBubbleInfo?.id.isNotEmpty ?? false))
                    ? Text(
                        customBubbleInfo?.name ?? customBubbleInfo?.id ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            height: 1.0,
                            color: RCKThemeProvider().themeColor.textPrimary,
                            fontSize: kBubbleNameFontSize),
                      )
                    : const SizedBox.shrink(),
              )
            : const SizedBox(),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (statusIndicator != null) statusIndicator,
            GestureDetector(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!(widget.message, context);
                  } else {
                    widget.onBubbleTap(context);
                  }
                  RCIMWrapperPlatform.instance.writeLog(
                      'RCKMessageBubble onTap',
                      '',
                      0,
                      'message: ${widget.message.messageId}');
                },
                onDoubleTap: () {
                  if (widget.onDoubleTap != null) {
                    widget.onDoubleTap!(widget.message, context);
                  }
                  RCIMWrapperPlatform.instance.writeLog(
                      'RCKMessageBubble onDoubleTap',
                      '',
                      0,
                      'message: ${widget.message.messageId}');
                },
                onLongPress: () {
                  if (widget.onLongPress != null) {
                    bool handled = widget.onLongPress!(widget.message, context);
                    if (!handled) {
                      _showContextMenu(context);
                    }
                  } else {
                    _showContextMenu(context);
                  }
                  RCIMWrapperPlatform.instance.writeLog(
                      'RCKMessageBubble onLongPress',
                      '',
                      0,
                      'message: ${widget.message.messageId}');
                },
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                    child: Container(
                      key: widget._anchorKey,
                      margin:
                          EdgeInsets.only(top: haveName ? kBubbleMarginTop : 0),
                      padding: bubblePadding,
                      decoration: withoutBubble
                          ? null
                          : effectiveConfig.getBubbleDecoration(
                              widget.message, withoutBubble),
                      child: widget.buildMessageContent(context, refName),
                    ))),
          ],
        )
      ],
    );
  }

  /// 将头像与气泡按左右方向进行组合
  Widget _composeWithAvatar({
    required Widget bubble,
    required bool isMe,
    required bool withoutName,
    required MainAxisAlignment mainAxisAlignment,
  }) {
    final avatar = _buildAvatar();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (!isMe && !withoutName) avatar,
        Flexible(child: bubble),
        if (isMe && !withoutName) avatar,
      ],
    );
  }

  /// 将“子类返回的追加气泡”附加到主气泡下方，并根据左右头像进行缩进对齐
  Widget _attachAppendBubbleBelow({
    required Widget bubbleRowWithAvatar,
    required bool isMe,
    required bool withoutName,
    required MainAxisAlignment mainAxisAlignment,
  }) {
    final Widget? append = widget.buildAppendBubble(context);
    if (append == null) return bubbleRowWithAvatar;

    final avatarSpacing =
        SizedBox(width: kBubbleAvatarSize + 2 * kBubbleAvatarPadding);

    final RCKAppendBubbleConfig appendCfg =
        _effectiveConfig().appendBubbleConfig;
    final BoxDecoration? appendDecoration = appendCfg.backgroundColor == null
        ? null
        : BoxDecoration(
            color: appendCfg.backgroundColor,
            borderRadius: BorderRadius.circular(appendCfg.borderRadius),
            border:
                (appendCfg.borderColor != null && appendCfg.borderWidth != null)
                    ? Border.all(
                        color: appendCfg.borderColor!,
                        width: appendCfg.borderWidth!)
                    : null,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bubbleRowWithAvatar,
        SizedBox(height: appendCfg.spacingToMain),
        Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && !withoutName) avatarSpacing,
            Flexible(
              child: GestureDetector(
                onTap: () {
                  if (widget.onAppendBubbleTap != null) {
                    widget.onAppendBubbleTap!(widget.message, context);
                  }
                },
                onLongPress: () {
                  if (widget.onAppendBubbleLongPress != null) {
                    bool handled = widget.onAppendBubbleLongPress!(
                        widget.message, context);
                    if (!handled) {
                      _showContextMenu(context, isBubbleAppend: true);
                    }
                  } else {
                    _showContextMenu(context, isBubbleAppend: true);
                  }
                },
                child: (appendCfg.padding == EdgeInsets.zero &&
                        appendDecoration == null)
                    ? append
                    : Container(
                        padding: appendCfg.padding,
                        decoration: appendDecoration,
                        child: append,
                      ),
              ),
            ),
            if (isMe && !withoutName) avatarSpacing,
          ],
        ),
      ],
    );
  }

  /// 在多选模式下为消息添加左侧选择器图标
  Widget _maybeWrapWithSelectorIcon({
    required Widget bubble,
    required bool isMultiSelect,
    required bool isSelected,
    required RCKChatProvider chatProvider,
  }) {
    if (!isMultiSelect) return bubble;
    Widget selector = GestureDetector(
      onTap: () {
        chatProvider.toggleMessageSelection(widget.message, context);
      },
      child: ImageUtil.getImageWidget(
          isSelected
              ? RCKThemeProvider().themeIcon.chatItemMultiSelect ?? ''
              : RCKThemeProvider().themeIcon.chatItemMultiUnselect ?? '',
          width: kBubbleMultiSelectIconSize,
          height: kBubbleMultiSelectIconSize),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                right: kBubbleMultiSelectIconPaddingRight),
            child: selector),
        Flexible(child: bubble),
      ],
    );
  }

  /// 包裹最终布局：时间戳 + （多选布局/普通布局的对齐与宽度约束）
  Widget _wrapFinalLayout({
    required BuildContext context,
    required bool isMultiSelect,
    required Alignment alignment,
    required Widget messageContainer,
    required RCKChatProvider chatProvider,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: kBubblePaddingVertical),
        child: Column(
          children: [
            if (widget.showTime)
              Padding(
                padding: const EdgeInsets.only(
                    bottom: kBubbleTimeVerticalPadding,
                    top: kBubbleTimeVerticalPadding),
                child: Text(
                  TimeUtil.chatViewFormatTime(widget.message.sentTime),
                  style: TextStyle(
                    color: RCKThemeProvider().themeColor.textSecondary,
                    fontSize: kBubbleTimeFontSize,
                  ),
                ),
              ),
            if (isMultiSelect)
              Padding(
                padding: const EdgeInsets.only(
                  left: kBubbleMultiSelectIconPaddingLeft,
                ),
                child: GestureDetector(
                  onTap: () => chatProvider.toggleMessageSelection(
                      widget.message, context),
                  onLongPress: () => _showContextMenu(context),
                  child: messageContainer,
                ),
              )
            else
              Align(
                alignment: alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * kBubbleWidthRatio,
                  ),
                  child: messageContainer,
                ),
              ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isNativeCustomOrMediaMessage()) {
      return _buildNativeCustomOrMedia(context);
    }

    final chatProvider = context.watch<RCKChatProvider>();
    final bool isMultiSelect = _isMultiSelectEnabled(chatProvider);
    final bool isSelected =
        chatProvider.selectedMessages.contains(widget.message);
    final bool isMe = _isMessageFromMe();

    final effectiveConfig = _effectiveConfig();
    final bubblePadding = effectiveConfig.padding;
    final bubbleMaxWidth = _bubbleMaxWidth(context, bubblePadding);

    final Widget? statusIndicator = _buildStatusIndicator(isMe, bubblePadding);

    Alignment alignment = _defaultAlignment(isMe);
    final MainAxisAlignment mainAxisAlignment = _defaultMainAxisAlignment(isMe);
    final CrossAxisAlignment crossAxisAlignment =
        _defaultCrossAxisAlignment(isMe);

    bool withoutBubble = _defaultWithoutBubble();
    bool withoutName = _defaultWithoutName();

    if (widget.alignment != null) {
      alignment = widget.alignment!;
    }
    if (widget.withoutBubble != null) {
      withoutBubble = widget.withoutBubble!;
    }
    if (widget.withoutName != null) {
      withoutName = widget.withoutName!;
    }

    final bool haveName = _hasSenderName();

    Widget bubble = _buildBubbleCore(
      haveName: haveName,
      withoutName: withoutName,
      crossAxisAlignment: crossAxisAlignment,
      statusIndicator: statusIndicator,
      bubbleMaxWidth: bubbleMaxWidth,
      effectiveConfig: effectiveConfig,
      bubblePadding: bubblePadding,
      withoutBubble: withoutBubble,
    );

    bubble = _composeWithAvatar(
      bubble: bubble,
      isMe: isMe,
      withoutName: withoutName,
      mainAxisAlignment: mainAxisAlignment,
    );

    // 附加子类定义的追加气泡（如语音转文字面板）
    bubble = _attachAppendBubbleBelow(
      bubbleRowWithAvatar: bubble,
      isMe: isMe,
      withoutName: withoutName,
      mainAxisAlignment: mainAxisAlignment,
    );

    bubble = _maybeWrapWithSelectorIcon(
      bubble: bubble,
      isMultiSelect: isMultiSelect,
      isSelected: isSelected,
      chatProvider: chatProvider,
    );

    Widget messageContainer = widget.onSwipe != null
        ? _buildSwipeableContainer(bubble, context)
        : bubble;

    return _wrapFinalLayout(
      context: context,
      isMultiSelect: isMultiSelect,
      alignment: alignment,
      messageContainer: messageContainer,
      chatProvider: chatProvider,
    );
  }

  // 构建可侧滑容器
  Widget _buildSwipeableContainer(Widget child, BuildContext context) {
    return Dismissible(
      key: Key(
          "message_${widget.message.messageUId ?? widget.message.messageId}"),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Icon(Icons.reply, color: Colors.white),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        child: const Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      confirmDismiss: (direction) async {
        if (widget.onSwipe != null) {
          widget.onSwipe!(
              widget.message,
              context,
              direction == DismissDirection.endToStart
                  ? SwipeDirection.left
                  : SwipeDirection.right);
        }
        return false; // 不真正删除元素
      },
      child: child,
    );
  }

  void _handleRetry(BuildContext context) {
    context.read<RCKChatProvider>().sendMessage(widget.message, isResend: true);
  }

  void _showContextMenu(BuildContext context, {bool isBubbleAppend = false}) {
    final chatProvider = context.read<RCKChatProvider>();
    if (chatProvider.isLongPressing) {
      return;
    }
    chatProvider.setIsLongPressing(true);
    if (chatProvider.multiSelectMode) {
      return;
    }
    if (widget.message.messageType == RCIMIWMessageType.nativeCustom ||
        widget.message.messageType == RCIMIWMessageType.nativeCustomMedia ||
        widget.message.messageType == RCIMIWMessageType.recall) {
      return;
    }
    bool canRecall = widget.message.direction == RCIMIWMessageDirection.send;
    bool canQuote = widget.message.sentStatus != RCIMIWSentStatus.failed;
    bool canCopy = widget.message is! RCIMIWMediaMessage;
    bool conversationIsSystem =
        widget.message.conversationType == RCIMIWConversationType.system;

    bool canSpeechToText = false;
    bool canCancelSpeechToText = false;
    bool speechToTextInfoNoEmpty = widget.message is RCIMIWVoiceMessage &&
        (widget.message as RCIMIWVoiceMessage).speechToTextInfo != null;
    final engineProvider = context.read<RCKEngineProvider>();
    bool speechToTextVisible = engineProvider.enableSpeechToText &&
        speechToTextInfoNoEmpty &&
        widget.message.sentStatus != RCIMIWSentStatus.failed &&
        widget.message.sentStatus != RCIMIWSentStatus.sending;
    if (widget.message is RCIMIWVoiceMessage && speechToTextVisible) {
      final speechToTextStatus =
          (widget.message as RCIMIWVoiceMessage).speechToTextInfo?.status;
      //如果是转换中的附加气泡，不显示长按菜单
      if (speechToTextStatus == RCIMIWSpeechToTextStatus.converting &&
          isBubbleAppend) {
        chatProvider.setIsLongPressing(false);
        return;
      }
      canSpeechToText =
          (speechToTextStatus == RCIMIWSpeechToTextStatus.notConverted ||
              speechToTextStatus == RCIMIWSpeechToTextStatus.success ||
              speechToTextStatus == RCIMIWSpeechToTextStatus.failed);

      canCancelSpeechToText = (chatProvider.speechToTextMessageIdsVisible
              .contains(widget.message.messageId) &&
          (speechToTextStatus == RCIMIWSpeechToTextStatus.failed ||
              speechToTextStatus == RCIMIWSpeechToTextStatus.success));
    }
    showPopupMenu(
            context, isBubbleAppend ? PopupType.bubbleAppend : PopupType.chat,
            canSpeechToText: canSpeechToText,
            canRecall: canRecall,
            canQuote: canQuote,
            canCopy: canCopy,
            canCancelSpeechToText: canCancelSpeechToText,
            conversationIsSystem: conversationIsSystem)
        .then((value) {
      chatProvider.setIsLongPressing(false);
      if (context.mounted && value != null) {
        _handleMenuAction(context, value, canSpeechToText,
            canCancelSpeechToText, isBubbleAppend);
      }
    });
  }

  void _handleMenuAction(BuildContext context, String action,
      bool canSpeechToText, bool canCancelSpeechToText, bool isBubbleAppend) {
    // 根据 action 处理逻辑
    switch (action) {
      case 'copy':
        // 处理复制逻辑
        if (isBubbleAppend) {
          if (widget.message is RCIMIWVoiceMessage) {
            Clipboard.setData(ClipboardData(
                text: (widget.message as RCIMIWVoiceMessage)
                        .speechToTextInfo
                        ?.text ??
                    ''));
          }
        } else if (widget.message is RCIMIWTextMessage) {
          Clipboard.setData(ClipboardData(
              text: (widget.message as RCIMIWTextMessage).text ?? ''));
        } else if (widget.message is RCIMIWReferenceMessage) {
          Clipboard.setData(ClipboardData(
              text: (widget.message as RCIMIWReferenceMessage).text ?? ''));
        }

        break;
      case 'delete':
        // 处理删除逻辑
        context
            .read<RCKChatProvider>()
            .deleteMessage([widget.message], context);
        break;
      case 'quote':
        // 处理引用逻辑
        context
            .read<RCKMessageInputProvider>()
            .setReferenceMessage(widget.message);
        // 弹起键盘
        context
            .read<RCKMessageInputProvider>()
            .setInputType(RCIMIWMessageInputType.text);
        break;
      case 'multi':
        // 处理多选逻辑：进入多选并默认选中当前消息
        final chatProvider = context.read<RCKChatProvider>();
        chatProvider.setMultiSelectMode(true);
        chatProvider.toggleMessageSelection(widget.message, context);
        break;
      case 'forward':
        // 处理转发逻辑
        RCKChatProvider chatProvider = context.read<RCKChatProvider>();
        context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
        context.read<RCKVoiceRecordProvider>().cancelRecord();
        chatProvider.toggleMessageSelection(widget.message, context);
        chatProvider.saveScrollOffset();
        Navigator.pushNamed(context, '/forward', arguments: {
          'chatProvider': chatProvider,
        }).then((value) {
          chatProvider.setMultiSelectMode(false);
          chatProvider.jumpToScrollOffset();
        });
        break;
      case 'recall':
        // 处理转发逻辑
        context.read<RCKChatProvider>().recallMessage(widget.message, context);
        break;
      case 'speechToText':
        // 处理语音转文字逻辑
        if (widget.message is RCIMIWVoiceMessage) {
          if (canCancelSpeechToText || isBubbleAppend) {
            context
                .read<RCKChatProvider>()
                .removeSpeechToTextMessageIdVisible(widget.message.messageId!);
          } else if (canSpeechToText) {
            context
                .read<RCKChatProvider>()
                .voiceMessageToText(widget.message as RCIMIWVoiceMessage);
          }
        }
        break;
    }
  }
}
