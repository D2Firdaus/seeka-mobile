import 'package:flutter/foundation.dart';

import 'models.dart';

/// Menangani akun: registrasi, login, logout, dan ganti kata sandi.
class AuthStore extends ChangeNotifier {
  AuthStore._();

  static final AuthStore instance = AuthStore._();

  final List<UserAccount> users = [];
  UserAccount? currentUser;

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
}
