import 'package:flutter/material.dart';

import '../core/utils/foto_store.dart';
import 'models.dart';
import 'prefs.dart';

/// Menangani data laporan: CRUD, status, dan query/filter.
class LaporanStore extends ChangeNotifier {
  LaporanStore._();

  static final LaporanStore instance = LaporanStore._();

  final List<Laporan> laporan = [];

  /// Hydrate dari SharedPreferences; seed demo bila belum ada data.
  Future<void> init() async {
    final rows = Prefs.readList(kKeyLaporan);
    laporan
      ..clear()
      ..addAll(rows == null ? _seed() : rows.map(Laporan.fromJson));
    notifyListeners();
  }

  Future<void> _save() => Prefs.writeList(
        kKeyLaporan,
        laporan.map((l) => l.toJson()).toList(growable: false),
      );

  List<Laporan> _seed() => [
        Laporan(
          id: '1',
          tipe: TipeLaporan.penemuan,
          namaBarang: 'Dompet kulit hitam',
          kategori: 'Dompet',
          deskripsi: 'Model lipat, ditemukan di dekat halte Dago.',
          fotoPaths: const [],
          lokasi: 'Lab Lanjut 2',
          tanggal: DateTime(2026, 10, 14),
          nomorWa: '6281234567890',
          pelapor: 'Demo',
        ),
        Laporan(
          id: '2',
          tipe: TipeLaporan.kehilangan,
          namaBarang: 'Kunci Warna Hitam',
          kategori: 'Kunci',
          deskripsi: 'Ada gantungan bola kecil.',
          fotoPaths: const [],
          lokasi: 'Lab Lanjut 2',
          tanggal: DateTime(2026, 10, 15),
          nomorWa: '6281234567891',
          pelapor: 'Demo',
        ),
        Laporan(
          id: '3',
          tipe: TipeLaporan.penemuan,
          namaBarang: 'Samsung Galaxy 90 Pro',
          kategori: 'Handphone',
          deskripsi: 'Galaxy Andromeda Aja kalah.',
          fotoPaths: const [],
          lokasi: 'Lab Lanjut 2',
          tanggal: DateTime(2026, 10, 14),
          nomorWa: '6281234567892',
          pelapor: 'Demo',
        ),
      ];

  void addLaporan(Laporan l) {
    laporan.insert(0, l);
    _save();
    notifyListeners();
  }

  void updateLaporan(Laporan updated) {
    final i = laporan.indexWhere((l) => l.id == updated.id);
    if (i != -1) {
      laporan[i] = updated;
      _save();
      notifyListeners();
    }
  }

  /// Hapus laporan beserta file fotonya dari disk.
  void deleteLaporan(String id) {
    final i = laporan.indexWhere((l) => l.id == id);
    if (i != -1) {
      final old = laporan.removeAt(i);
      FotoStore.hapusSemua(old.fotoPaths);
      _save();
      notifyListeners();
    }
  }

  void setStatusLaporan(String id, StatusLaporan status) {
    final i = laporan.indexWhere((l) => l.id == id);
    if (i != -1) {
      final old = laporan[i];
      laporan[i] = Laporan(
        id: old.id,
        tipe: old.tipe,
        namaBarang: old.namaBarang,
        kategori: old.kategori,
        deskripsi: old.deskripsi,
        fotoPaths: old.fotoPaths,
        lokasi: old.lokasi,
        tanggal: old.tanggal,
        nomorWa: old.nomorWa,
        pelapor: old.pelapor,
        pelaporEmail: old.pelaporEmail,
        status: status,
      );
      _save();
      notifyListeners();
    }
  }

  List<Laporan> laporanSaya(String email) =>
      laporan.where((l) => l.pelaporEmail == email).toList();

  List<Laporan> query({
    String? q,
    String? deskripsi,
    String? kategori,
    String? lokasi,
    String? tipe,
    DateTimeRange? tanggalRange,
  }) {
    var result = List<Laporan>.from(laporan);
    final qq = q?.trim().toLowerCase() ?? '';
    final dd = deskripsi?.trim().toLowerCase() ?? '';
    if (qq.isNotEmpty) {
      result = result
          .where((l) => l.namaBarang.toLowerCase().contains(qq))
          .toList();
    }
    if (dd.isNotEmpty) {
      result = result
          .where((l) => l.deskripsi.toLowerCase().contains(dd))
          .toList();
    }
    if (kategori != null && kategori != 'Semua') {
      result = result.where((l) => l.kategori == kategori).toList();
    }
    if (lokasi != null && lokasi != 'Semua') {
      result = result.where((l) => l.lokasi == lokasi).toList();
    }
    if (tipe != null && tipe != 'Semua') {
      if (tipe == 'Diklaim') {
        result = result.where((l) => l.diklaim).toList();
      } else {
        final t = tipe == 'Ditemukan'
            ? TipeLaporan.penemuan
            : TipeLaporan.kehilangan;
        result = result.where((l) => l.tipe == t).toList();
      }
    }
    if (tanggalRange != null) {
      result = result
          .where(
            (l) =>
                !l.tanggal.isBefore(tanggalRange.start) &&
                !l.tanggal.isAfter(tanggalRange.end),
          )
          .toList();
    }
    return result;
  }
}
