import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'package:just_audio/just_audio.dart';
import 'voice_record_provider.dart';
import 'chat_provider.dart';

enum RCKAudioPlayerState {
  playing,
  paused,
  stopped,
}

class RCKAudioPlayerProvider extends ChangeNotifier
    with WidgetsBindingObserver {
  final _player = AudioPlayer();
  String? _currentPlayingMessageId;
  String? get currentPlayingMessageId => _currentPlayingMessageId;
  RCKAudioPlayerState _state = RCKAudioPlayerState.stopped;
  RCKAudioPlayerState get state => _state;

  RCKAudioPlayerProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      stopVoiceMessage();
    }
  }

  Future<void> playVoiceMessage(RCIMIWMediaMessage message,
      [BuildContext? context]) async {
    if (context != null) {
      final recordProvider =
          Provider.of<RCKVoiceRecordProvider>(context, listen: false);
      if (recordProvider.voiceSendingType ==
              RCIMIWMessageVoiceSendingType.sending ||
          recordProvider.voiceSendingType ==
              RCIMIWMessageVoiceSendingType.canceling) {
        await recordProvider.cancelRecord();
      }
    }

    if (_currentPlayingMessageId != null &&
        _state == RCKAudioPlayerState.playing) {
      final willPlayMessageId = _currentPlayingMessageId;
      await stopVoiceMessage();
      if (willPlayMessageId == message.messageId.toString()) {
        // 如果当前正在播放的消息id与即将播放的消息id相同，则不进行播放
        return;
      }
    }

    final localPath = message.local;
    String? filePath = localPath;

    // 如果路径以file://开头，去掉这个前缀
    if (filePath != null && filePath.startsWith('file://')) {
      filePath = filePath.substring(7);
    }

    if (filePath != null && File(filePath).existsSync()) {
      try {
        // 使用 file:// 协议
        final fileUri = Uri.file(filePath).toString();

        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(fileUri)),
        );

        _currentPlayingMessageId = message.messageId.toString();
        _state = RCKAudioPlayerState.playing;
        notifyListeners();

        await _player.play();

        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            _currentPlayingMessageId = null;
            _state = RCKAudioPlayerState.stopped;
            notifyListeners();
          }
        });
      } catch (e) {
        _currentPlayingMessageId = null;
        _state = RCKAudioPlayerState.stopped;
        notifyListeners();
      }
    } else {
      bool autoPlay = true;
      if (filePath != null && !File(filePath).existsSync()) {
        autoPlay = false;
      }

      // 通过context获取ChatProvider来下载语音消息
      if (context != null && context.mounted) {
        final chatProvider = context.read<RCKChatProvider>();
        chatProvider.downloadVoiceMessage(message, autoPlay, context);
      }
    }
  }

  Future<void> stopVoiceMessage({bool notify = true}) async {
    _currentPlayingMessageId = null;
    _state = RCKAudioPlayerState.stopped;
    if (!notify) {
      if (_player.playerState.playing) {
        _player.stop();
      }
    } else {
      if (_player.playerState.playing) {
        await _player.stop();
      }
      notifyListeners();
    }
  }

  Future<void> pauseVoiceMessage({bool notify = true}) async {
    _state = RCKAudioPlayerState.paused;
    if (!notify) {
      if (_player.playerState.playing) {
        _player.pause();
      }
    } else {
      if (_player.playerState.playing) {
        await _player.pause();
      }
      notifyListeners();
    }
  }

  /// 根据音量大小获取不同的音量图标索引
  int getVolumeImageIndex(double volume) {
    if (volume < -30) {
      return 1;
    } else if (volume >= -30 && volume < -25) {
      return 2;
    } else if (volume >= -25 && volume < -20) {
      return 3;
    } else if (volume >= -20 && volume < -15) {
      return 4;
    } else if (volume >= -15 && volume < -10) {
      return 5;
    } else if (volume >= -10 && volume < -5) {
      return 6;
    } else if (volume >= -5 && volume < 0) {
      return 7;
    } else if (volume >= 0) {
      return 8;
    }
    return 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}
