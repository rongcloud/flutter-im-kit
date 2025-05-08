import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/providers/theme_provider.dart';
import 'package:rongcloud_im_kit/ui_config/chat/input/emoji_config.dart';
import '../../../providers/message_input_provider.dart';

// Emoji单元格Builder
typedef EmojiItemBuilder = Widget Function(
    BuildContext context, String emoji, VoidCallback onTap);

// 删除按钮Builder
typedef DeleteButtonBuilder = Widget Function(
    BuildContext context, VoidCallback onTap);

// 发送按钮Builder
typedef SendButtonBuilder = Widget Function(
    BuildContext context, VoidCallback onTap);

class EmojiGridWidget extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final VoidCallback? onDeletePressed; // 添加删除回调
  final VoidCallback? onSendPressed; // 添加发送回调

  // 新增Builder
  final EmojiItemBuilder? emojiItemBuilder;
  final DeleteButtonBuilder? deleteButtonBuilder;
  final SendButtonBuilder? sendButtonBuilder;

  // 新增表情配置
  final RCKEmojiConfig? config;

  const EmojiGridWidget({
    super.key,
    required this.onEmojiSelected,
    this.onDeletePressed, // 初始化删除回调
    this.onSendPressed,
    this.emojiItemBuilder,
    this.deleteButtonBuilder,
    this.sendButtonBuilder,
    this.config,
  });

  @override
  EmojiGridWidgetState createState() => EmojiGridWidgetState();
}

class EmojiGridWidgetState extends State<EmojiGridWidget> {
  late final PageController _pageController;
  static const _defaultConfig = RCKEmojiConfig();

  // 获取配置 - 优先使用传入的配置，否则使用默认配置
  RCKEmojiConfig get _config => widget.config ?? _defaultConfig;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      context.read<RCKMessageInputProvider>().setCurrentEmojiPage(page);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 使用config中的行列数
    final rowCount = _config.rowCount;
    final columnCount = _config.columnCount;
    context.read<RCKMessageInputProvider>().loadEmojis(
          rowCount: rowCount,
          columnCount: columnCount,
          customEmojis: _config.customEmojis,
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildGridPage(List<String> pageEmojis) {
    final List<Widget> gridItems = [
      ...pageEmojis.map((emoji) => _buildEmojiItem(emoji)),
      // 添加空白格子填充
      ...List.generate(
        _config.rowCount * _config.columnCount - pageEmojis.length - 1,
        (_) => const SizedBox(),
      ),
      // 添加删除按钮
      _buildDeleteButton(),
    ];

    return GridView.count(
      crossAxisCount: _config.columnCount,
      mainAxisSpacing: _config.rowSpacing,
      crossAxisSpacing: _config.columnSpacing,
      padding: _config.padding,
      physics: const NeverScrollableScrollPhysics(),
      children: gridItems,
    );
  }

  Widget _buildDeleteButton() {
    if (widget.deleteButtonBuilder != null) {
      return widget.deleteButtonBuilder!(
          context, widget.onDeletePressed ?? () {});
    }

    return InkWell(
      onTap: widget.onDeletePressed,
      child: Center(
        child: _config.deleteIcon,
      ),
    );
  }

  Widget _buildEmojiItem(String emoji) {
    if (widget.emojiItemBuilder != null) {
      return widget.emojiItemBuilder!(
          context, emoji, () => widget.onEmojiSelected(emoji));
    }

    return InkWell(
      onTap: () => widget.onEmojiSelected(emoji),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: _config.emojiSize),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final pageIndicatorConfig = _config.pageIndicatorConfig;

    return Consumer<RCKMessageInputProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(provider.emojiPages.length, (index) {
            return Container(
              width: pageIndicatorConfig.size,
              height: pageIndicatorConfig.size,
              margin:
                  EdgeInsets.symmetric(horizontal: pageIndicatorConfig.spacing),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.currentEmojiPage == index
                    ? pageIndicatorConfig.activeColor ??
                        RCKThemeProvider().themeColor.textInverse
                    : pageIndicatorConfig.inactiveColor ??
                        RCKThemeProvider().themeColor.textAuxiliary,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSendButton() {
    final sendConfig = _config.sendButtonConfig;

    if (widget.sendButtonBuilder != null) {
      return widget.sendButtonBuilder!(context, widget.onSendPressed ?? () {});
    }

    return Positioned(
      right: sendConfig.position == EmojiSendButtonPosition.bottomRight ||
              sendConfig.position == EmojiSendButtonPosition.topRight
          ? sendConfig.margin.right
          : null,
      left: sendConfig.position == EmojiSendButtonPosition.bottomLeft ||
              sendConfig.position == EmojiSendButtonPosition.topLeft
          ? sendConfig.margin.left
          : null,
      bottom: sendConfig.position == EmojiSendButtonPosition.bottomRight ||
              sendConfig.position == EmojiSendButtonPosition.bottomLeft
          ? sendConfig.margin.bottom
          : null,
      top: sendConfig.position == EmojiSendButtonPosition.topRight ||
              sendConfig.position == EmojiSendButtonPosition.topLeft
          ? sendConfig.margin.top
          : null,
      child: SizedBox(
        width: sendConfig.width,
        height: sendConfig.height,
        child: TextButton(
          onPressed: widget.onSendPressed,
          style: TextButton.styleFrom(
            backgroundColor: sendConfig.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sendConfig.borderRadius),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            sendConfig.text,
            style: sendConfig.textStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RCKMessageInputProvider>(
      builder: (context, provider, child) {
        return Container(
          color: _config.backgroundColor ??
              RCKThemeProvider().themeColor.bgRegular,
          child: Stack(
            children: [
              SizedBox(
                height: _config.height,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: provider.emojiPages.length,
                  itemBuilder: (context, index) {
                    return _buildGridPage(provider.emojiPages[index]);
                  },
                ),
              ),
              if (provider.hasMultipleEmojiPages)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _config.pageIndicatorConfig.bottomPadding,
                  child: _buildPageIndicator(),
                ),
              _buildSendButton(),
            ],
          ),
        );
      },
    );
  }
}
