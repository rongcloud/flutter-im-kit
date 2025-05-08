import 'package:flutter/material.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';
import 'engine_provider.dart';

typedef ConversationWidgetBuilder = Widget Function(
    RCIMIWConversation conversation);

typedef ConversationListItemOnTap = Function(
    RCIMIWConversation conversation, int index, BuildContext context);

class RCKConvoProvider with ChangeNotifier {
  List<RCIMIWConversation> _conversations = [];
  bool _isFetching = false;
  bool _isLoadingMore = false;
  int _currentFetchTime = 0;
  static const int _pageSize = 50;

  final bool isMainPage;

  int _longPressIndex = -1;
  int get longPressIndex => _longPressIndex;

  bool _isLongPressing = false;
  bool get isLongPressing => _isLongPressing;

  final RCKEngineProvider engineProvider;

  RCIMIWConnectionStatus? get connectionStatus =>
      engineProvider.networkChangeNotifier.value;

  final ScrollController scrollController = ScrollController();
  double _lastScrollOffset = 0;
  double _lastContentSize = 0;

  String lastUserId = '';

  RCKConvoProvider({required this.isMainPage, required this.engineProvider}) {
    engineProvider.receiveMessageNotifier.addListener(_onReceiveMessage);
    engineProvider.networkChangeNotifier.addListener(_onNetworkChange);
    engineProvider.failedMessageSentNotifier.addListener(_onFailedMessageSent);
    engineProvider.conversationStatus.addListener(_onConversationStatusChange);
    engineProvider.recallMessageNotifier.addListener(_onRecallMessage);
    engineProvider.readClearTargetId.addListener(_onReadClearTargetId);
    // 监听当前用户ID变化
    lastUserId = engineProvider.currentUserId;
    engineProvider.addListener(_onUserIdChange);
  }

  void _onUserIdChange() {
    // 只有当用户ID发生变化时才处理
    if (lastUserId != engineProvider.currentUserId) {
      lastUserId = engineProvider.currentUserId;
      if (lastUserId.isNotEmpty) {
        // 当用户ID变化且不为空时，可以在这里处理相关逻辑
        initConversations();
      }
    }
  }

  void _onReceiveMessage() {
    //判断对话是否免打扰
    final message = engineProvider.receiveMessageNotifier.value;
    bool isBlocked = false;
    for (var conversation in _conversations) {
      if (conversation.conversationType == message?.conversationType &&
          conversation.targetId == message?.targetId &&
          conversation.channelId == message?.channelId) {
        if (conversation.notificationLevel ==
            RCIMIWPushNotificationLevel.blocked) {
          isBlocked = true;
        }
      }
    }
    if (!isBlocked && message != null) {
      engineProvider.showLocalNotification(message);
    }

    initConversations();
  }

  void _onNetworkChange() {
    notifyListeners();
  }

  void _onFailedMessageSent() {
    initConversations();
  }

  void _onConversationStatusChange() {
    initConversations();
  }

  void _onRecallMessage() {
    initConversations();
  }

  void _onReadClearTargetId() {
    initConversations();
  }

  void setLongPressIndex(int index) {
    if (index < 0) {
      return;
    }
    _longPressIndex = index;
    _isLongPressing = true;
    notifyListeners();
  }

  void resetLongPressIndex() {
    _longPressIndex = -1;
    _isLongPressing = false;
    notifyListeners();
  }

  List<RCIMIWConversation> get conversations => _conversations;

  RCIMIWConversation? currentSelectedConversation;
  void initConversations() {
    if (_isFetching) return;
    _isFetching = true;
    _currentFetchTime = 0;
    _loadMoreConversations();
  }

