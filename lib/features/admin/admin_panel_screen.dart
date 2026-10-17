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

/// Panel admin: kelola referensi (kategori/lokasi), laporan, dan pengguna.
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            'Panel Admin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          bottom: const TabBar(
            labelColor: kPrimary,
            unselectedLabelColor: kTextGray,
            indicatorColor: kPrimary,
            tabs: [
              Tab(text: 'Referensi'),
              Tab(text: 'Laporan'),
              Tab(text: 'Pengguna'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabReferensi(),
            _TabLaporan(),
            _TabPengguna(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Kategori & Lokasi
// ---------------------------------------------------------------------------

class _TabReferensi extends StatelessWidget {
  const _TabReferensi();

  Future<void> _editDialog(
    BuildContext context, {
    required String title,
    required String? initial,
    required String? Function(String) onSubmit,
  }) async {
    final ctrl = TextEditingController(text: initial ?? '');
    final hasil = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: initial ?? 'Nama baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: kTextGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Simpan', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
    if (hasil == null) return;
    final message = onSubmit(hasil);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Data tersimpan.'), backgroundColor: kPrimary),
      );
    }
  }

  Future<void> _konfirmasiArsip(
    BuildContext context, {
    required String nama,
    required bool aktif,
    required void Function() onYes,
  }) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(aktif ? 'Arsipkan "$nama"?' : 'Aktifkan kembali "$nama"?'),
        content: Text(
          aktif
              ? '"$nama" tidak akan muncul di pilihan form & filter baru, '
                  'tapi tetap tampil pada laporan lama.'
              : '"$nama" akan kembali tersedia di form & filter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: kTextGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              aktif ? 'Arsipkan' : 'Aktifkan',
              style: const TextStyle(color: kPrimary),
            ),
          ),
        ],
      ),
    );
    if (ya == true) onYes();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReferensiStore.instance,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _RefSection(
            title: 'Kategori',
            items: ReferensiStore.instance.kategori,
            onAdd: () => _editDialog(
              context,
              title: 'Tambah kategori',
              initial: null,
              onSubmit: ReferensiStore.instance.addKategori,
            ),
            onEdit: (item) => _editDialog(
              context,
              title: 'Ubah kategori',
              initial: item.name,
              onSubmit: (v) => ReferensiStore.instance.renameKategori(item.id, v),
            ),
            onToggle: (item) => _konfirmasiArsip(
              context,
              nama: item.name,
              aktif: item.aktif,
              onYes: () =>
                  ReferensiStore.instance.setKategoriAktif(item.id, !item.aktif),
            ),
          ),
          const SizedBox(height: 24),
          _RefSection(
            title: 'Lokasi',
            items: ReferensiStore.instance.lokasi,
            onAdd: () => _editDialog(
              context,
              title: 'Tambah lokasi',
              initial: null,
              onSubmit: ReferensiStore.instance.addLokasi,
            ),
            onEdit: (item) => _editDialog(
              context,
              title: 'Ubah lokasi',
              initial: item.name,
              onSubmit: (v) => ReferensiStore.instance.renameLokasi(item.id, v),
            ),
            onToggle: (item) => _konfirmasiArsip(
              context,
              nama: item.name,
              aktif: item.aktif,
              onYes: () =>
                  ReferensiStore.instance.setLokasiAktif(item.id, !item.aktif),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefSection extends StatelessWidget {
  final String title;
  final List<RefItem> items;
  final VoidCallback onAdd;
  final ValueChanged<RefItem> onEdit;
  final ValueChanged<RefItem> onToggle;

  const _RefSection({
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: kPrimary),
                  tooltip: 'Tambah $title',
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                'Belum ada data.',
                style: TextStyle(fontSize: 13, color: kTextGray),
              ),
            )
          else
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(color: kBorder, height: 1),
              ListTile(
                dense: true,
                title: Text(
                  items[i].name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: items[i].aktif ? kTextDark : kTextGray,
                  ),
                ),
                subtitle: items[i].aktif
                    ? null
                    : const Text(
                        'Diarsipkan',
                        style: TextStyle(fontSize: 11, color: kTextGray),
                      ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        items[i].aktif ? Icons.archive_outlined : Icons.unarchive_outlined,
                        color: kTextGray,
                        size: 20,
                      ),
                      tooltip: items[i].aktif ? 'Arsipkan' : 'Aktifkan kembali',
                      onPressed: () => onToggle(items[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: kPrimary, size: 20),
                      tooltip: 'Ubah nama',
                      onPressed: () => onEdit(items[i]),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Laporan
// ---------------------------------------------------------------------------

class _TabLaporan extends StatefulWidget {
  const _TabLaporan();

  @override
  State<_TabLaporan> createState() => _TabLaporanState();
}

class _TabLaporanState extends State<_TabLaporan> {
  int? _kategoriId;
  int? _lokasiId;
  String? _tipe;
  DateTimeRange? _tanggal;
  String _q = '';
  String _dd = '';

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

  List<Item> get _hasil {
    var list = LaporanStore.instance.items;
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
    final qq = _q.trim().toLowerCase();
    if (qq.isNotEmpty) {
      list = list
          .where(
            (l) =>
                l.title.toLowerCase().contains(qq) ||
                AuthStore.instance.namaUser(l.userId).toLowerCase().contains(qq),
          )
          .toList();
    }
    final dd = _dd.trim().toLowerCase();
    if (dd.isNotEmpty) {
      list = list
          .where((l) => l.description.toLowerCase().contains(dd))
          .toList();
    }
    return list;
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LaporanStore.instance,
      builder: (context, _) {
        final hasil = _hasil;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari nama barang / pelapor',
                  prefixIcon: Icon(Icons.search, color: kTextGray, size: 20),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Masukkan Deskripsi',
                ),
                onChanged: (v) => setState(() => _dd = v),
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
                  ? const Center(
                      child: Text(
                        'Tidak ada laporan.',
                        style: TextStyle(fontSize: 13, color: kTextGray),
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
                            '${l.badge} · ${AuthStore.instance.namaUser(l.userId)}'
                            ' · ${formatTanggal(l.dateEvent)}'
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
                                onPressed: () {
                                  LaporanStore.instance.setStatusLaporan(
                                    l.id,
                                    l.diklaim
                                        ? ItemStatus.aktif
                                        : ItemStatus.diklaim,
                                  );
                                },
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
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3: Pengguna
// ---------------------------------------------------------------------------

class _TabPengguna extends StatelessWidget {
  const _TabPengguna();

  Future<void> _hapus(BuildContext context, User u) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Hapus akun ${u.name}?'),
        content: const Text(
          'Akun akan dihapus. Laporan miliknya tetap tersimpan dengan nama pelapor lama.',
        ),
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
    if (ya == true && context.mounted) {
      final err = AuthStore.instance.deleteUser(u.id);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red.shade700),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun ${u.name} dihapus.'),
            backgroundColor: kPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthStore.instance,
      builder: (context, _) {
        final users = AuthStore.instance.users;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: users.length,
          separatorBuilder: (_, _) => const Divider(color: kBorder, height: 1),
          itemBuilder: (context, i) {
            final u = users[i];
            final isAdmin = u.role == Role.admin;
            final isSelf =
                u.email == AuthStore.instance.currentUser?.email;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      u.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAdmin ? kPinkBg : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      isAdmin ? 'Admin' : 'User',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isAdmin ? kPrimary : kTextGray,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                u.email,
                style: const TextStyle(fontSize: 12, color: kTextGray),
              ),
              trailing: (isAdmin || isSelf)
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Hapus akun',
                      onPressed: () => _hapus(context, u),
                    ),
            );
          },
        );
      },
    );
  }
}
