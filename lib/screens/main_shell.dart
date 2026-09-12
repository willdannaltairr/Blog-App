import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'artikel_form_screen.dart';
import 'artikel_screen.dart';
import 'category_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// Shell 4 tab + bottom nav pill melayang. Tombol [+] tengah = tambah artikel.
class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  Key _homeKey = UniqueKey();
  Key _artikelKey = UniqueKey();
  Key _catKey = UniqueKey();
  Key _profileKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void _refreshAll() {
    setState(() {
      _homeKey = UniqueKey();
      _artikelKey = UniqueKey();
      _catKey = UniqueKey();
      _profileKey = UniqueKey();
    });
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ArtikelFormScreen()),
    );
    if (created == true) {
      _refreshAll();
      setState(() => _index = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: [
              HomeScreen(
                key: _homeKey,
                onOpenSearch: () => setState(() => _index = 1),
                onOpenProfile: () => setState(() => _index = 3),
              ),
              ArtikelScreen(key: _artikelKey),
              CategoryScreen(key: _catKey, inTab: true),
              ProfileScreen(key: _profileKey),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              onAdd: _openAdd,
            ),
          ),
        ],
      ),
    );
  }
}
