import '../data/models.dart';

/// Seed default kategori — sumber awal data ReferensiStore.
final kSeedKategori = [
  'Dompet',
  'Kunci',
  'Handphone',
  'Tas',
  'Dokumen',
  'Lainnya',
].map((n) => RefItem(nama: n)).toList();

/// Seed default lokasi — sumber awal data ReferensiStore.
final kSeedLokasi = [
  'Lab Lanjut 1',
  'Lab Lanjut 2',
  'Perpustakaan',
  'Kantin',
  'Aula',
  'Ruang Dosen',
  'Gerbang Utama',
].map((n) => RefItem(nama: n)).toList();
