import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_form_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goHome() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onGoHome: _goHome),
          ReportFormScreen(
            tipe: TipeLaporan.penemuan,
            onGoHome: _goHome,
            onSubmitted: _goHome,
          ),
          ReportFormScreen(
            tipe: TipeLaporan.kehilangan,
            onGoHome: _goHome,
            onSubmitted: _goHome,
          ),
          ProfileScreen(onGoHome: _goHome),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Penemuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred_outlined),
            activeIcon: Icon(Icons.report_gmailerrorred),
            label: 'Kehilangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
