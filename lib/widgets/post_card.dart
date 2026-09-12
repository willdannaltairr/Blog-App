import 'dart:io' show File;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'common.dart';

bool isNetworkUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

// Gambar artikel: dukung URL jaringan (cache) & file lokal hasil picker.
// Selalu ada fallback agar null/kosong tidak crash.
class PostImage extends StatelessWidget {
  final String? url;
  final double height;
  final double radius;

  const PostImage(
      {super.key, this.url, this.height = 180, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    Widget fallback({double? h}) => Container(
          height: h ?? height,
          width: double.infinity,
          color: AppColors.placeholder,
          child: const Icon(Icons.image_outlined,
              color: AppColors.textSecondary, size: 36),
        );
    final u = (url ?? '').trim();
    if (u.isEmpty) return fallback();
    Widget img;
    if (isNetworkUrl(u)) {
      img = CachedNetworkImage(
        imageUrl: u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (c, s) => Container(
          height: height,
          width: double.infinity,
          color: AppColors.placeholder,
        ),
        errorWidget: (c, s, e) => fallback(),
      );
    } else if (!kIsWeb) {
      img = Image.file(
        File(u),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
    } else {
      img = Image.network(
        u,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => fallback(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: img,
    );
  }
}

// Kartu feed 1 kolom penuh: avatar + nama + waktu, judul, isi singkat,
// badge kategori, lalu gambar besar. Dipakai di semua daftar artikel.
class PostFeedCard extends StatelessWidget {
  final PostModel post;
  final Map<int, String> categoryNames;
  final VoidCallback onTap;

  const PostFeedCard({
    super.key,
    required this.post,
    this.categoryNames = const {},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var author = post.authorName.trim();
    if (author.isEmpty) author = 'Anonymous';
    final List<String> names = post.displayCategoryNames(categoryNames);
    final String content = post.content.trim();
    var huruf = 'A';
    if (author.isNotEmpty) huruf = author[0].toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.placeholder,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    huruf,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$author · ${timeAgo(post.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      if (content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (names.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final n in names)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  n,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if ((post.imageUrl ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        PostImage(
                            url: post.imageUrl,
                            height: 200,
                            radius: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
