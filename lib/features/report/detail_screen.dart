import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models.dart';
import '../../shared/app_image.dart';
import '../../shared/report_card.dart';

class DetailScreen extends StatefulWidget {
  final Laporan laporan;
  final String backLabel;

  const DetailScreen({
    super.key,
    required this.laporan,
    this.backLabel = 'beranda',
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _fotoIndex = 0;

  Future<void> _ajukanKlaim() async {
    final l = widget.laporan;
    final nomor = nomorWaWaMe(l.nomorWa);
    final pesan = Uri.encodeComponent(
      'Halo, saya mengaku sebagai pemilik barang "${l.namaBarang}". '
      'Saya siap memberikan ciri khusus sebagai bukti kepemilikan.',
    );
    final uri = Uri.parse('https://wa.me/$nomor?text=$pesan');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.laporan;
    final isPenemuan = l.tipe == TipeLaporan.penemuan;

    return Scaffold(
      backgroundColor: kPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kembali ke ${widget.backLabel}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Detail barang',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FotoUtama(fotoPaths: l.fotoPaths, index: _fotoIndex),
                        if (l.fotoPaths.length > 1) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 56,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: l.fotoPaths.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) => InkWell(
                                onTap: () => setState(() => _fotoIndex = i),
                                child: Container(
                                  width: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: i == _fotoIndex
                                          ? kPrimary
                                          : kBorder,
                                      width: i == _fotoIndex ? 1.5 : 1,
                                    ),
                                    image: DecorationImage(
                                      image: imageProviderFor(l.fotoPaths[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.kategori.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: kTextGray,
                                  letterSpacing: .4,
                                ),
                              ),
                            ),
                            StatusBadge(
                              label: l.diklaim ? 'DIKLAIM' : l.badge,
                              found: isPenemuan,
                              claimed: l.diklaim,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.namaBarang,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.deskripsi,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kTextGray,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPenemuan
                              ? 'Informasi penemuan'
                              : 'Informasi kehilangan',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.place_outlined,
                          label: isPenemuan
                              ? 'Lokasi tercatat'
                              : 'Lokasi terakhir',
                          value: l.lokasi,
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: isPenemuan
                              ? 'Tanggal ditemukan'
                              : 'Tanggal kehilangan',
                          value: formatTanggal(l.tanggal),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: kBorder),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ini barang milikmu?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kTextDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Siapkan ciri khusus sebagai bukti kepemilikan.',
                          style: TextStyle(fontSize: 13, color: kTextGray),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: l.diklaim
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kTextGray,
                                    disabledBackgroundColor: const Color(
                                      0xFF9CA3AF,
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  onPressed: null,
                                  icon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                  ),
                                  label: const Text('Barang sudah diklaim'),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kWAGreen,
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  onPressed: _ajukanKlaim,
                                  icon: const Icon(Icons.chat, size: 22),
                                  label: const Text('Ajukan Klaim'),
                                ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: kTextGray,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Pemilik diverifikasi terlebih dahulu.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kTextGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoUtama extends StatelessWidget {
  final List<String> fotoPaths;
  final int index;

  const _FotoUtama({required this.fotoPaths, required this.index});

  @override
  Widget build(BuildContext context) {
    if (fotoPaths.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Icon(Icons.image_outlined, size: 48, color: kTextGray),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: AppImage(
        path: fotoPaths[index],
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: kTextGray),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
