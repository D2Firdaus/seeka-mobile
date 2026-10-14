enum TipeLaporan { penemuan, kehilangan }

enum StatusLaporan { aktif, diklaim }

class UserAccount {
  final String nama;
  final String email;
  String password;

  UserAccount({
    required this.nama,
    required this.email,
    required this.password,
  });
}

class Laporan {
  final String id;
  final TipeLaporan tipe;
  final String namaBarang;
  final String kategori;
  final String deskripsi;
  final List<String> fotoPaths;
  final String lokasi;
  final DateTime tanggal;
  final String nomorWa;
  final String pelapor;
  final String pelaporEmail;
  final StatusLaporan status;

  Laporan({
    required this.id,
    required this.tipe,
    required this.namaBarang,
    required this.kategori,
    required this.deskripsi,
    required this.fotoPaths,
    required this.lokasi,
    required this.tanggal,
    required this.nomorWa,
    required this.pelapor,
    this.pelaporEmail = '',
    this.status = StatusLaporan.aktif,
  });

  String get badge => tipe == TipeLaporan.penemuan ? 'DITEMUKAN' : 'KEHILANGAN';

  bool get diklaim => status == StatusLaporan.diklaim;
}
