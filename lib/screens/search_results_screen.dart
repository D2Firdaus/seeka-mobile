import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/report_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final String initialDeskripsi;
  final VoidCallback onGoHome;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
    this.initialDeskripsi = '',
    required this.onGoHome,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchCtrl;
  late final TextEditingController _descCtrl;

  String? _kategori;
  String? _lokasi;
  String? _tipe;
  DateTimeRange? _tanggal;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _descCtrl = TextEditingController(text: widget.initialDeskripsi);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<Laporan> get _hasil => AppState.instance.query(
    q: _searchCtrl.text,
    deskripsi: _descCtrl.text,
    kategori: _kategori,
    lokasi: _lokasi,
    tipe: _tipe,
    tanggalRange: _tanggal,
  );

  String get _ringkasan {
    final parts = <String>[];
    if (_searchCtrl.text.trim().isNotEmpty) parts.add(_searchCtrl.text.trim());
    if (_lokasi != null) parts.add(_lokasi!);
    if (_kategori != null) parts.add(_kategori!);
    if (_tipe != null) parts.add(_tipe!);
    if (_tanggal != null) {
      parts.add(
        '${_tanggal!.start.day}-${_tanggal!.end.day} ${_bulanPendek(_tanggal!.end)} ${_tanggal!.end.year}',
      );
    }
    return parts.isEmpty ? 'Semua laporan' : parts.join(' · ');
  }

  Future<void> _pilihOpsi(
    String title,
    List<String> options,
    String? current,
    void Function(String?) set,
  ) async {
    final pilihan = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...options.map(
              (o) => RadioGroup<String>(
                groupValue: current ?? 'Semua',
                onChanged: (v) => Navigator.pop(ctx, v),
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
      ),
    );
    if (pilihan != null) {
      setState(() => set(pilihan == 'Semua' ? null : pilihan));
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
    final hasil = _hasil;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: kPrimary),
                        SizedBox(width: 4),
                        Text(
                          'Kembali ke beranda',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Hasil pencarian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari Barang',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: kTextDark),
                        onPressed: () => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(hintText: 'Deskripsi'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _chip(
                      'Kategori',
                      _kategori,
                      () => _pilihOpsi(
                        'Kategori',
                        ['Semua', ...kKategoriOptions],
                        _kategori,
                        (v) => _kategori = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      'Lokasi',
                      _lokasi,
                      () => _pilihOpsi(
                        'Lokasi',
                        ['Semua', ...AppState.instance.semuaLokasi],
                        _lokasi,
                        (v) => _lokasi = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      'Tanggal',
                      _tanggal == null
                          ? null
                          : '${formatTanggal(_tanggal!.start)} - ${formatTanggal(_tanggal!.end)}',
                      _pilihTanggal,
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      'Tipe',
                      _tipe,
                      () => _pilihOpsi(
                        'Tipe',
                        const ['Semua', 'Ditemukan', 'Kehilangan'],
                        _tipe,
                        (v) => _tipe = v,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ringkasan,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ketuk filter di atas untuk mengubah pencarian.',
                    style: TextStyle(fontSize: 12, color: kTextGray),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                color: kPrimary,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${hasil.length} Barang Berhasil Ditemukan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: hasil.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada barang yang cocok.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                              itemCount: hasil.length,
                              itemBuilder: (_, i) => ReportCard(
                                laporan: hasil[i],
                                backLabel: 'hasil pencarian',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    String label,
    String? value,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    final selected = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : kPrimary,
          border: selected ? Border.all(color: Colors.white) : null,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected ? value : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? kPrimary : Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon ?? Icons.keyboard_arrow_down,
              size: icon == null ? 14 : 13,
              color: selected ? kPrimary : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

String _bulanPendek(DateTime d) {
  const bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return bulan[d.month - 1];
}
