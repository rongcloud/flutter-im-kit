import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rongcloud_im_kit/views/chat/input/message_input_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

// Grid按钮项Builder - 直接使用ExtensionMenuItemConfig
typedef GridItemBuilder = Widget Function(
  BuildContext context,
  RCKExtensionMenuItemConfig item,
);

class GridButtonWidget extends StatefulWidget {
  final List<RCKExtensionMenuItemConfig> items;
  final RCKExtensionMenuConfig? config;
  static final ImagePicker _picker = ImagePicker();

  // 新增Grid项的Builder
  final GridItemBuilder? gridItemBuilder;

  // 常规构造函数
  const GridButtonWidget({
    super.key,
    required this.items,
    this.config,
    this.gridItemBuilder,
  });

  /// 使用配置创建GridButtonWidget
  factory GridButtonWidget.fromConfig(RCKExtensionMenuConfig config,
      {GridItemBuilder? gridItemBuilder}) {
    return GridButtonWidget(
      items: config.items,
      config: config,
      gridItemBuilder: gridItemBuilder,
    );
  }

  static List<RCKExtensionMenuItemConfig> getDefaultGridItems(
      BuildContext context,
      {TapBeforePermissionCallback? onTapBeforePermission}) {
    return [
      RCKExtensionMenuItemConfig(
        title: '照片',
        icon: ImageUtil.getImageWidget(
            RCKThemeProvider().themeIcon.gallery ?? ''),
        onTap: () async {
          // 检查相册权限
          Permission checkPermission;
          if (Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            if (androidInfo.version.sdkInt <= 32) {
              checkPermission = Permission.storage;
            } else {
              checkPermission = Permission.photos;
            }
          } else {
            checkPermission = Permission.photos;
          }
          if (onTapBeforePermission != null && context.mounted) {
            onTapBeforePermission(context, checkPermission);
          }
          final status = await checkPermission.request();

          if (status.isGranted) {
            // 有权限
            if (context.mounted) {
              context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
            }
            List<XFile> imageFileList = await _picker.pickMultiImage();

            String imageFileListString = '';
            for (int i = 0; i < imageFileList.length; i++) {
              imageFileListString += imageFileList[i].path;
              if (i < imageFileList.length - 1) {
                imageFileListString += '|';
              }
            }
            RCIMWrapperPlatform.instance.writeLog(
                'GridButtonWidget pickMultiImage',
                '',
                0,
                'imageFileList: $imageFileListString');

            for (int i = 0; i < imageFileList.length; i++) {
              XFile imageFile = imageFileList[i];
              if (imageFile.mimeType == 'image/gif' ||
                  imageFile.path.endsWith('.gif')) {
                if (context.mounted) {
                  await context
                      .read<RCKChatProvider>()
                      .addGifMessage(imageFile.path);
                }
              } else {
                if (context.mounted) {
                  await context
                      .read<RCKChatProvider>()
                      .addImageMessage(imageFile.path);
                }
              }
            }
          } else {
            // 权限被拒绝，显示提示
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('需要相册权限才能选择图片'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '视频',
        icon: ImageUtil.getImageWidget(
            RCKThemeProvider().themeIcon.playVideoInMore ?? '',
            color: RCKThemeProvider().themeColor.textPrimary),
        onTap: () async {
          // 检查相册权限
          Permission checkPermission;
          if (Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            if (androidInfo.version.sdkInt <= 32) {
              checkPermission = Permission.storage;
            } else {
              checkPermission = Permission.photos;
            }
          } else {
            checkPermission = Permission.photos;
          }
          if (onTapBeforePermission != null && context.mounted) {
            onTapBeforePermission(context, checkPermission);
          }
          final status = await checkPermission.request();

          if (status.isGranted) {
            // 有权限
            if (context.mounted) {
              context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
            }
            XFile? imageFile =
                await _picker.pickVideo(source: ImageSource.gallery);
            if (imageFile != null) {
              // 在 Web 平台上不支持本地文件访问
              if (kIsWeb) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Web 平台不支持视频文件处理')),
                  );
                }
                return;
              }

              // 获取视频时长
              final VideoPlayerController controller =
                  VideoPlayerController.file(File(imageFile.path));
              await controller.initialize();
              final Duration duration = controller.value.duration;
              debugPrint('视频时长：${duration.inSeconds} 秒');
              await controller.dispose();

              RCIMWrapperPlatform.instance.writeLog(
                  'GridButtonWidget pickVideo',
                  '',
                  0,
                  'imageFile: ${imageFile.path} duration: ${duration.inSeconds}');

              if (context.mounted) {
                context
                    .read<RCKChatProvider>()
                    .addSightMessage(imageFile.path, duration.inSeconds);
              }
            }
          } else {
            // 权限被拒绝，显示提示
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('需要相册权限才能选择视频'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '拍照',
        icon:
            ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.camera ?? ''),
        onTap: () async {
          // 检查相机权限
          Permission checkPermission = Permission.camera;
          if (onTapBeforePermission != null) {
            onTapBeforePermission(context, checkPermission);
          }
          final status = await checkPermission.request();
          if (status.isGranted) {
            // 有权限
            if (context.mounted) {
              context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
            }
            XFile? pickMedia =
                await _picker.pickImage(source: ImageSource.camera);

            RCIMWrapperPlatform.instance.writeLog('GridButtonWidget pickImage',
                '', 0, 'pickMedia: ${pickMedia?.path}');

            if (pickMedia != null) {
              if (context.mounted) {
                context.read<RCKChatProvider>().addImageMessage(pickMedia.path);
              }
            }
          } else {
            // 权限被拒绝，显示提示
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('需要相机权限才能拍照'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定')),
                  ],
                ),
              );
            }
          }
        },
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '拍摄',
        icon: ImageUtil.getImageWidget(
            RCKThemeProvider().themeIcon.filming ?? '',
            color: RCKThemeProvider().themeColor.textPrimary),
        onTap: () async {
          // 检查相机权限
          Permission checkPermission = Permission.camera;
          if (onTapBeforePermission != null) {
            onTapBeforePermission(context, checkPermission);
          }
          final status = await checkPermission.request();
          if (status.isGranted) {
            // 有权限
            if (context.mounted) {
              context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
            }
            XFile? pickMedia = await _picker.pickVideo(
                source: ImageSource.camera,
                maxDuration: const Duration(seconds: 119));
            if (pickMedia != null) {
              // 在 Web 平台上不支持本地文件访问
              if (kIsWeb) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Web 平台不支持视频文件处理')),
                  );
                }
                return;
              }

              VideoPlayerController videoPlayerController =
                  VideoPlayerController.file(
                      File(pickMedia.path)); //Your file here
              await videoPlayerController.initialize();
              int videoDuration =
                  videoPlayerController.value.duration.inSeconds;

              RCIMWrapperPlatform.instance.writeLog(
                  'GridButtonWidget pickVideo',
                  '',
                  0,
                  'pickMedia: ${pickMedia.path} duration: $videoDuration');

              if (videoDuration <= 1) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('提示'),
                      content: const Text('视频时长不能小于1秒'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('确定')),
                      ],
                    ),
                  );
                }
                return;
              }
              if (context.mounted) {
                context
                    .read<RCKChatProvider>()
                    .addSightMessage(pickMedia.path, videoDuration);
              }
              await videoPlayerController.dispose();
            }
          } else {
            // 权限被拒绝，显示提示
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('需要相机权限才能拍摄'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定')),
                  ],
                ),
              );
            }
          }
        },
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '位置',
        icon:
            ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.local ?? ''),
        onTap: () async {},
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '文件',
        icon: ImageUtil.getImageWidget(
            RCKThemeProvider().themeIcon.document ?? ''),
        onTap: () async {
          // 检查文件权限
          final Permission checkPermission = !kIsWeb && Platform.isAndroid
              ? Permission.manageExternalStorage
              : Permission.storage;
          if (onTapBeforePermission != null) {
            onTapBeforePermission(context, checkPermission);
          }
          final status = await checkPermission.request();
          if (status.isGranted) {
            // 有权限
            FilePickerResult? res = await FilePicker.platform.pickFiles();
            if (res != null) {
              String resString = '';
              for (int i = 0; i < res.files.length; i++) {
                resString += res.files[i].path ?? '';
                if (i < res.files.length - 1) {
                  resString += '|';
                }
              }

              RCIMWrapperPlatform.instance.writeLog(
                  'GridButtonWidget pickFiles', '', 0, 'res: $resString');

              if (context.mounted) {
                context
                    .read<RCKChatProvider>()
                    .addFileMessage(res.files.single.path!);
              }
            }
          } else {
            // 权限被拒绝，显示提示
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('需要文件权限才能选择文件'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定')),
                  ],
                ),
              );
            }
          }
        },
        iconSize: kInputExtentionIconSize,
      ),
      RCKExtensionMenuItemConfig(
        title: '礼物',
        icon: ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.gift ?? ''),
        onTap: () {
          // 处理红包
        },
        iconSize: kInputExtentionIconSize,
      ),
    ];
  }

  @override
  GridButtonWidgetState createState() => GridButtonWidgetState();
}

