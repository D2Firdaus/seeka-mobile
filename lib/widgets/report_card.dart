import 'package:flutter/material.dart';

import '../data/models.dart';
import '../screens/detail_screen.dart';
import '../theme.dart';
import 'app_image.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final bool found;
  final bool claimed;

  const StatusBadge({
    super.key,
    required this.label,
    required this.found,
    this.claimed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: claimed ? kPrimary : (found ? kPinkBg : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: claimed ? Colors.white : (found ? kPrimary : kTextGray),
          letterSpacing: .3,
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Laporan laporan;
  final String backLabel;

  const ReportCard({
    super.key,
    required this.laporan,
    this.backLabel = 'beranda',
  });

  @override
  Widget build(BuildContext context) {
    final l = laporan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(fotoPaths: l.fotoPaths),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.kategori.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: kTextGray,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: l.diklaim ? 'DIKLAIM' : l.badge,
                          found: l.tipe == TipeLaporan.penemuan,
                          claimed: l.diklaim,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.namaBarang,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InfoLine(icon: Icons.place_outlined, text: l.lokasi),
                    const SizedBox(height: 2),
                    _InfoLine(
                      icon: Icons.calendar_today_outlined,
                      text: formatTanggal(l.tanggal),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.deskripsi,
            style: const TextStyle(fontSize: 13, color: kTextGray),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DetailScreen(laporan: l, backLabel: backLabel),
                  ),
                );
              },
              child: const Text('Lihat detail barang'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final List<String> fotoPaths;

  const _Thumb({required this.fotoPaths});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 94,
      height: 100,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: fotoPaths.isEmpty
          ? const Icon(Icons.image_outlined, size: 32, color: kTextGray)
          : AppImage(path: fotoPaths.first),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: kTextGray),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: kTextGray),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class FilterChipButton extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;

  const FilterChipButton({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : kPrimary,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected ? (value ?? label) : label,
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
