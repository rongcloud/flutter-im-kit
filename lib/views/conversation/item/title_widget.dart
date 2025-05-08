import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

typedef TitleBuilder = Widget Function(BuildContext context,
    RCIMIWConversation conversation, RCKConvoTitleConfig config);

class TitleWidget extends StatelessWidget {
  final RCIMIWConversation conversation;
  final RCKConvoTitleConfig config;
  final RCKChatProfileInfo? customInfo;
  const TitleWidget({
    super.key,
    required this.conversation,
    this.config = const RCKConvoTitleConfig(),
    this.customInfo,
  });

  @override
  Widget build(BuildContext context) {
    // 根据会话类型和属性确定标题文本
    String titleText = '';

    titleText = conversation.targetId ?? '';

    if (customInfo != null && customInfo!.name.isNotEmpty) {
      titleText = customInfo!.name;
    }
    // 创建标题文本
    Widget titleTextWidget = Flexible(
      fit: FlexFit.loose,
      child: Text(
        titleText,
        style: TextStyle(
          fontSize: config.fontSize,
          color: config.color ?? RCKThemeProvider().themeColor.textPrimary,
          fontWeight: config.fontWeight,
        ),
        maxLines: config.maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // 如果需要显示后缀
    if (config.showSuffix) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleTextWidget,
          const SizedBox(width: 4),
          // 显示后缀图标或文本
          if (config.suffixIcon != null)
            Icon(
              config.suffixIcon,
              size: 16,
              color: config.suffixTextStyle?.color ?? Colors.blue,
            )
          else if (config.suffixText != null)
            Text(
              config.suffixText!,
              style: config.suffixTextStyle ??
                  TextStyle(fontSize: config.fontSize - 2, color: Colors.grey),
            ),
        ],
      );
    } else {
      return titleTextWidget;
    }
  }
}
