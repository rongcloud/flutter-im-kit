import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/models/chat_profile_info.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RCKEngineProvider with ChangeNotifier {
  RCIMIWEngine? engine;

  String currentUserId = '';
  int _totalUnreadCount = 0;
  int get totalUnreadCount => _totalUnreadCount;

  final List<RCIMIWMessage> _failedMessages = [];

  final ValueNotifier<RCIMIWMessage?> receiveMessageNotifier =
      ValueNotifier(null);

  final ValueNotifier<RCIMIWMessage?> failedMessageSentNotifier =
      ValueNotifier(null);

  final ValueNotifier<RCIMIWConnectionStatus?> networkChangeNotifier =
      ValueNotifier(null);

  final ValueNotifier<RCIMIWMessage?> recallMessageNotifier =
      ValueNotifier(null);

  final ValueNotifier<String?> readClearTargetId = ValueNotifier(null);

  final ValueNotifier<String?> conversationStatus = ValueNotifier(null);

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isNotificationInitialized = false;
  bool _enableLocalNotification = false;
  set enableLocalNotification(bool value) {
    _enableLocalNotification = value;
    notifyListeners();
  }

  bool get enableLocalNotification => _enableLocalNotification;

  /// 自定义信息提供者
  CustomInfoProvider? customInfoProvider;

  // 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    if (_isNotificationInitialized) return;

    try {
      // 请求通知权限
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
          // 处理通知点击事件
          debugPrint('通知被点击: ${notificationResponse.payload}');
        },
      );
      _isNotificationInitialized = true;
    } catch (e) {
      debugPrint('初始化本地通知失败: $e');
    }
  }

  Future<RCIMIWEngine?> engineCreate(
      String appKey, RCIMIWEngineOptions options) async {
    engine = await RCIMIWEngine.create(appKey, options);
    RCIMWrapperPlatform.instance
        .writeLog('RCKEngineProvider engineCreate', '', 0, 'invoke finished');
    return engine;
  }

  Future<void> engineConnect(String token, int timeout,
      {required Function(int? code) onResult}) async {
    RCIMWrapperPlatform.instance.writeLog('RCKEngineProvider engineConnect', '',
        0, 'connecting to server with token');
    if (Platform.isIOS) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      await RCIMWrapperPlatform.instance
          .setModuleName('flutterimkit', packageInfo.version);
    }

    await engine?.connect(token, timeout,
        callback: RCIMIWConnectCallback(onConnected: (code, userIdReturn) {
      if (userIdReturn != null) {
        currentUserId = userIdReturn;
      }
      onResult(code);
      RCIMWrapperPlatform.instance.writeLog(
          'RCIMIWConnectCallback',
          'onConnected',
          code ?? 0,
          'connection successful, userId: $userIdReturn');
    }));
    notifyListeners();

    engine?.onMessageReceived = (message, left, hasPackage, offline) async {
      receiveMessageNotifier.value = message;
      RCIMWrapperPlatform.instance.writeLog('engine?.onMessageReceived',
          'engineConnect', 0, 'onMessageReceived ${message?.messageId}');
      notifyListeners();
    };

    engine?.onConnectionStatusChanged = (status) {
      networkChangeNotifier.value = status;
      if (status == RCIMIWConnectionStatus.connected) {
        resendFailedMessages();
      }
      RCIMWrapperPlatform.instance.writeLog('engine?.onConnectionStatusChanged',
          'engineConnect', 0, 'onConnectionStatusChanged $status');
      notifyListeners();
    };

    engine?.onConversationTopStatusSynced =
        (conversationType, targetId, channelId, isTop) {
      conversationStatus.value = targetId ?? '$isTop';
      RCIMWrapperPlatform.instance.writeLog(
          'engine?.onConversationTopStatusSynced',
          'engineConnect',
          0,
          'onConversationTopStatusSynced $targetId $isTop');
      notifyListeners();
    };

    engine?.onConversationNotificationLevelSynced =
        (conversationType, targetId, channelId, notificationLevel) {
      conversationStatus.value = targetId ?? '$notificationLevel';
      RCIMWrapperPlatform.instance.writeLog(
          'engine?.onConversationNotificationLevelSynced',
          'engineConnect',
          0,
          'onConversationNotificationLevelSynced $targetId $notificationLevel');
      notifyListeners();
    };

    engine?.onRemoteMessageRecalled = (message) {
      recallMessageNotifier.value = message;
      RCIMWrapperPlatform.instance.writeLog('engine?.onRemoteMessageRecalled',
          'engineConnect', 0, 'onRemoteMessageRecalled ${message?.messageId}');
      notifyListeners();
    };

    engine?.onConversationReadStatusSyncMessageReceived =
        (conversationType, targetId, timestamp) {
      engine?.clearUnreadCount(
          conversationType ?? RCIMIWConversationType.invalid,
          targetId ?? '',
          null,
          timestamp ?? 0, callback:
              IRCIMIWClearUnreadCountCallback(onUnreadCountCleared: (code) {
        if (code == 0) {
          readClearTargetId.value = "$targetId${timestamp ?? 0}";
          notifyListeners();
          debugPrint('同步会话阅读状态成功');
        }
        RCIMWrapperPlatform.instance.writeLog(
            'engine?.onConversationReadStatusSyncMessageReceived',
            'engineConnect',
            code ?? 0,
            'onConversationReadStatusSyncMessageReceived $targetId $timestamp');
      }));
    };
  }

  Future<void> setupLocalNotification({bool enable = true}) async {
    _enableLocalNotification = enable;
    if (_enableLocalNotification) {
      await _initializeLocalNotifications();
    }
    RCIMWrapperPlatform.instance.writeLog(
        'RCKEngineProvider setupLocalNotification',
        '',
        0,
        'setupLocalNotification $enable');
    notifyListeners();
  }

  Future<void> showLocalNotification(RCIMIWMessage message) async {
    // 仅在启用本地推送时执行
    if (_enableLocalNotification) {
      String targetId = message.targetId ?? '';
      String content = '';

      // 获取自定义信息
      if (customInfoProvider != null) {
        final customInfo =
            await customInfoProvider!(message: message, conversation: null);
        targetId = customInfo.name;
      }

      // 根据不同消息类型获取内容
      if (message.conversationType == RCIMIWConversationType.private ||
          message.conversationType == RCIMIWConversationType.group) {
        if (message is RCIMIWTextMessage) {
          content = message.text ?? '';
        } else if (message.messageType == RCIMIWMessageType.image) {
          content = '[图片消息]';
        } else if (message.messageType == RCIMIWMessageType.voice) {
          content = '[语音消息]';
        } else if (message.messageType == RCIMIWMessageType.file) {
          content = '[文件消息]';
        } else {
          content = '[新消息]';
        }

        // 显示本地通知
        _showLocalNotification(targetId, content);
      }
    }
  }

  // 显示本地通知的方法
  Future<void> _showLocalNotification(String targetId, String content) async {
    try {
      if (!_isNotificationInitialized) {
        await _initializeLocalNotifications();
      }

      // 创建通知详情
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'rongcloud_im',
        'rongcloud_im',
        channelDescription: 'rongcloud_im',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        showWhen: true,
        category: AndroidNotificationCategory.message,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      );

      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentSound: true,
        presentBadge: true,
        sound: 'default',
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );
      RCIMWrapperPlatform.instance.writeLog(
          'RCKEngineProvider showLocalNotification',
          '',
          0,
          'showLocalNotification $targetId $content');

      // 显示通知
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF,
        targetId,
        content,
        notificationDetails,
        payload: 'message_$targetId', // 添加payload用于通知点击回调
      );
    } catch (e) {
      debugPrint('显示本地通知时出错: $e');
    }
  }

  void updateTotalUnreadCount() {
    engine?.getTotalUnreadCount(null,
        callback: IRCIMIWGetTotalUnreadCountCallback(
          onSuccess: (count) {
            _totalUnreadCount = count ?? 0;
            RCIMWrapperPlatform.instance.writeLog(
                'RCKEngineProvider updateTotalUnreadCount',
                '',
                0,
                'updateTotalUnreadCount $count');
            notifyListeners();
          },
          onError: (code) {},
        ));
  }

  void addFailedMessage(RCIMIWMessage message) {
    _failedMessages.add(message);
    RCIMWrapperPlatform.instance.writeLog('RCKEngineProvider addFailedMessage',
        '', 0, 'addFailedMessage ${message.messageId}');
    notifyListeners();
  }

  void removeFailedMessage(RCIMIWMessage message) {
    _failedMessages.remove(message);
    RCIMWrapperPlatform.instance.writeLog(
        'RCKEngineProvider removeFailedMessage',
        '',
        0,
        'removeFailedMessage ${message.messageId}');
    notifyListeners();
  }

  void clearFailedMessages() {
    _failedMessages.clear();
    RCIMWrapperPlatform.instance.writeLog(
        'RCKEngineProvider clearFailedMessages', '', 0, 'clearFailedMessages');
    notifyListeners();
  }

  void resendFailedMessages() {
    for (var message in _failedMessages) {
      if (message is RCIMIWMediaMessage) {
        engine?.sendMediaMessage(message, listener:
            RCIMIWSendMediaMessageListener(onMediaMessageSent: (code, message) {
          if (code == 0 && message != null) {
            removeFailedMessage(message);
            failedMessageSentNotifier.value = message;
          }
        }));
      } else {
        engine?.sendMessage(message,
            callback: RCIMIWSendMessageCallback(onMessageSent: (code, message) {
          if (code == 0 && message != null) {
            removeFailedMessage(message);
            failedMessageSentNotifier.value = message;
          }
        }));
      }
    }
    RCIMWrapperPlatform.instance.writeLog(
        'RCKEngineProvider resendFailedMessages',
        '',
        0,
        'resendFailedMessages');
    notifyListeners();
  }

  void disconnect() async {
    await engine?.disconnect(true);
    await engine?.destroy();
    RCIMWrapperPlatform.instance
        .writeLog('RCKEngineProvider disconnect', '', 0, 'engine destroy');
    engine = null;
  }
}
