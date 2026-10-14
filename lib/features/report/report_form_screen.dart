import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/auth_store.dart';
import '../../data/laporan_store.dart';
import '../../data/models.dart';
import '../../shared/app_image.dart';

class ReportFormScreen extends StatefulWidget {
  final TipeLaporan tipe;
  final Laporan? existing;
  final String backLabel;
  final VoidCallback onGoHome;
  final VoidCallback onSubmitted;

  const ReportFormScreen({
    super.key,
    required this.tipe,
    this.existing,
    this.backLabel = 'beranda',
    required this.onGoHome,
    required this.onSubmitted,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen>
    with AutomaticKeepAliveClientMixin {
  late TipeLaporan _tipe;
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _waCtrl = TextEditingController();

  String? _kategori;
  DateTime? _tanggal;
  final List<String> _fotoPaths = [];
  bool _setuju = false;
  bool _submitting = false;

  final _picker = ImagePicker();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tipe = widget.existing?.tipe ?? widget.tipe;
    final e = widget.existing;
    if (e != null) {
      _namaCtrl.text = e.namaBarang;
      _descCtrl.text = e.deskripsi;
      _lokasiCtrl.text = e.lokasi;
      _waCtrl.text = e.nomorWa;
      _kategori = e.kategori;
      _tanggal = e.tanggal;
      _fotoPaths.addAll(e.fotoPaths);
      _setuju = true;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _descCtrl.dispose();
    _lokasiCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.existing != null;

  bool get _isPenemuan => _tipe == TipeLaporan.penemuan;

  String get _judul {
    final base = _isPenemuan ? 'Laporan Penemuan' : 'Laporan Kehilangan';
    return _isEdit ? 'Edit $base' : base;
  }

  String get _subtitle {
    if (_isEdit) {
      return 'Perbarui detail laporan agar informasinya tetap akurat.';
    }
    return _isPenemuan
        ? 'Menemukan barang? Ceritakan detailnya agar lebih mudah dikenali.'
        : 'Kehilangan? Ceritakan detailnya agar lebih mudah dikenali.';
  }

  String get _lokasiJudul => _isPenemuan
      ? 'Lokasi dan tanggal Penemuan'
      : 'Lokasi dan tanggal kehilangan';

  String get _lokasiSubtitle => _isPenemuan
      ? 'Isi lokasi barang terlihat dan tanggal penemuan.'
      : 'Isi lokasi terakhir barang terlihat dan perkiraan tanggal kehilangan.';

  String get _lokasiLabel =>
      _isPenemuan ? 'Lokasi penemuan' : 'Lokasi kehilangan';

  String get _tanggalLabel =>
      _isPenemuan ? 'Tanggal penemuan' : 'Tanggal kehilangan';

  Future<void> _pickFoto() async {
    if (_fotoPaths.length >= 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Maksimal 3 foto.')));
      return;
    }
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _fotoPaths.add(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih foto. Coba lagi.')),
        );
      }
    }
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context)
            .copyWith(colorScheme: const ColorScheme.light(primary: kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _namaCtrl.clear();
    _descCtrl.clear();
    _lokasiCtrl.clear();
    _waCtrl.clear();
    setState(() {
      _kategori = null;
      _tanggal = null;
      _fotoPaths.clear();
      _setuju = false;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_setuju) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centang pernyataan kebenaran informasi dulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    final user = AuthStore.instance.currentUser;
    if (_isEdit) {
      final old = widget.existing!;
      LaporanStore.instance.updateLaporan(
        Laporan(
          id: old.id,
          tipe: _tipe,
          namaBarang: _namaCtrl.text.trim(),
          kategori: _kategori!,
          deskripsi: _descCtrl.text.trim(),
          fotoPaths: List.from(_fotoPaths),
          lokasi: _lokasiCtrl.text.trim(),
          tanggal: _tanggal!,
          nomorWa: _waCtrl.text.trim(),
          pelapor: old.pelapor,
          pelaporEmail: old.pelaporEmail,
          status: old.status,
        ),
      );
      setState(() => _submitting = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil diperbarui!'),
          backgroundColor: kPrimary,
        ),
      );
      widget.onSubmitted();
      return;
    }
    LaporanStore.instance.addLaporan(
      Laporan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tipe: _tipe,
        namaBarang: _namaCtrl.text.trim(),
        kategori: _kategori!,
        deskripsi: _descCtrl.text.trim(),
        fotoPaths: List.from(_fotoPaths),
        lokasi: _lokasiCtrl.text.trim(),
        tanggal: _tanggal!,
        nomorWa: _waCtrl.text.trim(),
        pelapor: user?.nama ?? 'Anonim',
        pelaporEmail: user?.email ?? '',
      ),
    );
    setState(() => _submitting = false);
    _reset();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPenemuan
              ? 'Laporan penemuan berhasil dikirim!'
              : 'Laporan kehilangan berhasil dikirim!',
        ),
        backgroundColor: kPrimary,
      ),
    );
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              InkWell(
                onTap: widget.onGoHome,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: kPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Kembali ke ${widget.backLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _judul,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextGray,
                  height: 1.35,
                ),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Jenis laporan *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),
                    ),
                    const Text(
                      '* Kolom wajib diisi',
                      style: TextStyle(fontSize: 11, color: kTextGray),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _JenisOption(
                        label: 'Kehilangan',
                        selected: _tipe == TipeLaporan.kehilangan,
                        onTap: () =>
                            setState(() => _tipe = TipeLaporan.kehilangan),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _JenisOption(
                        label: 'Penemuan',
                        selected: _tipe == TipeLaporan.penemuan,
                        onTap: () =>
                            setState(() => _tipe = TipeLaporan.penemuan),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Nama barang *',
                      child: TextFormField(
                        controller: _namaCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Judul Barang',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Wajib diisi'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Kategori *',
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('kategori-$_kategori'),
                        initialValue: _kategori,
                        hint: const Text('Kategori Barang'),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: kTextGray,
                        ),
                        items: kKategoriOptions
                            .map(
                              (k) => DropdownMenuItem(value: k, child: Text(k)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _kategori = v),
                        validator: (v) => v == null ? 'Pilih' : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Deskripsi / ciri khas *',
                child: TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Jelaskan warna, merek, bahan, ukuran, atau tanda khusus pada barang.',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '*Simpan satu ciri unik untuk membantu verifikasi saat barang ditemukan.',
                style: TextStyle(fontSize: 11, color: kTextGray),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto barang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              _FotoBox(
                fotoPaths: _fotoPaths,
                onPick: _pickFoto,
                onRemove: (i) => setState(() => _fotoPaths.removeAt(i)),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _lokasiJudul,
                subtitle: _lokasiSubtitle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: '$_lokasiLabel *',
                        child: TextFormField(
                          controller: _lokasiCtrl,
                          decoration: InputDecoration(
                            hintText: 'Lokasi',
                            suffixIcon: const Icon(
                              Icons.place_outlined,
                              color: kTextGray,
                              size: 20,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Wajib diisi'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: '$_tanggalLabel *',
                        child: InkWell(
                          onTap: _pickTanggal,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: 'hh / bb / tttt',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: kTextGray,
                                size: 18,
                              ),
                            ),
                            child: Text(
                              _tanggal == null ? '' : formatTanggal(_tanggal!),
                              style: TextStyle(
                                fontSize: 14,
                                color: _tanggal == null
                                    ? const Color(0xFF9CA3AF)
                                    : kTextDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                validator: () =>
                    _tanggal == null ? 'Tanggal wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Informasi kontak pelapor',
                subtitle: 'Cantumkan kontak aktif yang dapat dihubungi.',
                child: _LabeledField(
                  label: 'Nomor WhatsApp *',
                  child: TextFormField(
                    controller: _waCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nomor aktif',
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Wajib diisi';
                      final cleaned = t.replaceAll(RegExp(r'[\s\-]'), '');
                      if (!RegExp(r'^(\+?62|0)\d{8,13}$').hasMatch(cleaned)) {
                        return 'Format nomor tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _setuju,
                      onChanged: (v) => setState(() => _setuju = v ?? false),
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      activeColor: kPrimary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Saya menyatakan informasi dalam laporan ini benar dan dapat dipertanggungjawabkan. *',
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
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
                      onPressed: _submitting
                          ? null
                          : (widget.existing != null
                                ? () => Navigator.pop(context)
                                : _reset),
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
                      onPressed: _submitting ? null : _submit,
                      child: Text(
                        _isEdit ? 'Simpan perubahan' : 'Kirim laporan',
                      ),
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

class _JenisOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _JenisOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? kPinkBg : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? kPrimary : kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? kPrimary : kTextGray,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kPrimary : kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

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
        child,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String? Function()? validator;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: kTextGray,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          FormField<String>(
            validator: (_) => validator?.call(),
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoBox extends StatelessWidget {
  final List<String> fotoPaths;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  const _FotoBox({
    required this.fotoPaths,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          if (fotoPaths.isNotEmpty) ...[
            Row(
              children: [
                for (var i = 0; i < fotoPaths.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: AppImage(
                            path: fotoPaths[i],
                            width: 56,
                            height: 56,
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: InkWell(
                            onTap: () => onRemove(i),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: kPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              const Icon(Icons.add_photo_alternate_outlined, color: kPrimary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'JPG atau PNG\nMaks. 5 MB per foto\nHingga 3 foto',
                  style: TextStyle(fontSize: 12, color: kTextGray, height: 1.4),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextDark,
                  side: const BorderSide(color: kBorder),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: onPick,
                child: const Text('Pilih foto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
