import 'package:flutter/material.dart';
import '../../../ui_config/chat/page/chat_app_bar_config.dart';

/// Leading部件的构建器类型定义
typedef LeadingBuilder = Widget Function(
    BuildContext context, RCKLeadingConfig config);

/// AppBar左侧Leading部件
class LeadingWidget extends StatelessWidget {
  /// 配置
  final RCKLeadingConfig config;

  /// 点击事件回调
  final VoidCallback? onPressed;

  const LeadingWidget({
    super.key,
    this.config = const RCKLeadingConfig(),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 默认使用返回按钮
    if (config.icon == null && config.text == null) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
      );
    }

    // 根据配置构建
    return InkWell(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Padding(
        padding: config.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.icon != null) config.icon!,
            if (config.icon != null && config.text != null)
              SizedBox(width: config.spacing),
            if (config.text != null)
              Text(
                config.text!,
                style: config.textStyle,
              ),
          ],
        ),
      ),
    );
  }
}
