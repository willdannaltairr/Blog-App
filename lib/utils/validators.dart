// Validator form sederhana yang dipakai ulang di semua screen.
String? validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
  final t = v.trim();
  if (!t.contains('@') || !t.contains('.')) return 'Format email tidak valid';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Password wajib diisi';
  if (v.length < 6) return 'Password minimal 6 karakter';
  return null;
}

String? validateRequired(String? v, String label) {
  if (v == null || v.trim().isEmpty) return '$label wajib diisi';
  return null;
}

String timeAgo(String? isoString) {
  if (isoString == null || isoString.isEmpty) return 'baru saja';
  try {
    final dt = DateTime.parse(isoString).toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  } catch (_) {
    return 'baru saja';
  }
}
