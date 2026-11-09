# 💰 Smart Money - Aplikasi Pencatatan Keuangan & Pengeluaran Pribadi

Aplikasi pencatatan keuangan modern (Personal Expense & Money Tracker) berbasis **Flutter**, dirancang dengan antarmuka yang bersih, estetik, dan fungsionalitas lengkap untuk membantu mengelola arus kas harian, anggaran bulanan, serta target tabungan impian.

---

## 🌟 Fitur Utama (Full Features)

### 1. 📊 Dashboard & Ringkasan Finansial
- **Total Saldo Bersih Real-time**: Menghitung akumulasi saldo dari semua dompet (Cash, Bank, E-Wallet).
- **Mode Privasi**: Sembunyikan atau tampilkan angka saldo dengan satu sentuhan.
- **Kartu Arus Kas**: Ringkasan pemasukan, pengeluaran, dan selisih kas (net cashflow) bulan berjalan.
- **Aksi Cepat (Quick Actions)**: Tombol instan untuk Catat Pengeluaran, Catat Pemasukan, Transfer Dana, dan Target Impian.
- **Peringatan Anggaran Pintar**: Notifikasi visual langsung di dashboard jika ada kategori yang mendekati (≥80%) atau melampaui batas anggaran bulanan.
- **Sorotan Pengeluaran Terbesar**: Widget kartu pengeluaran teratas bulan ini.

### 2. 📝 Pencatatan Transaksi Lengkap
- **3 Tipe Transaksi**: Pengeluaran (Expense), Pemasukan (Income), dan Transfer Antar Dompet.
- **Mata Uang Rupiah (IDR)**: Format rapi otomatis (`Rp 1.500.000` / `Rp 1,5 Jt`).
- **Kategori Berwarna & Berikon**:
  - *Pengeluaran*: Makanan & Minuman, Transportasi, Belanja, Tagihan & Utilitas, Hiburan, Kesehatan, Pendidikan, Donasi, dll.
  - *Pemasukan*: Gaji Pokok, Bonus & THR, Usaha/Bisnis, Investasi, dll.
- **Pencarian & Multi-Filter**: Filter berdasarkan kata kunci, jenis transaksi (Semua, Pengeluaran, Pemasukan, Transfer), kategori, atau akun dompet.
- **Swipe to Delete & Tap to Edit**: Hapus transaksi dengan swipe ke kiri disertai konfirmasi, atau tap untuk mengubah data transaksi.

### 3. 🎯 Manajemen Anggaran (Budgeting)
- Tetapkan batas maksimal pengeluaran bulanan per kategori.
- Visual **Progress Bar Interaktif**:
  - 🟢 Hijau: Aman (<80%)
  - 🟡 Oranye: Waspada (80% - 99%)
  - 🔴 Merah: Overbudget (>100%)
- Ringkasan total anggaran vs total terpakai.

### 4. 📈 Laporan & Analitik Grafik Interaktif
- **Pie Chart Interaktif** (`fl_chart`): Visualisasi persentase pengeluaran per kategori yang dapat disentuh (touchable).
- **Selector Periode Bulan & Tahun**: Navigasi riwayat pengeluaran dari bulan ke bulan.
- **Metrik Analitik**:
  - Rata-rata pengeluaran per hari
  - Total pemasukan vs pengeluaran
  - Peringkat kategori pengeluaran tertinggi dengan progress bar.

### 5. 💳 Multi-Dompet & Transfer Antar Akun
- Kelola berbagai jenis rekening: Uang Tunai, Bank BCA, Bank Mandiri, GoPay/OVO, dan Tabungan.
- **Fitur Transfer Antar Dompet**: Mutasi saldo antar akun otomatis dengan validasi saldo.
- Tambah atau sesuaikan saldo dompet baru dengan pilihan palet warna tema.

### 6. 🏆 Target Menabung (Financial Goals / Tabungan Impian)
- Buat target impian (contoh: Dana Darurat, Liburan, Upgrade Gadget).
- Hitung sisa hari menuju target tanggal pencapaian.
- **Fitur "Nabung" Langsung**: Alokasikan dana dari dompet pilihan ke target impian dengan satu klik.

### 7. ⚙️ Pengaturan, Backup & Personalisasi
- **Mode Gelap (Dark Mode)** dan Mode Terang (Light Mode) dengan Material 3.
- **Export Data (JSON)**: Salin seluruh riwayat ke clipboard untuk backup.
- **Muat Data Sampel (Demo Data)**: Isi data contoh realistis secara instan untuk mencoba seluruh fitur visual.
- **Reset Data**: Bersihkan semua data jika ingin memulai pembukuan dari nol.

---

## 📁 Struktur Proyek

```
lib/
├── models/
│   ├── category.dart          # Model kategori & daftar default
│   ├── wallet.dart            # Model dompet/rekening
│   ├── transaction.dart       # Model transaksi & transfer
│   ├── budget.dart            # Model anggaran bulanan
│   └── goal.dart              # Model target menabung
├── providers/
│   ├── expense_provider.dart  # Business logic & state management utama
│   └── theme_provider.dart    # State tema gelap & palet warna
├── services/
│   └── storage_service.dart   # Persistensi data lokal via SharedPreferences
├── utils/
│   ├── app_icons.dart         # Resolver IconData untuk tree-shaking
│   ├── currency_formatter.dart# Format Rupiah standar & ringkas
│   └── app_date_utils.dart    # Format tanggal & waktu lokal Indonesia
├── widgets/
│   ├── summary_card.dart      # Hero card saldo & arus kas
│   ├── transaction_tile.dart  # Item tile transaksi
│   ├── category_icon_widget.dart # Icon badge kategori
│   ├── budget_progress_card.dart # Card progress bar anggaran
│   └── goal_card.dart         # Card target menabung
├── screens/
│   ├── main_navigation_screen.dart     # Navigasi utama (Bottom bar)
│   ├── dashboard_screen.dart           # Layar Beranda
│   ├── transactions_screen.dart        # Layar Riwayat Transaksi
│   ├── add_edit_transaction_screen.dart# Formulir Tambah/Edit Transaksi
│   ├── transfer_screen.dart            # Formulir Transfer Antar Dompet
│   ├── reports_screen.dart             # Layar Laporan & Pie Chart
│   ├── budgets_screen.dart             # Layar Anggaran
│   ├── wallets_screen.dart             # Layar Kelola Dompet
│   ├── goals_screen.dart               # Layar Target Menabung
│   └── settings_screen.dart            # Layar Pengaturan & Backup
└── main.dart
```

---

## 🚀 Cara Menjalankan Aplikasi

Pastikan Flutter SDK sudah terpasang di komputer Anda.

### 1. Menjalankan di Browser (Chrome):
```bash
flutter run -d chrome
```

### 2. Menjalankan di Windows Desktop:
```bash
flutter run -d windows
```

### 3. Menjalankan di HP / Emulator Android:
```bash
flutter run
```

### 4. Menjalankan Pengujian Otomatis (Unit Tests):
```bash
flutter test
```

### 5. Membangun Web Release:
```bash
flutter build web
```
