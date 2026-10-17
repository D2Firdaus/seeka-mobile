import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import 'models.dart';
import 'prefs.dart';

/// Menangani akun (tabel `users`): registrasi, login, logout, ganti kata sandi,
/// dan sesi. Hapus akun = soft delete; laporan tetap bisa resolusi nama pelapor.
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  static const _adminEmail = 'admin@gmail.com';

  final List<User> _users = [];
  User? currentUser;

  /// Akun aktif saja (tanpa yang soft delete).
  List<User> get users => _users.where((u) => u.aktif).toList();

  /// Resolusi nama pelapor — termasuk akun yang sudah soft delete.
  String namaUser(int id) =>
      _users.where((u) => u.id == id).firstOrNull?.name ?? 'Pengguna';

  /// Hydrate dari SharedPreferences; seed admin bila belum ada data.
  Future<void> init() async {
    final rows = Prefs.readList(kKeyUsers);
    if (rows == null) {
      final now = DateTime.now();
      _users
        ..clear()
        ..addAll([
          User(
            id: 1,
            name: 'Admin',
            email: _adminEmail,
            password: '',
            role: Role.admin,
            createdAt: now,
            updatedAt: now,
          ),
          User(
            id: kDemoUserId,
            name: 'Demo',
            email: '',
            password: '',
            createdAt: now,
            updatedAt: now,
            deletedAt: now,
          ),
        ]);
      await _saveUsers();
    } else {
      _users
        ..clear()
        ..addAll(rows.map(User.fromJson));
    }

    final session = Prefs.readString(kKeySessionUserId);
    if (session != null) {
      final id = int.tryParse(session);
      final u = _users.where((x) => x.id == id && x.aktif).firstOrNull;
      if (u != null) currentUser = u;
    }
    notifyListeners();
  }

  Future<void> _saveUsers() => Prefs.writeList(
        kKeyUsers,
        _users.map((u) => u.toJson()).toList(growable: false),
      );

  Future<void> _saveSession() => currentUser == null
      ? Prefs.remove(kKeySessionUserId)
      : Prefs.writeString(kKeySessionUserId, currentUser!.id.toString());

  /// True bila email terdaftar dan akunnya punya kata sandi
  /// (false utk email belum terdaftar atau akun tanpa sandi seperti admin).
  bool emailButuhPassword(String email) {
    final e = email.trim().toLowerCase();
    final u = _users.where((x) => x.email == e && x.aktif).firstOrNull;
    return u != null && u.password.isNotEmpty;
  }

  /// True bila email terdaftar dengan akun tanpa kata sandi (admin seed).
  bool akunTanpaPassword(String email) {
    final e = email.trim().toLowerCase();
    return _users.any((x) => x.email == e && x.aktif && x.password.isEmpty);
  }

  String? register({
    required String nama,
    required String email,
    required String password,
  }) {
    final e = email.trim().toLowerCase();
    if (e == _adminEmail) {
      return 'Email tersebut tidak bisa didaftarkan.';
    }
    if (_users.any((u) => u.email == e && u.aktif)) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }
    final maxId = _users.fold<int>(0, (m, u) => u.id > m ? u.id : m);
    _users.add(User(id: maxId + 1, name: nama.trim(), email: e, password: password));
    _saveUsers();
    notifyListeners();
    return null;
  }

  String? login({required String email, required String password}) {
    final e = email.trim().toLowerCase();
    final user = _users.where((u) => u.email == e && u.aktif).firstOrNull;
    if (user == null) return 'Email belum terdaftar. Daftar dulu yuk.';
    if (user.password.isNotEmpty && user.password != password) {
      return 'Kata sandi salah. Coba lagi.';
    }
    currentUser = user;
    _saveSession();
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    _saveSession();
    notifyListeners();
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    final user = currentUser;
    if (user == null) return 'Sesi berakhir. Silakan login ulang.';
    if (user.password.isNotEmpty && user.password != currentPassword) {
      return 'Kata sandi saat ini salah.';
    }
    if (newPassword.length < 8) return 'Kata sandi baru minimal 8 karakter.';
    user.password = newPassword;
    _saveUsers();
    notifyListeners();
    return null;
  }

  /// Soft delete akun user lain. Akun sendiri tidak bisa dihapus.
  String? deleteUser(int id) {
    final i = _users.indexWhere((u) => u.id == id);
    if (i == -1) return 'Akun tidak ditemukan.';
    final target = _users[i];
    if (target.email == currentUser?.email) {
      return 'Tidak bisa menghapus akun yang sedang digunakan.';
    }
    if (target.role == Role.admin) return 'Akun admin tidak bisa dihapus.';
    if (!target.aktif) return 'Akun tidak ditemukan.';
    _users[i] = User(
      id: target.id,
      name: target.name,
      email: target.email,
      password: target.password,
      role: target.role,
      createdAt: target.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: DateTime.now(),
    );
    _saveUsers();
    notifyListeners();
    return null;
  }
}
