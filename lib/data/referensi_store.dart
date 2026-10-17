import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import 'models.dart';
import 'prefs.dart';

/// Menangani data referensi kategori & lokasi (tabel `categories`/`locations`).
/// Arsip = soft delete (`deletedAt`), tidak menghapus baris.
class ReferensiStore extends ChangeNotifier {
  ReferensiStore._();

  static final ReferensiStore instance = ReferensiStore._();

  final List<RefItem> kategori = [];
  final List<RefItem> lokasi = [];

  /// Hydrate dari SharedPreferences; seed default bila belum ada data.
  Future<void> init() async {
    final kRows = Prefs.readList(kKeyCategories);
    kategori
      ..clear()
      ..addAll(kRows == null ? kSeedKategori : kRows.map(RefItem.fromJson));

    final lRows = Prefs.readList(kKeyLocations);
    lokasi
      ..clear()
      ..addAll(lRows == null ? kSeedLokasi : lRows.map(RefItem.fromJson));

    notifyListeners();
  }

  Future<void> _save() async {
    await Prefs.writeList(
      kKeyCategories,
      kategori.map((r) => r.toJson()).toList(growable: false),
    );
    await Prefs.writeList(
      kKeyLocations,
      lokasi.map((r) => r.toJson()).toList(growable: false),
    );
  }

  List<RefItem> get kategoriAktif => kategori.where((r) => r.aktif).toList();

  List<RefItem> get lokasiAktif => lokasi.where((r) => r.aktif).toList();

  List<String> get semuaNamaKategori => kategori.map((r) => r.name).toList();

  List<String> get semuaNamaLokasi => lokasi.map((r) => r.name).toList();

  String namaKategori(int id) =>
      kategori.where((r) => r.id == id).firstOrNull?.name ?? '-';

  String namaLokasi(int id) =>
      lokasi.where((r) => r.id == id).firstOrNull?.name ?? '-';

  int? idKategoriDariNama(String nama) =>
      kategori.where((r) => r.name == nama).firstOrNull?.id;

  int? idLokasiDariNama(String nama) =>
      lokasi.where((r) => r.name == nama).firstOrNull?.id;

  /// Termasuk yang terarsip — utk nilai lama pada form edit.
  RefItem? kategoriById(int id) =>
      kategori.where((r) => r.id == id).firstOrNull;

  RefItem? lokasiById(int id) => lokasi.where((r) => r.id == id).firstOrNull;

  int _nextId(List<RefItem> rows) =>
      rows.fold<int>(0, (m, r) => r.id > m ? r.id : m) + 1;

  String? _validasiNama(String nama) {
    final t = nama.trim();
    if (t.isEmpty) return 'Nama tidak boleh kosong.';
    if (t.toLowerCase() == 'semua') return 'Nama "Semua" dilarang dipakai.';
    return null;
  }

  String? addKategori(String nama) {
    final err = _validasiNama(nama);
    if (err != null) return err;
    final t = nama.trim();
    if (kategori.any((r) => r.name.toLowerCase() == t.toLowerCase())) {
      return 'Kategori "$t" sudah ada.';
    }
    kategori.add(RefItem(id: _nextId(kategori), name: t));
    _save();
    notifyListeners();
    return null;
  }

  String? addLokasi(String nama) {
    final err = _validasiNama(nama);
    if (err != null) return err;
    final t = nama.trim();
    if (lokasi.any((r) => r.name.toLowerCase() == t.toLowerCase())) {
      return 'Lokasi "$t" sudah ada.';
    }
    lokasi.add(RefItem(id: _nextId(lokasi), name: t));
    _save();
    notifyListeners();
    return null;
  }

  String? renameKategori(int id, String baru) {
    final err = _validasiNama(baru);
    if (err != null) return err;
    final t = baru.trim();
    if (kategori.any(
      (r) => r.id != id && r.name.toLowerCase() == t.toLowerCase(),
    )) {
      return 'Kategori "$t" sudah ada.';
    }
    final i = kategori.indexWhere((r) => r.id == id);
    if (i == -1) return 'Kategori tidak ditemukan.';
    kategori[i] = kategori[i].copyWith(name: t, updatedAt: DateTime.now());
    _save();
    notifyListeners();
    return null;
  }

  String? renameLokasi(int id, String baru) {
    final err = _validasiNama(baru);
    if (err != null) return err;
    final t = baru.trim();
    if (lokasi.any(
      (r) => r.id != id && r.name.toLowerCase() == t.toLowerCase(),
    )) {
      return 'Lokasi "$t" sudah ada.';
    }
    final i = lokasi.indexWhere((r) => r.id == id);
    if (i == -1) return 'Lokasi tidak ditemukan.';
    lokasi[i] = lokasi[i].copyWith(name: t, updatedAt: DateTime.now());
    _save();
    notifyListeners();
    return null;
  }

  void _setAktif(List<RefItem> rows, int id, bool aktif) {
    final i = rows.indexWhere((r) => r.id == id);
    if (i == -1 || rows[i].aktif == aktif) return;
    final r = rows[i];
    rows[i] = RefItem(
      id: r.id,
      name: r.name,
      createdAt: r.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: aktif ? null : DateTime.now(),
    );
    _save();
    notifyListeners();
  }

  void setKategoriAktif(int id, bool aktif) => _setAktif(kategori, id, aktif);

  void setLokasiAktif(int id, bool aktif) => _setAktif(lokasi, id, aktif);
}
