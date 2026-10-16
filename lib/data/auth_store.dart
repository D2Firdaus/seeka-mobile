import 'package:flutter/foundation.dart';

import 'models.dart';
import 'prefs.dart';

/// Menangani akun: registrasi, login, logout, ganti kata sandi, dan sesi.
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  static const _adminEmail = 'admin@gmail.com';

  final List<UserAccount> users = [];
  UserAccount? currentUser;

  /// Hydrate dari SharedPreferences; seed admin bila belum ada data.
  Future<void> init() async {
    final rows = Prefs.readList(kKeyUsers);
    if (rows == null) {
      users.add(
        UserAccount(
          nama: 'Admin',
          email: _adminEmail,
          password: '',
          role: Role.admin,
        ),
      );
      await _saveUsers();
    } else {
      users
        ..clear()
        ..addAll(rows.map(UserAccount.fromJson));
    }

    final session = Prefs.readString(kKeySessionEmail);
    if (session != null) {
      final u = users.where((x) => x.email == session).firstOrNull;
      if (u != null) currentUser = u;
    }
    notifyListeners();
  }

  Future<void> _saveUsers() => Prefs.writeList(
        kKeyUsers,
        users.map((u) => u.toJson()).toList(growable: false),
      );

  Future<void> _saveSession() => currentUser == null
      ? Prefs.remove(kKeySessionEmail)
      : Prefs.writeString(kKeySessionEmail, currentUser!.email);

  /// True bila email terdaftar dan akunnya punya kata sandi
  /// (false utk email belum terdaftar atau akun tanpa sandi seperti admin).
  bool emailButuhPassword(String email) {
    final e = email.trim().toLowerCase();
    final u = users.where((x) => x.email == e).firstOrNull;
    return u != null && u.password.isNotEmpty;
  }

  /// True bila email terdaftar dengan akun tanpa kata sandi (admin seed).
  bool akunTanpaPassword(String email) {
    final e = email.trim().toLowerCase();
    return users.any((x) => x.email == e && x.password.isEmpty);
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
    if (users.any((u) => u.email == e)) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }
    users.add(UserAccount(nama: nama.trim(), email: e, password: password));
    _saveUsers();
    notifyListeners();
    return null;
  }

  String? login({required String email, required String password}) {
    final e = email.trim().toLowerCase();
    final user = users.where((u) => u.email == e).firstOrNull;
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

  /// Hapus akun user lain. Akun sendiri tidak bisa dihapus.
  String? deleteUser(String email) {
    final target = users.where((u) => u.email == email).firstOrNull;
    if (target == null) return 'Akun tidak ditemukan.';
    if (target.email == currentUser?.email) {
      return 'Tidak bisa menghapus akun yang sedang digunakan.';
    }
    if (target.role == Role.admin) return 'Akun admin tidak bisa dihapus.';
    users.remove(target);
    _saveUsers();
    notifyListeners();
    return null;
  }
}
