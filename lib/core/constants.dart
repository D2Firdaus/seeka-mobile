import '../data/models.dart';

/// Id user utk laporan demo (soft delete — hanya sbg atribusi pelapor).
const kDemoUserId = 2;

/// Seed default kategori — sumber awal data ReferensiStore.
final kSeedKategori = [
  'Dompet',
  'Kunci',
  'Handphone',
  'Tas',
  'Dokumen',
  'Lainnya',
].asMap().entries.map((e) => RefItem(id: e.key + 1, name: e.value)).toList();

/// Seed default lokasi — sumber awal data ReferensiStore.
final kSeedLokasi = [
  'Lab Lanjut 1',
  'Lab Lanjut 2',
  'Perpustakaan',
  'Kantin',
  'Aula',
  'Ruang Dosen',
  'Gerbang Utama',
].asMap().entries.map((e) => RefItem(id: e.key + 1, name: e.value)).toList();
