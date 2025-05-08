import 'package:flutter/material.dart';
import 'package:rongcloud_im_kit/utils/image_util.dart';

class RotatingImage extends StatefulWidget {
  final String imagePath;
  final double size;
  const RotatingImage({super.key, required this.imagePath, this.size = 100});

  @override
  RotatingImageState createState() => RotatingImageState();
}

class RotatingImageState extends State<RotatingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: ImageUtil.getImageWidget(widget.imagePath,
          width: widget.size, height: widget.size),
    );
  }
}
