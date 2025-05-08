import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/views/chat/input/voice_record_button.dart';
import 'emoji_grid_widget.dart';
import 'grid_button_widget.dart';

// 左侧按钮Builder类型定义
typedef LeftButtonBuilder = Widget Function(
  BuildContext context,
  RCIMIWMessageInputType inputType,
  VoidCallback onTap,
);

// 右侧按钮Builder类型定义
typedef RightButtonBuilder = Widget Function(
  BuildContext context,
  RCIMIWMessageInputType inputType,
  List<RCKInputButtonConfig> buttonsConfig,
);

// 顶部按钮Builder类型定义
typedef TopButtonsBuilder = Widget Function(
  BuildContext context,
  List<RCKInputButtonConfig> buttonsConfig,
);

// 底部按钮Builder类型定义
typedef BottomButtonsBuilder = Widget Function(
  BuildContext context,
  List<RCKInputButtonConfig> buttonsConfig,
);

// 点击权限弹窗之前回调类型定义
typedef TapBeforePermissionCallback = void Function(
    BuildContext context, Permission permission);

class RCKMessageInput extends StatefulWidget {
  /// 消息输入配置
  final RCKMessageInputConfig config;

  /// 左侧按钮Builder
  final LeftButtonBuilder? leftButtonBuilder;

  /// 右侧按钮Builder
  final RightButtonBuilder? rightButtonBuilder;

  /// 顶部按钮Builder
  final TopButtonsBuilder? topButtonsBuilder;

  /// 底部按钮Builder
  final BottomButtonsBuilder? bottomButtonsBuilder;

  /// Emoji界面Builder
  final Widget Function(
      BuildContext, Function(String), VoidCallback, VoidCallback)? emojiBuilder;

  /// 扩展菜单Builder
  final Widget Function(BuildContext)? gridBuilder;

  /// 点击权限弹窗之前回调
  final TapBeforePermissionCallback? onTapBeforePermission;

  RCKMessageInput({
    super.key,
    RCKMessageInputConfig? config,
    this.leftButtonBuilder,
    this.rightButtonBuilder,
    this.topButtonsBuilder,
    this.bottomButtonsBuilder,
    this.emojiBuilder,
    this.gridBuilder,
    this.onTapBeforePermission,
  }) : config = config ?? RCKMessageInputConfig();

  @override
  State<RCKMessageInput> createState() => _RCKMessageInputState();
}

class _RCKMessageInputState extends State<RCKMessageInput> {
  String? refName;
  final ScrollController _textScrollController = ScrollController();
  late RCKMessageInputProvider _inputProvider;

