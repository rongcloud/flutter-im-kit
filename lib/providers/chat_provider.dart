import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/providers/message_input_provider.dart';
import 'package:rongcloud_im_kit/utils/constants.dart';
import 'package:rongcloud_im_kit/views/chat/page/message_list_widget.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'engine_provider.dart';
import 'audio_player_provider.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

class RCKChatProvider extends ChangeNotifier {
  List<RCIMIWMessage> _messages = [];

  List<RCIMIWMessage> get messages => List.unmodifiable(_messages);

  late RCIMIWConversation _con;
  RCIMIWConversation get conversation => _con;

  bool _multiSelectMode = false; // 新增：多选模式标识
  bool get multiSelectMode => _multiSelectMode;

  final List<RCIMIWMessage> selectedMessages = []; // 新增：保存选中的消息

  List<RCIMIWMessage>? _unreadMentionedMessages;
  List<RCIMIWMessage>? get unreadMentionedMessages => _unreadMentionedMessages;

  final RCKEngineProvider engineProvider;
  final GlobalKey<RCKMessageListState> _messageListKey =
      GlobalKey<RCKMessageListState>();
  GlobalKey<RCKMessageListState> get messageListKey => _messageListKey;

  String? _conversationDraft;
  String? get conversationDraft => _conversationDraft;

  bool _isClearingUnread = false;
  bool _hasPendingClearUnread = false;

  bool _isLongPressing = false;
  bool get isLongPressing => _isLongPressing;

  RCIMIWConnectionStatus? get connectionStatus =>
      engineProvider.networkChangeNotifier.value;

  double _scrollOffset = 0;

  Set<int> _speechToTextMessageIdsVisible = {};

  Set<int> get speechToTextMessageIdsVisible => _speechToTextMessageIdsVisible;

  //界面上语音转文字已经展示过，未展示过的需要有动画
  List<int> _speechToTextMessageIdsHasShown = [];

  List<int> get speechToTextMessageIdsHasShown =>
      _speechToTextMessageIdsHasShown;

  RCKChatProvider({required this.engineProvider}) {
    engineProvider.receiveMessageNotifier.addListener(_onReceiveMessage);
    engineProvider.failedMessageSentNotifier.addListener(_onFailedMessageSent);
    engineProvider.recallMessageNotifier.addListener(_onRecallMessage);
    engineProvider.networkChangeNotifier.addListener(_onNetworkChange);
    engineProvider.speechToTextMessageNotifier
        .addListener(_onSpeechToTextCompleted);
    _initSpeechToTextUIInfo();
  }

  void _onNetworkChange() {
    notifyListeners();
  }

