import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import '../../../ui_config/chat/page/chat_app_bar_config.dart';
import 'leading_widget.dart';

typedef ChatAppBarBuilder = PreferredSizeWidget Function(
    BuildContext context, RCKChatAppBarConfig config);

class RCKChatAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  /// AppBar配置
  final RCKChatAppBarConfig config;

  /// 会话标题（如果不使用config中的标题）
  final String? title;

  /// 标题点击回调
  final VoidCallback? onTitleTap;

  /// 自定义Leading构建器
  final LeadingBuilder? leadingBuilder;

  /// 返回按钮点击回调
  final VoidCallback? onLeadingPressed;

  /// 操作按钮点击回调列表
  final List<VoidCallback>? onActionPressed;

  const RCKChatAppBarWidget({
    super.key,
    this.config = const RCKChatAppBarConfig(),
    this.title,
    this.onTitleTap,
    this.leadingBuilder,
    this.onLeadingPressed,
    this.onActionPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(config.height);

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;

    Widget? textWidget;
    if (config.titleConfig.text != null) {
      textWidget = Text(
        config.titleConfig.text!,
        style: config.titleConfig.textStyle,
      );
    } else if (title != null) {
      textWidget = Text(
        title ?? '',
        style: TextStyle(
          color: RCKThemeProvider().themeColor.textPrimary,
          fontSize: appbarFontSize,
          fontWeight: appbarFontWeight,
        ),
      );
    }

    titleWidget = GestureDetector(
      onTap: onTitleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: config.titleConfig.alignment,
        children: [
          if (config.titleConfig.prefixIcon != null)
            config.titleConfig.prefixIcon!,
          if (config.titleConfig.prefixIcon != null && textWidget != null)
            SizedBox(width: config.titleConfig.spacing),
          if (textWidget != null) textWidget,
          if (textWidget != null && config.titleConfig.suffixIcon != null)
            SizedBox(width: config.titleConfig.spacing),
          if (config.titleConfig.suffixIcon != null)
            config.titleConfig.suffixIcon!,
        ],
      ),
    );

    // 构建操作按钮
    List<Widget> actions = [];

    // 使用配置的操作按钮
    for (var i = 0; i < config.actionsConfig.items.length; i++) {
      var item = config.actionsConfig.items[i];
      actions.add(
        Padding(
          padding: item.padding,
          child: InkWell(
            onTap: onActionPressed != null && i < onActionPressed!.length
                ? onActionPressed![i]
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                item.icon,
                if (item.text != null)
                  Padding(
                    padding: EdgeInsets.only(left: item.spacing),
                    child: Text(item.text!, style: item.textStyle),
                  ),
              ],
            ),
          ),
        ),
      );

      // 添加间距（最后一个不需要）
      if (item != config.actionsConfig.items.last) {
        actions.add(SizedBox(width: config.actionsConfig.spacing));
      }
    }

    // 如果操作按钮为空，则添加一个占位符，与标题栏左边保持对称
    if (actions.isEmpty) {
      actions.add(const SizedBox(width: 100));
    }

    // 构建AppBar
    return AppBar(
      backgroundColor: config.backgroundConfig.color ??
          (RCKThemeProvider().currentTheme == RCIMIWAppTheme.dark
              ? RCKThemeProvider().themeColor.bgRegular
              : RCKThemeProvider().themeColor.bgAuxiliary1), // 使用与原AppBar相同的背景色
      leadingWidth: 100, // 设置固定宽度，与原AppBar保持一致
      flexibleSpace: config.backgroundConfig.image != null ||
              config.backgroundConfig.gradient != null ||
              config.backgroundConfig.border != null ||
              config.backgroundConfig.borderRadius != null ||
              config.backgroundConfig.boxShadow != null
          ? Container(
              decoration: BoxDecoration(
                image: config.backgroundConfig.image,
                gradient: config.backgroundConfig.gradient,
                border: config.backgroundConfig.border,
                borderRadius: config.backgroundConfig.borderRadius,
                boxShadow: config.backgroundConfig.boxShadow,
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      leading: leadingBuilder?.call(context, config.leadingConfig) ??
          LeadingWidget(
            config: config.leadingConfig,
            onPressed: onLeadingPressed,
          ),
      title: titleWidget,
      centerTitle: config.centerTitle,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: RCKThemeProvider().currentTheme == RCIMIWAppTheme.dark
              ? const Color(0xFF1D1D1D)
              : RCKThemeProvider().themeColor.outline,
        ),
      ),
    );
  }
}
