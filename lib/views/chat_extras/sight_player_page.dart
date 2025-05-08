import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';

class RCKSightPlayerPage extends StatefulWidget {
  /// 当前播放的视频索引
  final int currentIndex;

  /// 视频消息列表
  final List<RCIMIWMessage> videos;

  const RCKSightPlayerPage({
    super.key,
    this.currentIndex = 0,
    required this.videos,
  });

  @override
  State<RCKSightPlayerPage> createState() => _RCKSightPlayerPageState();
}

class _RCKSightPlayerPageState extends State<RCKSightPlayerPage>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isControlsVisible = true;
  double _progress = 0.0;
  RCIMIWSightMessage? message;
  bool _controllerInitialized = false; // 跟踪控制器是否已初始化

  @override
  void initState() {
    super.initState();
    // 添加应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);

    message = widget.videos.first as RCIMIWSightMessage;
    _initializeVideoPlayer();
  }

  // 初始化视频播放器
  Future<void> _initializeVideoPlayer() async {
    // 如果控制器已经初始化过，先释放资源
    if (_controllerInitialized) {
      try {
        await _controller.pause();
        _controller.removeListener(_videoListener);
        await _controller.dispose();
        _controllerInitialized = false;
      } catch (e) {
        debugPrint('视频控制器释放资源出错: $e');
      }
    }

    // 获取视频路径
    if (message?.local != null) {
      // 如果路径以file://开头，去掉这个前缀
      String? filePath = message?.local;
      if (filePath != null && filePath.startsWith('file://')) {
        filePath = filePath.substring(7);
      }
      File file = File(filePath ?? '');
      if (!file.existsSync() && mounted) {
        Navigator.pop(context);
        return;
      }
      _controller = VideoPlayerController.file(file)
        ..setLooping(true) // 设置循环播放
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller.addListener(_videoListener);
            _controller.play();
            _isPlaying = true;
            _controllerInitialized = true;
          }
        });
    } else if (message?.remote != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(message?.remote ?? ''))
            ..setLooping(true) // 设置循环播放
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _controller.addListener(_videoListener);
                _controllerInitialized = true;
              }
            }).catchError((error) {
              debugPrint('网络视频初始化失败: $error');
            });
    }
  }

  // 监听应用生命周期状态变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 应用进入后台
    if (state == AppLifecycleState.paused) {
      if (_isPlaying) {
        _controller.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    }

    // 应用回到前台
    if (state == AppLifecycleState.resumed) {
      // 在Android平台上，需要重新初始化视频播放器来解决黑屏问题
      if (Platform.isAndroid) {
        _initializeVideoPlayer();
      } else {
        // 在iOS平台上，可以简单地恢复播放
        if (_isPlaying) {
          _controller.play();
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _progress = _controller.value.position.inMilliseconds /
          (_controller.value.duration.inMilliseconds);
    });
  }

  @override
  void dispose() {
    // 移除应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final videoValue = _controller.value;
    final Size videoSize = videoValue.size;

    // 检查视频尺寸是否有效
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
            child: Text('无效的视频尺寸', style: TextStyle(color: Colors.white))),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    // 获取旋转角度和原始尺寸
    final int rotation = videoValue.rotationCorrection;
    final double videoActualWidth = videoSize.width;
    final double videoActualHeight = videoSize.height;

    // 判断是否为竖屏录制的视频（高度大于宽度）
    final bool isPortraitVideo = videoActualHeight > videoActualWidth;

    // 计算显示内容的宽高和旋转角度
    double displayContentWidth;
    double displayContentHeight;
    int quarterTurns;

    // 处理不同的情况
    if (isPortraitVideo) {
      // 竖屏视频的处理：重点修改这部分让竖屏视频竖向播放
      if (rotation == 90) {
        // 竖屏 + 旋转90度
        displayContentWidth = videoActualHeight;
        displayContentHeight = videoActualWidth;
        quarterTurns = 3; // 调整为3次顺时针旋转(相当于顺时针旋转270度)
      } else if (rotation == 270) {
        // 竖屏 + 旋转270度
        displayContentWidth = videoActualHeight;
        displayContentHeight = videoActualWidth;
        quarterTurns = 1; // 保持1次顺时针旋转(90度)
      } else {
        // 竖屏 + 无旋转或旋转180度
        displayContentWidth = videoActualWidth;
        displayContentHeight = videoActualHeight;
        quarterTurns = 0; // 不旋转，保持原样
      }
    } else {
      // 横屏视频的处理
      if (rotation == 90 || rotation == 270) {
        displayContentWidth = videoActualHeight;
        displayContentHeight = videoActualWidth;
        // 根据旋转角度确定旋转次数
        quarterTurns = rotation == 90 ? 1 : 3; // 90度为1次，270度为3次
      } else {
        displayContentWidth = videoActualWidth;
        displayContentHeight = videoActualHeight;
        quarterTurns = rotation == 180 ? 2 : 0;
      }
    }

    // 计算修正后的宽高比
    final double displayAspectRatio = (displayContentHeight > 0)
        ? displayContentWidth / displayContentHeight
        : 16.0 / 9.0; // 默认16:9比例

    // 确保竖屏视频使用竖屏比例(小于1的宽高比)，横屏视频使用横屏比例(大于1的宽高比)
    final double finalAspectRatio;
    if (isPortraitVideo) {
      // 竖屏视频：确保宽高比小于1（高大于宽）
      finalAspectRatio =
          displayAspectRatio > 1 ? 1 / displayAspectRatio : displayAspectRatio;
    } else {
      // 横屏视频：确保宽高比大于1（宽大于高）
      finalAspectRatio =
          displayAspectRatio < 1 ? 1 / displayAspectRatio : displayAspectRatio;
    }

    // // 打印调试信息
    // print('原始视频尺寸: $videoActualWidth x $videoActualHeight');
    // print('旋转角度: $rotation');
    // print('是否竖屏视频: $isPortraitVideo');
    // print('修正后尺寸: $displayContentWidth x $displayContentHeight');
    // print('原始宽高比: $displayAspectRatio');
    // print('最终宽高比: $finalAspectRatio');
    // print('旋转次数: $quarterTurns');

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: finalAspectRatio,
                child: RotatedBox(
                  quarterTurns: quarterTurns,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            if (_isControlsVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.3),
                        ),
                        child: Slider(
                          value:
                              _progress.isNaN ? 0.0 : _progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final duration = _controller.value.duration;
                            if (duration.inMilliseconds > 0) {
                              final position = duration * value;
                              _controller.seekTo(position);
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: _togglePlay,
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
