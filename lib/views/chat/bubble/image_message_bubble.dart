import 'dart:io';

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

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth * scale,
            maxHeight: maxHeight * scale,
          ),
          child: ImageUtil.getImageWidget(
            "",
            thumbnailBase64String: imageMessage.thumbnailBase64String,
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

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth * scale,
            maxHeight: maxHeight * scale,
          ),
          child: filePath != null && filePath.isNotEmpty
              ? ImageUtil.getImageWidget(
                  filePath,
                  fit: fit,
                  notInAssets: true,
                )
              : ImageUtil.getImageWidget(
                  gifMessage.remote ?? "",
                  fit: fit,
                ),
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

    var messages = context.read<RCKChatProvider>().messages;
    var imageCopy = messages.toList();
    imageCopy.removeWhere((element) =>
        element is! RCIMIWImageMessage && element is! RCIMIWGIFMessage);
    List<RCIMIWMediaMessage> images = imageCopy.cast<RCIMIWMediaMessage>();
    int currentIndex = imageCopy.indexOf(imageMessage);

    final chatProvider = context.read<RCKChatProvider>();
    chatProvider.saveScrollOffset();

    Navigator.pushNamed(context, '/photo_preview', arguments: {
      'currentIndex': currentIndex,
      'images': images,
    }).then((value) {
      chatProvider.jumpToScrollOffset();
    });
  }
}