class GridButtonWidgetState extends State<GridButtonWidget> {
  int _currentPage = 0;
  late final PageController _pageController;

  // 默认配置，当widget.config为null时使用
  static const _defaultConfig = RCKExtensionMenuConfig();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      int page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 获取当前使用的配置
  RCKExtensionMenuConfig get _config => widget.config ?? _defaultConfig;

  int get pageCount => (widget.items.length / _config.itemsPerPage).ceil();

  List<RCKExtensionMenuItemConfig> _getItemsForPage(int page) {
    int start = page * _config.itemsPerPage;
    int end = (start + _config.itemsPerPage) > widget.items.length
        ? widget.items.length
        : start + _config.itemsPerPage;
    return widget.items.sublist(start, end);
  }

  Widget _buildGridPage(List<RCKExtensionMenuItemConfig> items) {
    return GridView.count(
      crossAxisCount: _config.crossAxisCount,
      mainAxisSpacing: _config.mainAxisSpacing,
      crossAxisSpacing: _config.crossAxisSpacing,
      padding: _config.padding,
      childAspectRatio:
          kInputExtentionItemSize / (kInputExtentionItemSize + 22),
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => _buildGridItem(item)).toList(),
    );
  }

  Widget _buildGridItem(RCKExtensionMenuItemConfig item) {
    // 使用自定义builder或默认样式
    if (widget.gridItemBuilder != null) {
      return widget.gridItemBuilder!(context, item);
    }

    return InkWell(
        onTap: item.onTap,
        child: SizedBox(
            width: kInputExtentionItemSize,
            height: kInputExtentionItemSize + 22,
            child: Column(
              children: [
                Container(
                    width: kInputExtentionItemSize,
                    height: kInputExtentionItemSize,
                    decoration: BoxDecoration(
                      color: RCKThemeProvider().themeColor.bgRegular,
                      borderRadius:
                          BorderRadius.circular(kInputExtentionItemRadius),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: item.iconSize,
                        height: item.iconSize,
                        child: item.icon,
                      ),
                    )),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: item.titleStyle ??
                      TextStyle(
                        fontSize: kInputExtentionItemFontSize,
                        color: RCKThemeProvider().themeColor.textSecondary,
                      ),
                ),
              ],
            )));
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? _config.indicatorSelectedColor
                : _config.indicatorUnselectedColor,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _config.backgroundColor,
      child: Stack(
        children: [
          SizedBox(
            height: _config.height,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                return _buildGridPage(_getItemsForPage(index));
              },
            ),
          ),
          if (pageCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: _buildPageIndicator(),
            ),
        ],
      ),
    );
  }
}
