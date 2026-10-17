import '../core/constants.dart';
import 'models.dart';
import 'prefs.dart';

/// One-time migrasi data format lama (denormalisasi) ke skema ERD.
/// Jalankan setelah [Prefs.init] dan sebelum store di-hydrate.
///
/// Pemetaan: `users_json` lama (nama) -> bentuk baru (name + id + timestamps),
/// `kategori_json`/`lokasi_json` -> `categories_json`/`locations_json`,
/// `laporan_json` -> `items_json` + `item_images_json` (fotoPaths jadi rows),
/// `session_email` -> `session_user_id`.
Future<void> migrasiDataLama() async {
  if (Prefs.readString(kKeySchemaVersion) == kSchemaVersion) return;
  final now = DateTime.now().toIso8601String();

  final oldUsers = Prefs.readList(kKeyUsers);
  final users = <Map<String, dynamic>>[];
  var nextUserId = 1;
  if (oldUsers != null && oldUsers.any((u) => u.containsKey('nama'))) {
    for (final u in oldUsers) {
      users.add({
        'id': nextUserId++,
        'name': u['nama'] ?? '',
        'email': u['email'] ?? '',
        'password': u['password'] ?? '',
        'role': u['role'] ?? 'user',
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
      });
    }
    await Prefs.writeList(kKeyUsers, users);
  }

  int userIdByEmail(String email) =>
      users.firstWhere(
        (u) => (u['email'] as String? ?? '') == email && email.isNotEmpty,
        orElse: () => const {},
      )['id'] as int? ??
      0;

  int userIdByName(String name) =>
      users.firstWhere(
        (u) => (u['name'] as String? ?? '') == name && name.isNotEmpty,
        orElse: () => const {},
      )['id'] as int? ??
      0;

  int userAtauBuatTombstone(String name) {
    final id = nextUserId++;
    users.add({
      'id': id,
      'name': name.isEmpty ? 'Pengguna' : name,
      'email': '',
      'password': '',
      'role': 'user',
      'created_at': now,
      'updated_at': now,
      'deleted_at': now,
    });
    return id;
  }

  List<Map<String, dynamic>> refKeBaru(
    List<Map<String, dynamic>>? rows,
    List<RefItem> seed,
  ) {
    final hasil = <Map<String, dynamic>>[];
    if (rows == null) {
      hasil.addAll(seed.map((r) => r.toJson()));
      return hasil;
    }
    var id = 0;
    for (final r in rows) {
      id++;
      hasil.add({
        'id': id,
        'name': r['nama'] ?? '',
        'created_at': now,
        'updated_at': now,
        'deleted_at': (r['aktif'] as bool? ?? true) ? null : now,
      });
    }
    return hasil;
  }

  final oldKategori = Prefs.readList('kategori_json');
  final oldLokasi = Prefs.readList('lokasi_json');
  final oldLaporan = Prefs.readList('laporan_json');

  final kategori = refKeBaru(oldKategori, kSeedKategori);
  final lokasi = refKeBaru(oldLokasi, kSeedLokasi);
  if (oldKategori != null || oldLaporan != null) {
    await Prefs.writeList(kKeyCategories, kategori);
  }
  if (oldLokasi != null || oldLaporan != null) {
    await Prefs.writeList(kKeyLocations, lokasi);
  }

  int refIdAtauBuatTombstone(List<Map<String, dynamic>> rows, String name) {
    if (name.isEmpty) return 0;
    for (final r in rows) {
      if ((r['name'] as String? ?? '') == name) return r['id'] as int;
    }
    var maxId = 0;
    for (final r in rows) {
      final id = r['id'] as int? ?? 0;
      if (id > maxId) maxId = id;
    }
    rows.add({
      'id': maxId + 1,
      'name': name,
      'created_at': now,
      'updated_at': now,
      'deleted_at': now,
    });
    return maxId + 1;
  }

  if (oldLaporan != null) {
    var nextImageId = 0;
    final items = <Map<String, dynamic>>[];
    final images = <Map<String, dynamic>>[];

    for (final l in oldLaporan) {
      final idLama = (l['id'] ?? '').toString();
      var id = idLama;
      if (id.length > 10) {
        final n = int.tryParse(idLama);
        id = n?.toRadixString(36) ?? idLama.substring(0, 10);
      }

      final pelaporEmail = l['pelaporEmail'] as String? ?? '';
      final pelapor = l['pelapor'] as String? ?? '';
      final userId = pelaporEmail.isNotEmpty
          ? userIdByEmail(pelaporEmail)
          : userIdByName(pelapor);
      final resolvedUserId =
          userId != 0 ? userId : userAtauBuatTombstone(pelapor);

      items.add({
        'id': id,
        'user_id': resolvedUserId,
        'category_id': refIdAtauBuatTombstone(
          kategori,
          l['kategori'] as String? ?? '',
        ),
        'location_id': refIdAtauBuatTombstone(
          lokasi,
          l['lokasi'] as String? ?? '',
        ),
        'type': l['tipe'] == 'penemuan' ? 'ditemukan' : 'kehilangan',
        'title': l['namaBarang'] ?? '',
        'description': l['deskripsi'] ?? '',
        'date_event': l['tanggal'] ?? now,
        'status': l['status'] ?? 'aktif',
        'nomor_wa': l['nomorWa'] ?? '',
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
      });

      for (final path in (l['fotoPaths'] as List<dynamic>? ?? const [])) {
        images.add({
          'id': ++nextImageId,
          'item_id': id,
          'path': path,
          'created_at': now,
          'updated_at': now,
          'deleted_at': null,
        });
      }
    }

    await Prefs.writeList(kKeyItems, items);
    await Prefs.writeList(kKeyItemImages, images);
    await Prefs.writeList(kKeyCategories, kategori);
    await Prefs.writeList(kKeyLocations, lokasi);
    if (oldUsers != null && users.isNotEmpty) {
      await Prefs.writeList(kKeyUsers, users);
    }
  }

  final sessionEmail = Prefs.readString('session_email');
  if (sessionEmail != null) {
    final id = userIdByEmail(sessionEmail);
    if (id != 0) await Prefs.writeString(kKeySessionUserId, id.toString());
    await Prefs.remove('session_email');
  }

  await Prefs.remove('kategori_json');
  await Prefs.remove('lokasi_json');
  await Prefs.remove('laporan_json');
  await Prefs.writeString(kKeySchemaVersion, kSchemaVersion);
}
