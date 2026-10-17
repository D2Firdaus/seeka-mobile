import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ikon gembok polos (assets/icons/locked.svg) tanpa lubang kunci.
/// Warna mengikuti `color`, atau IconTheme kalau tidak diisi.
class LockIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const LockIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.white;
    return SvgPicture.asset(
      'assets/icons/locked.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
