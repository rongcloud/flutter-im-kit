import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../utils/time_util.dart';
import '../bubble/message_callbacks.dart';

class RCKMessageList extends StatefulWidget {
  // 自定义生成器参数
  final Map<
      RCIMIWMessageType,
      RCKMessageBubble Function(
          {required RCIMIWMessage message,
          bool? showTime,
          RCKBubbleConfig? config})>? customChatItemBubbleBuilders;

  /// 吸顶区域构建器，默认为null（不显示）
  final Widget Function(BuildContext context)? stickyHeaderBuilder;

  /// 气泡配置
  final RCKBubbleConfig? bubbleConfig;

  /// 消息单击回调
  final MessageTapCallback? onMessageTap;

  /// 消息双击回调
  final MessageDoubleTapCallback? onMessageDoubleTap;

  /// 消息长按回调
  final MessageLongPressCallback? onMessageLongPress;

  /// 消息侧滑回调
  final MessageSwipeCallback? onMessageSwipe;

  const RCKMessageList({
    super.key,
    this.customChatItemBubbleBuilders,
    this.stickyHeaderBuilder,
    this.bubbleConfig,
    this.onMessageTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageSwipe,
  });

  @override
  RCKMessageListState createState() => RCKMessageListState();
}

class RCKMessageListState extends State<RCKMessageList> {
  late AutoScrollController _autoScrollController;

  // 添加一个状态变量，控制是否可以点击
  bool _canInteract = false;

  @override
  void initState() {
    super.initState();
    _autoScrollController = AutoScrollController();

    // 设置延迟，300毫秒后允许点击
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _canInteract = true;
        });
      }
    });
  }

  // 滚动到最新消息
  Future<void> scrollToLatestMessage({bool? noAnimation}) async {
    final messages = context.read<RCKChatProvider>().messages;
    if (_autoScrollController.hasClients &&
        !_autoScrollController.isAutoScrolling) {
      if (noAnimation ?? false) {
        // 判断内容是否超过一屏幕
        bool isContentOverflowing =
            _autoScrollController.position.maxScrollExtent > 0;
        if (isContentOverflowing) {
          _autoScrollController.scrollToIndex(
            messages.length,
            preferPosition: AutoScrollPosition.end,
            duration: const Duration(milliseconds: 1),
          );
        }
      } else {
        await _autoScrollController.scrollToIndex(
          messages.length,
          preferPosition: AutoScrollPosition.end,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
  }

  double getScrollOffset() {
    return _autoScrollController.offset;
  }

  listJumpToScrollOffset(double offset) {
    if (_autoScrollController.hasClients) {
      _autoScrollController.jumpTo(offset);
    }
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<RCKChatProvider>();
    final oldCount = provider.messages.length;
    await provider.loadOlderMessages();
    final newCount = provider.messages.length - oldCount;
    if (newCount > 0) {
      // 滚动到新加载的历史消息的最后一条（即newCount-1位置）
      await _autoScrollController.scrollToIndex(newCount - 1,
          preferPosition: AutoScrollPosition.begin,
          duration: const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<RCKChatProvider>();
    final messages = chatProvider.messages;

    return Stack(
      children: [
        AbsorbPointer(
          // 使用AbsorbPointer根据_canInteract状态决定是否拦截点击事件
          absorbing: !_canInteract,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              controller: _autoScrollController,
              slivers: [
                // 消息列表
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final message = messages[index];
                      final bool showTime = index == 0 ||
                          TimeUtil.shouldShowTime(message, messages[index - 1]);
                      return VisibilityDetector(
                        key: Key('message_$index'),
                        onVisibilityChanged: (VisibilityInfo info) {
                          if (info.visibleFraction >= 0.5) {
                            // 如果消息属于未读@消息，则移除
                            final foundIndex = chatProvider
                                .unreadMentionedMessages
                                ?.indexWhere((msg) =>
                                    msg.messageId == message.messageId);
                            if (foundIndex != -1 &&
                                foundIndex != null &&
                                chatProvider.unreadMentionedMessages != null) {
                              chatProvider.removeUnreadMentiondMessage(
                                  chatProvider
                                      .unreadMentionedMessages![foundIndex]);
                            }
                          }
                        },
                        child: AutoScrollTag(
                          key: ValueKey(index),
                          controller: _autoScrollController,
                          index: index,
                          child: Padding(
                            // 消息列表顶部和底部留白
                            padding: EdgeInsets.only(
                                top: index == 0 ? 10 : 0,
                                bottom: index == messages.length - 1 ? 10 : 0),
                            child: RCKMessageBubble.create(
                              message: message,
                              showTime: showTime,
                              config: widget.bubbleConfig,
                              customChatItemBubbleBuilders:
                                  widget.customChatItemBubbleBuilders,
                              onTap: widget.onMessageTap,
                              onDoubleTap: widget.onMessageDoubleTap,
                              onLongPress: widget.onMessageLongPress,
                              onSwipe: widget.onMessageSwipe,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: messages.length,
                  ),
                ),

                // 添加吸顶区域（如果提供了构建器）
                if (widget.stickyHeaderBuilder != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyHeaderDelegate(
                      child: widget.stickyHeaderBuilder!(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 右上角悬浮按钮，根据 unreadMentionedMessages 数量显示
        if (chatProvider.unreadMentionedMessages?.isNotEmpty ?? false)
          Positioned(
            top: 20,
            right: 20,
            child: AbsorbPointer(
              // 快捷跳转按钮也需要控制点击状态
              absorbing: !_canInteract,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: .8),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final targetMessage =
                      chatProvider.unreadMentionedMessages!.last;
                  int? messageId = targetMessage.messageId;
                  final index = chatProvider.messages
                      .indexWhere((msg) => msg.messageId == messageId);
                  if (index != -1) {
                    _autoScrollController.scrollToIndex(
                      index,
                      preferPosition: AutoScrollPosition.begin,
                      duration: const Duration(milliseconds: 100),
                    );
                  }
                },
                child: Text(
                    "有人@你(${chatProvider.unreadMentionedMessages?.length.toString()})"),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _autoScrollController.dispose();
    super.dispose();
  }
}

/// 吸顶区域代理类
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyHeaderDelegate({
    required this.child,
    this.height = 50.0,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
