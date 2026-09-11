import 'package:flutter/material.dart';
import 'articles_page.dart';
import 'blog_form_page.dart';
import 'category_crud_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

// Shell tab bawah: Home, Search, Tambah, Kategori, Profil.
// Ikon flat tanpa label.
class MainNavPage extends StatefulWidget {
  final int initialIndex;
  const MainNavPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  late int _index;
  // Key untuk refresh tab setelah create/edit.
  Key _homeKey = UniqueKey();
  Key _searchKey = UniqueKey();
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
      _searchKey = UniqueKey();
      _catKey = UniqueKey();
      _profileKey = UniqueKey();
    });
  }

  Future<void> _onTap(int i) async {
    if (i == 2) {
      final created = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BlogFormPage()),
      );
      if (created == true) {
        _refreshAll();
        setState(() => _index = 0);
      }
      return;
    }
    setState(() => _index = i);
  }

  int get _stackIndex {
    // Index 2 adalah aksi tambah, tampilkan Home di belakangnya.
    if (_index == 2) return 0;
    if (_index > 2) return _index - 1;
    return _index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          HomePage(key: _homeKey),
          ArticlesPage(key: _searchKey),
          CategoryCrudPage(key: _catKey, inTab: true),
          ProfilePage(key: _profileKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_outlined),
            activeIcon: Icon(Icons.tag),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
