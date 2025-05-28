import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rongcloud_im_kit/utils/file_util.dart';

class RCKFilePreviewPage extends StatefulWidget {
  /// 文件消息对象
  final RCIMIWFileMessage fileMessage;

  const RCKFilePreviewPage({
    super.key,
    required this.fileMessage,
  });

  @override
  RCKFilePreviewPageState createState() => RCKFilePreviewPageState();
}

class RCKFilePreviewPageState extends State<RCKFilePreviewPage> {
  late RCIMIWFileMessage fileMessage;

  @override
  void initState() {
    super.initState();
    fileMessage = widget.fileMessage;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  String _getProgressKey(int? messageId) => 'file_${messageId ?? 0}';

  @override
  Widget build(BuildContext context) {
    final progressKey = _getProgressKey(fileMessage.messageId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('文件预览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              if (fileMessage.local != null && fileMessage.local!.isNotEmpty) {
                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(fileMessage.local!)],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileMessage.name ?? '未知文件',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FileUtil.formatFileSize(fileMessage.size ?? 0),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Consumer<RCKDownloadProgressProvider>(
            builder: (context, provider, child) {
              double progress = provider.getProgress(progressKey).value;
              bool isDownloaded =
                  fileMessage.local != null && fileMessage.local!.isNotEmpty;

              if (progress > 0 && progress < 1) {
                return Column(
                  children: [
                    CircularProgressIndicator(value: progress),
                    const SizedBox(height: 16),
                    Text('下载中 ${(progress * 100).toInt()}%'),
                  ],
                );
              }

              return ElevatedButton(
                onPressed: isDownloaded
                    ? null
                    : () {
                        // 下载文件
                        context.read<RCKChatProvider>().downloadMediaMessage(
                          fileMessage,
                          downloaded: (code, message) {
                            provider.reset(progressKey);
                            if (message is RCIMIWFileMessage) {
                              fileMessage = message;
                            }
                          },
                          downloading: (message, progress) {
                            provider.updateProgress(
                                progressKey, (progress ?? 0) / 100);
                          },
                          downloadCancel: (message) {
                            provider.reset(progressKey);
                          },
                        );
                      },
                child: Text(isDownloaded ? '已下载' : '下载文件'),
              );
            },
          ),
        ],
      ),
    );
  }
}
