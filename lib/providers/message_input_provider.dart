import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:xml/xml.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

enum RCIMIWMessageInputType {
  initial,
  text,
  voice,
  emoji,
  more,
}

class RCKMessageInputProvider with ChangeNotifier {
  RCKMessageInputProvider() {
    _focusNode.addListener(_onFocusChange);
  }

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  RCIMIWMessageInputType _inputType = RCIMIWMessageInputType.initial;

  TextEditingController get controller => _controller;
  FocusNode get focusNode => _focusNode;
  RCIMIWMessageInputType get inputType => _inputType;

  String lastChangedText = '';

  final List<String> _userAtInfo = [];
  List<String> get userAtInfo => _userAtInfo;
  void addUserAtInfo(String info) {
    _userAtInfo.add(info);
    notifyListeners();
  }

  void removeUserAtInfo(String info) {
    _userAtInfo.remove(info);
    notifyListeners();
  }

  void clearAtInfo() {
    _userAtInfo.clear();
    notifyListeners();
  }

  // 新增表情管理相关属性
  final List<List<String>> _emojiPages = [];
  int _currentEmojiPage = 0;
  bool get hasMultipleEmojiPages => _emojiPages.length > 1;
  List<List<String>> get emojiPages => _emojiPages;
  int get currentEmojiPage => _currentEmojiPage;

  // 添加网格配置属性
  int _rowCount = 3;
  int _columnCount = 8;

  // 提供getter方法
  int get rowCount => _rowCount;
  int get columnCount => _columnCount;

