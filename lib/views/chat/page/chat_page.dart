import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import '../bubble/message_callbacks.dart';
import 'chat_app_bar_widget.dart';
import 'message_list_widget.dart';
import '../input/message_input_widget.dart';

class RCKChatPage extends StatefulWidget {
  /// 聊天页面配置
  final RCKChatPageConfig config;

  /// 自定义AppBar构建器
  final ChatAppBarBuilder? appBarBuilder;

  /// 自定义消息气泡构建器
  final Map<
      RCIMIWMessageType,
      RCKMessageBubble Function(
          {required RCIMIWMessage message,
          bool? showTime,
          RCKBubbleConfig? config})>? customChatItemBubbleBuilders;

  /// 自定义吸顶区域构建器
  final Widget Function(BuildContext context)? stickyHeaderBuilder;

  /// 消息单击回调
  final MessageTapCallback? onMessageTap;

  /// 消息双击回调
  final MessageDoubleTapCallback? onMessageDoubleTap;

  /// 消息长按回调
  final MessageLongPressCallback? onMessageLongPress;

  /// 消息侧滑回调
  final MessageSwipeCallback? onMessageSwipe;

  /// 点击权限弹窗之前回调
  final TapBeforePermissionCallback? onTapBeforePermission;

  /// 会话对象
  final RCIMIWConversation? conversation;

  RCKChatPage({
    super.key,
    RCKChatPageConfig? config,
    this.appBarBuilder,
    this.customChatItemBubbleBuilders,
    this.stickyHeaderBuilder,
    this.onMessageTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageSwipe,
    this.conversation,
    this.onTapBeforePermission,
  }) : config = config ?? RCKChatPageConfig();

  @override
  RCKChatPageState createState() => RCKChatPageState();
}

class RCKChatPageState extends State<RCKChatPage> {
  late RCKChatProvider chatProvider;
  late RCKVoiceRecordProvider voiceRecordProvider;
  late RCKAudioPlayerProvider audioPlayerProvider;
  String conversationName = 'Default Name';

  bool isSystemConversation = false;

  @override
  void initState() {
    super.initState();
    // 初始化 Provider
    final engineProvider = context.read<RCKEngineProvider>();

    chatProvider = RCKChatProvider(engineProvider: engineProvider);
    voiceRecordProvider = RCKVoiceRecordProvider();
    audioPlayerProvider = RCKAudioPlayerProvider();

    if (widget.conversation?.conversationType ==
        RCIMIWConversationType.system) {
      isSystemConversation = true;
    }

    if (widget.conversation != null) {
      _fetchMessage();
    }

    _fetchChatName();
  }

  void _fetchMessage() {
    chatProvider.initMessages(widget.conversation!, onSuccess: () {
      chatProvider.fetchUnreadMentiondMessage();
      chatProvider.clearUnread();
    });
  }

