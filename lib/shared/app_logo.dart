import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;

  const AppLogo({super.key, this.width = 110});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/SEEKA.png',
      width: width,
      height: width / 2,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Text(
        'SEEKA',
        style: TextStyle(
          fontSize: width / 3.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: Colors.black,
        ),
      ),
    );
  }
}
