import 'package:flutter/material.dart';
import '../utils/theme_color.dart';
import '../utils/theme_icon.dart';

enum RCIMIWAppTheme { light, dark, red, blue, custom } // 新增 custom 状态

class RCKThemeProvider with ChangeNotifier {
  static final RCKThemeProvider _instance = RCKThemeProvider._internal();
  RCIMIWAppTheme _currentTheme = RCIMIWAppTheme.light; // 默认采用 light
  RCKThemeColor? _customColor; // 新增存储自定义主题颜色
  RCKThemeIcon? _customIcon; // 新增存储自定义主题图标

  factory RCKThemeProvider() => _instance;
  RCKThemeProvider._internal();

  RCIMIWAppTheme get currentTheme => _currentTheme;

  RCKThemeColor get themeColor {
    if (_currentTheme == RCIMIWAppTheme.custom && _customColor != null) {
      return _customColor!;
    }
    switch (_currentTheme) {
      case RCIMIWAppTheme.dark:
        return RCKThemeColor.dark;
      case RCIMIWAppTheme.light:
        return RCKThemeColor.light;
      default:
        return RCKThemeColor.light;
    }
  }

  // 新增：根据当前主题返回对应的主题图标
  RCKThemeIcon get themeIcon {
    if (_currentTheme == RCIMIWAppTheme.custom && _customIcon != null) {
      return _customIcon!;
    }
    switch (_currentTheme) {
      case RCIMIWAppTheme.dark:
        return RCKThemeIcon.dark;
      case RCIMIWAppTheme.light:
        return RCKThemeIcon.light;
      default:
        return RCKThemeIcon.light;
    }
  }

  void setTheme(RCIMIWAppTheme theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      if (theme != RCIMIWAppTheme.custom) {
        _customColor = null; // 非自定义时清除自定义值
        _customIcon = null;
      }
      notifyListeners();
    }
  }

  // 修改：合并自定义颜色与图标，设置后 _currentTheme 变为 custom
  void setCustomTheme(RCKThemeColor color, RCKThemeIcon icon) {
    _customColor = color;
    _customIcon = icon;
    _currentTheme = RCIMIWAppTheme.custom;
    notifyListeners();
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // _customColor = null;
    // _customIcon = null;
    // super.dispose();
  }
}
