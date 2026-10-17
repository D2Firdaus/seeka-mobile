import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/utils/foto_store.dart';
import 'models.dart';
import 'prefs.dart';

/// Menangani data laporan (tabel `items` + `item_images`): CRUD, status,
/// foto, dan query/filter.
class LaporanStore extends ChangeNotifier {
  LaporanStore._();

  static final LaporanStore instance = LaporanStore._();

  final List<Item> items = [];
  final List<ItemImage> images = [];

  /// Hydrate dari SharedPreferences; seed demo bila belum ada data.
  Future<void> init() async {
    final rows = Prefs.readList(kKeyItems);
    items
      ..clear()
      ..addAll(rows == null ? _seed() : rows.map(Item.fromJson));

    final imgRows = Prefs.readList(kKeyItemImages);
    images
      ..clear()
      ..addAll(imgRows?.map(ItemImage.fromJson) ?? const []);
    notifyListeners();
  }

  Future<void> _save() async {
    await Prefs.writeList(
      kKeyItems,
      items.map((l) => l.toJson()).toList(growable: false),
    );
    await Prefs.writeList(
      kKeyItemImages,
      images.map((i) => i.toJson()).toList(growable: false),
    );
  }

  List<Item> _seed() => [
        Item(
          id: '1',
          userId: kDemoUserId,
          categoryId: 1,
          locationId: 2,
          type: ItemType.ditemukan,
          title: 'Dompet kulit hitam',
          description: 'Model lipat, ditemukan di dekat halte Dago.',
          dateEvent: DateTime(2026, 10, 14),
          nomorWa: '6281234567890',
        ),
        Item(
          id: '2',
          userId: kDemoUserId,
          categoryId: 2,
          locationId: 2,
          type: ItemType.kehilangan,
          title: 'Kunci Warna Hitam',
          description: 'Ada gantungan bola kecil.',
          dateEvent: DateTime(2026, 10, 15),
          nomorWa: '6281234567891',
        ),
        Item(
          id: '3',
          userId: kDemoUserId,
          categoryId: 3,
          locationId: 2,
          type: ItemType.ditemukan,
          title: 'Samsung Galaxy 90 Pro',
          description: 'Galaxy Andromeda Aja kalah.',
          dateEvent: DateTime(2026, 10, 14),
          nomorWa: '6281234567892',
        ),
      ];

  /// Path foto milik satu item (tabel `item_images`).
  List<String> fotoOf(String itemId) => images
      .where((i) => i.itemId == itemId)
      .map((i) => i.path)
      .toList(growable: false);

  int _nextImageId() =>
      images.fold<int>(0, (m, i) => i.id > m ? i.id : m) + 1;

  void _syncFoto(String itemId, List<String> paths) {
    images.removeWhere((i) => i.itemId == itemId);
    var id = _nextImageId();
    for (final p in paths) {
      images.add(ItemImage(id: id++, itemId: itemId, path: p));
    }
  }

  void addLaporan(Item l, List<String> fotoPaths) {
    items.insert(0, l);
    _syncFoto(l.id, fotoPaths);
    _save();
    notifyListeners();
  }

  void updateLaporan(Item updated, List<String> fotoPaths) {
    final i = items.indexWhere((l) => l.id == updated.id);
    if (i != -1) {
      items[i] = updated.copyWith(updatedAt: DateTime.now());
      _syncFoto(updated.id, fotoPaths);
      _save();
      notifyListeners();
    }
  }

  /// Hapus laporan beserta baris foto & file fotonya dari disk.
  void deleteLaporan(String id) {
    final i = items.indexWhere((l) => l.id == id);
    if (i != -1) {
      items.removeAt(i);
      final paths = fotoOf(id);
      images.removeWhere((img) => img.itemId == id);
      FotoStore.hapusSemua(paths);
      _save();
      notifyListeners();
    }
  }

  void setStatusLaporan(String id, ItemStatus status) {
    final i = items.indexWhere((l) => l.id == id);
    if (i != -1) {
      items[i] = items[i].copyWith(status: status, updatedAt: DateTime.now());
      _save();
      notifyListeners();
    }
  }

  List<Item> laporanSaya(int userId) =>
      items.where((l) => l.userId == userId).toList();

  List<Item> query({
    String? q,
    String? deskripsi,
    int? kategori,
    int? lokasi,
    String? tipe,
    DateTimeRange? tanggalRange,
  }) {
    var result = List<Item>.from(items);
    final qq = q?.trim().toLowerCase() ?? '';
    final dd = deskripsi?.trim().toLowerCase() ?? '';
    if (qq.isNotEmpty) {
      result = result
          .where((l) => l.title.toLowerCase().contains(qq))
          .toList();
    }
    if (dd.isNotEmpty) {
      result = result
          .where((l) => l.description.toLowerCase().contains(dd))
          .toList();
    }
    if (kategori != null) {
      result = result.where((l) => l.categoryId == kategori).toList();
    }
    if (lokasi != null) {
      result = result.where((l) => l.locationId == lokasi).toList();
    }
    if (tipe != null && tipe != 'Semua') {
      if (tipe == 'Diklaim') {
        result = result.where((l) => l.diklaim).toList();
      } else {
        final t = tipe == 'Ditemukan'
            ? ItemType.ditemukan
            : ItemType.kehilangan;
        result = result.where((l) => l.type == t).toList();
      }
    }
    if (tanggalRange != null) {
      result = result
          .where(
            (l) =>
                !l.dateEvent.isBefore(tanggalRange.start) &&
                !l.dateEvent.isAfter(tanggalRange.end),
          )
          .toList();
    }
    return result;
  }
}
