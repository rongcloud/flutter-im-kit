import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

/// 输入框配置
class RCKInputFieldConfig {
  /// 最大高度限制
  final double? maxHeight;

  /// 填充颜色
  final Color fillColor;

  /// 边框样式
  final InputBorder? border;

  /// 聚焦时的边框样式
  final InputBorder? focusedBorder;

  /// 内部填充
  final EdgeInsets contentPadding;

  /// 文本样式
  final TextStyle? textStyle;

  /// 提示文本
  final String? hintText;

  /// 提示文本样式
  final TextStyle? hintStyle;

  /// 光标颜色
  final Color? cursorColor;

  /// 圆角大小
  final double borderRadius;

  /// 文本输入动作
  final TextInputAction textInputAction;

  const RCKInputFieldConfig({
    this.maxHeight = kInputFieldMaxHeight,
    this.fillColor = const Color(0xFFFFFFFF),
    this.border,
    this.focusedBorder,
    this.contentPadding = const EdgeInsets.all(8.0),
    this.textStyle,
    this.hintText,
    this.hintStyle,
    this.cursorColor,
    this.borderRadius = 10.0,
    this.textInputAction = TextInputAction.send,
  });

  /// 获取输入框装饰
  InputDecoration getDecoration() {
    return InputDecoration(
      contentPadding: contentPadding,
      filled: true,
      fillColor: fillColor,
      hintText: hintText,
      hintStyle: hintStyle,
      border: border ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
      focusedBorder: focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
    );
  }

  RCKInputFieldConfig copyWith({
    double? maxHeight,
    Color? fillColor,
    InputBorder? border,
    InputBorder? focusedBorder,
    EdgeInsets? contentPadding,
    TextStyle? textStyle,
    String? hintText,
    TextStyle? hintStyle,
    Color? cursorColor,
    double? borderRadius,
    TextInputAction? textInputAction,
  }) {
    return RCKInputFieldConfig(
      maxHeight: maxHeight ?? this.maxHeight,
      fillColor: fillColor ?? this.fillColor,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      textStyle: textStyle ?? this.textStyle,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      borderRadius: borderRadius ?? this.borderRadius,
      textInputAction: textInputAction ?? this.textInputAction,
    );
  }
}
