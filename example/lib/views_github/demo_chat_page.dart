import 'package:flutter/material.dart';

class DemoChatPage extends StatelessWidget {
  const DemoChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天页面说明'),
        automaticallyImplyLeading: false, // 禁用自动返回按钮
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          '关于聊天页面',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'RCKChatPage 是融云IM Kit提供的聊天页面组件。\n\n'
                      '在实际使用中，应该从会话列表点击进入聊天页面，'
                      '而不是单独设置参数。',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '主要功能',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• 发送文本、图片、语音等消息'),
                    Text('• 支持消息撤回、删除'),
                    Text('• 支持@功能'),
                    Text('• 支持表情、更多功能扩展'),
                    Text('• 支持自定义消息气泡'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '使用方式',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. 从会话列表点击进入：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'RCKConvoPage(\n'
                        '  onItemTap: (conversation, index, context) {\n'
                        '    Navigator.push(\n'
                        '      context,\n'
                        '      MaterialPageRoute(\n'
                        '        builder: (context) => RCKChatPage(\n'
                        '          conversation: conversation,\n'
                        '        ),\n'
                        '      ),\n'
                        '    );\n'
                        '  },\n'
                        ')',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '2. 或者先获取会话对象：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'engine.getConversations(\n'
                        '  [conversationType],\n'
                        '  channelId,\n'
                        '  startTime,\n'
                        '  count,\n'
                        '  callback: (conversations) {\n'
                        '    RCKChatPage(\n'
                        '      conversation: conversations[0],\n'
                        '    )\n'
                        '  }\n'
                        ');',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '注意事项',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '重要提示',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• conversation参数必须是从SDK获取的真实对象\n'
                      '• 不能手动创建conversation对象\n'
                      '• 通常从会话列表点击进入聊天页面',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
