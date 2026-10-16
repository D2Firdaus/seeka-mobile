enum TipeLaporan { penemuan, kehilangan }

enum StatusLaporan { aktif, diklaim }

enum Role { user, admin }

class UserAccount {
  final String nama;
  final String email;
  String password;
  final Role role;

  UserAccount({
    required this.nama,
    required this.email,
    required this.password,
    this.role = Role.user,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'email': email,
        'password': password,
        'role': role.name,
      };

  static UserAccount fromJson(Map<String, dynamic> j) => UserAccount(
        nama: j['nama'] as String? ?? '',
        email: j['email'] as String? ?? '',
        password: j['password'] as String? ?? '',
        role: Role.values.firstWhere(
          (r) => r.name == j['role'],
          orElse: () => Role.user,
        ),
      );
}

/// Item referensi (kategori/lokasi) yang bisa diarsipkan admin.
class RefItem {
  final String nama;
  final bool aktif;

  RefItem({required this.nama, this.aktif = true});

  RefItem copyWith({String? nama, bool? aktif}) =>
      RefItem(nama: nama ?? this.nama, aktif: aktif ?? this.aktif);

  Map<String, dynamic> toJson() => {'nama': nama, 'aktif': aktif};

  static RefItem fromJson(Map<String, dynamic> j) => RefItem(
        nama: j['nama'] as String? ?? '',
        aktif: j['aktif'] as bool? ?? true,
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipe': tipe.name,
        'namaBarang': namaBarang,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'fotoPaths': fotoPaths,
        'lokasi': lokasi,
        'tanggal': tanggal.toIso8601String(),
        'nomorWa': nomorWa,
        'pelapor': pelapor,
        'pelaporEmail': pelaporEmail,
        'status': status.name,
      };

  static Laporan fromJson(Map<String, dynamic> j) => Laporan(
        id: j['id'] as String? ?? '',
        tipe: TipeLaporan.values.firstWhere(
          (t) => t.name == j['tipe'],
          orElse: () => TipeLaporan.penemuan,
        ),
        namaBarang: j['namaBarang'] as String? ?? '',
        kategori: j['kategori'] as String? ?? '',
        deskripsi: j['deskripsi'] as String? ?? '',
        fotoPaths: (j['fotoPaths'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        lokasi: j['lokasi'] as String? ?? '',
        tanggal: DateTime.tryParse(j['tanggal'] as String? ?? '') ??
            DateTime.now(),
        nomorWa: j['nomorWa'] as String? ?? '',
        pelapor: j['pelapor'] as String? ?? '',
        pelaporEmail: j['pelaporEmail'] as String? ?? '',
        status: StatusLaporan.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => StatusLaporan.aktif,
        ),
      );
}
