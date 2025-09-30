import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:record/record.dart';
import 'package:rongcloud_im_kit/providers/audio_player_provider.dart';
import 'package:rongcloud_im_kit/providers/chat_provider.dart';
// ignore: implementation_imports
import 'package:rongcloud_im_wrapper_plugin/src/rongcloud_im_wrapper_platform_interface.dart';

enum RCIMIWMessageVoiceSendingType {
  notStart,
  sending,
  canceling,
}

class RCKVoiceRecordProvider extends ChangeNotifier
    with WidgetsBindingObserver {
  RCKVoiceRecordProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioRecorder _recorder = AudioRecorder();

  Timer? _volumeTimer;
  double currentVolume = 0;
  DateTime voiceStartTime = DateTime.now();
  DateTime voiceEndTime = DateTime.now();
  DateTime? _pauseTime;
  String voicePath = '';

  RCIMIWMessageVoiceSendingType _voiceSendingType =
      RCIMIWMessageVoiceSendingType.notStart;
  RCIMIWMessageVoiceSendingType get voiceSendingType => _voiceSendingType;

  int get voiceDuration => voiceEndTime.difference(voiceStartTime).inSeconds;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      cancelRecord();
    }
  }

  void startRecord(BuildContext context) async {
    try {
      // 停止正在播放的语音消息
      context.read<RCKAudioPlayerProvider>().stopVoiceMessage();
      // 生成唯一的录音文件路径
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'voice_record_$timestamp.m4a';

      // 使用应用临时目录路径，兼容安卓和iOS
      final tempDir = await getTemporaryDirectory();
      voicePath = '${tempDir.path}/$fileName';

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 32000,
          numChannels: 1,
        ),
        path: voicePath,
      );

      setVoiceSendingType(RCIMIWMessageVoiceSendingType.sending);
      voiceStartTime = DateTime.now();

      RCIMWrapperPlatform.instance.writeLog(
          'RCKVoiceRecordProvider startRecord', '', 0, 'voicePath: $voicePath');

      _volumeTimer?.cancel();
      _volumeTimer =
          Timer.periodic(const Duration(milliseconds: 20), (timer) async {
        if (await _recorder.isRecording()) {
          try {
            final volume = await _recorder.getAmplitude();
            currentVolume = volume.current;
            voiceEndTime = DateTime.now();
            if (voiceDuration >= 60 && context.mounted) {
              finishRecord(context);
            }
            notifyListeners();
          } catch (e) {
            RCIMWrapperPlatform.instance.writeLog(
                'RCKVoiceRecordProvider record error', '', 0, 'error: $e');
            if (kDebugMode) {
              print('Error getting volume: $e');
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<String?> finishRecord(BuildContext context) async {
    try {
      RCIMWrapperPlatform.instance.writeLog(
          'RCKVoiceRecordProvider finishRecord',
          '',
          0,
          'voicePath: $voicePath');

      _volumeTimer?.cancel();
      currentVolume = 0.0;
      voiceEndTime = DateTime.now();
      if (await _recorder.isRecording()) {
        voicePath = await _recorder.stop() ?? '';
      }

      setVoiceSendingType(RCIMIWMessageVoiceSendingType.notStart);

      if (voiceDuration < 1 || voiceDuration > 61) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(voiceDuration < 1 ? '录音时间太短' : '录音时间超过60秒'),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
        return null;
      }

      if (voicePath.isEmpty) {
        return null;
      }
      if (context.mounted) {
        context
            .read<RCKChatProvider>()
            .addVoiceMessage(voicePath, voiceDuration);
      }
      return voicePath;
    } catch (e) {
      RCIMWrapperPlatform.instance.writeLog(
          'RCKVoiceRecordProvider finishRecord error', '', 0, 'error: $e');
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      return null;
    }
  }

  Future<void> cancelRecord() async {
    try {
      _volumeTimer?.cancel();
      currentVolume = 0.0;
      setVoiceSendingType(RCIMIWMessageVoiceSendingType.notStart);
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling recording: $e');
      }
    }
  }

  void pauseRecord() async {
    try {
      await _recorder.pause();
      setVoiceSendingType(RCIMIWMessageVoiceSendingType.canceling);
      currentVolume = 0.0;
      _pauseTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error pausing recording: $e');
      }
    }
  }

  void resumeRecord() async {
    try {
      await _recorder.resume();
      if (_pauseTime != null) {
        Duration pauseDuration = DateTime.now().difference(_pauseTime!);
        voiceStartTime = voiceStartTime.add(pauseDuration);
        _pauseTime = null;
      }
      setVoiceSendingType(RCIMIWMessageVoiceSendingType.sending);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error resuming recording: $e');
      }
    }
  }

  void setVoiceSendingType(RCIMIWMessageVoiceSendingType type) {
    _voiceSendingType = type;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _volumeTimer?.cancel();
    _recorder.stop().catchError((e) {
      if (kDebugMode) {
        print('Error disposing recorder: $e');
      }
      return null;
    });
    super.dispose();
  }
}
