import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Pembungkus SharedPreferences untuk persistensi data JSON.
class Prefs {
  Prefs._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static List<Map<String, dynamic>>? readList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> writeList(String key, List<Map<String, dynamic>> value) {
    return _prefs?.setString(key, jsonEncode(value)) ?? Future.value();
  }

  static String? readString(String key) => _prefs?.getString(key);

  static Future<void> writeString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value();
  }

  static Future<void> remove(String key) {
    return _prefs?.remove(key) ?? Future.value();
  }
}

const kKeyUsers = 'users_json';
const kKeySessionEmail = 'session_email';
const kKeyLaporan = 'laporan_json';
const kKeyKategori = 'kategori_json';
const kKeyLokasi = 'lokasi_json';