  void _loadMoreConversations({bool? firstLoad}) {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    if (scrollController.hasClients) {
      _lastScrollOffset = scrollController.offset;
      _lastContentSize = scrollController.position.maxScrollExtent;
    }

    bool isFirstLoadInFetch = firstLoad ?? true;

    engineProvider.engine?.getConversations([
      RCIMIWConversationType.private,
      RCIMIWConversationType.group,
      RCIMIWConversationType.chatroom,
      RCIMIWConversationType.system
    ], null, _currentFetchTime, _pageSize,
        callback: IRCIMIWGetConversationsCallback(onSuccess: (t) {
          if (t != null && t.isNotEmpty) {
            if (isFirstLoadInFetch) {
              debugPrint(
                  'GetConversations onSuccess: ${t.length} _conversations = t;');
              _conversations = t;
            } else {
              debugPrint(
                  'GetConversations onSuccess: ${t.length} _conversations.addAll(t);');
              _conversations.addAll(t);
            }
            int minOperationTime = t.fold(
                t.first.operationTime ?? 0,
                (previousValue, conversation) =>
                    (conversation.operationTime ?? 0) < previousValue
                        ? conversation.operationTime ?? 0
                        : previousValue);

            if (minOperationTime > 0) {
              _currentFetchTime = minOperationTime;
            }
            _isLoadingMore = false;
            notifyListeners();

            if (scrollController.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_lastContentSize > 0 &&
                    scrollController.position.maxScrollExtent > 0) {
                  try {
                    if (scrollController.position.maxScrollExtent >
                        _lastContentSize) {
                      scrollController.jumpTo(_lastScrollOffset);
                    }
                  } catch (e) {
                    debugPrint('恢复滚动位置时出错: $e');
                  }
                }
              });
            }

            if (t.length == _pageSize) {
              _loadMoreConversations(firstLoad: false);
            } else {
              _isFetching = false;
            }
          } else {
            _isLoadingMore = false;
            _isFetching = false;
            notifyListeners();
          }
          RCIMWrapperPlatform.instance.writeLog(
              'RCKConvoProvider getConversations onSuccess',
              'initConversations',
              0,
              'isFetching: $_isFetching, isLoadingMore: $_isLoadingMore, _currentFetchTime: $_currentFetchTime, _pageSize: $_pageSize');
        }, onError: (code) {
          _isLoadingMore = false;
          _isFetching = false;
          notifyListeners();
          RCIMWrapperPlatform.instance.writeLog(
              'RCKConvoProvider getConversations onError',
              'initConversations',
              code ?? 0,
              'isFetching: $_isFetching, isLoadingMore: $_isLoadingMore, _currentFetchTime: $_currentFetchTime, _pageSize: $_pageSize');
        }));

    engineProvider.updateTotalUnreadCount();
  }

  void selectConversation(RCIMIWConversation conversation) {
    currentSelectedConversation = conversation;
    notifyListeners();
  }

  void popConversation() {
    currentSelectedConversation = null;
    initConversations();
    notifyListeners();
  }

  void setConversations(List<RCIMIWConversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  void pinConversation(int index) {
    engineProvider.engine?.changeConversationTopStatus(
        _conversations[index].conversationType ??
            RCIMIWConversationType.invalid,
        _conversations[index].targetId ?? '',
        _conversations[index].channelId,
        !(_conversations[index].top ?? false),
        callback: IRCIMIWChangeConversationTopStatusCallback(
      onConversationTopStatusChanged: (int? code) {
        initConversations();
      },
    ));
  }

  void removeConversation(int index) {
    engineProvider.engine?.removeConversation(
        _conversations[index].conversationType ??
            RCIMIWConversationType.invalid,
        _conversations[index].targetId ?? '',
        _conversations[index].channelId,
        callback: IRCIMIWRemoveConversationCallback(
      onConversationRemoved: (int? code) {
        initConversations();
      },
    ));
  }

  void blockConversation(int index) {
    engineProvider.engine?.changeConversationNotificationLevel(
        _conversations[index].conversationType ??
            RCIMIWConversationType.invalid,
        _conversations[index].targetId ?? '',
        _conversations[index].channelId,
        _conversations[index].notificationLevel ==
                RCIMIWPushNotificationLevel.blocked
            ? RCIMIWPushNotificationLevel.none
            : RCIMIWPushNotificationLevel.blocked,
        callback: IRCIMIWChangeConversationNotificationLevelCallback(
            onConversationNotificationLevelChanged: (int? code) {
      initConversations();
    }));
  }

  @override
  void dispose() {
    engineProvider.receiveMessageNotifier.removeListener(_onReceiveMessage);
    engineProvider.networkChangeNotifier.removeListener(_onNetworkChange);
    engineProvider.failedMessageSentNotifier
        .removeListener(_onFailedMessageSent);
    engineProvider.conversationStatus
        .removeListener(_onConversationStatusChange);
    engineProvider.recallMessageNotifier.removeListener(_onRecallMessage);
    engineProvider.readClearTargetId.removeListener(_onReadClearTargetId);
    engineProvider.removeListener(_onUserIdChange);
    scrollController.dispose();
    super.dispose();
  }
}
