import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:rongcloud_im_kit/ui_config/chat/page/chat_app_bar_config.dart';

enum PopupType {
  /// 对话列表
  convo,

  /// 对话详情
  chat,

  /// 附加气泡
  bubbleAppend,
}

Future<String?> showPopupMenu(BuildContext context, PopupType type,
    {List<PopupMenuEntry<String>>? items,
    bool? isPin,
    bool? isMute,
    bool? canRecall,
    bool? canQuote,
    bool? canCopy,
    bool? canSpeechToText,
    bool? canCancelSpeechToText,
    bool conversationIsSystem = false}) {
// 默认菜单项列表
  final defaultItemsChat = [
    if (((canSpeechToText ?? false) || (canCancelSpeechToText ?? false)) && !conversationIsSystem)
      PopupMenuItem<String>(
        value: 'speechToText',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(
                  RCKThemeProvider().themeIcon.speechToText ?? '',
                  width: kPopupIconSize,
                  height: kPopupIconSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
              Text(
                (canCancelSpeechToText ?? false) ? '取消转文字' : '转文字',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          ),
        ),
      ),
    if (canCopy ?? true)
      PopupMenuItem<String>(
        value: 'copy',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageUtil.getImageWidget(
                    RCKThemeProvider().themeIcon.copy ?? '',
                    width: kPopupIconSize,
                    height: kPopupIconSize),
                Text(
                  '复制',
                  style: TextStyle(
                      fontSize: convoPopupFontSize,
                      color: RCKThemeProvider().themeColor.textPrimary),
                ),
              ],
            )),
      ),
    if (!conversationIsSystem)
      PopupMenuItem<String>(
        value: 'forward',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageUtil.getImageWidget(
                    RCKThemeProvider().themeIcon.forwardSingle ?? '',
                    width: kPopupIconSize,
                    height: kPopupIconSize),
                Text(
                  '转发',
                  style: TextStyle(
                      fontSize: convoPopupFontSize,
                      color: RCKThemeProvider().themeColor.textPrimary),
                ),
              ],
            )),
      ),
    PopupMenuItem<String>(
      value: 'delete',
      height: 34,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.delete ?? '',
                width: kPopupIconSize, height: kPopupIconSize),
            Text(
              '删除',
              style: TextStyle(
                  fontSize: convoPopupFontSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
            ),
          ],
        ),
      ),
    ),
    if (!conversationIsSystem)
      PopupMenuItem<String>(
        value: 'multi',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ImageUtil.getImageWidget(
                    RCKThemeProvider().themeIcon.multiSelect ?? '',
                    width: kPopupIconSize,
                    height: kPopupIconSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
                Text(
                  '多选',
                  style: TextStyle(
                      fontSize: convoPopupFontSize,
                      color: RCKThemeProvider().themeColor.textPrimary),
                ),
              ],
            )),
      ),
    if ((canQuote ?? true) && !conversationIsSystem)
      PopupMenuItem<String>(
        value: 'quote',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.reply ?? '',
                  width: kPopupIconSize,
                  height: kPopupIconSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
              Text(
                '回复',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          ),
        ),
      ),
    if ((canRecall ?? false) && !conversationIsSystem)
      PopupMenuItem<String>(
        value: 'recall',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(
                  RCKThemeProvider().themeIcon.recall ?? '',
                  width: kPopupIconSize,
                  height: kPopupIconSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
              Text(
                '撤回',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          ),
        ),
      ),
  ];

  // 附加气泡菜单项列表
  final defaultItemsBubbleAppend = [
    if ((canCancelSpeechToText ?? false) && !conversationIsSystem)
      PopupMenuItem<String>(
        value: 'speechToText',
        height: 34,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(
                  RCKThemeProvider().themeIcon.speechToText ?? '',
                  width: kPopupIconSize,
                  height: kPopupIconSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
              Text(
                '取消转文字',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          ),
        ),
      ),
    PopupMenuItem<String>(
      value: 'copy',
      height: 34,
      padding: EdgeInsets.zero,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.copy ?? '',
                  width: kPopupIconSize, height: kPopupIconSize),
              Text(
                '复制',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          )),
    ),
  ];

  // 默认菜单项列表
  final defaultItemsConvo = [
    PopupMenuItem<String>(
      value: 'pin',
      height: 34,
      padding: EdgeInsets.zero,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageUtil.getImageWidget(
                  isPin ?? false
                      ? RCKThemeProvider().themeIcon.unpin ?? ''
                      : RCKThemeProvider().themeIcon.pin ?? '',
                  width: kPopupIconSize,
                  height: kPopupIconSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
              Text(
                isPin ?? false ? '取消置顶' : '置顶',
                style: TextStyle(
                    fontSize: convoPopupFontSize,
                    color: RCKThemeProvider().themeColor.textPrimary),
              ),
            ],
          )),
    ),
    PopupMenuItem<String>(
      value: 'mute',
      height: 34,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ImageUtil.getImageWidget(
                isMute ?? false
                    ? RCKThemeProvider().themeIcon.allowNotification ?? ''
                    : RCKThemeProvider().themeIcon.doNotDisturb1 ?? '',
                width: kPopupIconSize,
                height: kPopupIconSize),
            Text(
              isMute ?? false ? '允许消息通知' : '免打扰',
              style: TextStyle(
                  fontSize: convoPopupFontSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
            ),
          ],
        ),
      ),
    ),
    PopupMenuItem<String>(
      value: 'delete',
      height: 34,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.delete ?? '',
                width: kPopupIconSize, height: kPopupIconSize),
            Text(
              '删除',
              style: TextStyle(
                  fontSize: convoPopupFontSize,
                  color: RCKThemeProvider().themeColor.textPrimary),
            ),
          ],
        ),
      ),
    ),
  ];
  // 获取点击 widget 的全局坐标
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  final Offset offset =
      renderBox.localToGlobal(renderBox.size.center(Offset.zero));
  final RelativeRect position =
      RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy);

  // 如果是在对话详情页面，调整菜单位置以避免遮挡输入框
  RelativeRect menuPosition = position;

  if (type == PopupType.chat) {
    // 获取屏幕高度
    final double screenHeight = MediaQuery.of(context).size.height;
    // 获取底部安全区域高度
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;
    // 获取顶部安全区域高度（状态栏）
    final double topSafeArea = MediaQuery.of(context).padding.top;
    // 计算header高度（状态栏高度 + 标题栏高度）
    final double headerHeight = topSafeArea + kChatAppBarHeight;

    final messageInputProvider =
        Provider.of<RCKMessageInputProvider>(context, listen: false);

    // 底部按钮高度
    final double heightBottomBar =
        messageInputProvider.inputType == RCIMIWMessageInputType.emoji ||
                messageInputProvider.inputType == RCIMIWMessageInputType.more
            ? kInputExtentionHeight
            : 0;
    // 计算输入框顶部位置（屏幕底部减去输入框高度和安全区域高度）
    final double inputFieldTop = screenHeight -
        heightBottomBar -
        kInputMultiSelectHeight -
        bottomSafeArea;

    // 如果点击位置在输入框附近，调整菜单位置
    if (offset.dy > inputFieldTop - 300) {
      // 预留一些空间，避免菜单太靠近输入框
      // 将菜单显示在点击位置上方
      menuPosition = RelativeRect.fromLTRB(
          offset.dx,
          inputFieldTop - 300, // 将菜单放在输入框上方
          offset.dx,
          offset.dy);
    }

    // 如果点击位置在header及以上，调整菜单位置
    if (offset.dy <= (headerHeight + 50)) {
      // 将菜单显示在header下方
      menuPosition = RelativeRect.fromLTRB(
          offset.dx,
          headerHeight + 50, // 将菜单放在header下方
          offset.dx,
          offset.dy);
    }
  }

  // 使用自定义主题和样式设置
  return showMenu<String>(
    menuPadding: EdgeInsets.zero,
    context: context,
    position: menuPosition,
    elevation: 8.0, // 阴影高度
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // 圆角为10
    ),
    constraints: const BoxConstraints(
      minWidth: 160,
      maxWidth: 160, // 固定宽度为160
    ),
    color: RCKThemeProvider().themeColor.textInverse, // 背景色
    items: [
      // 顶部填充
      const PopupMenuItem<String>(
        enabled: false,
        height: 4, // 顶部padding高度
        padding: EdgeInsets.zero,
        child: SizedBox(),
      ),
      // 真实菜单项
      ...(items ??
          (switch (type) {
            PopupType.convo => defaultItemsConvo,
            PopupType.chat => defaultItemsChat,
            PopupType.bubbleAppend => defaultItemsBubbleAppend,
          })),
      // 底部填充
      const PopupMenuItem<String>(
        enabled: false,
        height: 4, // 底部padding高度
        padding: EdgeInsets.zero,
        child: SizedBox(),
      ),
    ],
    // 自定义内边距和项目间距
    surfaceTintColor: Colors.transparent,
    shadowColor: const Color(0x33000000), // 阴影颜色对应 #00000033
  );
}
