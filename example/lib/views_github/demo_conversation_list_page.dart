import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:provider/provider.dart';

class DemoConversationListPage extends StatelessWidget {
  const DemoConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会话列表'),
        automaticallyImplyLeading: false, // 禁用自动返回按钮
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('关于会话列表'),
                  content: const Text(
                    '这是融云IM Kit提供的会话列表页面。\n\n'
                    '在未连接状态下，页面会显示空状态。\n'
                    '连接成功后，会自动显示会话列表。\n\n'
                    '主要功能：\n'
                    '• 显示所有会话\n'
                    '• 点击会话直接进入聊天页面\n'
                    '• 支持删除、置顶等操作\n'
                    '• 显示未读消息数',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          // 断开连接按钮
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('断开连接'),
                  content: const Text('确定要断开与融云服务器的连接吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 断开连接
                        final engineProvider = Provider.of<RCKEngineProvider>(
                            context,
                            listen: false);
                        engineProvider.disconnect();

                        // 返回到设置页面
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 会话列表组件
          Expanded(
            child: RCKConvoPage(
              // 自定义点击事件
              onItemTap: (buildContext, conversation, index) {
                // 直接跳转到聊天页面
                Navigator.push(
                  buildContext,
                  MaterialPageRoute(
                    builder: (context) => RCKChatPage(
                      conversation: conversation,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
