import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_kit/views/chat/input/message_input_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:photo_manager/photo_manager.dart' as pm;
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

  @override
  GridButtonWidgetState createState() => GridButtonWidgetState();
}

class GridButtonWidgetState extends State<GridButtonWidget> {
  int _currentPage = 0;
  late final PageController _pageController;

  // 默认配置，当widget.config为null时使用
  static const _defaultConfig = RCKExtensionMenuConfig();
  // 标题区域高度，统一用于计算 childAspectRatio 与项容器高度，保持原有高度
  static const double _titleAreaHeight = 22.0;

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
      childAspectRatio: kInputExtentionItemSize /
          (kInputExtentionItemSize + _titleAreaHeight),
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
        onTap: () async {
          if (item.onTapWithContext != null) {
            await item.onTapWithContext!(context);
          } else {
            item.onTap?.call();
          }
        },
        child: SizedBox(
            width: kInputExtentionItemSize,
            height: kInputExtentionItemSize + _titleAreaHeight,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  strutStyle: const StrutStyle(
                    forceStrutHeight: true,
                    height: 1.0,
                    leading: 0,
                  ),
                  style: item.titleStyle ??
                      TextStyle(
                        fontSize: kInputExtentionItemFontSize,
                        height: 1.0,
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

List<RCKExtensionMenuItemConfig> getDefaultGridItems(
    {TapBeforePermissionCallback? onTapBeforePermission}) {
  return [
    RCKExtensionMenuItemConfig(
      title: '照片',
      icon:
          ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.gallery ?? ''),
      onTapWithContext: (context) async {
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
          await onTapBeforePermission(context, checkPermission);
        }
        final status = await checkPermission.request();

        if (status.isGranted) {
          // 有权限
          if (context.mounted) {
            context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
          }

          List<AssetEntity>? assets = [];
          if (context.mounted) {
            assets = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                requestType: RequestType.image,
                maxAssets: 50,
                textDelegate: const AssetPickerTextDelegate(),
              ),
            );
          }

          if (assets == null || assets.isEmpty) return;

          String imageFileListString = '';
          for (int i = 0; i < assets.length; i++) {
            final asset = assets[i];
            final file = await asset.file;
            final path = file?.path ?? '';
            imageFileListString += path;
            if (i < assets.length - 1) imageFileListString += '|';

            if (path.isEmpty) continue;
            final mime = asset.mimeType ?? '';
            if (mime == 'image/gif' || path.toLowerCase().endsWith('.gif')) {
              if (context.mounted) {
                await context.read<RCKChatProvider>().addGifMessage(path);
              }
            } else {
              if (context.mounted) {
                await context.read<RCKChatProvider>().addImageMessage(path);
              }
            }
          }
          RCIMWrapperPlatform.instance.writeLog(
              'GridButtonWidget pickAssets(images)',
              '',
              0,
              imageFileListString);
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
      onTapWithContext: (context) async {
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
          await onTapBeforePermission(context, checkPermission);
        }
        final status = await checkPermission.request();

        if (status.isGranted) {
          // 有权限
          if (context.mounted) {
            context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
          }

          List<AssetEntity>? result = [];
          if (context.mounted) {
            result = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                requestType: RequestType.video,
                maxAssets: 1,
                filterOptions: pm.FilterOptionGroup()
                  ..setOption(
                    pm.AssetType.video,
                    const pm.FilterOption(
                      durationConstraint:
                          pm.DurationConstraint(max: Duration(seconds: 11)),
                    ),
                  ),
                textDelegate: const AssetPickerTextDelegate(),
              ),
            );
          }

          if (result != null && result.isNotEmpty) {
            final AssetEntity picked = result.first;
            final file = await picked.file;
            final path = file?.path;
            final durationSec = picked.duration;
            if (path == null || path.isEmpty) return;
            // 获取视频时长（双保险）
            if (durationSec > 10) {
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('提示'),
                    content: const Text('视频时长不能超过10秒'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
              }
              return;
            }
            RCIMWrapperPlatform.instance.writeLog('GridButtonWidget pickVideo',
                '', 0, 'video: $path duration: $durationSec');

            if (context.mounted) {
              context
                  .read<RCKChatProvider>()
                  .addSightMessage(path, durationSec);
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
      icon: ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.camera ?? ''),
      onTapWithContext: (context) async {
        // 检查相机权限
        Permission checkPermission = Permission.camera;
        if (onTapBeforePermission != null) {
          await onTapBeforePermission(context, checkPermission);
        }
        final status = await checkPermission.request();
        if (status.isGranted) {
          // 有权限
          if (context.mounted) {
            context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
          }

          AssetEntity? shot;
          if (context.mounted) {
            shot = await CameraPicker.pickFromCamera(
              context,
              pickerConfig: const CameraPickerConfig(
                enableRecording: false,
                textDelegate: CameraPickerTextDelegate(),
              ),
            );
          }

          final file = await shot?.file;
          final String? path = file?.path;
          RCIMWrapperPlatform.instance
              .writeLog('GridButtonWidget cameraPhoto', '', 0, 'path: $path');

          if (path != null && path.isNotEmpty) {
            if (context.mounted) {
              context.read<RCKChatProvider>().addImageMessage(path);
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
      icon: ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.filming ?? '',
          color: RCKThemeProvider().themeColor.textPrimary),
      onTapWithContext: (context) async {
        // 检查相机权限
        Permission checkPermission = Permission.camera;
        if (onTapBeforePermission != null) {
          await onTapBeforePermission(context, checkPermission);
        }
        final status = await checkPermission.request();
        if (status.isGranted) {
          // 有权限
          if (context.mounted) {
            context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
          }

          AssetEntity? pickMedia;
          if (context.mounted) {
            pickMedia = await CameraPicker.pickFromCamera(
              context,
              pickerConfig: const CameraPickerConfig(
                enableRecording: true,
                onlyEnableRecording: true,
                enableTapRecording: true,
                maximumRecordingDuration: Duration(seconds: 10),
                textDelegate: CameraPickerTextDelegate(),
              ),
            );
          }

          if (pickMedia != null) {
            final file = await pickMedia.file;
            final String? capturedPath = file?.path;
            if (capturedPath == null || capturedPath.isEmpty) return;

            VideoPlayerController videoPlayerController =
                VideoPlayerController.file(File(capturedPath));
            await videoPlayerController.initialize();
            int videoDuration = videoPlayerController.value.duration.inSeconds;

            RCIMWrapperPlatform.instance.writeLog('GridButtonWidget pickVideo',
                '', 0, 'pickMedia: $capturedPath duration: $videoDuration');

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
                  .addSightMessage(capturedPath, videoDuration);
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
      title: '文件',
      icon:
          ImageUtil.getImageWidget(RCKThemeProvider().themeIcon.document ?? ''),
      onTapWithContext: (context) async {
        FilePickerResult? res = await FilePicker.platform.pickFiles();
        if (res != null) {
          String resString = '';
          for (int i = 0; i < res.files.length; i++) {
            resString += res.files[i].path ?? '';
            if (i < res.files.length - 1) {
              resString += '|';
            }
          }

          RCIMWrapperPlatform.instance
              .writeLog('GridButtonWidget pickFiles', '', 0, 'res: $resString');

          if (context.mounted) {
            context
                .read<RCKChatProvider>()
                .addFileMessage(res.files.single.path!);
          }
        }
      },
      iconSize: kInputExtentionIconSize,
    ),
  ];
}
