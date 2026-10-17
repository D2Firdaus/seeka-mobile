import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Menyimpan foto laporan ke penyimpanan permanen, agar tetap valid
/// setelah restart (bukan path sementara image_picker).
///
/// - Mobile/desktop: salin file ke app documents (path file biasa).
/// - Web: simpan sebagai data URL base64 terkompres — `dart:io` tidak
///   tersedia di web dan blob URL image_picker mati saat halaman reload.
class FotoStore {
  FotoStore._();

  static const _dirName = 'seeka_foto';
  static const _maxWidth = 1024;

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$_dirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Simpan foto terpilih; return path/URL permanennya.
  static Future<String> simpanFoto(XFile picked) async {
    if (kIsWeb) return _simpanFotoWeb(picked);
    final dir = await _dir();
    final ext = picked.path.contains('.')
        ? '.${picked.path.split('.').last}'
        : '.jpg';
    final dest =
        '${dir.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}$ext';
    await File(picked.path).copy(dest);
    return dest;
  }

  /// Web: decode, upscale-max 1024px, kompres ke JPEG/PNG, encode base64.
  static Future<String> _simpanFotoWeb(XFile picked) async {
    var bytes = await picked.readAsBytes();
    var mime = _deteksiMime(bytes);
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final scaled = decoded.width > _maxWidth
            ? img.copyResize(decoded, width: _maxWidth)
            : decoded;
        if (decoded.hasAlpha) {
          bytes = img.encodePng(scaled);
          mime = 'image/png';
        } else {
          bytes = img.encodeJpg(scaled, quality: 80);
          mime = 'image/jpeg';
        }
      }
    } catch (_) {}
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static String _deteksiMime(List<int> b) {
    if (b.length > 3 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length > 2 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (b.length > 9 &&
        b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b[8] == 0x57 &&
        b[9] == 0x45) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  /// Hapus file foto (best-effort; no-op untuk data URL dan di web).
  static Future<void> hapusFoto(String path) async {
    if (kIsWeb || path.startsWith('data:')) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<void> hapusSemua(List<String> paths) async {
    for (final p in paths) {
      await hapusFoto(p);
    }
  }
}
