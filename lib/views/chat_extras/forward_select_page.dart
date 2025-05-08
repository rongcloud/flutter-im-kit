import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../rongcloud_im_kit.dart';

class RCKForwardSelectPage extends StatefulWidget {
  const RCKForwardSelectPage({
    super.key,
  });

  @override
  RCKForwardSelectPageState createState() => RCKForwardSelectPageState();
}

class RCKForwardSelectPageState extends State<RCKForwardSelectPage> {
  late CustomInfoProvider? customInfoProvider;

  @override
  void initState() {
    super.initState();
    customInfoProvider = context.read<RCKEngineProvider>().customInfoProvider;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RCKForwardProvider>(
        create: (_) {
          final provider = RCKForwardProvider(context.read<RCKChatProvider>());
          // 在Provider创建后立即获取聊天资料信息
          if (customInfoProvider != null) {
            // 使用Future.microtask确保在build完成后执行
            // Future.delayed(const Duration(seconds: 2), () {
            provider.setCustomInfoProvider(context, customInfoProvider!);
            // });
          }
          return provider;
        },
        child: Scaffold(
            backgroundColor: RCKThemeProvider().themeColor.bgRegular,
            appBar: AppBar(
              backgroundColor: RCKThemeProvider().themeColor.bgRegular,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: RCKThemeProvider().themeColor.textPrimary,
                ),
              ),
              title: Text(
                "选择一个聊天",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RCKThemeProvider().themeColor.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  color: RCKThemeProvider().themeColor.bgTop,
                ),
              ),
            ),
            body: Consumer<RCKForwardProvider>(
                builder: (context, forwardProvider, child) {
              bool isChatProfileInfosEmpty =
                  forwardProvider.chatProfileInfos.isEmpty;

              int itemCount = isChatProfileInfosEmpty
                  ? forwardProvider.conversationsToForward.length
                  : forwardProvider.chatProfileInfos.length;

              return ListView.builder(
                itemCount: itemCount,
                itemBuilder: (itemContext, index) {
                  String title = '';
                  if (!isChatProfileInfosEmpty) {
                    title = forwardProvider.chatProfileInfos[index].name;
                  } else {
                    title = forwardProvider
                            .conversationsToForward[index].targetId ??
                        '';
                  }
                  String? portrait = '';
                  if (!isChatProfileInfosEmpty) {
                    portrait = forwardProvider.chatProfileInfos[index].avatar;
                  }

                  // 默认头像图片
                  Widget defaultAvatar =
                      ImageUtil.getImageWidget('avatar_default_single.png');

                  // 根据会话类型选择头像
                  Widget avatarImage;

                  if (forwardProvider
                          .conversationsToForward[index].conversationType ==
                      RCIMIWConversationType.private) {
                    // 单聊默认头像
                    avatarImage =
                        ImageUtil.getImageWidget('avatar_default_single.png');
                  } else if (forwardProvider
                          .conversationsToForward[index].conversationType ==
                      RCIMIWConversationType.group) {
                    // 群聊默认头像
                    avatarImage =
                        ImageUtil.getImageWidget('avatar_default_group.png');
                  } else if (forwardProvider
                          .conversationsToForward[index].conversationType ==
                      RCIMIWConversationType.system) {
                    // 系统消息默认头像
                    avatarImage =
                        ImageUtil.getImageWidget('avatar_default_system.png');
                  } else {
                    // 其他类型使用通用默认头像
                    avatarImage = defaultAvatar;
                  }

                  if (portrait.isNotEmpty) {
                    avatarImage = ImageUtil.getImageWidget(portrait);
                  }
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 25),
                    minTileHeight: 62,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: avatarImage,
                    ),
                    title: Text(title,
                        style: TextStyle(
                          color: RCKThemeProvider().themeColor.textPrimary,
                          fontSize: 16,
                        )),
                    onTap: () async {
                      forwardProvider.forwardMessages(
                          forwardProvider.conversationsToForward[index],
                          context);
                      if (itemContext.mounted) {
                        Navigator.pop(itemContext);
                      }
                    },
                  );
                },
              );
            })));
  }
}
