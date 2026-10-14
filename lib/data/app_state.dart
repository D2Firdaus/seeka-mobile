import 'package:flutter/material.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  AppState._() {
    _seed();
  }

  static final AppState instance = AppState._();

  final List<UserAccount> users = [];
  UserAccount? currentUser;
  final List<Laporan> laporan = [];

  void _seed() {
    laporan.addAll([
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
    ]);
  }

  String? register({
    required String nama,
    required String email,
    required String password,
  }) {
    final e = email.trim().toLowerCase();
    if (users.any((u) => u.email == e)) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }
    users.add(UserAccount(nama: nama.trim(), email: e, password: password));
    notifyListeners();
    return null;
  }

  String? login({required String email, required String password}) {
    final e = email.trim().toLowerCase();
    final user = users.where((u) => u.email == e).firstOrNull;
    if (user == null) return 'Email belum terdaftar. Daftar dulu yuk.';
    if (user.password != password) return 'Kata sandi salah. Coba lagi.';
    currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final user = currentUser;
    if (user == null) return 'Sesi berakhir. Silakan login ulang.';
    if (user.password != currentPassword) return 'Kata sandi saat ini salah.';
    if (newPassword.length < 8) return 'Kata sandi baru minimal 8 karakter.';
    user.password = newPassword;
    notifyListeners();
    return null;
  }

  void addLaporan(Laporan l) {
    laporan.insert(0, l);
    notifyListeners();
  }

  List<Laporan> laporanSaya(String email) =>
      laporan.where((l) => l.pelaporEmail == email).toList();

  void updateLaporan(Laporan updated) {
    final i = laporan.indexWhere((l) => l.id == updated.id);
    if (i != -1) {
      laporan[i] = updated;
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
      notifyListeners();
    }
  }

  List<String> get semuaLokasi =>
      laporan.map((l) => l.lokasi).toSet().toList()..sort();

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
      final t = tipe == 'Ditemukan'
          ? TipeLaporan.penemuan
          : TipeLaporan.kehilangan;
      result = result.where((l) => l.tipe == t).toList();
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
