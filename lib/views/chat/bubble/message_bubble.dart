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
  }) : _anchorKey = GlobalKey();

  factory RCKMessageBubble.create({
    required RCIMIWMessage message,
    bool showTime = false,
    RCKBubbleConfig? config, // 新增：气泡配置参数
    Map<
            RCIMIWMessageType,
            RCKMessageBubble Function(
                {required RCIMIWMessage message,
                bool? showTime,
                RCKBubbleConfig? config})>?
        customChatItemBubbleBuilders,
    MessageTapCallback? onTap,
    MessageDoubleTapCallback? onDoubleTap,
    MessageLongPressCallback? onLongPress,
    MessageSwipeCallback? onSwipe,
  }) {
    RCKMessageBubble bubble;

    if (customChatItemBubbleBuilders != null &&
        customChatItemBubbleBuilders.containsKey(message.messageType)) {
      bubble = customChatItemBubbleBuilders[message.messageType]!(
          message: message, showTime: showTime, config: config);
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
              onSwipe: onSwipe);
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

  @override
  Widget build(BuildContext context) {
    if (widget.message.messageType == RCIMIWMessageType.nativeCustom ||
        widget.message.messageType == RCIMIWMessageType.nativeCustomMedia) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: kBubblePaddingVertical * 2),
        child: Align(
          alignment: widget.alignment ?? Alignment.center,
          child: widget.buildMessageContent(context, refName),
        ),
      );
    }
    final chatProvider = context.watch<RCKChatProvider>();
    // 根据多选模式决定是否显示选择器
    bool isMultiSelect = chatProvider.multiSelectMode;
    if (widget.message.messageType == RCIMIWMessageType.recall) {
      isMultiSelect = false;
    }
    bool isSelected = chatProvider.selectedMessages.contains(widget.message);
    bool isMe = widget.message.direction == RCIMIWMessageDirection.send;

    // 使用配置或默认值
    final effectiveConfig = widget.config ?? RCKBubbleConfig();
    final bubblePadding = effectiveConfig.padding;
    final bubbleMaxWidth =
        MediaQuery.of(context).size.width * kBubbleWidthRatio -
            kBubbleAvatarSize -
            2 * bubblePadding.horizontal;

    // 新增：根据消息状态构建状态指示器（仅对发送者生效）
    Widget? statusIndicator;
    if (isMe && widget.message.messageType != RCIMIWMessageType.recall) {
      if (widget.message.sentStatus == RCIMIWSentStatus.sending) {
        statusIndicator = Padding(
          padding: EdgeInsets.only(
              right: kBubbleStatusPadding, top: bubblePadding.vertical / 2),
          child: const RotatingImage(
            imagePath: 'messageSending.png',
            size: kBubbleStatusSize,
          ),
        );
      } else if (widget.message.sentStatus == RCIMIWSentStatus.failed) {
        statusIndicator = Padding(
          padding: EdgeInsets.only(
              right: kBubbleStatusPadding, top: bubblePadding.vertical / 2),
          child: GestureDetector(
            onTap: () => _handleRetry(context),
            child: ImageUtil.getImageWidget('messageSendFail.png',
                width: kBubbleStatusSize, height: kBubbleStatusSize),
          ),
        );
      }
    }

    Alignment alignment = Alignment.center;
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    bool withoutBubble = false;
    bool withoutName = false;
    // 确定是否需要气泡
    if (widget.message.messageType == RCIMIWMessageType.image ||
        widget.message.messageType == RCIMIWMessageType.gif ||
        widget.message.messageType == RCIMIWMessageType.sight ||
        widget.message.messageType == RCIMIWMessageType.file) {
      withoutBubble = true;
    }

    // 确定对齐方式
    if (widget.message.messageType == RCIMIWMessageType.unknown ||
        widget.message.messageType == RCIMIWMessageType.recall) {
      alignment = Alignment.center;
      mainAxisAlignment = MainAxisAlignment.center;
      crossAxisAlignment = CrossAxisAlignment.center;
      withoutName = true;
    } else {
      alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
      mainAxisAlignment =
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
      crossAxisAlignment =
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    }

    // 用类属性覆盖临时变量
    if (widget.alignment != null) {
      alignment = widget.alignment!;
    }

    if (widget.withoutBubble != null) {
      withoutBubble = widget.withoutBubble!;
    }
    if (widget.withoutName != null) {
      withoutName = widget.withoutName!;
    }

    Widget avatar = Padding(
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

    final haveName = customBubbleInfo != null &&
        widget.message.conversationType == RCIMIWConversationType.group;

    // 构建气泡带名字
    Widget bubble = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        haveName && !withoutName
            ? Text(
                customBubbleInfo?.name ?? customBubbleInfo?.id ?? '',
                style: TextStyle(
                    color: RCKThemeProvider().themeColor.textPrimary,
                    fontSize: kBubbleNameFontSize),
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

    bubble = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (!isMe && !withoutName) avatar,
        Flexible(child: bubble),
        if (isMe && !withoutName) avatar,
      ],
    );

    if (isMultiSelect) {
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

      // 直接在Row中应用左侧填充，避免多层嵌套
      bubble = Row(
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

    // 添加侧滑支持
    Widget messageContainer = widget.onSwipe != null
        ? _buildSwipeableContainer(bubble, context)
        : bubble;

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
            // 多选模式和非多选模式使用不同的布局
            if (isMultiSelect)
              // 多选模式下不使用对齐，保持左对齐
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
              // 非多选模式下使用原来的对齐和约束
              Align(
                alignment: alignment,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        kBubbleWidthRatio, // 限制最大宽度为屏幕70%
                  ),
                  child: messageContainer,
                ),
              ),
          ],
        ));
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

  void _showContextMenu(BuildContext context) {
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
    showPopupMenu(context, PopupType.chat,
            canRecall: canRecall,
            canQuote: canQuote,
            canCopy: canCopy,
            conversationIsSystem: conversationIsSystem)
        .then((value) {
      chatProvider.setIsLongPressing(false);
      if (context.mounted && value != null) {
        _handleMenuAction(context, value);
      }
    });
  }

  void _handleMenuAction(BuildContext context, String action) {
    // 根据 action 处理逻辑
    switch (action) {
      case 'copy':
        // 处理复制逻辑
        if (widget.message is RCIMIWTextMessage) {
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
        break;
      case 'multi':
        // 处理多选逻辑
        context.read<RCKChatProvider>().setMultiSelectMode(true);
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
    }
  }
}
