import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../utils/time_util.dart';
import '../bubble/message_callbacks.dart';

class RCKMessageList extends StatefulWidget {
  // 自定义生成器参数
  final Map<RCIMIWMessageType, CustomChatItemBubbleBuilder>?
      customChatItemBubbleBuilders;

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

  /// 消息追加气泡点击回调
  final MessageTapCallback? onMessageAppendBubbleTap;

  /// 消息追加气泡长按回调
  final MessageLongPressCallback? onMessageAppendBubbleLongPress;

  const RCKMessageList({
    super.key,
    this.customChatItemBubbleBuilders,
    this.stickyHeaderBuilder,
    this.bubbleConfig,
    this.onMessageTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageSwipe,
    this.onMessageAppendBubbleTap,
    this.onMessageAppendBubbleLongPress,
  });

  @override
  RCKMessageListState createState() => RCKMessageListState();
}

class RCKMessageListState extends State<RCKMessageList> {
  // scrollable_positioned_list 控制器
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  // 添加一个状态变量，控制是否可以点击
  bool _canInteract = false;

  // 合并滚动请求：同一帧仅执行最后一次
  bool _scrollToBottomCoalesced = false;
  bool _pendingScrollToBottom = false;
  static const int _adjustRetryLimit = 5;

  @override
  void initState() {
    super.initState();

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
  Future<void> scrollToLatestMessage() async {
    // 记录本帧需要滚动到底部，并以最后一次请求的 noAnimation 为准
    _pendingScrollToBottom = true;

    // 若已安排本帧执行，直接返回（帧末统一处理最新状态）
    if (_scrollToBottomCoalesced) return;
    _scrollToBottomCoalesced = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scrollToBottomCoalesced = false;

      // 若期间被取消或无需滚动，直接返回
      if (!_pendingScrollToBottom) return;
      _pendingScrollToBottom = false; // 消耗本帧的滚动请求

      final messages = context.read<RCKChatProvider>().messages;
      if (!_itemScrollController.isAttached || messages.isEmpty) return;

      final int lastIndex = messages.length - 1;
      _itemScrollController.jumpTo(index: lastIndex, alignment: 0.0);
      _scheduleAdjustLastItem(lastIndex, _adjustRetryLimit);
    });
  }

  void _scheduleAdjustLastItem(int lastIndex, int retriesLeft) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_itemScrollController.isAttached) return;

      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) {
        if (retriesLeft > 0) {
          _scheduleAdjustLastItem(lastIndex, retriesLeft - 1);
        }
        return;
      }

      ItemPosition? targetPosition;
      for (final pos in positions) {
        if (pos.index == lastIndex) {
          targetPosition = pos;
          break;
        }
      }

      if (targetPosition == null) {
        if (retriesLeft > 0) {
          _scheduleAdjustLastItem(lastIndex, retriesLeft - 1);
        }
        return;
      }

      const double kAlignmentTolerance = 0.01;
      if ((targetPosition.itemTrailingEdge - 1.0).abs() <=
          kAlignmentTolerance) {
        return;
      }

      _applyLastItemAlignment(lastIndex, targetPosition);

      if (retriesLeft > 0) {
        _scheduleAdjustLastItem(lastIndex, retriesLeft - 1);
      }
    });
  }

  void _applyLastItemAlignment(int lastIndex, ItemPosition targetPosition) {
    final double itemHeightFraction =
        (targetPosition.itemTrailingEdge - targetPosition.itemLeadingEdge);
    final double desiredAlignment = (1.0 - itemHeightFraction).clamp(0.0, 1.0);

    _itemScrollController.jumpTo(
      index: lastIndex,
      alignment: desiredAlignment,
    );
  }

  // 用 index+alignment 编码/解码的方式，保持 Provider 接口不改
  double getScrollOffset() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return 0.0;
    // 选择可见区域内 itemLeadingEdge >= 0 的最靠上的一项
    final visible = positions.where((p) => p.itemLeadingEdge >= 0).toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    final first = visible.isNotEmpty
        ? visible.first
        : (positions.toList()..sort((a, b) => a.index.compareTo(b.index)))
            .first;
    final double alignment = first.itemLeadingEdge.clamp(0.0, 1.0);
    return first.index + alignment; // 编码
  }

  void listJumpToScrollOffset(double offset) {
    if (!_itemScrollController.isAttached) return;
    final int index = offset.floor();
    double alignment = offset - index;
    if (alignment < 0.0) alignment = 0.0;
    if (alignment > 1.0) alignment = 1.0;
    _itemScrollController.jumpTo(index: index, alignment: alignment);
  }

  Future<void> _handleRefresh() async {
    final provider = context.read<RCKChatProvider>();

    // 1) 记录当前首个可见项 index + alignment（0 顶部 ~ 1 底部）
    int firstVisibleIndex = 0;
    double firstAlignment = 0.0;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final visible = positions.where((p) => p.itemLeadingEdge >= 0).toList()
        ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
      final first = visible.isNotEmpty
          ? visible.first
          : (positions.toList()..sort((a, b) => a.index.compareTo(b.index)))
              .first;
      firstVisibleIndex = first.index;
      firstAlignment = first.itemLeadingEdge.clamp(0.0, 1.0);
    }

    final int oldCount = provider.messages.length;

    // 2) 头部加载
    await provider.loadOlderMessages();

    // 3) 恢复到原首个可见项（新 index = oldIndex + insertedCount），保持 alignment 不变
    final int inserted = provider.messages.length - oldCount;
    if (inserted > 0 && _itemScrollController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_itemScrollController.isAttached) return;
        _itemScrollController.jumpTo(
          index: firstVisibleIndex + inserted,
          alignment: firstAlignment,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        context.select<RCKChatProvider, List<RCIMIWMessage>>((p) => p.messages);

    return Stack(
      children: [
        AbsorbPointer(
          // 使用AbsorbPointer根据_canInteract状态决定是否拦截点击事件
          absorbing: !_canInteract,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ScrollablePositionedList.builder(
                itemCount: messages.length,
                itemScrollController: _itemScrollController,
                itemPositionsListener: _itemPositionsListener,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final bool showTime = index == 0 ||
                      TimeUtil.shouldShowTime(message, messages[index - 1]);
                  return VisibilityDetector(
                    key: Key('message_${message.messageId ?? index}'),
                    onVisibilityChanged: (VisibilityInfo info) {
                      if (info.visibleFraction >= 0.5) {
                        // 如果消息属于未读@消息，则移除（使用 read 避免触发重建依赖）
                        final provider = context.read<RCKChatProvider>();
                        final list = provider.unreadMentionedMessages;
                        final idx = list?.indexWhere(
                            (msg) => msg.messageId == message.messageId);
                        if (idx != null && idx != -1 && list != null) {
                          provider.removeUnreadMentiondMessage(list[idx]);
                        }
                      }
                    },
                    child: RCKMessageBubble.create(
                      context: context,
                      message: message,
                      showTime: showTime,
                      config: widget.bubbleConfig,
                      customChatItemBubbleBuilders:
                          widget.customChatItemBubbleBuilders,
                      onTap: widget.onMessageTap,
                      onDoubleTap: widget.onMessageDoubleTap,
                      onLongPress: widget.onMessageLongPress,
                      onSwipe: widget.onMessageSwipe,
                      onAppendBubbleTap: widget.onMessageAppendBubbleTap,
                      onAppendBubbleLongPress:
                          widget.onMessageAppendBubbleLongPress,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // 右上角悬浮按钮：用 Selector 降低重建范围
        Selector<RCKChatProvider, int>(
          selector: (_, p) => p.unreadMentionedMessages?.length ?? 0,
          builder: (context, unreadCount, _) {
            if (unreadCount <= 0) return const SizedBox.shrink();
            return Positioned(
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
                    final provider = context.read<RCKChatProvider>();
                    final targetMessage =
                        provider.unreadMentionedMessages!.last;
                    int? messageId = targetMessage.messageId;
                    final index = provider.messages
                        .indexWhere((msg) => msg.messageId == messageId);
                    if (index != -1 && _itemScrollController.isAttached) {
                      _itemScrollController.scrollTo(
                        index: index,
                        alignment: 0.0,
                        duration: const Duration(milliseconds: 100),
                      );
                    }
                  },
                  child: Text("有人@你($unreadCount)"),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// 吸顶区域代理类（已不使用 SliverPinned，保留以兼容老接口）
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
