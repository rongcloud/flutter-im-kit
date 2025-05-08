import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

typedef ConvoAppBarBuilder = PreferredSizeWidget Function(
    BuildContext context, RCKConvoAppBarConfig config);

class RCKConvoAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  /// AppBar配置
  final RCKConvoAppBarConfig config;

  RCKConvoAppBarWidget({
    super.key,
    RCKConvoAppBarConfig? config,
  }) : config = config ?? RCKConvoAppBarConfig();

  @override
  Size get preferredSize => Size.fromHeight(config.height);

  @override
  Widget build(BuildContext context) {
    // 检查是否需要自定义背景
    bool needCustomBackground = config.backgroundConfig.image != null ||
        config.backgroundConfig.gradient != null ||
        config.backgroundConfig.border != null ||
        config.backgroundConfig.borderRadius != null ||
        config.backgroundConfig.boxShadow != null;

    return AppBar(
      backgroundColor: config.backgroundConfig.color ??
          (RCKThemeProvider().currentTheme == RCIMIWAppTheme.light
              ? RCKThemeProvider().themeColor.bgAuxiliary1
              : RCKThemeProvider().themeColor.bgRegular),
      automaticallyImplyLeading: config.automaticallyImplyLeading,
      leading: _buildLeadingWidget(),
      title: _buildTitleWidget(),
      centerTitle: config.centerTitle,
      actions: _buildActionsWidgets(),
      flexibleSpace: needCustomBackground
          ? Container(
              decoration: BoxDecoration(
                color: config.backgroundConfig.color,
                image: config.backgroundConfig.image,
                gradient: config.backgroundConfig.gradient,
                border: config.backgroundConfig.border,
                borderRadius: config.backgroundConfig.borderRadius,
                boxShadow: config.backgroundConfig.boxShadow,
              ),
            )
          : null,
      toolbarHeight: config.height,
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

  // 构建左侧区域Widget
  Widget? _buildLeadingWidget() {
    if (config.leadingConfig.icon == null &&
        config.leadingConfig.text == null) {
      return null;
    }

    return InkWell(
      onTap: config.leadingConfig.onPressed,
      child: Container(
        padding: config.leadingConfig.padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.leadingConfig.icon != null) config.leadingConfig.icon!,
            if (config.leadingConfig.icon != null &&
                config.leadingConfig.text != null)
              SizedBox(width: config.leadingConfig.spacing),
            if (config.leadingConfig.text != null)
              Flexible(
                child: Text(
                  config.leadingConfig.text!,
                  style: config.leadingConfig.textStyle,
                  overflow: config.leadingConfig.textOverflow,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建标题Widget
  Widget _buildTitleWidget() {
    Widget titleContent;

    if (config.titleConfig.prefixIcon == null &&
        config.titleConfig.suffixIcon == null) {
      // 只有文本
      titleContent = Text(
        config.titleConfig.text,
        style: config.titleConfig.textStyle,
        overflow: config.titleConfig.textOverflow,
      );
    } else {
      // 有图标和文本
      titleContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: config.titleConfig.alignment,
        children: [
          if (config.titleConfig.prefixIcon != null) ...[
            config.titleConfig.prefixIcon!,
            SizedBox(width: config.titleConfig.spacing),
          ],
          Flexible(
            child: Text(
              config.titleConfig.text,
              style: config.titleConfig.textStyle,
              overflow: config.titleConfig.textOverflow,
            ),
          ),
          if (config.titleConfig.suffixIcon != null) ...[
            SizedBox(width: config.titleConfig.spacing),
            config.titleConfig.suffixIcon!,
          ],
        ],
      );
    }

    // 应用padding
    return Padding(
      padding: config.titleConfig.padding,
      child: titleContent,
    );
  }

  // 构建操作按钮列表
  List<Widget> _buildActionsWidgets() {
    // if (config.actionsConfig.items.isEmpty) {
    //   return [_buildDefaultAddButton()];
    // }

    return config.actionsConfig.items.map((item) {
      if (item.text == null) {
        // 只有图标
        return IconButton(
          icon: item.icon,
          onPressed: item.onPressed,
          padding: item.padding,
        );
      } else {
        // 图标和文本
        return InkWell(
          onTap: item.onPressed,
          child: Padding(
            padding: item.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                item.icon,
                SizedBox(width: item.spacing),
                Text(
                  item.text!,
                  style: item.textStyle,
                  overflow: item.textOverflow,
                ),
              ],
            ),
          ),
        );
      }
    }).toList();
  }

  // // 构建默认的添加按钮
  // Widget _buildDefaultAddButton() {
  //   return Builder(
  //     builder: (context) {
  //       return IconButton(
  //         icon: const Icon(Icons.add),
  //         onPressed: () {
  //           final RenderBox button = context.findRenderObject() as RenderBox;
  //           final RenderBox overlay =
  //               Overlay.of(context)!.context.findRenderObject() as RenderBox;
  //           final RelativeRect position = RelativeRect.fromRect(
  //             Rect.fromPoints(
  //               button.localToGlobal(Offset.zero, ancestor: overlay),
  //               button.localToGlobal(button.size.bottomRight(Offset.zero),
  //                   ancestor: overlay),
  //             ),
  //             Offset.zero & overlay.size,
  //           );
  //           showMenu<String>(
  //             context: context,
  //             position: position,
  //             items: [
  //               const PopupMenuItem<String>(
  //                 value: 'create_group',
  //                 child: Text('创建群组'),
  //               ),
  //             ],
  //           ).then((value) {
  //             if (value == 'create_group') {
  //               Navigator.pushNamed(context, '/create_group');
  //             }
  //           });
  //         },
  //       );
  //     },
  //   );
  // }
}
