import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/models/chat_profile_info.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

import 'chat_provider.dart';

class RCKForwardProvider extends ChangeNotifier {
  List<RCIMIWConversation> conversationsToForward = []; // 现有聊天列表
  List<RCIMIWMessage> messagesToForward = []; // 待转发的消息

  RCKChatProvider? _chatProvider;
  List<RCKChatProfileInfo> chatProfileInfos = [];

  CustomInfoProvider? customInfoProvider;
  BuildContext? context;

  bool _isLoadingMore = false;
  int _currentFetchTime = 0;
  static const int _pageSize = 50;

  RCKForwardProvider(RCKChatProvider? chatProvider) {
    _chatProvider = chatProvider;
    messagesToForward =
        List<RCIMIWMessage>.from(chatProvider?.selectedMessages ?? []);
    _loadMoreConversations(chatProvider);
  }

  void _loadMoreConversations(RCKChatProvider? chatProvider) {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    chatProvider?.engineProvider.engine?.getConversations([
      RCIMIWConversationType.private,
      RCIMIWConversationType.group,
      RCIMIWConversationType.chatroom,
      RCIMIWConversationType.system
    ], null, _currentFetchTime, _pageSize,
        callback: IRCIMIWGetConversationsCallback(onSuccess: (t) {
          if (t != null && t.isNotEmpty) {
            conversationsToForward.addAll(t);
            // 比较t中所有会话的时间，找到最小的
            int minOperationTime = t.fold(
                t.first.operationTime ?? 0,
                (previousValue, conversation) =>
                    (conversation.operationTime ?? 0) < previousValue
                        ? conversation.operationTime ?? 0
                        : previousValue);

            // 更新当前获取时间为最小操作时间
            if (minOperationTime > 0) {
              _currentFetchTime = minOperationTime;
            }
            _isLoadingMore = false;
            notifyListeners();
            // 如果返回的数量等于页面大小，说明可能还有更多数据
            if (t.length == _pageSize) {
              _loadMoreConversations(chatProvider);
            } else {
              if (customInfoProvider != null &&
                  context != null &&
                  context!.mounted) {
                getChatProfileInfos(context!, customInfoProvider!);
              }
            }
          } else {
            _isLoadingMore = false;
            notifyListeners();
          }
        }, onError: (code) {
          _isLoadingMore = false;
          notifyListeners();
        }));
  }

  void setCustomInfoProvider(
      BuildContext context, CustomInfoProvider customInfoProvider) {
    this.context = context;
    this.customInfoProvider = customInfoProvider;
    if (conversationsToForward.isNotEmpty) {
      getChatProfileInfos(context, customInfoProvider);
    }
  }

  Future<void> getChatProfileInfos(
      BuildContext context, CustomInfoProvider customInfoProvider) async {
    for (int i = 0; i < conversationsToForward.length; i++) {
      RCKChatProfileInfo chatProfileInfo = await customInfoProvider(
          message: null, conversation: conversationsToForward[i]);
      chatProfileInfos.add(chatProfileInfo);
    }
    notifyListeners();
  }

  Future<void> forwardMessages(
      RCIMIWConversation forwardConversation, BuildContext context) async {
    String targetId = forwardConversation.targetId ?? '';
    String? channelId = forwardConversation.channelId;
    RCIMIWConversationType conversationType =
        forwardConversation.conversationType ?? RCIMIWConversationType.invalid;

    if (_chatProvider == null) return;

    RCKChatProvider chatProvider = _chatProvider!;
    for (var message in messagesToForward) {
      switch (message.messageType) {
        case RCIMIWMessageType.text:
          {
            RCIMIWTextMessage? forwardMsg = RCIMIWTextMessage.fromJson(
                (message as RCIMIWTextMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.voice:
          {
            RCIMIWVoiceMessage? forwardMsg = RCIMIWVoiceMessage.fromJson(
                (message as RCIMIWVoiceMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.image:
          {
            RCIMIWImageMessage? forwardMsg = RCIMIWImageMessage.fromJson(
                (message as RCIMIWImageMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.gif:
          {
            RCIMIWGIFMessage? forwardMsg = RCIMIWGIFMessage.fromJson(
                (message as RCIMIWGIFMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }

        case RCIMIWMessageType.file:
          {
            RCIMIWFileMessage? forwardMsg = RCIMIWFileMessage.fromJson(
                (message as RCIMIWFileMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.reference:
          {
            RCIMIWReferenceMessage? forwardMsg = RCIMIWReferenceMessage
                .fromJson((message as RCIMIWReferenceMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }

        case RCIMIWMessageType.sight:
          {
            RCIMIWSightMessage? forwardMsg = RCIMIWSightMessage.fromJson(
                (message as RCIMIWSightMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.nativeCustom:
          {
            RCIMIWNativeCustomMessage? forwardMsg = RCIMIWNativeCustomMessage
                .fromJson((message as RCIMIWNativeCustomMessage).toJson())
              ..messageId = null
              ..targetId = targetId
              ..channelId = channelId
              ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        case RCIMIWMessageType.nativeCustomMedia:
          {
            RCIMIWNativeCustomMediaMessage? forwardMsg =
                RCIMIWNativeCustomMediaMessage.fromJson(
                    (message as RCIMIWNativeCustomMediaMessage).toJson())
                  ..messageId = null
                  ..targetId = targetId
                  ..channelId = channelId
                  ..conversationType = conversationType;

            chatProvider.sendMessage(forwardMsg, isForward: true);
            break;
          }
        // 根据需要增加其他消息类型的转发逻辑
        default:
          {
            // 不支持的消息类型，可跳过或显示提示
            break;
          }
      }
    }
  }
}
