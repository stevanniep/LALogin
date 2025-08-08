# MyIMV

**MyIMV** adalah aplikasi manajemen open-source berbasis mobile yang dikembangkan untuk mendukung kegiatan asisten Laboratorium IMV (Image Processing and Computer Vision). Aplikasi ini memfasilitasi pencatatan aktivitas, kehadiran, komunikasi antar asisten, serta pengelolaan proyek dan jadwal laboratorium secara efisien.

---

## 🚀 Fitur Utama

### 🖼️ Splash Screen
- Menampilkan logo aplikasi selama ±2 detik sebelum masuk ke halaman login/registrasi.

### 🔐 Autentikasi (Login & Registrasi)
- Pengguna mendaftar dengan email dan password.
- Sistem mengirimkan tautan verifikasi (OTP) ke email menggunakan layanan SMTP dari Brevo.
- Setelah pengguna mengklik tautan verifikasi, akun akan aktif.
- Setelah login:
  - Sistem akan memeriksa **peran pengguna** (admin/pengguna) dari tabel `profiles`.
  - Jika **admin**, diarahkan ke halaman admin.
  - Jika **pengguna biasa**, diarahkan ke halaman pengguna.

---

## 👨‍💼 Alur Admin

### 3.1 HomePage Admin
- Melihat jadwal kegiatan hari ini.
- Menambah jadwal kegiatan baru.
- Membuat presensi (harian atau event).
- Melihat data profil semua user.
- Menambah proyek baru.

### 3.2 ProyekPage Admin
- Melihat daftar proyek yang telah ditambahkan.
- Melihat detail proyek.

### 3.3 AktivitasPage Admin
- Melihat aktivitas pengguna berdasarkan username.

### 3.4 ForumPage Admin
- Menambah postingan atau komentar di forum diskusi.

### 3.5 ProfilPage Admin
- Melihat dan mengedit data profil.
- Melakukan logout dari aplikasi.

---

## 👩‍💻 Alur Pengguna

### 4.1 HomePage Pengguna
- Melihat jadwal kegiatan hari ini.
- Melihat kontak admin.
- Melihat riwayat presensi.
- Melihat riwayat aktivitas.
- Melihat statistik pribadi.

### 4.2 ProyekPage Pengguna
- Menambahkan aktivitas harian proyek.
- Melihat detail proyek yang ditugaskan.
- Melakukan ceklist pada tahapan proyek yang sudah selesai.

### 4.3 ForumPage Pengguna
- Menambah postingan atau komentar pada forum diskusi.

### 4.4 ProfilPage Pengguna
- Melihat dan mengedit data profil.
- Menampilkan persentase kehadiran.
- Menampilkan statistik aktivitas.
- Logout dari aplikasi.

---

## 🛠️ Teknologi yang Digunakan

- **Flutter** – UI Framework untuk pengembangan aplikasi mobile.
- **Supabase** – Backend sebagai layanan (Auth, Database, dan Storage).
- **SMTP Brevo** – Untuk pengiriman tautan verifikasi OTP.
- **GitHub** – Manajemen source code dan dokumentasi.

---

## 🧱 Struktur Folder Utama

lib/
├── admin/ # Halaman admin
├── pages/ # Halaman pengguna
├── screens/ # Halaman Autentikasi
├── main.dart # Entry point utama aplikasi Flutter
