import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Menyimpan foto laporan ke penyimpanan permanen app documents,
/// agar path tetap valid setelah restart (bukan path sementara image_picker).
class FotoStore {
  FotoStore._();

  static const _dirName = 'seeka_foto';

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}$_dirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Salin foto terpilih ke app documents; return path permanennya.
  static Future<String> simpanFoto(XFile picked) async {
    final dir = await _dir();
    final ext = picked.path.contains('.')
        ? '.${picked.path.split('.').last}'
        : '.jpg';
    final dest =
        '${dir.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}$ext';
    await File(picked.path).copy(dest);
    return dest;
  }

  /// Hapus file foto (best-effort, diamankan bila file tidak ada).
  static Future<void> hapusFoto(String path) async {
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
