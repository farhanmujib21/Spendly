# Spendly 

##  Deskripsi Singkat Aplikasi
**Spendly** adalah aplikasi mobile pintar untuk manajemen keuangan pribadi yang dibangun menggunakan framework Flutter. Aplikasi ini dirancang untuk membantu pengguna melacak setiap pemasukan dan pengeluaran, memvisualisasikan kebiasaan finansial mereka melalui grafik analitik, serta membantu pengguna merencanakan anggaran bulanan dan target tabungan masa depan.

##  Tujuan Pengembangan Aplikasi
* Memberikan kemudahan bagi pengguna dalam mencatat transaksi harian (pengeluaran dan pemasukan).
* Membantu pengguna memonitor kondisi keuangan mereka melalui ringkasan dan statistik yang mudah dipahami.
* Mendorong kebiasaan menabung dan mengontrol pengeluaran dengan fitur Budgeting dan Savings Goal.
* Menyediakan pengalaman pengguna yang mulus (smooth) dan modern dalam aplikasi pencatatan keuangan.

##  Daftar Fitur yang Tersedia
* **Dashboard Utama:** Ringkasan saldo, pengeluaran/pemasukan terkini, serta akses cepat ke berbagai menu.
* **Pencatatan Transaksi:** Tambah transaksi pengeluaran atau pemasukan lengkap dengan kategori, tanggal, catatan, *mood*, hingga **foto struk** (menggunakan kamera/galeri).
* **Analitik & Laporan:** Visualisasi pengeluaran dalam bentuk grafik (Pie Chart/Bar Chart) untuk analisis pengeluaran berdasarkan kategori.
* **Manajemen Anggaran (Budget):** Menentukan batas maksimal pengeluaran per kategori setiap bulannya.
* **Target Tabungan (Savings Goal):** Membuat dan melacak progres tabungan untuk target tertentu beserta tenggat waktunya.
* **Riwayat Transaksi:** Daftar semua transaksi secara historis yang bisa difilter dan dicari.
* **Pengaturan & Notifikasi:** Pengaturan profil pengguna dan pengingat harian (local notification).
* **Onboarding & Splash Screen:** Tampilan perkenalan awal untuk pengguna baru.

##  Teknologi, Framework, Library, dan Komponen
Aplikasi ini dikembangkan dengan teknologi berikut:
* **Framework Utama:** Flutter (Dart)
* **State Management:** Provider (`provider: ^6.1.1`)
* **Database Lokal:** SQLite (`sqflite: ^2.3.0`, `path_provider`, `path`)
* **Routing/Navigasi:** GoRouter (`go_router: ^13.0.0`)
* **Visualisasi Data:** FL Chart (`fl_chart: ^0.66.0`)
* **Media / Kamera:** Image Picker (`image_picker: ^1.0.7`)
* **Penyimpanan Preferensi:** Shared Preferences (`shared_preferences: ^2.2.2`)
* **Notifikasi:** Flutter Local Notifications (`flutter_local_notifications: ^17.2.3`)
* **Font & Format:** Google Fonts (`google_fonts`), Intl (`intl`)

##  Struktur Database (SQLite)
Aplikasi ini menggunakan 3 tabel utama di dalam database `spendly.db`:

### 1. Tabel `transactions`
Menyimpan riwayat transaksi keuangan.
* `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT)
* `amount` (REAL, NOT NULL) - Jumlah uang
* `type` (TEXT, NOT NULL) - Jenis (Income/Expense)
* `category` (TEXT, NOT NULL) - Nama kategori
* `categoryIcon` (TEXT, NOT NULL) - Ikon kategori
* `date` (INTEGER, NOT NULL) - Tanggal (timestamp)
* `mood` (TEXT, NOT NULL) - Perasaan saat transaksi
* `note` (TEXT) - Catatan tambahan
* `photoPath` (TEXT) - Path lokasi foto struk

### 2. Tabel `budgets`
Menyimpan batas anggaran pengeluaran bulanan.
* `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT)
* `category` (TEXT, NOT NULL) - Kategori anggaran
* `categoryIcon` (TEXT, NOT NULL) - Ikon kategori
* `monthlyLimit` (REAL, NOT NULL) - Batas anggaran per bulan
* `currentSpent` (REAL, DEFAULT 0) - Jumlah yang sudah dihabiskan

### 3. Tabel `savings_goals`
Menyimpan target tabungan pengguna.
* `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT)
* `name` (TEXT, NOT NULL) - Nama target tabungan
* `icon` (TEXT, NOT NULL) - Ikon target
* `targetAmount` (REAL, NOT NULL) - Jumlah target
* `currentAmount` (REAL, DEFAULT 0) - Jumlah yang sudah terkumpul
* `deadline` (INTEGER) - Tenggat waktu tabungan
* `isCompleted` (INTEGER, DEFAULT 0) - Status (0: Belum, 1: Selesai)

##  Panduan Instalasi dan Menjalankan Aplikasi

1. **Prasyarat:** Pastikan Anda telah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.12.2 atau terbaru) dan Dart.
2. **Clone Repositori:**
   ```bash
   git clone <url-repositori-ini>
   cd Spendly
   ```
3. **Instal Dependensi:** Unduh semua library yang dibutuhkan dengan menjalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   ```
4. **Jalankan Aplikasi:** Hubungkan emulator atau perangkat fisik Anda, lalu jalankan perintah:
   ```bash
   flutter run
   ```

##  Screenshot Tampilan Aplikasi
*(Silakan ganti URL gambar di bawah ini dengan screenshot aplikasi Anda)*

<p align="center">
  <img src="https://via.placeholder.com/250x500.png?text=Splash+Screen" width="200" alt="Splash Screen"/>
  <img src="https://via.placeholder.com/250x500.png?text=Dashboard" width="200" alt="Dashboard"/>
  <img src="https://via.placeholder.com/250x500.png?text=Add+Transaction" width="200" alt="Add Transaction"/>
</p>
<p align="center">
  <img src="https://via.placeholder.com/250x500.png?text=Analytics" width="200" alt="Analytics"/>
  <img src="https://via.placeholder.com/250x500.png?text=Savings+Goal" width="200" alt="Savings Goal"/>
</p>
