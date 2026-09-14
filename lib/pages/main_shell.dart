import 'package:flutter/material.dart';
import '../widgets/theme.dart';
import '../widgets/post_widgets.dart';
import 'artikel_form_page.dart';
import 'artikel_page.dart';
import 'category_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  Key _homeKey = UniqueKey();
  Key _artikelKey = UniqueKey();
  Key _catKey = UniqueKey();
  Key _profileKey = UniqueKey();

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
      MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
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
              HomePage(
                key: _homeKey,
                onOpenSearch: () => setState(() => _index = 1),
                onOpenProfile: () => setState(() => _index = 3),
              ),
              ArtikelPage(key: _artikelKey),
              CategoryPage(key: _catKey),
              ProfilePage(key: _profileKey),
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
