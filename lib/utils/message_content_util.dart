import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// 获取引用消息的内容文本
///
/// 根据不同的消息类型返回对应的引用内容文本
String getReferenceMessageContent(RCIMIWMessage? refMsg) {
  String referenceContent = "";
  if (refMsg is RCIMIWTextMessage) {
    referenceContent = refMsg.text ?? "";
  } else if (refMsg is RCIMIWReferenceMessage) {
    referenceContent = refMsg.text ?? "";
  } // 图片消息
  else if (refMsg is RCIMIWImageMessage) {
    referenceContent = '[图片]';
  }
  // 语音消息
  else if (refMsg is RCIMIWVoiceMessage) {
    referenceContent = "[语音] ${refMsg.duration} ''";
  }
  // 表情消息
  else if (refMsg is RCIMIWGIFMessage) {
    referenceContent = '[表情]';
  }
  // 位置消息
  else if (refMsg is RCIMIWLocationMessage) {
    referenceContent = '[位置]';
  }
  // 文件消息
  else if (refMsg is RCIMIWFileMessage) {
    referenceContent = '[文件] ${refMsg.name}';
  }
  // 小视频消息
  else if (refMsg is RCIMIWSightMessage) {
    referenceContent = '[视频]';
  } else {
    referenceContent = refMsg?.toString() ?? "";
  }
  return referenceContent;
}
