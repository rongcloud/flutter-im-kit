import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/views/conversation/page/conversation_app_bar_widget.dart';

/// 新版对话列表页面，支持完整的配置和自定义构建器
class RCKConvoPage extends StatefulWidget {
  /// 整体配置对象
  final RCKConvoConfig config;

  /// 自定义 AppBar 构建器
  final ConvoAppBarBuilder? appBarBuilder;

  /// 对话单元格构建器
  final ItemBuilder? itemBuilder;

  /// 头像构建器
  final AvatarBuilder? avatarBuilder;

  /// 标题构建器
  final TitleBuilder? titleBuilder;

  /// 最后一条消息构建器
  final LastMessageBuilder? lastMessageBuilder;

  /// 时间构建器
  final TimeBuilder? timeBuilder;

  /// 未读消息角标构建器
  final UnreadBadgeBuilder? unreadBadgeBuilder;

  /// 顶部提示构建器，显示在搜索框上方
  final Widget Function(BuildContext context)? tipBuilder;

  /// 空列表构建器
  final Widget Function(BuildContext context)? emptyBuilder;

  /// 单元格点击回调
  final ItemOnTap? onItemTap;

  /// 单元格长按回调
  final ItemOnLongPress? onItemLongPress;

  /// 搜索框点击回调
  final void Function(BuildContext context)? onSearchTap;

  RCKConvoPage({
    super.key,
    RCKConvoConfig? config,
    this.appBarBuilder,
    this.itemBuilder,
    this.avatarBuilder,
    this.titleBuilder,
    this.lastMessageBuilder,
    this.timeBuilder,
    this.unreadBadgeBuilder,
    this.tipBuilder,
    this.emptyBuilder,
    this.onItemTap,
    this.onItemLongPress,
    this.onSearchTap,
  }) : config = config ?? RCKConvoConfig();

  @override
  State<RCKConvoPage> createState() => _RCKConvoPageState();
}

class _RCKConvoPageState extends State<RCKConvoPage> {
  late RCKConvoProvider conversationProvider;

  @override
  void initState() {
    super.initState();
    conversationProvider = RCKConvoProvider(
        isMainPage: true, engineProvider: context.read<RCKEngineProvider>());
    conversationProvider.initConversations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: conversationProvider,
        child: PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: widget.config.listConfig.backgroundColor ??
                  RCKThemeProvider().themeColor.bgRegular,
              appBar: widget.appBarBuilder
                      ?.call(context, widget.config.appBarConfig) ??
                  RCKConvoAppBarWidget(
                    config: widget.config.appBarConfig,
                  ),
              body: _buildBody(),
            )));
  }

  Widget _buildBody() {
    return Consumer<RCKConvoProvider>(
      builder: (context, provider, child) {
        // 空列表处理
        if (provider.conversations.isEmpty) {
          return Column(
            children: [
              (provider.connectionStatus ==
                          RCIMIWConnectionStatus.networkUnavailable ||
                      provider.connectionStatus ==
                          RCIMIWConnectionStatus.unconnected ||
                      provider.connectionStatus ==
                          RCIMIWConnectionStatus.suspend ||
                      provider.connectionStatus ==
                          RCIMIWConnectionStatus.timeout ||
                      provider.connectionStatus ==
                          RCIMIWConnectionStatus.unknown)
                  ? _buildNetworkUnavailableTip()
                  : const SizedBox.shrink(),
              Expanded(child: _buildEmptyList()),
            ],
          );
        }

        return CustomScrollView(
          controller: provider.scrollController,
          slivers: [
            // 顶部提示内容 - 由开发者自定义，如果不提供则不显示
            if (widget.tipBuilder != null)
              SliverToBoxAdapter(
                child: widget.tipBuilder!(context),
              )
            else
              SliverToBoxAdapter(
                child: (provider.connectionStatus ==
                            RCIMIWConnectionStatus.networkUnavailable ||
                        provider.connectionStatus ==
                            RCIMIWConnectionStatus.unconnected ||
                        provider.connectionStatus ==
                            RCIMIWConnectionStatus.suspend ||
                        provider.connectionStatus ==
                            RCIMIWConnectionStatus.timeout ||
                        provider.connectionStatus ==
                            RCIMIWConnectionStatus.unknown)
                    ? _buildNetworkUnavailableTip()
                    : const SizedBox.shrink(),
              ),

            // 搜索框
            if (widget.config.listConfig.showSearchBar) _buildSearchBar(),
            // 会话列表
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final conversation = provider.conversations[index];
                  return Column(
                    children: [
                      // 使用自定义构建器或默认构建器
                      widget.itemBuilder != null
                          ? widget.itemBuilder!(
                              context, conversation, widget.config.itemConfig)
                          : ConversationItem(
                              conversation: conversation,
                              index: index,
                              config: widget.config,
                              avatarBuilder: widget.avatarBuilder,
                              titleBuilder: widget.titleBuilder,
                              lastMessageBuilder: widget.lastMessageBuilder,
                              timeBuilder: widget.timeBuilder,
                              unreadBadgeBuilder: widget.unreadBadgeBuilder,
                              onTap: widget.onItemTap,
                              onLongPress: widget.onItemLongPress,
                            ),
                      // 分割线
                      Divider(
                        indent: widget.config.itemConfig.dividerIndent,
                        endIndent: widget.config.itemConfig.dividerEndIndent,
                        height: widget.config.itemConfig.dividerHeight,
                        color: widget.config.itemConfig.dividerColor ??
                            (RCKThemeProvider().currentTheme ==
                                    RCIMIWAppTheme.light
                                ? RCKThemeProvider().themeColor.bgAuxiliary1
                                : RCKThemeProvider().themeColor.bgRegular),
                      ),
                    ],
                  );
                },
                childCount: provider.conversations.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          if (widget.onSearchTap != null) {
            widget.onSearchTap!(context);
          } else {
            Navigator.pushNamed(context, '/search');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: TextField(
                enabled: false,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '搜索',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageUtil.getImageWidget(
            RCKThemeProvider().themeIcon.noMessages ?? '',
            width: kConvoItemEmptyIconSize,
            height: kConvoItemEmptyIconSize,
            color: const Color(0xFFD7D7D7),
          ),
          const SizedBox(height: 14),
          Text(
            widget.config.listConfig.emptyText,
            style: TextStyle(
              fontSize: convoLastFontSize,
              color: RCKThemeProvider().themeColor.textAuxiliary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkUnavailableTip() {
    return Container(
      height: 42,
      color: pageTipColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.attention ?? '',
              width: 18,
              height: 18,
              color: RCKThemeProvider().themeColor.notice),
          const SizedBox(width: 4.0),
          Text(
            '当前网络不可用，请检查你的网络设置',
            style: TextStyle(
              color: RCKThemeProvider().themeColor.textPrimary,
              fontSize: convoTipFontSize,
            ),
          ),
        ],
      )),
    );
  }
}
