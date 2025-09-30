import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// 消息气泡形状
enum BubbleShape {
  roundedRectangle, // 圆角矩形
  oval, // 椭圆形
  rectangle, // 矩形
}

/// 消息气泡配置
class RCKBubbleConfig {
  /// 形状相关
  final BubbleShape shape;

  /// 圆角大小 (当形状为roundedRectangle时有效)
  final double borderRadius;

  /// 发送者的消息气泡颜色
  final Color senderColor;

  /// 接收者的消息气泡颜色
  final Color receiverColor;

  /// 系统消息颜色
  final Color systemColor;

  /// 文件消息颜色
  final Color? fileColor;

  /// 根据消息类型自定义颜色
  final Map<RCIMIWMessageType, Color>? messageTypeColors;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 边框样式
  final BorderStyle? borderStyle;

  /// 气泡内边距
  final EdgeInsetsGeometry padding;

  /// 文本样式配置
  final RCKTextStyleConfig textStyleConfig;

  /// 链接样式配置
  final RCKLinkStyleConfig linkStyleConfig;

  /// 图片样式配置
  final RCKImageStyleConfig imageStyleConfig;

  /// 语音样式配置
  final RCKVoiceStyleConfig voiceStyleConfig;

  /// 视频样式配置
  final RCKSightStyleConfig sightStyleConfig;

  /// 文件样式配置
  final RCKFileStyleConfig fileStyleConfig;

  /// 引用消息样式配置
  final RCKReferenceStyleConfig referenceStyleConfig;

  /// 追加气泡样式配置（控制主气泡下方的附加面板样式）
  final RCKAppendBubbleConfig appendBubbleConfig;

  RCKBubbleConfig({
    this.shape = BubbleShape.roundedRectangle,
    this.borderRadius = kBubbleBorderRadius,
    Color? senderColor,
    Color? receiverColor,
    this.systemColor = const Color(0xFFE0E0E0), // 默认浅灰色
    this.fileColor, // 默认浅灰色
    this.messageTypeColors,
    this.borderColor,
    this.borderWidth,
    this.borderStyle,
    this.padding = const EdgeInsets.all(10.0),
    RCKTextStyleConfig? textStyleConfig,
    RCKLinkStyleConfig? linkStyleConfig,
    this.imageStyleConfig = const RCKImageStyleConfig(),
    this.voiceStyleConfig = const RCKVoiceStyleConfig(),
    this.sightStyleConfig = const RCKSightStyleConfig(),
    RCKFileStyleConfig? fileStyleConfig,
    this.referenceStyleConfig = const RCKReferenceStyleConfig(),
    this.appendBubbleConfig = const RCKAppendBubbleConfig(),
  })  : senderColor = senderColor ??
            RCKThemeProvider().themeColor.bgAuxiliary2 ??
            const Color(0xFFE1FFC7),
        receiverColor = receiverColor ??
            RCKThemeProvider().themeColor.bgAuxiliary1 ??
            const Color(0xFFFFFFFF),
        textStyleConfig = textStyleConfig ?? RCKTextStyleConfig(),
        linkStyleConfig = linkStyleConfig ?? RCKLinkStyleConfig(),
        fileStyleConfig = fileStyleConfig ?? RCKFileStyleConfig();

  /// 获取气泡装饰
  BoxDecoration getBubbleDecoration(RCIMIWMessage message, bool withoutBubble) {
    if (withoutBubble) {
      return const BoxDecoration(); // 无气泡样式
    }

    // 获取基础颜色
    final Color bubbleColor = getBubbleColor(message);

    // 根据形状获取边框半径
    BorderRadius? borderRadius;
    switch (shape) {
      case BubbleShape.roundedRectangle:
        final double radius = this.borderRadius;
        borderRadius = BorderRadius.all(Radius.circular(radius));
        break;
      case BubbleShape.oval:
        borderRadius = const BorderRadius.all(Radius.elliptical(20, 20));
        break;
      case BubbleShape.rectangle:
        borderRadius = BorderRadius.zero;
        break;
    }

    // 构建边框
    BoxBorder? border;
    if (borderColor != null && borderWidth != null) {
      border = Border.all(
        color: borderColor!,
        width: borderWidth!,
        style: borderStyle ?? BorderStyle.solid,
      );
    }

    BoxDecoration decoration = BoxDecoration(
      color: bubbleColor,
      borderRadius: borderRadius,
      border: border,
    );

    if (message.messageType == RCIMIWMessageType.recall) {
      decoration = decoration.copyWith(
        color: RCKThemeProvider().themeColor.bgTip,
        borderRadius: BorderRadius.circular(6),
      );
    }

    return decoration;
  }

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKBubbleConfig copyWith({
    Color? senderBubbleColor,
    Color? receiverBubbleColor,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    RCKTextStyleConfig? textStyleConfig,
    RCKLinkStyleConfig? linkStyleConfig,
    RCKImageStyleConfig? imageStyleConfig,
    RCKVoiceStyleConfig? voiceStyleConfig,
    RCKSightStyleConfig? sightStyleConfig,
    RCKFileStyleConfig? fileStyleConfig,
    RCKReferenceStyleConfig? referenceStyleConfig,
    RCKAppendBubbleConfig? appendBubbleConfig,
  }) {
    return RCKBubbleConfig(
      senderColor: senderBubbleColor ?? senderColor,
      receiverColor: receiverBubbleColor ?? receiverColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      textStyleConfig: textStyleConfig ?? this.textStyleConfig,
      linkStyleConfig: linkStyleConfig ?? this.linkStyleConfig,
      imageStyleConfig: imageStyleConfig ?? this.imageStyleConfig,
      voiceStyleConfig: voiceStyleConfig ?? this.voiceStyleConfig,
      sightStyleConfig: sightStyleConfig ?? this.sightStyleConfig,
      fileStyleConfig: fileStyleConfig ?? this.fileStyleConfig,
      referenceStyleConfig: referenceStyleConfig ?? this.referenceStyleConfig,
      appendBubbleConfig: appendBubbleConfig ?? this.appendBubbleConfig,
    );
  }
}

/// 扩展方法，根据消息类型获取气泡颜色
extension BubbleConfigExtension on RCKBubbleConfig {
  Color getBubbleColor(RCIMIWMessage message) {
    // 首先检查是否有特定消息类型的颜色配置
    if (messageTypeColors != null &&
        messageTypeColors!.containsKey(message.messageType)) {
      return messageTypeColors![message.messageType]!;
    }

    // 如果是系统消息
    if (message.messageType == RCIMIWMessageType.unknown ||
        message.messageType == RCIMIWMessageType.recall ||
        message.messageType == RCIMIWMessageType.nativeCustom ||
        message.messageType == RCIMIWMessageType.nativeCustomMedia) {
      return systemColor;
    }

    // 如果是文件消息
    if (message.messageType == RCIMIWMessageType.file) {
      return fileColor ??
          (message.direction == RCIMIWMessageDirection.send
              ? RCKThemeProvider().themeColor.bgAuxiliary2
              : RCKThemeProvider().themeColor.bgAuxiliary1) ??
          const Color(0xFFF5F5F5);
    }

    // 根据消息方向返回相应的颜色
    return message.direction == RCIMIWMessageDirection.send
        ? senderColor
        : receiverColor;
  }
}
