import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/laporan_store.dart';
import '../../shared/app_logo.dart';
import '../../shared/report_card.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoHome;

  const HomeScreen({super.key, required this.onGoHome});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _kategori;
  String? _lokasi;
  String? _tipe;
  DateTimeRange? _tanggal;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          initialQuery: _searchCtrl.text,
          initialDeskripsi: _descCtrl.text,
          onGoHome: widget.onGoHome,
        ),
      ),
    );
  }

  Future<void> _pilihKategori() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _FilterSheet(
        title: 'Kategori',
        options: ['Semua', ...kKategoriOptions],
        selected: _kategori ?? 'Semua',
      ),
    );
    if (pilihan != null) {
      setState(() => _kategori = pilihan == 'Semua' ? null : pilihan);
    }
  }

  Future<void> _pilihLokasi() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _FilterSheet(
        title: 'Lokasi',
        options: ['Semua', ...kLokasiOptions],
        selected: _lokasi ?? 'Semua',
      ),
    );
    if (pilihan != null) {
      setState(() => _lokasi = pilihan == 'Semua' ? null : pilihan);
    }
  }

  Future<void> _pilihTipe() async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _FilterSheet(
        title: 'Tipe',
        options: const ['Semua', 'Ditemukan', 'Kehilangan'],
        selected: _tipe ?? 'Semua',
      ),
    );
    if (pilihan != null) {
      setState(() => _tipe = pilihan == 'Semua' ? null : pilihan);
    }
  }

  Future<void> _pilihTanggal() async {
    final aksi = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range_outlined, color: kPrimary),
              title: const Text('Pilih rentang tanggal'),
              subtitle: _tanggal == null
                  ? const Text('Belum ada filter tanggal')
                  : Text(
                      '${formatTanggal(_tanggal!.start)} - ${formatTanggal(_tanggal!.end)}',
                    ),
              onTap: () => Navigator.pop(ctx, 'pilih'),
            ),
            if (_tanggal != null)
              ListTile(
                leading: const Icon(Icons.clear, color: kTextGray),
                title: const Text('Hapus filter tanggal'),
                onTap: () => Navigator.pop(ctx, 'hapus'),
              ),
          ],
        ),
      ),
    );
    if (aksi == 'pilih' && mounted) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 1),
        initialDateRange: _tanggal,
        builder: (context, child) => Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
          child: child!,
        ),
      );
      if (picked != null) setState(() => _tanggal = picked);
    } else if (aksi == 'hapus') {
      setState(() => _tanggal = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasil = LaporanStore.instance.query(
      kategori: _kategori,
      lokasi: _lokasi,
      tipe: _tipe,
      tanggalRange: _tanggal,
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(width: 115),
                const SizedBox(height: 14),
                const Text(
                  'Bantu barang-barang yang hilang menemukan pemilik aslinya.',
                  style: TextStyle(
                    fontSize: 15,
                    color: kTextDark,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _submitSearch(),
                  decoration: InputDecoration(
                    hintText: 'Cari Barang',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: kTextDark),
                      onPressed: _submitSearch,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan Deskripsi',
                  ),
                  onSubmitted: (_) => _submitSearch(),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipButton(
                        label: 'Kategori',
                        value: _kategori,
                        onTap: _pilihKategori,
                      ),
                      const SizedBox(width: 10),
                      FilterChipButton(
                        label: 'Lokasi',
                        value: _lokasi,
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
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: kPrimary,
              child: hasil.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada laporan yang cocok.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                      itemCount: hasil.length,
                      itemBuilder: (_, i) =>
                          ReportCard(laporan: hasil[i], backLabel: 'beranda'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          ...options.map(
            (o) => RadioGroup<String>(
              groupValue: selected,
              onChanged: (v) => Navigator.pop(context, v),
              child: RadioListTile<String>(
                value: o,
                activeColor: kPrimary,
                title: Text(o),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
