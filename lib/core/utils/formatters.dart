const _bulanSingkat = [
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

String formatTanggal(DateTime d) =>
    '${d.day} ${_bulanSingkat[d.month - 1]} ${d.year}';

String nomorWaWaMe(String nomor) {
  var n = nomor.replaceAll(RegExp(r'[\s\-]'), '');
  if (n.startsWith('0')) n = '62${n.substring(1)}';
  return n;
}