  fetchRefInfo(BuildContext context, RCIMIWMessage? message) async {
    if (context.read<RCKEngineProvider>().customInfoProvider != null) {
      refName = (await context.read<RCKEngineProvider>().customInfoProvider!(
              message: message))
          .name;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _inputProvider = context.read<RCKMessageInputProvider>();
    final chatProvider = context.read<RCKChatProvider>();
    _inputProvider.controller.text = chatProvider.conversation.draft ?? '';
    _inputProvider.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _inputProvider.controller.removeListener(_handleTextChange);
    _textScrollController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (!_inputProvider.focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _textScrollController.hasClients) {
          final position = _textScrollController.position;
          final maxScroll = position.maxScrollExtent;
          final currentScroll = position.pixels;

          // 定义阈值：距离底部多少像素以内算作"在底部附近"
          const double nearBottomThreshold = 20.0;

          // 检查当前滚动位置是否接近或就在底部
          bool isScrolledToEnd =
              (maxScroll - currentScroll) <= nearBottomThreshold;

          // 如果滚动条接近或就在底部，则滚动到最底部
          if (isScrolledToEnd) {
            // 使用 jumpTo 确保精确到达底部
            _textScrollController.jumpTo(maxScroll);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<RCKChatProvider>();
    if (chatProvider.multiSelectMode) {
      return SizedBox(
          height: kInputMultiSelectHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
                  context.read<RCKVoiceRecordProvider>().cancelRecord();
                  chatProvider.saveScrollOffset();
                  Navigator.pushNamed(context, '/forward', arguments: {
                    'chatProvider': chatProvider,
                  }).then((value) {
                    chatProvider.setMultiSelectMode(false);
                    chatProvider.jumpToScrollOffset();
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ImageUtil.getImageWidget(
                        RCKThemeProvider().themeIcon.forwardSingle ?? '',
                        width: kInputMultiSelectButtonHeight,
                        height: kInputMultiSelectButtonHeight),
                    Text(
                      "逐条转发",
                      style: TextStyle(
                        fontSize: kInputMultiSelectButtonFontSize,
                        color: RCKThemeProvider().themeColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  chatProvider.deleteMessage(
                      chatProvider.selectedMessages, context);
                  chatProvider.setMultiSelectMode(false);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ImageUtil.getImageWidget(
                        RCKThemeProvider().themeIcon.delete ?? '',
                        color: RCKThemeProvider().themeColor.notice,
                        width: kInputMultiSelectButtonHeight,
                        height: kInputMultiSelectButtonHeight),
                    Text(
                      "删除",
                      style: TextStyle(
                        fontSize: kInputMultiSelectButtonFontSize,
                        color: RCKThemeProvider().themeColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
    }

    return Consumer<RCKMessageInputProvider>(
      builder: (context, provider, child) {
        Widget leftButton;

        final buttonConfig = widget.config.leftButtonConfig;
        final isActive = provider.inputType == RCIMIWMessageInputType.voice;

        if (widget.leftButtonBuilder != null) {
          leftButton = widget.leftButtonBuilder!(
            context,
            provider.inputType,
            () {
              RCIMIWMessageInputType targetType =
                  provider.inputType != RCIMIWMessageInputType.voice
                      ? RCIMIWMessageInputType.voice
                      : RCIMIWMessageInputType.text;
              provider.setInputType(targetType);
            },
          );
        } else {
          final icon = isActive
              ? buttonConfig.activeIcon ??
                  ImageUtil.getImageWidget(
                      RCKThemeProvider().themeIcon.enterTheKeyboard ??
                          'inputbar_keyboard.png',
                      height: buttonConfig.size,
                      color: buttonConfig.activeColor)
              : buttonConfig.icon ??
                  ImageUtil.getImageWidget(
                      RCKThemeProvider().themeIcon.voiceMessage ??
                          'inputbar_voice.png',
                      height: buttonConfig.size,
                      color: buttonConfig.color);

          leftButton = GestureDetector(
            onTap: () {
              RCIMIWMessageInputType targetType =
                  provider.inputType != RCIMIWMessageInputType.voice
                      ? RCIMIWMessageInputType.voice
                      : RCIMIWMessageInputType.text;
              provider.setInputType(targetType);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonConfig.spacing),
              child: icon,
            ),
          );
        }

        Widget rightButtonsWidget;

        if (widget.rightButtonBuilder != null) {
          rightButtonsWidget = widget.rightButtonBuilder!(
              context,
              provider.inputType,
              widget.config.rightButtonsConfig.isNotEmpty
                  ? widget.config.rightButtonsConfig
                  : []);
        } else {
          List<Widget> rightButtons = [];
          if (widget.config.rightButtonsConfig.isNotEmpty) {
            for (var buttonConfig in widget.config.rightButtonsConfig) {
              if (!buttonConfig.visible) continue;

              final icon = isActive
                  ? buttonConfig.activeIcon ?? buttonConfig.icon
                  : buttonConfig.icon;

              rightButtons.add(
                Padding(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: buttonConfig.size,
                    height: buttonConfig.size,
                    child: icon,
                  ),
                ),
              );

              if (buttonConfig != widget.config.rightButtonsConfig.last) {
                rightButtons.add(SizedBox(width: buttonConfig.spacing));
              }
            }
          } else {
            rightButtons = [
              GestureDetector(
                onTap: () {
                  RCIMIWMessageInputType targetType =
                      provider.inputType != RCIMIWMessageInputType.emoji
                          ? RCIMIWMessageInputType.emoji
                          : RCIMIWMessageInputType.text;
                  provider.setInputType(targetType);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: buttonConfig.spacing),
                  child: ImageUtil.getImageWidget(
                      RCKThemeProvider().themeIcon.emoji1 ??
                          'inputbar_emoji.png',
                      height: buttonConfig.size,
                      color: buttonConfig.color),
                ),
              ),
              GestureDetector(
                onTap: () {
                  RCIMIWMessageInputType targetType =
                      provider.inputType != RCIMIWMessageInputType.more
                          ? RCIMIWMessageInputType.more
                          : RCIMIWMessageInputType.text;
                  provider.setInputType(targetType);
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: buttonConfig.spacing),
                  child: ImageUtil.getImageWidget(
                      RCKThemeProvider().themeIcon.more ?? 'inputbar_add.png',
                      height: buttonConfig.size,
                      color: buttonConfig.color),
                ),
              ),
            ];
          }

          rightButtonsWidget = Row(
            children: rightButtons,
          );
        }

        String referenceMessageContent = '';
        TextStyle? refTextStyle;
        if (provider.isQuoting) {
          var refMsg = provider.referenceMessage;
          referenceMessageContent = getReferenceMessageContent(refMsg);

          fetchRefInfo(context, refMsg);
          if (refName == null || refName!.isEmpty) {
            refName = refMsg?.senderUserId ?? '';
          }

          refTextStyle = widget.config.quotePreviewConfig.textStyle ??
              TextStyle(
                  color: RCKThemeProvider().themeColor.textSecondary,
                  fontSize: kBubbleRefTextFontSize);
        }

        return Container(
          color: widget.config.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: widget.config.dividerColor ??
                    ((RCKThemeProvider().currentTheme == RCIMIWAppTheme.dark)
                        ? const Color(0xFF1D1D1D)
                        : const Color(0xFFE6E6E6)),
                height: 1.0,
              ),
              if (provider.isQuoting)
                Container(
                  color: widget.config.quotePreviewConfig.backgroundColor ??
                      RCKThemeProvider().themeColor.bgAuxiliary1,
                  padding: widget.config.quotePreviewConfig.padding ??
                      const EdgeInsets.symmetric(
                          horizontal: kInputQuotePreviewPaddingH),
                  height: kInputQuotePreviewHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "| 回复 $refName：$referenceMessageContent",
                          style: refTextStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: provider.clearReferenceMessage,
                        child: widget.config.quotePreviewConfig.closeIcon ??
                            ImageUtil.getImageWidget(
                                RCKThemeProvider().themeIcon.error ?? '',
                                height: kInputQuotePreviewCloseIconSize,
                                color:
                                    RCKThemeProvider().themeColor.bgQuoteExit),
                      )
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          bottom: kInputFieldIconPaddingBottom),
                      child: leftButton),
                  Expanded(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          widget.config.inputFieldConfig.maxHeight ?? 100,
                      minHeight: kInputFieldMinHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: kInputFieldContentPaddingV),
                      child: provider.inputType == RCIMIWMessageInputType.voice
                          ? const VoiceRecordButton()
                          : TextField(
                              focusNode: provider.focusNode,
                              controller: provider.controller,
                              scrollController: _textScrollController,
                              maxLines: 5,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.send,
                              scrollPhysics: const BouncingScrollPhysics(),
                              style: widget.config.inputFieldConfig.textStyle ??
                                  TextStyle(
                                    fontSize: kInputFieldFontSize,
                                    color: RCKThemeProvider()
                                        .themeColor
                                        .textPrimary,
                                    height: kInputFieldFontHeight /
                                        kInputFieldFontSize,
                                  ),
                              cursorHeight: kInputFieldFontHeight,
                              decoration: InputDecoration(
                                isDense: true,
                                hintStyle:
                                    widget.config.inputFieldConfig.hintStyle ??
                                        TextStyle(
                                          fontSize: kInputFieldFontSize,
                                          color: RCKThemeProvider()
                                              .themeColor
                                              .textAuxiliary,
                                        ),
                                hintText:
                                    widget.config.inputFieldConfig.hintText,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: kInputFieldContentPaddingV,
                                    horizontal: kInputFieldContentPaddingH),
                                filled: true,
                                fillColor:
                                    RCKThemeProvider().themeColor.bgRegular,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      kInputFieldBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (text) {
                                provider.onTextChanged(text, context);
                              },
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  provider.inputSendMessage(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('请输入消息内容'),
                                      duration:
                                          const Duration(milliseconds: 500),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  FocusScope.of(context)
                                      .requestFocus(provider.focusNode);
                                }
                              },
                            ),
                    ),
                  )),
                  Padding(
                      padding: const EdgeInsets.only(
                          bottom: kInputFieldIconPaddingBottom),
                      child: rightButtonsWidget),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: (provider.inputType ==
                                RCIMIWMessageInputType.more ||
                            provider.inputType == RCIMIWMessageInputType.emoji)
                        ? kInputFieldMorePaddingV
                        : 0.0),
                child: provider.inputType == RCIMIWMessageInputType.more
                    ? widget.gridBuilder != null
                        ? widget.gridBuilder!(context)
                        : widget.config.extensionMenuConfig != null
                            ? GridButtonWidget.fromConfig(
                                widget.config.extensionMenuConfig!)
                            : GridButtonWidget(
                                items: GridButtonWidget.getDefaultGridItems(
                                    context,
                                    onTapBeforePermission:
                                        widget.onTapBeforePermission),
                              )
                    : provider.inputType == RCIMIWMessageInputType.emoji
                        ? widget.emojiBuilder != null
                            ? widget.emojiBuilder!(
                                context,
                                (emoji) => provider.addText(emoji, context),
                                () => provider.deleteText(context),
                                () => provider.inputSendMessage(context),
                              )
                            : EmojiGridWidget(
                                onEmojiSelected: (emoji) {
                                  provider.addText(emoji, context);
                                },
                                onDeletePressed: () {
                                  provider.deleteText(context);
                                },
                                onSendPressed: () {
                                  provider.inputSendMessage(context,
                                      keepFocus: true);
                                },
                              )
                        : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
