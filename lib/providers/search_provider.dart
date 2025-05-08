import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

// 新增的 SearchResult 数据结构
class SearchResult {
  final RCIMIWTextMessage message;
  final RCIMIWConversation conversation;
  SearchResult({required this.message, required this.conversation});
}

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<SearchResult> _results = []; // 修改结果类型

  String get query => _query;
  List<SearchResult> get results => _results;

  final RCKEngineProvider engineProvider;

  SearchProvider({required this.engineProvider});

  updateQuery(String query) async {
    _query = query;
    List<SearchResult> searchResults = []; // 新的数据结构
    List<Future> searchFutures = [];
    Completer conversationCompleter = Completer();

    engineProvider.engine?.searchConversations(
      [
        RCIMIWConversationType.private,
        RCIMIWConversationType.group,
        RCIMIWConversationType.chatroom,
        RCIMIWConversationType.system,
        RCIMIWConversationType.ultraGroup
      ],
      null,
      [RCIMIWMessageType.text],
      query,
      callback: IRCIMIWSearchConversationsCallback(
        onSuccess: (results) async {
          if (results == null) {
            conversationCompleter.complete();
            return;
          }
          for (var result in results) {
            RCIMIWConversation? con = result.conversation;
            if (con != null) {
              // 抓取对应对话的消息，并构建新的 SearchResult
              var future = () {
                Completer completer = Completer();
                engineProvider.engine?.searchMessages(
                  con.conversationType ?? RCIMIWConversationType.invalid,
                  con.targetId ?? '',
                  con.channelId,
                  query,
                  DateTime.now().millisecondsSinceEpoch,
                  20,
                  callback: IRCIMIWSearchMessagesCallback(
                    onSuccess: (messages) {
                      if (messages != null) {
                        for (var msg in messages) {
                          if (msg is RCIMIWTextMessage) {
                            final conversationModel = (con);
                            searchResults.add(SearchResult(
                                message: msg, conversation: conversationModel));
                          }
                        }
                      }
                      completer.complete();
                    },
                    onError: (code) {
                      completer.complete();
                    },
                  ),
                );
                return completer.future;
              }();
              searchFutures.add(future);
            }
          }
          conversationCompleter.complete();
        },
        onError: (code) {
          conversationCompleter.complete();
        },
      ),
    );

    await conversationCompleter.future;
    if (searchFutures.isNotEmpty) {
      await Future.wait(searchFutures);
    }
    _results = searchResults;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = [];
    notifyListeners();
  }
}
