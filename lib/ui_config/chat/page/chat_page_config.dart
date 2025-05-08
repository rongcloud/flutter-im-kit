import '../bubble/bubble_config.dart';
import '../input/input_config_exports.dart';
import 'chat_app_bar_config.dart';
import 'chat_background_config.dart';

/// 聊天页面总配置
class RCKChatPageConfig {
  /// 应用栏配置
  final RCKChatAppBarConfig appBarConfig;

  /// 消息气泡配置
  final RCKBubbleConfig? bubbleConfig;

  /// 背景配置
  final RCKChatBackgroundConfig backgroundConfig;

  /// 输入框配置
  final RCKMessageInputConfig? inputConfig;

  /// 是否使用默认的AppBarLeading
  final bool useDefaultAppBarLeading;

  RCKChatPageConfig({
    RCKChatAppBarConfig? appBarConfig,
    RCKBubbleConfig? bubbleConfig,
    RCKChatBackgroundConfig? backgroundConfig,
    RCKMessageInputConfig? inputConfig,
    this.useDefaultAppBarLeading = true,
  })  : appBarConfig = appBarConfig ?? RCKChatAppBarConfig(),
        backgroundConfig = backgroundConfig ?? RCKChatBackgroundConfig(),
        bubbleConfig = bubbleConfig ?? RCKBubbleConfig(),
        inputConfig = inputConfig ?? RCKMessageInputConfig();

  /// 创建一个新的配置，覆盖当前配置的某些属性
  RCKChatPageConfig copyWith({
    RCKChatAppBarConfig? appBarConfig,
    RCKBubbleConfig? bubbleConfig,
    RCKChatBackgroundConfig? backgroundConfig,
    RCKMessageInputConfig? inputConfig,
  }) {
    return RCKChatPageConfig(
      appBarConfig: appBarConfig ?? this.appBarConfig,
      bubbleConfig: bubbleConfig ?? this.bubbleConfig,
      backgroundConfig: backgroundConfig ?? this.backgroundConfig,
      inputConfig: inputConfig ?? this.inputConfig,
    );
  }
}
