import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/auth_store.dart';
import '../../data/laporan_store.dart';
import '../../data/models.dart';
import '../../shared/report_card.dart';
import '../report/report_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onGoHome;

  const ProfileScreen({super.key, required this.onGoHome});

  void _showGantiSandi(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const _GantiSandiSheet(),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login lagi untuk menggunakan SEEKA.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: kTextGray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
    if (ya == true && context.mounted) {
      AuthStore.instance.logout();
    }
  }

  void _editLaporan(BuildContext context, Laporan laporan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (formCtx) => ReportFormScreen(
          tipe: laporan.tipe,
          existing: laporan,
          backLabel: 'profil',
          onGoHome: () => Navigator.pop(formCtx),
          onSubmitted: () => Navigator.pop(formCtx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthStore.instance, LaporanStore.instance]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final user = AuthStore.instance.currentUser;
    final daftar = user == null
        ? <Laporan>[]
        : LaporanStore.instance.laporanSaya(user.email);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          InkWell(
            onTap: onGoHome,
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
          const SizedBox(height: 12),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kelola akun dan keamanan kata sandimu.',
            style: TextStyle(fontSize: 14, color: kTextGray, height: 1.35),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: kPinkBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 40, color: kPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.nama ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: kTextGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Laporan Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ketuk laporan untuk mengubah detailnya.',
                  style: TextStyle(fontSize: 12, color: kTextGray),
                ),
                const SizedBox(height: 8),
                if (daftar.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada laporan. Buat lewat tab Penemuan atau Kehilangan.',
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextGray,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < daftar.length; i++) ...[
                    if (i > 0) const Divider(color: kBorder, height: 1),
                    _LaporanTile(
                      laporan: daftar[i],
                      onTap: () => _editLaporan(context, daftar[i]),
                      onToggleStatus: () {
                        final l = daftar[i];
                        final next = l.diklaim
                            ? StatusLaporan.aktif
                            : StatusLaporan.diklaim;
                        LaporanStore.instance.setStatusLaporan(l.id, next);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              next == StatusLaporan.diklaim
                                  ? '"${l.namaBarang}" ditandai sebagai diklaim.'
                                  : 'Status "${l.namaBarang}" diaktifkan kembali.',
                            ),
                            backgroundColor: kPrimary,
                          ),
                        );
                      },
                    ),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: kPrimary),
                  title: const Text(
                    'Ganti kata sandi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Perbarui kata sandi akunmu',
                    style: TextStyle(fontSize: 12, color: kTextGray),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: kTextGray,
                    size: 20,
                  ),
                  onTap: () => _showGantiSandi(context),
                ),
                const Divider(color: kBorder, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: kPrimary),
                  title: const Text(
                    'Keluar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  subtitle: const Text(
                    'Akun tetap tersimpan di perangkat ini',
                    style: TextStyle(fontSize: 12, color: kTextGray),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: kTextGray,
                    size: 20,
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'SEEKA v0.1.0',
              style: TextStyle(fontSize: 12, color: kTextGray),
            ),
          ),
        ],
      ),
    );
  }
}

class _GantiSandiSheet extends StatefulWidget {
  const _GantiSandiSheet();

  @override
  State<_GantiSandiSheet> createState() => _GantiSandiSheetState();
}

class _GantiSandiSheetState extends State<_GantiSandiSheet> {
  final _formKey = GlobalKey<FormState>();
  final _lamaCtrl = TextEditingController();
  final _baruCtrl = TextEditingController();
  final _ulangCtrl = TextEditingController();
  bool _lihatLama = false;
  bool _lihatBaru = false;

  @override
  void dispose() {
    _lamaCtrl.dispose();
    _baruCtrl.dispose();
    _ulangCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final err = AuthStore.instance.changePassword(
      currentPassword: _lamaCtrl.text,
      newPassword: _baruCtrl.text,
    );
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil diganti.'),
        backgroundColor: kPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ganti kata sandi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masukkan kata sandi saat ini lalu kata sandi baru.',
                style: TextStyle(fontSize: 12, color: kTextGray),
              ),
              const SizedBox(height: 16),
              _SandiField(
                label: 'Kata sandi saat ini',
                controller: _lamaCtrl,
                obscure: !_lihatLama,
                onToggle: () => setState(() => _lihatLama = !_lihatLama),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Kata sandi saat ini wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              _SandiField(
                label: 'Kata sandi baru',
                controller: _baruCtrl,
                obscure: !_lihatBaru,
                onToggle: () => setState(() => _lihatBaru = !_lihatBaru),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Kata sandi baru wajib diisi';
                  }
                  if (v.length < 8) return 'Kata sandi minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _SandiField(
                label: 'Ulangi kata sandi baru',
                controller: _ulangCtrl,
                obscure: true,
                validator: (v) =>
                    v != _baruCtrl.text ? 'Kata sandi tidak sama' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextDark,
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: kBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _simpan,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SandiField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggle;
  final String? Function(String?)? validator;

  const _SandiField({
    required this.label,
    required this.controller,
    required this.obscure,
    this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Minimal 8 karakter',
            suffixIcon: onToggle == null
                ? null
                : IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kTextGray,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  ),
          ),
        ),
      ],
    );
  }
}

class _LaporanTile extends StatelessWidget {
  final Laporan laporan;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const _LaporanTile({
    required this.laporan,
    required this.onTap,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isPenemuan = laporan.tipe == TipeLaporan.penemuan;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(label: laporan.badge, found: isPenemuan),
                  const SizedBox(height: 6),
                  Text(
                    laporan.namaBarang,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${laporan.lokasi} · ${formatTanggal(laporan.tanggal)}',
                    style: const TextStyle(fontSize: 12, color: kTextGray),
                  ),
                  const SizedBox(height: 8),
                  _StatusToggle(
                    diklaim: laporan.diklaim,
                    onTap: onToggleStatus,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextGray, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final bool diklaim;
  final VoidCallback onTap;

  const _StatusToggle({required this.diklaim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: diklaim ? kPrimary : Colors.white,
          border: Border.all(color: kPrimary),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              diklaim ? Icons.check_circle_outline : Icons.radio_button_off,
              size: 12,
              color: diklaim ? Colors.white : kPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              diklaim ? 'DIKLAIM' : 'Tandai Diklaim',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: diklaim ? Colors.white : kPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
