import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import 'models.dart';
import 'prefs.dart';

/// Menangani data referensi kategori & lokasi (CRUD + arsip).
class ReferensiStore extends ChangeNotifier {
  ReferensiStore._();

  static final ReferensiStore instance = ReferensiStore._();

  final List<RefItem> kategori = [];
  final List<RefItem> lokasi = [];

  /// Hydrate dari SharedPreferences; seed default bila belum ada data.
  Future<void> init() async {
    final kRows = Prefs.readList(kKeyKategori);
    kategori
      ..clear()
      ..addAll(kRows == null ? kSeedKategori : kRows.map(RefItem.fromJson));

    final lRows = Prefs.readList(kKeyLokasi);
    lokasi
      ..clear()
      ..addAll(lRows == null ? kSeedLokasi : lRows.map(RefItem.fromJson));

    notifyListeners();
  }

  Future<void> _save() async {
    await Prefs.writeList(
      kKeyKategori,
      kategori.map((r) => r.toJson()).toList(growable: false),
    );
    await Prefs.writeList(
      kKeyLokasi,
      lokasi.map((r) => r.toJson()).toList(growable: false),
    );
  }

  List<String> get kategoriAktif =>
      kategori.where((r) => r.aktif).map((r) => r.nama).toList();

  List<String> get lokasiAktif =>
      lokasi.where((r) => r.aktif).map((r) => r.nama).toList();

  List<String> get semuaNamaKategori => kategori.map((r) => r.nama).toList();

  List<String> get semuaNamaLokasi => lokasi.map((r) => r.nama).toList();

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
    if (kategori.any((r) => r.nama.toLowerCase() == t.toLowerCase())) {
      return 'Kategori "$t" sudah ada.';
    }
    kategori.add(RefItem(nama: t));
    _save();
    notifyListeners();
    return null;
  }

  String? addLokasi(String nama) {
    final err = _validasiNama(nama);
    if (err != null) return err;
    final t = nama.trim();
    if (lokasi.any((r) => r.nama.toLowerCase() == t.toLowerCase())) {
      return 'Lokasi "$t" sudah ada.';
    }
    lokasi.add(RefItem(nama: t));
    _save();
    notifyListeners();
    return null;
  }

  String? renameKategori(String lama, String baru) {
    final err = _validasiNama(baru);
    if (err != null) return err;
    final t = baru.trim();
    if (kategori.any(
      (r) => r.nama != lama && r.nama.toLowerCase() == t.toLowerCase(),
    )) {
      return 'Kategori "$t" sudah ada.';
    }
    final i = kategori.indexWhere((r) => r.nama == lama);
    if (i == -1) return 'Kategori tidak ditemukan.';
    kategori[i] = kategori[i].copyWith(nama: t);
    _save();
    notifyListeners();
    return null;
  }

  String? renameLokasi(String lama, String baru) {
    final err = _validasiNama(baru);
    if (err != null) return err;
    final t = baru.trim();
    if (lokasi.any(
      (r) => r.nama != lama && r.nama.toLowerCase() == t.toLowerCase(),
    )) {
      return 'Lokasi "$t" sudah ada.';
    }
    final i = lokasi.indexWhere((r) => r.nama == lama);
    if (i == -1) return 'Lokasi tidak ditemukan.';
    lokasi[i] = lokasi[i].copyWith(nama: t);
    _save();
    notifyListeners();
    return null;
  }

  void setKategoriAktif(String nama, bool aktif) {
    final i = kategori.indexWhere((r) => r.nama == nama);
    if (i != -1 && kategori[i].aktif != aktif) {
      kategori[i] = kategori[i].copyWith(aktif: aktif);
      _save();
      notifyListeners();
    }
  }

  void setLokasiAktif(String nama, bool aktif) {
    final i = lokasi.indexWhere((r) => r.nama == nama);
    if (i != -1 && lokasi[i].aktif != aktif) {
      lokasi[i] = lokasi[i].copyWith(aktif: aktif);
      _save();
      notifyListeners();
    }
  }
}