  void _onReceiveMessage() {
    final newMessage = engineProvider.receiveMessageNotifier.value;
    if (newMessage != null &&
        newMessage.conversationType == _con.conversationType &&
        newMessage.targetId == _con.targetId) {
      _messages.insert(_messages.length, newMessage);

      clearUnread();
      notifyListeners();

      // 操作移到下一帧
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messageListScrollToBottom();
      });
    }
  }

  void _onFailedMessageSent() {
    final failedMessage = engineProvider.failedMessageSentNotifier.value;
    if (failedMessage != null) {
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].messageId == failedMessage.messageId) {
          _messages[i] = failedMessage;
          break;
        }
      }
      notifyListeners();
    }
  }

  void _onRecallMessage() {
    final recallMessage = engineProvider.recallMessageNotifier.value;
    if (recallMessage != null &&
        recallMessage.conversationType == _con.conversationType &&
        recallMessage.targetId == _con.targetId) {
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].messageId == recallMessage.messageId) {
          _messages[i] = recallMessage;
          break;
        }
      }

      if (selectedMessages.isNotEmpty) {
        selectedMessages.removeWhere((msg) =>
            msg.messageId != null &&
            msg.messageId == recallMessage.messageId);
      }
      notifyListeners();
    }
  }

  void clearUnread() {
    if (_isClearingUnread) {
      _hasPendingClearUnread = true;
      return;
    }

    _isClearingUnread = true;
    RCIMIWConversation curCon = _con;
    engineProvider.engine?.clearUnreadCount(
        curCon.conversationType ?? RCIMIWConversationType.invalid,
        curCon.targetId ?? '',
        curCon.channelId,
        messages.last.sentTime ?? DateTime.now().millisecondsSinceEpoch,
        callback: IRCIMIWClearUnreadCountCallback(
      onUnreadCountCleared: (code) {
        _isClearingUnread = false;
        if (code == 0) {
          curCon.unreadCount = 0;
          notifyListeners();
        }
        engineProvider.engine?.syncConversationReadStatus(
            curCon.conversationType ?? RCIMIWConversationType.invalid,
            curCon.targetId ?? '',
            curCon.channelId,
            messages.last.sentTime ?? DateTime.now().millisecondsSinceEpoch,
            callback: IRCIMIWSyncConversationReadStatusCallback(
                onConversationReadStatusSynced: (code) {
          if (code == 0) {
            debugPrint('同步会话阅读状态成功');
          }
        }));
        // 更新总未读消息数
        engineProvider.updateTotalUnreadCount();

        // 如果有待处理的清除未读请求，执行一次
        if (_hasPendingClearUnread) {
          _hasPendingClearUnread = false;
          clearUnread();
        }
      },
    ));
  }

  void fetchUnreadMentiondMessage() {
    _unreadMentionedMessages = [];
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].mentionedInfo != null &&
          _messages[i].receivedStatus == RCIMIWReceivedStatus.unread) {
        _unreadMentionedMessages?.add(_messages[i]);
      }
    }
    notifyListeners();
  }

  void removeUnreadMentiondMessage(RCIMIWMessage removeMessage) {
    _unreadMentionedMessages?.remove(removeMessage);
    notifyListeners();
  }

  void initMessages(RCIMIWConversation con, {Function()? onSuccess}) {
    _con = con;
    RCIMIWMessageOperationPolicy policy =
        RCIMIWMessageOperationPolicy.localRemote;
    if (connectionStatus == RCIMIWConnectionStatus.networkUnavailable ||
        connectionStatus == RCIMIWConnectionStatus.unconnected ||
        connectionStatus == RCIMIWConnectionStatus.suspend ||
        connectionStatus == RCIMIWConnectionStatus.timeout ||
        connectionStatus == RCIMIWConnectionStatus.unknown) {
      policy = RCIMIWMessageOperationPolicy.local;
    }
    engineProvider.engine?.getMessages(
        con.conversationType ?? RCIMIWConversationType.invalid,
        con.targetId ?? '',
        con.channelId,
        0,
        RCIMIWTimeOrder.before,
        policy,
        20,
        callback: IRCIMIWGetMessagesCallback(
          onSuccess: (t) {
            // 将消息列表倒置
            _messages = t?.reversed.toList() ?? [];
            notifyListeners();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              messageListScrollToBottom();
            });
            onSuccess?.call();
            RCIMWrapperPlatform.instance.writeLog(
                'RCKChatProvider initMessages',
                '',
                0,
                'onSuccess t: ${t?.length}');
          },
          onError: (code) {
            RCIMWrapperPlatform.instance.writeLog(
                'RCKChatProvider initMessages', '', code ?? 0, 'onError');
          },
        ));
  }

  Future<void> addTextOrRefrenceMessage(String text,
      [RCIMIWMessage? referenceMessage, List<String>? mentionList]) async {
    RCIMIWMessage? message;
    if (referenceMessage != null) {
      message = await engineProvider.engine?.createReferenceMessage(
        _con.conversationType ?? RCIMIWConversationType.invalid,
        _con.targetId ?? '',
        _con.channelId,
        referenceMessage,
        text,
      );
    } else {
      message = await engineProvider.engine?.createTextMessage(
        _con.conversationType ?? RCIMIWConversationType.invalid,
        _con.targetId ?? '',
        _con.channelId,
        text,
      );
    }

    if (mentionList != null && mentionList.isNotEmpty) {
      RCIMIWMentionedType? type;
      if (mentionList.contains('All')) {
        // 如果mentionList中包含'id'为'All'的节点，则处理@所有成员的逻辑
        type = RCIMIWMentionedType.all;
      } else {
        type = RCIMIWMentionedType.part;
      }
      RCIMIWMentionedInfo mentionedInfo =
          RCIMIWMentionedInfo.create(type: type, userIdList: mentionList);
      message?.mentionedInfo = mentionedInfo;
    }

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> addVoiceMessage(String localPath, int duration) async {
    RCIMIWMediaMessage? message =
        await engineProvider.engine?.createVoiceMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      localPath,
      duration,
    );

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> addImageMessage(String localPath) async {
    RCIMIWMediaMessage? message =
        await engineProvider.engine?.createImageMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      localPath,
    );

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> addGifMessage(String localPath) async {
    RCIMIWMediaMessage? message = await engineProvider.engine?.createGIFMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      localPath,
    );

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> addSightMessage(String localPath, int duration,
      {BuildContext? context}) async {
    RCIMIWMediaMessage? message = await engineProvider.engine
        ?.createSightMessage(
            _con.conversationType ?? RCIMIWConversationType.invalid,
            _con.targetId ?? '',
            _con.channelId,
            localPath,
            duration);

    if (message != null) {
      if (context != null && context.mounted) {
        sendMessage(message, context: context);
      } else {
        sendMessage(message);
      }
    }
  }

  Future<void> addLocationMessage(double longitude, double latitude,
      String poiName, String thumbnailPath) async {
    RCIMIWLocationMessage? message = await engineProvider.engine
        ?.createLocationMessage(
            _con.conversationType ?? RCIMIWConversationType.invalid,
            _con.targetId ?? '',
            _con.channelId,
            longitude,
            latitude,
            poiName,
            thumbnailPath);

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> addFileMessage(String localPath) async {
    RCIMIWMediaMessage? message =
        await engineProvider.engine?.createFileMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      localPath,
    );

    if (message != null) {
      sendMessage(message);
    }
  }

  Future<void> recallMessage(
      RCIMIWMessage recallMessage, BuildContext context) async {
    stopPlayVoiceAndReference([recallMessage], context);
    await engineProvider.engine?.recallMessage(
      recallMessage,
      callback: IRCIMIWRecallMessageCallback(
        onMessageRecalled: (code, message) {
          if (code == 0) {
            for (var i = 0; i < messages.length; i++) {
              if (messages[i].messageId == message?.messageId) {
                _messages[i] = message!;
                break;
              }
            }
            notifyListeners();
          }
          RCIMWrapperPlatform.instance.writeLog('RCKChatProvider recallMessage',
              '', code ?? 0, 'onMessageRecalled: ${message?.messageId}');
        },
      ),
    );
  }

  Future<void> sendMessage(RCIMIWMessage sendMessage,
      {bool isResend = false,
      bool isForward = false,
      BuildContext? context}) async {
    if (sendMessage is RCIMIWMediaMessage && !isForward) {
      if (sendMessage.local != null) {
        await engineProvider.engine?.sendMediaMessage(sendMessage,
            listener: RCIMIWSendMediaMessageListener(
                onMediaMessageSaved: (message) {
                  _onMessageSaved(message, isResend: isResend);
                },
                onMediaMessageSending: (message, progress) {},
                onSendingMediaMessageCanceled: (message) {},
                onMediaMessageSent: (code, message) {
                  _onMessageSent(code, message,
                      isResend: isResend, context: context);
                }));
      }
    } else {
      await engineProvider.engine?.sendMessage(sendMessage,
          callback: RCIMIWSendMessageCallback(
            onMessageSaved: (message) {
              _onMessageSaved(message, isResend: isResend);
            },
            onMessageSent: (code, message) {
              _onMessageSent(code, message, isResend: isResend);
            },
          ));
    }
  }

  void _onMessageSaved(RCIMIWMessage? message, {bool isResend = false}) {
    // 保存成功，清空草稿
    clearDraft();

    // 保存成功，更新消息列表
    if (message != null && conversation.targetId == message.targetId) {
      if (!isResend) {
        _messages.insert(_messages.length, message); // 新消息插到顶部
      } else {
        for (int i = 0; i < _messages.length; i++) {
          if (_messages[i].messageId == message.messageId) {
            _messages[i] = message;
            break;
          }
        }
      }
      notifyListeners();

      if (!isResend) {
        // 操作移到下一帧
        WidgetsBinding.instance.addPostFrameCallback((_) {
          messageListScrollToBottom();
        });
      }
    }

    RCIMWrapperPlatform.instance.writeLog('RCKChatProvider _onMessageSaved', '',
        0, 'message: ${message?.messageId}');
  }

  void _onMessageSent(int? code, RCIMIWMessage? message,
      {bool isResend = false, BuildContext? context}) {
    // 发送成功，更新消息列表
    if (message != null && conversation.targetId == message.targetId) {
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].messageId == message.messageId) {
          _messages[i] = message;
          break;
        }
      }
      notifyListeners();
    }
    if (code != 0 && message != null && !isResend) {
      // 发送失败
      if (message.messageType == RCIMIWMessageType.sight) {
        if (context != null && context.mounted) {
          String errorMessage;

          switch (code) {
            case 34002:
              errorMessage = '小视频时间长度超出2分钟限制';
              break;
            case 34015:
              errorMessage = '视频压缩失败';
              break;
            case 34011:
              errorMessage = '视频上传失败';
              break;
            case 34018:
              errorMessage = '视频上传异常，文件不存在或大小为0';
              break;
            case 34019:
              errorMessage = '上传文件格式不支持';
              break;
            default:
              errorMessage = '错误码: $code';
              break;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        }
      }
      engineProvider.addFailedMessage(message);
      RCIMWrapperPlatform.instance.writeLog('RCKChatProvider _onMessageSent',
          '', code ?? 0, 'onMessageSent failed: ${message.messageId}');
    }

    if (code == 0 && message != null) {
      // 发送成功
      engineProvider.removeFailedMessage(message);
      RCIMWrapperPlatform.instance.writeLog('RCKChatProvider _onMessageSent',
          '', 0, 'onMessageSent success: ${message.messageId}');
    }
  }

  Future<void> deleteMessage(
      List<RCIMIWMessage> deleteMessage, BuildContext context) async {
    stopPlayVoiceAndReference(deleteMessage, context);
    await engineProvider.engine?.deleteMessages(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      deleteMessage,
      callback: IRCIMIWDeleteMessagesCallback(
        onMessagesDeleted: (code, messages) {
          if (code == 0) {
            for (var i = 0; i < messages!.length; i++) {
              for (var j = 0; j < _messages.length; j++) {
                if (_messages[j].messageId == messages[i].messageId) {
                  _messages.removeAt(j);
                }
              }
            }
            notifyListeners();
          }
          RCIMWrapperPlatform.instance.writeLog('RCKChatProvider deleteMessage',
              '', code ?? 0, 'onMessagesDeleted: ${messages?.length}');
        },
      ),
    );
  }

  // 将_downloadVoiceMessage改为公开方法，以便AudioPlayerProvider可以调用
  Future<void> downloadVoiceMessage(
      RCIMIWMediaMessage message, bool autoPlay, BuildContext? context) async {
    await engineProvider.engine?.downloadMediaMessage(message, listener:
        RCIMIWDownloadMediaMessageListener(
            onMediaMessageDownloaded: (int? code, RCIMIWMediaMessage? message) {
      if (code == 0 && message != null) {
        for (int i = 0; i < _messages.length; i++) {
          if (_messages[i].messageId == message.messageId) {
            _messages[i] = message;
            if (autoPlay && context != null && context.mounted) {
              // 下载完成后，使用AudioPlayerProvider播放
              final audioPlayerProvider =
                  context.read<RCKAudioPlayerProvider>();
              audioPlayerProvider.playVoiceMessage(message, context);
            }
            notifyListeners();
            break;
          }
        }
      }
    }));
  }

  Future<void> downloadMediaMessage(
    RCIMIWMediaMessage message, {
    Function(int? code, RCIMIWMediaMessage? message)? downloaded,
    Function(RCIMIWMediaMessage? message, int? progress)? downloading,
    Function(RCIMIWMediaMessage? message)? downloadCancel,
  }) async {
    await engineProvider.engine?.downloadMediaMessage(message,
        listener: RCIMIWDownloadMediaMessageListener(
          onMediaMessageDownloaded: (int? code, RCIMIWMediaMessage? message) {
            if (code == 0) {
              for (int i = 0; i < _messages.length; i++) {
                if (_messages[i].messageId == message?.messageId) {
                  _messages[i] = message!;
                  // 如果消息不是gif，则通知消息列表更新，因为gif会跳动
                  if (message is! RCIMIWGIFMessage) {
                    notifyListeners();
                  }
                  break;
                }
              }
            }
            downloaded?.call(code, message);
            RCIMWrapperPlatform.instance.writeLog(
                'RCKChatProvider downloadMediaMessage',
                '',
                code ?? 0,
                'onMediaMessageDownloaded: ${message?.messageId}');
          },
          onMediaMessageDownloading: (message, progress) {
            downloading?.call(message, progress);
          },
          onDownloadingMediaMessageCanceled: (message) {
            downloadCancel?.call(message);
            RCIMWrapperPlatform.instance.writeLog(
                'RCKChatProvider downloadMediaMessage',
                '',
                0,
                'onDownloadingMediaMessageCanceled: ${message?.messageId}');
          },
        ));
  }

  Future<void> cancelDownloadMediaMessage(
    RCIMIWMediaMessage message, {
    Function(RCIMIWMediaMessage? message)? downloadCancel,
  }) async {
    await engineProvider.engine?.cancelDownloadingMediaMessage(message,
        callback: IRCIMIWCancelDownloadingMediaMessageCallback(
      onCancelDownloadingMediaMessageCalled: (code, message) {
        downloadCancel?.call(message);
      },
    ));
  }

  void saveDraft(String draft) async {
    await engineProvider.engine?.saveDraftMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      draft,
      callback: IRCIMIWSaveDraftMessageCallback(
        onDraftMessageSaved: (code) {
          if (code == 0) {
            _con.draft = draft;
            notifyListeners();
          }
        },
      ),
    );
  }

  void clearDraft() async {
    await engineProvider.engine?.clearDraftMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      callback: IRCIMIWClearDraftMessageCallback(
        onDraftMessageCleared: (code) {
          if (code == 0) {
            _con.draft = null;
            notifyListeners();
          }
        },
      ),
    );
  }

  void getDraft() async {
    await engineProvider.engine?.getDraftMessage(
      _con.conversationType ?? RCIMIWConversationType.invalid,
      _con.targetId ?? '',
      _con.channelId,
      callback: IRCIMIWGetDraftMessageCallback(
        onSuccess: (draft) {
          _conversationDraft = draft;
          notifyListeners();
        },
        onError: (code) {},
      ),
    );
  }

  void toggleMessageSelection(RCIMIWMessage message, BuildContext context) {
    if (selectedMessages.contains(message)) {
      selectedMessages.remove(message);
    } else {
      if (selectedMessages.length >= 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('聊天记录选择不能超过100条'),
          ),
        );
        return;
      }
      selectedMessages.add(message);
    }
    notifyListeners();
  }

  void setMultiSelectMode(bool isMultiSelectMode) {
    _multiSelectMode = isMultiSelectMode;
    if (!isMultiSelectMode) {
      selectedMessages.clear();
    }
    notifyListeners();
  }

  Future<void> loadOlderMessages() async {
    final completer = Completer<void>();
    int lastSentTime = _messages.isNotEmpty
        ? (_messages.first.sentTime ?? DateTime.now().millisecondsSinceEpoch)
        : DateTime.now().millisecondsSinceEpoch;
    engineProvider.engine?.getMessages(
        _con.conversationType ?? RCIMIWConversationType.invalid,
        _con.targetId ?? '',
        _con.channelId,
        lastSentTime,
        RCIMIWTimeOrder.before,
        RCIMIWMessageOperationPolicy.localRemote,
        20,
        callback: IRCIMIWGetMessagesCallback(
          onSuccess: (t) {
            // 将消息列表倒置
            _messages.insertAll(0, t?.reversed.toList() ?? []);
            notifyListeners();
            completer.complete();
          },
          onError: (code) {
            completer.complete();
          },
        ));
    return completer.future;
  }

  void messageListScrollToBottom() {
    final messageListState = _messageListKey.currentState;
    if (messageListState != null) {
      messageListState.scrollToLatestMessage();
    }
  }

  void stopPlayVoiceAndReference(
      List<RCIMIWMessage> messages, BuildContext context) {
    for (var message in messages) {
      if (message.messageType == RCIMIWMessageType.voice) {
        final audioPlayerProvider = context.read<RCKAudioPlayerProvider>();
        if (audioPlayerProvider.currentPlayingMessageId ==
            message.messageId.toString()) {
          audioPlayerProvider.stopVoiceMessage();
        }
      }

      final messageInputProvider = context.read<RCKMessageInputProvider>();
      if (messageInputProvider.referenceMessage?.messageId ==
          message.messageId) {
        messageInputProvider.clearReferenceMessage();
      }
    }
  }

  void setIsLongPressing(bool isLongPressing) {
    _isLongPressing = isLongPressing;
  }

  void saveScrollOffset() {
    final messageListState = _messageListKey.currentState;
    if (messageListState != null) {
      _scrollOffset = messageListState.getScrollOffset();
    }
  }

  void jumpToScrollOffset() {
    final messageListState = _messageListKey.currentState;
    if (messageListState != null &&
        _scrollOffset != messageListState.getScrollOffset()) {
      messageListState.listJumpToScrollOffset(_scrollOffset);
    }
  }

  void _onSpeechToTextCompleted() {
    final speechToTextMessage =
        engineProvider.speechToTextMessageNotifier.value;
    if (speechToTextMessage != null) {
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].messageUId == speechToTextMessage.messageUId) {
          (_messages[i] as RCIMIWVoiceMessage).speechToTextInfo =
              speechToTextMessage.speechToTextInfo;
          if (speechToTextMessage.speechToTextInfo?.status ==
              RCIMIWSpeechToTextStatus.failed) {
            // final ctx = _messageListKey.currentContext;
            // if (ctx != null && speechToTextFailShowToast) {
            //   ScaffoldMessenger.of(ctx).showSnackBar(
            //     const SnackBar(content: Text('转文字失败，请稍后重试')),
            //   );
            // }
          }
          break;
        }
      }
      notifyListeners();
    }
  }

  Future<void> voiceMessageToText(RCIMIWVoiceMessage message) async {
    if (message.messageUId == null || message.messageId == null) {
      return;
    }
    engineProvider.engine?.requestSpeechToTextForMessage(message.messageUId!,
        callback: IRCIMIWOperationCallback(
          onSuccess: () {
            debugPrint('requestSpeechToTextForMessage success');
          },
          onError: (code) {
            debugPrint('requestSpeechToTextForMessage error: $code');
            for (int i = 0; i < _messages.length; i++) {
              if (_messages[i].messageId == message.messageId) {
                (_messages[i] as RCIMIWVoiceMessage).speechToTextInfo?.status =
                    RCIMIWSpeechToTextStatus.failed;
                final ctx = _messageListKey.currentContext;
                if (ctx != null) {
                  String errorMessage = '转文字失败，请稍后重试';
                  switch (code) {
                    case 30002:
                      errorMessage = '当前网络不可用，无法转文字，请检查网络设置后再试';
                      break;
                    case 35059:
                      errorMessage = '此语音消息格式不支持转文字功能';
                  }
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
                notifyListeners();
                break;
              }
            }
          },
        ));
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].messageId == message.messageId) {
        (_messages[i] as RCIMIWVoiceMessage).speechToTextInfo?.status =
            RCIMIWSpeechToTextStatus.converting;
        break;
      }
    }
    addSpeechToTextMessageIdVisible(message.messageId!);
    notifyListeners();
  }

  void addSpeechToTextMessageIdVisible(int messageId) {
    _speechToTextMessageIdsVisible.add(messageId);
    _saveSpeechToTextMessageIdsVisible();
    notifyListeners();
  }

  void removeSpeechToTextMessageIdVisible(int messageId) {
    _speechToTextMessageIdsVisible.remove(messageId);
    _saveSpeechToTextMessageIdsVisible();
    notifyListeners();
  }

  void addSpeechToTextMessageIdHasShown(int messageId) {
    if (_speechToTextMessageIdsHasShown.contains(messageId)) {
      return;
    }
    if (_speechToTextMessageIdsHasShown.length >= speechToTextShownCountCache) {
      _speechToTextMessageIdsHasShown.removeAt(0);
    }
    _speechToTextMessageIdsHasShown.add(messageId);
    _saveSpeechToTextMessageIdsHasShown();
  }

  Future<void> _initSpeechToTextUIInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('speechToTextMessageIdsVisible')) {
      _speechToTextMessageIdsVisible = prefs
              .getStringList('speechToTextMessageIdsVisible')
              ?.map(int.parse)
              .toSet() ??
          {};
    } else {
      prefs.setStringList('speechToTextMessageIdsVisible', []);
      _speechToTextMessageIdsVisible = {};
    }
    notifyListeners();

    if (prefs.containsKey('speechToTextMessageIdsHasShown')) {
      _speechToTextMessageIdsHasShown = prefs
              .getStringList('speechToTextMessageIdsHasShown')
              ?.map(int.parse)
              .toList() ??
          [];
    }
  }

  Future<void> _saveSpeechToTextMessageIdsVisible() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('speechToTextMessageIdsVisible',
        _speechToTextMessageIdsVisible.map((e) => e.toString()).toList());
  }

  Future<void> _saveSpeechToTextMessageIdsHasShown() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('speechToTextMessageIdsHasShown',
        _speechToTextMessageIdsHasShown.map((e) => e.toString()).toList());
  }

  @override
  void dispose() {
    engineProvider.receiveMessageNotifier.removeListener(_onReceiveMessage);
    engineProvider.failedMessageSentNotifier
        .removeListener(_onFailedMessageSent);
    engineProvider.recallMessageNotifier.removeListener(_onRecallMessage);
    engineProvider.networkChangeNotifier.removeListener(_onNetworkChange);
    engineProvider.speechToTextMessageNotifier
        .removeListener(_onSpeechToTextCompleted);
    super.dispose();
  }
}
