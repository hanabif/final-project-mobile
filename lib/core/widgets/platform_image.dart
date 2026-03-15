import 'package:flutter/material.dart';
import 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_io.dart'
    if (dart.library.html) 'platform_image_web.dart';

class PlatformImage extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const PlatformImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return buildPlatformImage(path, height: height, width: width, fit: fit);
  }
}
