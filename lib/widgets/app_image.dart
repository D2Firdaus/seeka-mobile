import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Provider gambar yang aman untuk web (blob:/data:/http) maupun mobile (path file).
ImageProvider imageProviderFor(String path) {
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}

/// Tampilan gambar dari path file (mobile) atau URL (web).
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => const _FallbackIcon(),
      );
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => const _FallbackIcon(),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Icon(Icons.image_outlined, size: 32, color: kTextGray),
    );
  }
}
