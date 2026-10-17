import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

final _dataCache = <String, Uint8List>{};

Uint8List? _decodeDataUrl(String path) {
  final cached = _dataCache[path];
  if (cached != null) return cached;
  try {
    final i = path.indexOf(',');
    if (i == -1) return null;
    final bytes = base64Decode(path.substring(i + 1));
    if (_dataCache.length > 8) _dataCache.clear();
    _dataCache[path] = bytes;
    return bytes;
  } catch (_) {
    return null;
  }
}

/// Provider gambar yang aman untuk data URL (web), blob:/http (web),
/// maupun path file (mobile/desktop).
ImageProvider imageProviderFor(String path) {
  if (path.startsWith('data:')) {
    final bytes = _decodeDataUrl(path);
    // Bytes kosong: sengaja gagal decode → errorBuilder yang tampilkan ikon.
    return MemoryImage(bytes ?? Uint8List(0));
  }
  if (kIsWeb) return NetworkImage(path);
  return FileImage(File(path));
}

/// Tampilan gambar dari data URL (web), URL (web), atau path file (mobile).
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
    if (path.startsWith('data:')) {
      final bytes = _decodeDataUrl(path);
      if (bytes == null) return const _FallbackIcon();
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => const _FallbackIcon(),
      );
    }
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
