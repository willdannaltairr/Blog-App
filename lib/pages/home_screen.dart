import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/post_card.dart';
import 'artikel_detail_screen.dart';

// Beranda ala Threads: foto+nama kiri, logo di tengah,
// ikon search kanan, lalu feed artikel 1 kolom.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenProfile;

  const HomeScreen({
    super.key,
    this.onOpenSearch,
    this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PostModel> _posts = [];
  final Map<int, String> _catName = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await ApiService.getCategories();
      final posts = await ApiService.getPosts();
      if (!mounted) return;
      final names = {for (final c in cats) c.id: c.name};
      setState(() {
        _catName
          ..clear()
          ..addAll(names);
        _posts =
            posts.map((p) => p.withResolvedCategory(names)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(PostModel p) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArtikelDetailScreen(postId: p.id)),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Navbar sticky di atas: profil kiri, logo tengah, search kanan.
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.background,
                surfaceTintColor: AppColors.background,
                toolbarHeight: 56,
                titleSpacing: 0,
                title: _topBarContent(),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(1),
                  child: Divider(height: 1, color: AppColors.surfaceBorder),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(message: _error!, onRetry: _load),
                )
              else if (_posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(message: 'Belum ada artikel.'),
                )
              else
                SliverList.separated(
                  itemCount: _posts.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 4),
                  itemBuilder: (c, i) {
                    final p = _posts[i];
                    return PostFeedCard(
                      post: p,
                      categoryNames: _catName,
                      onTap: () => _openDetail(p),
                    );
                  },
                ),
              // Ruang bawah agar tidak tertutup bottom nav melayang.
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBarContent() {
    // Materi: String, var, final, operator perbandingan & logika.
    final user = AuthService.currentUser;
    var name = user?.username.trim() ?? '';
    if (name.isEmpty) name = user?.name.trim() ?? '';
    if (name.isEmpty) name = 'Saya';
    var initial = 'K';
    if (name.isNotEmpty) initial = name[0].toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onOpenProfile,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.placeholder,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Image.asset(
            AppConstants.logoPath,
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Text(
              'b',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: widget.onOpenSearch,
                icon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
