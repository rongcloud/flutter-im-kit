import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:typed_data';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

class ImageUtil {
  /// 用于缓存已经decode的base64图片数据
  static final Map<String, Uint8List> _base64Cache = {};

  /// 获取base64缓存的大小
  static int get base64CacheSize => _base64Cache.length;

  /// 清空base64缓存
  static void clearBase64Cache() {
    _base64Cache.clear();
  }

  /// 从缓存中获取已解码的base64图片数据，如果不存在则解码并缓存
  static Uint8List? getDecodedBase64(String base64String) {
    // 快速检查缓存中是否存在
    if (_base64Cache.containsKey(base64String)) {
      return _base64Cache[base64String];
    }

    try {
      // 解码并缓存
      final bytes = base64.decode(base64String);
      _base64Cache[base64String] = bytes;
      return bytes;
    } catch (e) {
      RCIMWrapperPlatform.instance
          .writeLog('ImageUtil getDecodedBase64 error', '', 0, 'error: $e');
      return null;
    }
  }

  /// 移除特定base64字符串的缓存
  static void removeFromCache(String base64String) {
    _base64Cache.remove(base64String);
  }

  /// 限制缓存大小，移除最早添加的项
  static void limitCacheSize(int maxSize) {
    if (_base64Cache.length <= maxSize) return;

    final keysToRemove = _base64Cache.keys.take(_base64Cache.length - maxSize);
    for (final key in keysToRemove.toList()) {
      _base64Cache.remove(key);
    }
  }

  /// 获取图片 Widget，可以自动判断图片路径类型
  static Widget getImageWidget(
    String imagePath, {
    double? width,
    double? height,
    bool inRongCloud = true,
    Color? color,
    BoxFit fit = BoxFit.cover,
    String? thumbnailBase64String,
    bool notInAssets = false,
  }) {
    if (thumbnailBase64String != null && thumbnailBase64String.isNotEmpty) {
      try {
        // 使用缓存机制解码base64数据
        Uint8List? bytes = getDecodedBase64(thumbnailBase64String);

        if (bytes == null) {
          return SizedBox(width: width, height: height);
        }

        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(width: width, height: height);
          },
        );
      } catch (e) {
        return SizedBox(width: width, height: height);
      }
    }

    if (imagePath.isEmpty) {
      return SizedBox(width: width, height: height);
    }
    // 判断图片路径是否为网络地址
    bool isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    double circularSize =
        (width ?? 20) > (height ?? 20) ? (width ?? 20) / 2 : (height ?? 20) / 2;

    if (isNetworkImage) {
      // 使用 CachedNetworkImage 显示网络图片
      return CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Center(
            child: SizedBox(
                width: circularSize,
                height: circularSize,
                child: CircularProgressIndicator(strokeWidth: 2))), // 加载中的占位符
        errorWidget: (context, url, error) =>
            const Icon(Icons.error), // 加载失败的占位符
        color: color,
      );
    } else {
      // 本地资源图片，判断是否已经有 "assets/" 前缀
      if (notInAssets) {
        return Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(width: width, height: height);
          },
        );
      } else {
        String assetPath =
            imagePath.startsWith('assets/') ? imagePath : 'assets/$imagePath';

        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          color: color,
          package: inRongCloud ? 'rongcloud_im_kit' : null,
        );
      }
    }
  }

  static Future<String?> detectImageFormat(String filePath) async {
    final file = File(filePath);
    final List<int> bytes = await file.openRead(0, 20).first;

    if (bytes.length < 4) return null;

    if (bytes
        .sublist(0, 8)
        .equals([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return 'png';
    }

    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpeg';
    }

    if ((bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38)) {
      return 'gif';
    }

    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'bmp';
    }

    if ((bytes[0] == 0x49 &&
            bytes[1] == 0x49 &&
            bytes[2] == 0x2A &&
            bytes[3] == 0x00) ||
        (bytes[0] == 0x4D &&
            bytes[1] == 0x4D &&
            bytes[2] == 0x00 &&
            bytes[3] == 0x2A)) {
      return 'tiff';
    }

    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }

    if (bytes[0] == 0x00 &&
        bytes[1] == 0x00 &&
        bytes[2] == 0x01 &&
        bytes[3] == 0x00) {
      return 'ico';
    }

    if (bytes.length >= 12 &&
        bytes
            .sublist(4, 12)
            .equals([0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63])) {
      return 'heic'; // or heif
    }

    return null;
  }
}

extension ListEquality on List<int> {
  bool equals(List<int> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != other[i]) return false;
    }
    return true;
  }
}
