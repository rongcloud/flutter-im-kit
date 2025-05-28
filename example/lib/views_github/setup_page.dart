// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _appKeyController = TextEditingController();
  final _tokenController = TextEditingController();
  final _naviServerController = TextEditingController();
  final _fileServerController = TextEditingController();

  bool _isConnecting = false;

  @override
  void dispose() {
    _appKeyController.dispose();
    _tokenController.dispose();
    _naviServerController.dispose();
    _fileServerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RongCloud IM Kit Demo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎使用融云 Flutter IM Kit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '这是一个简单的演示Demo，展示了如何快速集成融云IM Kit。',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. 输入App Key和Token，点击"连接融云服务器"',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '2. 连接成功后自动跳转到会话列表',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '3. 点击会话列表中的会话进入聊天页面',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // App Key 输入
            TextField(
              controller: _appKeyController,
              decoration: const InputDecoration(
                labelText: 'App Key *',
                hintText: '请输入您的融云 App Key',
                border: OutlineInputBorder(),
                helperText: '从融云开发者后台获取',
              ),
            ),
            const SizedBox(height: 16),

            // Token 输入
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Token *',
                hintText: '请输入用户 Token',
                border: OutlineInputBorder(),
                helperText: '通过服务端 API 获取',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // 高级选项（可选）
            ExpansionTile(
              title: const Text('高级选项（可选）'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _naviServerController,
                        decoration: const InputDecoration(
                          labelText: '导航服务器地址',
                          hintText: '留空使用默认地址',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _fileServerController,
                        decoration: const InputDecoration(
                          labelText: '文件服务器地址',
                          hintText: '留空使用默认地址',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 连接按钮
            ElevatedButton(
              onPressed: _isConnecting ? null : _connect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isConnecting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('连接融云服务器', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    final appKey = _appKeyController.text.trim();
    final token = _tokenController.text.trim();

    if (appKey.isEmpty || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 App Key 和 Token')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final engineProvider =
          Provider.of<RCKEngineProvider>(context, listen: false);

      // 创建引擎选项
      RCIMIWEngineOptions options = RCIMIWEngineOptions.create();
      if (_naviServerController.text.isNotEmpty) {
        options.naviServer = _naviServerController.text.trim();
      }
      if (_fileServerController.text.isNotEmpty) {
        options.fileServer = _fileServerController.text.trim();
      }

      // 创建引擎
      await engineProvider.engineCreate(appKey, options);

      // 连接服务器
      await engineProvider.engineConnect(
        token,
        30,
        onResult: (code) {
          setState(() {
            _isConnecting = false;
          });

          if (code == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('连接成功！')),
            );
            // 连接成功后跳转到会话列表页面
            Navigator.pushReplacementNamed(context, '/conversation_list');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('连接失败，错误码：$code')),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('连接出错：$e')),
      );
    }
  }
}