  Future<void> _fetchChatName() async {
    if (context.read<RCKEngineProvider>().customInfoProvider != null) {
      RCKChatProfileInfo chatProfileInfo =
          await context.read<RCKEngineProvider>().customInfoProvider!(
              message: null, conversation: widget.conversation);
      conversationName = chatProfileInfo.name.isNotEmpty
          ? chatProfileInfo.name
          : widget.conversation?.targetId ?? '';
      if (mounted) {
        setState(() {});
      }
    } else {
      conversationName = widget.conversation?.targetId ?? '';
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 根据配置构建背景装饰
  BoxDecoration? _buildBackgroundDecoration() {
    final bgConfig = widget.config.backgroundConfig;
    if (bgConfig.backgroundImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: bgConfig.backgroundImage!,
          fit: bgConfig.imageFitMode,
          repeat: bgConfig.imageRepeat,
        ),
      );
    } else if (bgConfig.backgroundImageUrl != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(bgConfig.backgroundImageUrl!),
          fit: bgConfig.imageFitMode,
          repeat: bgConfig.imageRepeat,
        ),
      );
    } else if (bgConfig.backgroundColor != null ||
        bgConfig.safeAreaColor != null) {
      return BoxDecoration(
        color: bgConfig.safeAreaColor ?? bgConfig.backgroundColor,
      );
    }
    return null;
  }

  @override
  void dispose() {
    // 安全地停止音频播放和录音
    try {
      audioPlayerProvider.stopVoiceMessage(notify: false);
    } catch (e) {
      debugPrint('AudioPlayerProvider dispose error: $e');
    }

    try {
      voiceRecordProvider.cancelRecord();
    } catch (e) {
      debugPrint('VoiceRecordProvider dispose error: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = _buildBackgroundDecoration();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => chatProvider),
          ChangeNotifierProvider(create: (_) => RCKMessageInputProvider()),
          ChangeNotifierProvider(create: (_) => voiceRecordProvider),
          ChangeNotifierProvider(create: (_) => audioPlayerProvider),
        ],
        child: Scaffold(
          appBar: widget.appBarBuilder
                  ?.call(context, widget.config.appBarConfig) ??
              RCKChatAppBarWidget(
                config: widget.config.appBarConfig,
                title: Text(
                  conversationName,
                  style: TextStyle(
                    color: RCKThemeProvider().themeColor.textPrimary,
                    fontSize: appbarFontSize,
                    fontWeight: appbarFontWeight,
                  ),
                ),
                onLeadingPressed: () {
                  Navigator.of(context).pop();
                },
                leadingBuilder: widget.config.useDefaultAppBarLeading
                    ? (context, config) {
                        return Consumer<RCKChatProvider>(
                            builder: (context, provider, child) {
                          final leadingWidget = TextButton(
                            onPressed: () => provider.setMultiSelectMode(false),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                  color:
                                      RCKThemeProvider().themeColor.textPrimary,
                                  fontSize: 16),
                            ),
                          );
                          return provider.multiSelectMode
                              ? leadingWidget
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 0, 3, 0),
                                          child: Icon(
                                            Icons.arrow_back_ios_new,
                                            size: 24,
                                            color: RCKThemeProvider()
                                                .themeColor
                                                .textPrimary,
                                          )),
                                      Consumer<RCKEngineProvider>(
                                          builder: (context, value, child) {
                                        // 获取总未读数，并排除当前对话的未读数
                                        // 计算当前会话的未读数
                                        final currentConversationUnread =
                                            widget.conversation?.unreadCount ??
                                                0;
                                        // 计算其他会话的未读数，确保不小于0
                                        final otherConversationUnread =
                                            value.totalUnreadCount -
                                                currentConversationUnread;
                                        final unreadCount =
                                            otherConversationUnread < 0
                                                ? 0
                                                : otherConversationUnread;
                                        final unreadCountString =
                                            unreadCount > 99
                                                ? "99+"
                                                : unreadCount.toString();
                                        double unreadWidth = unreadCount > 99
                                            ? unreadBubbleWidth
                                            : unreadCount > 9
                                                ? unreadBubbleWidth * 0.7
                                                : unreadBubbleWidth / 2;
                                        return unreadCount == 0
                                            ? const SizedBox.shrink()
                                            : Container(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                width: unreadWidth,
                                                height: unreadBubbleWidth / 2,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.5),
                                                ),
                                                child: Center(
                                                    child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            unreadBubbleWidth /
                                                                4),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    unreadCountString,
                                                    style: TextStyle(
                                                      fontSize: unreadFontSize,
                                                      color: RCKThemeProvider()
                                                                  .currentTheme ==
                                                              RCIMIWAppTheme
                                                                  .dark
                                                          ? RCKThemeProvider()
                                                              .themeColor
                                                              .textPrimary
                                                          : RCKThemeProvider()
                                                              .themeColor
                                                              .textInverse,
                                                      fontWeight:
                                                          convoUnreadFontWeight,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )));
                                      })
                                    ],
                                  ),
                                );
                        });
                      }
                    : null,
              ),
          body: Container(
            decoration: backgroundDecoration,
            child: Consumer<RCKVoiceRecordProvider>(
              builder: (context, provider, child) {
                return Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                              child: Container(
                                  color: (widget.config.backgroundConfig
                                                  .backgroundImage ==
                                              null ||
                                          widget.config.backgroundConfig
                                                  .backgroundImageUrl ==
                                              null)
                                      ? widget.config.backgroundConfig
                                          .backgroundColor
                                      : Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () {
                                      final inputProvider = context
                                          .read<RCKMessageInputProvider>();
                                      if (inputProvider.inputType !=
                                          RCIMIWMessageInputType.voice) {
                                        inputProvider.setInputType(
                                            RCIMIWMessageInputType.initial);
                                      }
                                    },
                                    child: RCKMessageList(
                                      key: context
                                          .read<RCKChatProvider>()
                                          .messageListKey,
                                      customChatItemBubbleBuilders:
                                          widget.customChatItemBubbleBuilders,
                                      stickyHeaderBuilder:
                                          widget.stickyHeaderBuilder,
                                      bubbleConfig: widget.config.bubbleConfig,
                                      onMessageTap: widget.onMessageTap,
                                      onMessageDoubleTap:
                                          widget.onMessageDoubleTap,
                                      onMessageLongPress:
                                          widget.onMessageLongPress,
                                      onMessageSwipe: widget.onMessageSwipe,
                                    ),
                                  ))),
                          isSystemConversation
                              ? const SizedBox.shrink()
                              : RCKMessageInput(
                                  config: widget.config.inputConfig,
                                  onTapBeforePermission:
                                      widget.onTapBeforePermission,
                                ), // 输入框部分
                        ],
                      ),
                    ),
                    if (provider.voiceSendingType !=
                        RCIMIWMessageVoiceSendingType.notStart)
                      Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: [
                            Positioned.fill(
                                child: Container(
                              decoration: BoxDecoration(
                                color: RCKThemeProvider().currentTheme ==
                                        RCIMIWAppTheme.light
                                    ? Colors.grey.withValues(alpha: .5)
                                    : Colors.black.withValues(alpha: .7),
                              ),
                            )),
                            ImageUtil.getImageWidget(
                              "voice_send_bg.png",
                              height: kVoiceRecordingBackgroundHeight,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ImageUtil.getImageWidget(
                                  RCKThemeProvider().themeIcon.error ?? '',
                                  height: kVoiceRecordingCloseIconSize,
                                  width: kVoiceRecordingCloseIconSize,
                                ),
                                const SizedBox(
                                  height: kVoiceRecordingIconSpace,
                                ),
                                ImageUtil.getImageWidget(
                                  'voice_send_icon.png',
                                  width: kVoiceRecordingVoiceIconWidth,
                                  height: kVoiceRecordingVoiceIconHeight,
                                ),
                                const SizedBox(
                                  height: kVoiceRecordingIconSpace / 2,
                                ),
                                Text("松开发送  |  上划取消",
                                    style: TextStyle(
                                        fontSize: kVoiceRecordingFontSize,
                                        color:
                                            RCKThemeProvider().currentTheme ==
                                                    RCIMIWAppTheme.light
                                                ? RCKThemeProvider()
                                                    .themeColor
                                                    .textInverse
                                                : Colors.white)),
                                const SizedBox(
                                  height: kVoiceRecordingBottomSpace,
                                ),
                              ],
                            ),
                          ]),
                  ],
                );
              },
            ),
          ),
        ));
  }
}
