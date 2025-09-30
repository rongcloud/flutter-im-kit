import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:flutter/material.dart';
import '../../../rongcloud_im_kit.dart';
import 'package:provider/provider.dart';

class RCKImageMessageBubble extends RCKMessageBubble {
  RCKImageMessageBubble({
    super.key,
    required super.message,
    super.showTime,
    super.alignment,
    super.withoutBubble,
    super.config,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onSwipe,
  });

  @override
  Widget buildMessageContent(BuildContext context, String? refName) {
    RCIMIWMediaMessage imageMessage = message as RCIMIWMediaMessage;
    //如果没有原图，下载原图
    if (imageMessage.local == null || imageMessage.local!.isEmpty) {
      context.read<RCKChatProvider>().downloadMediaMessage(imageMessage);
    }

    // 使用配置的图片样式
    final imageStyleConfig = config?.imageStyleConfig;
    final double maxWidth = imageStyleConfig?.maxWidth ?? 80;
    final double maxHeight = imageStyleConfig?.maxHeight ?? 150;
    final double scale = imageStyleConfig?.scale ?? 1.0;
    final BoxFit fit = imageStyleConfig?.fit ?? BoxFit.contain;
    final double borderRadius = imageStyleConfig?.borderRadius ?? 8.0;

    if (message is RCIMIWImageMessage) {
      RCIMIWImageMessage imageMessage = message as RCIMIWImageMessage;

      final double maxW = maxWidth * scale;
      final double maxH = maxHeight * scale;
      final String b64 = imageMessage.thumbnailBase64String ?? '';

      final natural = ImageUtil.getBase64NaturalSize(b64);
      final double ratio =
          (natural != null && natural.width > 0 && natural.height > 0)
              ? natural.width / natural.height
              : 3 / 4;

      double w = maxW;
      double h = w / ratio;
      if (h > maxH) {
        h = maxH;
        w = h * ratio;
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: w,
          height: h,
          child: ImageUtil.getImageWidget(
            "",
            thumbnailBase64String: b64,
            fit: fit,
          ),
        ),
      );
    } else if (message is RCIMIWGIFMessage) {
      RCIMIWGIFMessage gifMessage = message as RCIMIWGIFMessage;
      String? filePath = gifMessage.local;

      if (filePath != null &&
          filePath.startsWith('file://') &&
          Platform.isAndroid) {
        filePath = filePath.substring(7);
      }

      final double maxW = maxWidth * scale;
      final double maxH = maxHeight * scale;

      // 优先使用模型自带尺寸，否则尝试从本地文件解尺寸，最后兜底比例
      double? modelW = (gifMessage.width ?? 0).toDouble();
      double? modelH = (gifMessage.height ?? 0).toDouble();
      double? ratio;

      if ((modelW > 0) && (modelH > 0)) {
        ratio = modelW / modelH;
      } else if (filePath != null && filePath.isNotEmpty) {
        final natural = ImageUtil.getFileNaturalSize(filePath);
        if (natural != null && natural.width > 0 && natural.height > 0) {
          ratio = natural.width / natural.height;
        }
      }

      ratio ??= 1.0; // GIF 兜底为 1:1

      double w = maxW;
      double h = w / ratio;
      if (h > maxH) {
        h = maxH;
        w = h * ratio;
      }

      Widget child;
      if (filePath != null && filePath.isNotEmpty) {
        child = ImageUtil.getImageWidget(
          filePath,
          fit: fit,
          notInAssets: true,
        );
      } else {
        child = ImageUtil.getImageWidget(
          gifMessage.remote ?? "",
          fit: fit,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: w,
          height: h,
          child: child,
        ),
      );
    }
    return Container();
  }

  @override
  void onBubbleTap(BuildContext context) {
    context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
    context.read<RCKVoiceRecordProvider>().cancelRecord();

    RCIMIWMediaMessage imageMessage = message as RCIMIWMediaMessage;

    final chatProvider = context.read<RCKChatProvider>();

    var messages = chatProvider.messages;
    var imageCopy = messages.toList();
    imageCopy.removeWhere((element) =>
        element is! RCIMIWImageMessage && element is! RCIMIWGIFMessage);
    List<RCIMIWMediaMessage> images = imageCopy.cast<RCIMIWMediaMessage>();
    int currentIndex = imageCopy.indexOf(imageMessage);

    chatProvider.saveScrollOffset();

    final inputProvider = context.read<RCKMessageInputProvider>();
    inputProvider.setInputType(RCIMIWMessageInputType.initial);

    Navigator.pushNamed(context, '/photo_preview', arguments: {
      'currentIndex': currentIndex,
      'images': images,
    }).then((value) {
      chatProvider.jumpToScrollOffset();
    });
  }
}
