import 'package:flutter/material.dart';

Widget buildPlatformImage(String path, {double? height, double? width, BoxFit? fit}) {
  return Image.network(path, height: height, width: width, fit: fit);
}
