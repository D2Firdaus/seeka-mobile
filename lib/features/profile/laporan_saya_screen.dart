import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/auth_store.dart';
import '../../data/laporan_store.dart';
import '../../data/models.dart';
import '../../data/referensi_store.dart';
import '../../shared/filter_sheet.dart';
import '../../shared/report_card.dart';
import '../report/report_form_screen.dart';

/// Halaman "Laporan Saya": daftar laporan milik pengguna bergaya seperti
/// tab Laporan di panel admin — pencarian, filter Tipe + rentang tanggal,
/// dan baris ListTile ringkas dengan aksi toggle diklaim / edit.
class LaporanSayaScreen extends StatefulWidget {
  const LaporanSayaScreen({super.key});

  @override
  State<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends State<LaporanSayaScreen> {
  final _searchCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _kategoriId;
  int? _lokasiId;
  String? _tipe;
  DateTimeRange? _tanggal;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihKategori() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => FilterSheet(
        title: 'Kategori',
        options: ['Semua', ...ReferensiStore.instance.semuaNamaKategori],
        selected: _kategoriId == null
            ? 'Semua'
            : ReferensiStore.instance.namaKategori(_kategoriId!),
      ),
    );
    if (pilihan != null) {
      setState(() => _kategoriId =
          pilihan == 'Semua' ? null : ReferensiStore.instance.idKategoriDariNama(pilihan));
    }
  }

  Future<void> _pilihLokasi() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => FilterSheet(
        title: 'Lokasi',
        options: ['Semua', ...ReferensiStore.instance.semuaNamaLokasi],
        selected: _lokasiId == null
            ? 'Semua'
            : ReferensiStore.instance.namaLokasi(_lokasiId!),
      ),
    );
    if (pilihan != null) {
      setState(() => _lokasiId =
          pilihan == 'Semua' ? null : ReferensiStore.instance.idLokasiDariNama(pilihan));
    }
  }

  Future<void> _pilihTipe() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => FilterSheet(
        title: 'Tipe',
        options: const ['Semua', 'Ditemukan', 'Kehilangan', 'Diklaim'],
        selected: _tipe ?? 'Semua',
      ),
    );
    if (pilihan != null) {
      setState(() => _tipe = pilihan == 'Semua' ? null : pilihan);
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await pilihTanggalFilter(context, _tanggal);
    if (picked != _tanggal && mounted) {
      setState(() => _tanggal = picked);
    }
  }

  List<Item> _filter(List<Item> list) {
    if (_kategoriId != null) {
      list = list.where((l) => l.categoryId == _kategoriId).toList();
    }
    if (_lokasiId != null) {
      list = list.where((l) => l.locationId == _lokasiId).toList();
    }
    if (_tipe == 'Ditemukan') {
      list = list.where((l) => l.type == ItemType.ditemukan).toList();
    } else if (_tipe == 'Kehilangan') {
      list = list.where((l) => l.type == ItemType.kehilangan).toList();
    } else if (_tipe == 'Diklaim') {
      list = list.where((l) => l.diklaim).toList();
    }
    final range = _tanggal;
    if (range != null) {
      list = list
          .where(
            (l) =>
                !l.dateEvent.isBefore(range.start) &&
                !l.dateEvent.isAfter(range.end),
          )
          .toList();
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((l) => l.title.toLowerCase().contains(q)).toList();
    }
    final dd = _descCtrl.text.trim().toLowerCase();
    if (dd.isNotEmpty) {
      list = list
          .where((l) => l.description.toLowerCase().contains(dd))
          .toList();
    }
    return list;
  }

  void _edit(Item l) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (formCtx) => ReportFormScreen(
          tipe: l.type,
          existing: l,
          onSubmitted: () => Navigator.pop(formCtx),
        ),
      ),
    );
  }

  void _toggleStatus(Item l) {
    final next = l.diklaim ? ItemStatus.aktif : ItemStatus.diklaim;
    LaporanStore.instance.setStatusLaporan(l.id, next);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next == ItemStatus.diklaim
              ? '"${l.title}" ditandai sebagai diklaim.'
              : 'Status "${l.title}" diaktifkan kembali.',
        ),
        backgroundColor: kPrimary,
      ),
    );
  }

  Future<void> _hapus(Item l) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Hapus "${l.title}"?'),
        content: const Text('Laporan dan fotonya akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: kTextGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ya == true) {
      LaporanStore.instance.deleteLaporan(l.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${l.title}" dihapus.'),
            backgroundColor: kPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthStore.instance,
        LaporanStore.instance,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final user = AuthStore.instance.currentUser;
    final semua =
        user == null
            ? <Item>[]
            : LaporanStore.instance.laporanSaya(user.id);
    final hasil = _filter(semua);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Laporan Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Cari nama barang',
                prefixIcon: Icon(Icons.search, color: kTextGray, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _descCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Masukkan Deskripsi'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipButton(
                    label: 'Kategori',
                    value: _kategoriId == null
                        ? null
                        : ReferensiStore.instance.namaKategori(_kategoriId!),
                    onTap: _pilihKategori,
                  ),
                  const SizedBox(width: 10),
                  FilterChipButton(
                    label: 'Lokasi',
                    value: _lokasiId == null
                        ? null
                        : ReferensiStore.instance.namaLokasi(_lokasiId!),
                    onTap: _pilihLokasi,
                  ),
                  const SizedBox(width: 10),
                  FilterChipButton(
                    label: 'Tanggal',
                    icon: Icons.calendar_today_outlined,
                    value: _tanggal == null
                        ? null
                        : '${formatTanggal(_tanggal!.start)} - ${formatTanggal(_tanggal!.end)}',
                    onTap: _pilihTanggal,
                  ),
                  const SizedBox(width: 10),
                  FilterChipButton(
                    label: 'Tipe',
                    value: _tipe,
                    onTap: _pilihTipe,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: hasil.isEmpty
                ? Center(
                    child: Text(
                      semua.isEmpty
                          ? 'Belum ada laporan. Buat lewat tab Penemuan atau Kehilangan.'
                          : 'Tidak ada laporan.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextGray,
                        height: 1.4,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: hasil.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: kBorder, height: 1),
                    itemBuilder: (context, i) {
                      final l = hasil[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        title: Text(
                          l.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kTextDark,
                          ),
                        ),
                        subtitle: Text(
                          '${l.badge} · ${formatTanggal(l.dateEvent)}'
                          '${l.diklaim ? ' · Diklaim' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: kTextGray,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: l.diklaim
                                  ? 'Aktifkan kembali'
                                  : 'Tandai diklaim',
                              icon: Icon(
                                l.diklaim
                                    ? Icons.visibility_off_outlined
                                    : Icons.check_circle_outline,
                                color: l.diklaim ? kTextGray : kWAGreen,
                                size: 21,
                              ),
                              onPressed: () => _toggleStatus(l),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: kPrimary,
                                size: 21,
                              ),
                              onPressed: () => _edit(l),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 21,
                              ),
                              onPressed: () => _hapus(l),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
