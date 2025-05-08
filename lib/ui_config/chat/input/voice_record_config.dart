import 'package:flutter/material.dart';

import '../../../rongcloud_im_kit.dart';

/// 语音录制按钮配置
class RCKVoiceRecordConfig {
  /// 默认状态下的背景颜色
  final Color? backgroundColor;

  /// 按下状态下的背景颜色
  final Color? pressedBackgroundColor;

  /// 默认状态下的文本
  final String defaultText;

  /// 录制状态下的文本
  final String recordingText;

  /// 松开取消的文本
  final String cancelText;

  /// 默认文本样式
  final TextStyle? defaultTextStyle;

  /// 录制中文本样式
  final TextStyle? recordingTextStyle;

  /// 取消文本样式
  final TextStyle? cancelTextStyle;

  /// 录制按钮圆角
  final double borderRadius;

  /// 内边距
  final EdgeInsets padding;

  const RCKVoiceRecordConfig({
    this.backgroundColor,
    this.pressedBackgroundColor,
    this.defaultText = '发送语音',
    this.recordingText = '',
    this.cancelText = '',
    this.defaultTextStyle,
    this.recordingTextStyle,
    this.cancelTextStyle,
    this.borderRadius = kInputFieldBorderRadius,
    this.padding =
        const EdgeInsets.symmetric(vertical: kInputFieldContentPaddingV),
  });

  RCKVoiceRecordConfig copyWith({
    Color? backgroundColor,
    Color? pressedBackgroundColor,
    String? defaultText,
    String? recordingText,
    String? cancelText,
    TextStyle? defaultTextStyle,
    TextStyle? recordingTextStyle,
    TextStyle? cancelTextStyle,
    double? borderRadius,
    EdgeInsets? padding,
    Widget Function(BuildContext, bool, bool)? recordTipBuilder,
  }) {
    return RCKVoiceRecordConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
      defaultText: defaultText ?? this.defaultText,
      recordingText: recordingText ?? this.recordingText,
      cancelText: cancelText ?? this.cancelText,
      defaultTextStyle: defaultTextStyle ?? this.defaultTextStyle,
      recordingTextStyle: recordingTextStyle ?? this.recordingTextStyle,
      cancelTextStyle: cancelTextStyle ?? this.cancelTextStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }
}
