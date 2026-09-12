# B Log — Aplikasi Blog (Flutter + Express + MySQL)

Dark-theme premium (`#000000`) ala Threads + kartu bergambar ala Adverse/F1 The Movie.
CRUD Artikel & Kategori tetap ke backend Express yang sama, ditambah auth JWT.

## Struktur Flutter (`lib/`)

```
lib/
├── main.dart                  # BLogApp + theme
├── utils/
│   ├── colors.dart            # SATU-SATUNYA sumber warna
│   ├── constants.dart         # nama app, logo, radius
│   ├── theme.dart             # dark theme + Plus Jakarta Sans
│   └── validators.dart        # email/password/required + timeAgo
├── models/
│   ├── post_model.dart        # artikel (tabel `blogs`/`posts` -> class sama)
│   ├── category_model.dart
│   └── user_model.dart
├── services/
│   ├── auth_service.dart      # login/register/me + token shared_preferences
│   └── api_service.dart       # CRUD posts & categories (kirim Bearer bila ada)
├── screens/
│   ├── splash_screen.dart     # logo b fade-in + cek token
│   ├── auth/login_screen.dart + register_screen.dart
│   ├── main_shell.dart        # IndexedStack 4 tab + BottomNavBar pill
│   ├── home_screen.dart       # header logo/notif/avatar + avatar kategori + grid 2 kolom
│   ├── artikel_screen.dart    # list + search (debounce Timer)
│   ├── artikel_detail_screen.dart  # hero rounded + Baca Selengkapnya + terkait
│   ├── artikel_form_screen.dart    # tambah/edit + dropdown kategori + image_picker
│   ├── category_screen.dart   # CRUD kategori (kartu gelap + dialog Form)
│   ├── profile_screen.dart    # avatar, artikel saya, logout
│   └── edit_profile_screen.dart
└── widgets/
    ├── post_card.dart         # PostImage (cache+fallback) + PostCard + PostListTile
    ├── category_chip.dart     # CategoryChip + CategoryAvatar
    ├── bottom_nav_bar.dart    # pill melayang manual, tombol [+] emas tengah
    └── common.dart            # AppTextField, Loading/Empty/ErrorView, FormErrorBanner
```

`lib/pages/` adalah kode lama (Threads-style) yang dipertahankan agar tidak ada regresi;
aplikasi berjalan memakai `lib/screens/`.

## Design token (`utils/colors.dart`)

| Token | Nilai |
|---|---|
| background | `#000000` |
| surface | `#121212` |
| surfaceBorder | `#242424` |
| textPrimary | `#FFFFFF` |
| textSecondary | `#9E9E9E` |
| accent (tombol utama, status aktif) | `#FFFFFF` |
| danger | `#FFFFFF` |

Radius kartu 20, tombol/input 12, font Plus Jakarta Sans via `google_fonts`.
State: `StatefulWidget` + `setState` saja. Navigasi: `Navigator.push`/`MaterialPageRoute`.

## Backend — tambahan auth (`express/`)

Nilai tambah di luar skema awal (`blogs` & `categories`):

- `database_auth_update.sql` — buat tabel `users` + kolom opsional
  `blogs.author_id` (FK ke `users.id`). Password disimpan sebagai **hash bcrypt**.
- Endpoint baru (JWT via `jsonwebtoken`, secret `JWT_SECRET`, default
  `b_log_secret`, kedaluwarsa 7 hari):

| Method | Endpoint | Body | Response |
|---|---|---|---|
| POST | `/api/auth/register` | `{ name, email, password }` | 201 + `{ token, user }` |
| POST | `/api/auth/login` | `{ email, password }` | 200 + `{ token, user }` |
| GET | `/api/auth/me` | `Authorization: Bearer <token>` | 200 + user login |

Cara kerja singkat (untuk penguji): register/login memverifikasi kredensial lalu
server menandatangani JWT berisi `{ id, email }`. Flutter menyimpan token di
`shared_preferences`; splash screen memvalidasinya via `GET /api/auth/me`.
Endpoint lama (`POST /api/users`, `POST /api/login`) tetap jalan — login lama
otomatis meng-upgrade password plain menjadi hash bcrypt saat berhasil.

## Jalankan

```bash
# Backend
cd express
npm install
# buat DB db_blog_app lalu jalankan database_auth_update.sql
npm run dev   # http://localhost:8000

# Flutter (base URL default: 10.0.2.2:8000 di emulator, localhost:8000 di web/desktop)
cd flutter/blog
flutter pub get
flutter run
```

Package pub.dev yang dipakai (hanya yang benar-benar dipakai):
`http`, `shared_preferences`, `google_fonts`, `cached_network_image`, `image_picker`.