  void onTextChanged(String newText, BuildContext context) {
    String oldText = lastChangedText;
    // 检测删除操作
    if (newText.length < oldText.length) {
      int diffIndex = 0;
      while (diffIndex < newText.length &&
          diffIndex < oldText.length &&
          newText[diffIndex] == oldText[diffIndex]) {
        diffIndex++;
      }
      // 修改正则，匹配 "@姓名 "，支持中文、字母、数字与下划线
      RegExp mentionRegExp = RegExp(r'@[\w\u4e00-\u9fa5]+ ');
      for (var m in mentionRegExp.allMatches(oldText)) {
        if (diffIndex >= m.start && diffIndex < m.end) {
          // 计算新的结束索引，避免越界
          int endIndex = m.end > newText.length ? newText.length : m.end;
          newText = newText.substring(0, m.start) + newText.substring(endIndex);
          controller.value = controller.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: m.start));
          String mentionName = oldText.substring(m.start, m.end);
          removeUserAtInfo(mentionName);
          break;
        }
      }
    }

    RCKChatProvider chatProvider = context.read<RCKChatProvider>();
    if (newText.isEmpty) {
      chatProvider.clearDraft();
    } else {
      chatProvider.saveDraft(newText);
    }
    // 当文本增加字符且新增加的字符中包含 '@' 时触发
    if (newText.length > oldText.length &&
        chatProvider.conversation.conversationType ==
            RCIMIWConversationType.group) {
      int cursorIndex = controller.selection.baseOffset;
      // 验证 cursorIndex 的有效性
      if (cursorIndex == -1) {
        cursorIndex = newText.length;
      }
      if (cursorIndex > 0 && newText[cursorIndex - 1] == '@') {
        context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
        context.read<RCKVoiceRecordProvider>().cancelRecord();
        Navigator.pushNamed(context, '/at_people',
                arguments: {'groupId': chatProvider.conversation.targetId})
            .then((value) {
          RCKUserAtInfo? atInfo = value as RCKUserAtInfo?;
          if (atInfo == null) return;
          final currentText = controller.text;
          final selection = controller.selection;
          int cursorIndex = selection.baseOffset;
          // 验证 cursorIndex 的有效性
          if (cursorIndex == -1) {
            cursorIndex = currentText.length;
          }
          // 判断光标前一个字符是否为 '@'
          if (cursorIndex > 0 && currentText[cursorIndex - 1] == '@') {
            final newText = currentText.replaceRange(
              cursorIndex,
              cursorIndex,
              '${atInfo.name} ',
            );
            controller.value = controller.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(
                offset: cursorIndex + atInfo.name.length + 1,
              ),
            );
          }
          addUserAtInfo(atInfo.userId);
          if (context.mounted) {
            onTextChanged(controller.text, context);
          }
        });
      }
    }
    lastChangedText = newText;
  }

  void inputSendMessage(BuildContext context, {bool keepFocus = false}) {
    if (text.isEmpty) return;
    if (text.trim().isEmpty) return;

    context.read<RCKChatProvider>().addTextOrRefrenceMessage(
        text, isQuoting ? referenceMessage! : null, List.from(userAtInfo));

    clearText();
    clearReferenceMessage(); // 发送后清除引用状态
    clearAtInfo();
    lastChangedText = '';
    // 重新设置焦点，保持键盘打开
    if (!keepFocus) {
      setInputType(RCIMIWMessageInputType.text);
    }
  }

  // 新增：引用消息状态，与 inputType 无关
  RCIMIWMessage? _referenceMessage;
  RCIMIWMessage? get referenceMessage => _referenceMessage;
  bool get isQuoting => _referenceMessage != null;
  void setReferenceMessage(RCIMIWMessage message) {
    _referenceMessage = message;
    notifyListeners();
  }

  void clearReferenceMessage() {
    _referenceMessage = null;
    notifyListeners();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // 当输入框获得焦点时，确保列表滚动到最后
      // 使用延迟确保键盘完全升起后再滚动到底部
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_focusNode.hasFocus) {
          final chatProvider = Provider.of<RCKChatProvider>(
            _focusNode.context!,
            listen: false,
          );
          chatProvider.messageListScrollToBottom();
        }
      });
    }

    if (_focusNode.hasFocus && _inputType != RCIMIWMessageInputType.text) {
      _inputType = RCIMIWMessageInputType.text;
      notifyListeners();
    }
  }

  void setInputType(RCIMIWMessageInputType type) {
    _inputType = type;
    switch (type) {
      case RCIMIWMessageInputType.voice:
      case RCIMIWMessageInputType.emoji:
      case RCIMIWMessageInputType.more:
      case RCIMIWMessageInputType.initial:
        _focusNode.unfocus();
        // 延迟200ms后，如果输入框没有获得焦点，则滚动到最新消息
        if (type != RCIMIWMessageInputType.initial) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!_focusNode.hasFocus &&
                _focusNode.context != null &&
                _focusNode.context!.mounted) {
              final chatProvider = Provider.of<RCKChatProvider>(
                _focusNode.context!,
                listen: false,
              );
              chatProvider.messageListScrollToBottom();
            }
          });
        }
        break;
      case RCIMIWMessageInputType.text:
        _focusNode.requestFocus();
        break;
    }
    notifyListeners();

    RCIMWrapperPlatform.instance.writeLog(
        'RCKMessageInputProvider setInputType',
        '',
        0,
        'inputType: $_inputType');
  }

  void addText(String text, BuildContext context) {
    final currentText = _controller.text;
    final currentSelection = _controller.selection;

    // 验证 TextSelection 的有效性，如果无效则使用默认值
    int start = currentSelection.start;
    int end = currentSelection.end;

    // 如果 start 或 end 为 -1，说明选择无效，使用文本长度作为默认位置
    if (start == -1 || end == -1) {
      start = currentText.length;
      end = currentText.length;
    }

    // 确保 start 和 end 在有效范围内
    start = start.clamp(0, currentText.length);
    end = end.clamp(0, currentText.length);

    // 在当前光标位置或者选区插入文本
    final newText = currentText.replaceRange(
      start,
      end,
      text,
    );
    // 计算新的光标位置
    final newOffset = start + text.length;
    // 使用 copyWith 更新 controller 的 value
    _controller.value = _controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    onTextChanged(_controller.text, context); // 触发 onChanged 回调
    notifyListeners();
  }

  void deleteText(BuildContext context) {
    if (_controller.text.isEmpty) return;

    final text = _controller.text;
    final selection = _controller.selection;

    // 验证 TextSelection 的有效性
    int offset = selection.baseOffset;
    if (offset == -1) {
      offset = text.length;
    }

    offset = offset > 0 ? offset : text.length;
    if (offset <= 0) return;

    bool isEmoji = _containsEmoji(text);

    int deleteLength = isEmoji ? 2 : 1;
    if (offset - deleteLength < 0) {
      deleteLength = 1;
    }

    final newText =
        text.substring(0, offset - deleteLength) + text.substring(offset);
    _controller.text = newText;
    _controller.selection =
        TextSelection.collapsed(offset: offset - deleteLength);
    onTextChanged(_controller.text, context); // 触发 onChanged 回调
    notifyListeners();
  }

  bool _containsEmoji(String text) {
    // Emoji 正则表达式（匹配大部分表情符号）
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{2300}-\u{23FF}\u{2B50}\u{3030}]',
      unicode: true,
    );

    return emojiRegex.hasMatch(text);
  }

  void clearText() {
    _userAtInfo.clear();
    _controller.clear();
    notifyListeners();
  }

  String get text => _controller.text;

  void setCurrentEmojiPage(int page) {
    if (_currentEmojiPage != page) {
      _currentEmojiPage = page;
      notifyListeners();
    }
  }

  Future<void> loadEmojis(
      {int? rowCount, int? columnCount, List<String>? customEmojis}) async {
    if (rowCount != null) _rowCount = rowCount;
    if (columnCount != null) _columnCount = columnCount;
    try {
      final emojiString = await rootBundle
          .loadString('packages/rongcloud_im_kit/assets/emoji.plist');
      final document = XmlDocument.parse(emojiString);
      final emojis = document.findAllElements('string').map((node) {
        final value = node.innerText;
        return value;
      }).toList();
      _processEmojiPages(emojis);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading emojis: $e');
      }
      _processEmojiPages(['😀', '😃', '😄', '😁', '😆']);
      notifyListeners();
    }
  }

  void _processEmojiPages(List<String> emojis) {
    _emojiPages.clear();

    // 每页项目数等于行数*列数-1(删除按钮占位)
    final int itemsPerPage = _rowCount * _columnCount - 1;

    for (var i = 0; i < emojis.length; i += itemsPerPage) {
      final end =
          (i + itemsPerPage) > emojis.length ? emojis.length : i + itemsPerPage;
      _emojiPages.add(emojis.sublist(i, end));
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
