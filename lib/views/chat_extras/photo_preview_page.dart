import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:rongcloud_im_kit/utils/image_util.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class RCKPhotoPreviewPage extends StatefulWidget {
  /// 当前查看的图片索引
  final int currentIndex;

  /// 图片消息列表
  final List<RCIMIWMediaMessage> images;

  const RCKPhotoPreviewPage({
    super.key,
    this.currentIndex = 0,
    required this.images,
  });

  @override
  State<RCKPhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<RCKPhotoPreviewPage> {
  late int currentIndex;
  late PageController _pageController;
  late List<RCIMIWMediaMessage> images;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: currentIndex);
    images = widget.images;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(RCIMIWMediaMessage message) {
    // 优先使用本地地址，如果没有则使用远程地址
    if (message.local?.isNotEmpty == true) {
      String filePath = message.local!;
      if (!kIsWeb && filePath.startsWith('file://') && Platform.isAndroid) {
        filePath = filePath.substring(7);
      }
      return filePath;
    } else if (message.remote?.isNotEmpty == true) {
      return message.remote!;
    }
    return '';
  }

  Future<void> _saveImage(String url) async {
    // 在 Web 平台上不支持保存到相册
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Web 平台不支持保存到相册')),
        );
      }
      return;
    }

    try {
      if (url.startsWith('http')) {
        final response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(response.data),
          quality: 100,
          name: 'image_${DateTime.now().millisecondsSinceEpoch}',
        );
        if (result['isSuccess']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片已保存到相册')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存失败')),
            );
          }
        }
      } else if (url.isNotEmpty) {
        final mimeType = await ImageUtil.detectImageFormat(url);
        // 判断图片是否有正确后缀
        if (mimeType != null) {
          final expectedExtension = '.$mimeType';
          if (!url.toLowerCase().endsWith(expectedExtension)) {
            // 如果文件没有后缀或后缀不正确，创建一个新的临时文件并复制内容
            final File originalFile = File(url);
            if (await originalFile.exists()) {
              final newPath = '$url$expectedExtension';

              // 复制文件内容
              await originalFile.copy(newPath);

              // 更新URL为新文件路径
              url = newPath;
            }
          }
        }
        final result = await ImageGallerySaverPlus.saveFile(url);
        if (result['isSuccess']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片已保存到相册')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('保存失败')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  void _showSaveMenu(BuildContext context, String url) {
    // 使用底部弹出菜单代替Snackbar
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 保存按钮
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('保存到相册'),
                onTap: () {
                  Navigator.pop(context);
                  _saveImage(url);
                },
              ),
              const Divider(height: 1),
              // 取消按钮
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageView(String url) {
    if (url.startsWith('http')) {
      return GestureDetector(
        onLongPress: () => _showSaveMenu(context, url),
        child: PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
        ),
      );
    } else if (url.isNotEmpty && !kIsWeb) {
      return GestureDetector(
        onLongPress: () => _showSaveMenu(context, url),
        child: PhotoView(
          imageProvider: FileImage(File(url)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
        ),
      );
    }
    return const Center(child: Text('图片加载失败'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              String imageUrl = _getImageUrl(images[index]);
              return PhotoViewGalleryPageOptions.customChild(
                child: _buildImageView(imageUrl),
                onTapUp: (context, details, controllerValue) {
                  Navigator.pop(context);
                },
              );
            },
            itemCount: images.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event?.expectedTotalBytes != null
                    ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                    : null,
              ),
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          // 页码指示器
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              '${currentIndex + 1}/${images.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
