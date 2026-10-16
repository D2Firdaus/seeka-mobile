import 'package:flutter/material.dart';

import 'app.dart';
import 'data/auth_store.dart';
import 'data/laporan_store.dart';
import 'data/prefs.dart';
import 'data/referensi_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  await AuthStore.instance.init();
  await ReferensiStore.instance.init();
  await LaporanStore.instance.init();
  runApp(const SeekaApp());
}
