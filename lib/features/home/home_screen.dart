import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/laporan_store.dart';
import '../../data/referensi_store.dart';
import '../../shared/app_logo.dart';
import '../../shared/filter_sheet.dart';
import '../../shared/report_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _stickyKey = GlobalKey();
  double? _stickyExtent;
  int _measureTries = 0;

  String? _kategori;
  String? _lokasi;
  String? _tipe;
  DateTimeRange? _tanggal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSticky());
  }

  void _measureSticky() {
    if (!mounted || _stickyExtent != null) return;
    final h = _stickyKey.currentContext?.size?.height;
    if (h != null && h > 0) {
      setState(() => _stickyExtent = h);
      return;
    }
    if (++_measureTries <= 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureSticky());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    setState(() {});
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
      builder: (ctx) => FilterSheet(
        title: 'Lokasi',
        options: ['Semua', ...ReferensiStore.instance.semuaNamaLokasi],
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LaporanStore.instance,
        ReferensiStore.instance,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final hasil = LaporanStore.instance.query(
      q: _searchCtrl.text,
      deskripsi: _descCtrl.text,
      kategori: _kategori,
      lokasi: _lokasi,
      tipe: _tipe,
      tanggalRange: _tanggal,
    );

    final stickyExtent = _stickyExtent;

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    AppLogo(width: 115),
                    SizedBox(height: 14),
                    Text(
                      'Bantu barang-barang yang hilang menemukan pemilik aslinya.',
                      style: TextStyle(
                        fontSize: 15,
                        color: kTextDark,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (stickyExtent == null)
              SliverToBoxAdapter(child: _buildStickyArea())
            else
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyAreaDelegate(
                  child: _buildStickyArea(),
                  extent: stickyExtent,
                ),
              ),
            if (hasil.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Tidak ada laporan yang cocok.',
                    style: TextStyle(color: kTextGray),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                sliver: SliverList.builder(
                  itemCount: hasil.length,
                  itemBuilder: (_, i) =>
                      ReportCard(laporan: hasil[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyArea() {
    return Container(
      key: _stickyKey,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

class _StickyAreaDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  const _StickyAreaDelegate({required this.child, required this.extent});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(width: double.infinity, height: extent, child: child);
  }

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => extent;

  @override
  bool shouldRebuild(covariant _StickyAreaDelegate oldDelegate) {
    return oldDelegate.extent != extent || oldDelegate.child != child;
  }
}
