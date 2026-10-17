import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/utils/formatters.dart';

/// Bottom sheet daftar opsi filter (radio) — gaya filter beranda.
class FilterSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;

  const FilterSheet({
    super.key,
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

/// Sheet aksi "Pilih rentang tanggal" / "Hapus filter tanggal", lalu buka
/// date range picker berwarna primary. Mengembalikan `current` saat batal.
Future<DateTimeRange?> pilihTanggalFilter(
  BuildContext context,
  DateTimeRange? current,
) async {
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
            subtitle: current == null
                ? const Text('Belum ada filter tanggal')
                : Text(
                    '${formatTanggal(current.start)} - ${formatTanggal(current.end)}',
                  ),
            onTap: () => Navigator.pop(ctx, 'pilih'),
          ),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.clear, color: kTextGray),
              title: const Text('Hapus filter tanggal'),
              onTap: () => Navigator.pop(ctx, 'hapus'),
            ),
        ],
      ),
    ),
  );
  if (aksi == 'pilih') {
    if (!context.mounted) return current;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: current,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
        child: child!,
      ),
    );
    return picked ?? current;
  }
  if (aksi == 'hapus') return null;
  return current;
}
