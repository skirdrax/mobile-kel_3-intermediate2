# Kasir Toko — POS Flutter + Firebase

**Kelompok 3**

### Anggota Kelompok

| Nama | NIM |
| :--- | :--- |
| Izanagi Faris Aslam | 2405060 |
| Muhammad Fadlurahman | 2405057 |
| Sakhi Ardra Handaru | 2405061 |

---

Aplikasi Point-of-Sale (POS) sederhana: admin mengelola produk, kasir melayani penjualan, pembayaran tunai atau QRIS (MiomiPay sandbox), dan admin menerima notifikasi FCM tiap transaksi baru.

Target utama: **Android**. Web (Chrome) hanya alat uji lokal.

## Fitur

- Login peran: **admin** dan **kasir** (Firebase Auth + Firestore `users`)
- Admin: CRUD produk realtime, kategori, dashboard ringkasan (omzet/transaksi/item hari ini, 5 transaksi terakhir, stok kritis)
- Kasir: katalog + keranjang + checkout
- Pembayaran: tunai (langsung `paid`, stok berkurang saat checkout) dan QRIS via MiomiPay (stok berkurang saat webhook `PAID`)
- Riwayat transaksi + detail + struk
- Notifikasi FCM ke topik `admin-alerts` (dikirim server Express)

## Struktur

```text
lib/             aplikasi Flutter (screens/, services/, state/, models/, core/)
server/          Express: kirim FCM + buat tagihan MiomiPay + webhook
firestore.rules  Security Rules (ter-deploy ke project pelatihanpos)
web/             build web hanya untuk uji lokal
```

## Setup

1. **Flutter** — butuh Dart 3.10+. Proyek ini dibangun dengan SDK di `C:\fluttersdk\flutter\bin\flutter.bat`.
2. **Firebase** — project `pelatihanpos` (Android `com.pos.myapp`). `android/app/google-services.json` dan `lib/firebase_options.dart` sudah di-commit. Jangan jalankan ulang `flutterfire configure` tanpa kebutuhan; ia menimpa config dengan app ID lama.
3. **Server**:
   ```bash
   cd server
   npm install
   # taruh serviceAccountKey.json (dari Firebase Console) di folder server/
   node server.js
   ```
   Variabel lingkungan (opsional, ada default sandbox): `PORT`, `API_KEY` (default `kasir-toko-dev-key`), `MIOMIPAY_API_KEY`, `MIOMIPAY_WEBHOOK_SECRET`.
4. **Seed data demo**:
   ```bash
   node server/seed.js
   ```

## Menjalankan

Android (HP terhubung / emulator):
```bash
flutter run --dart-define=API_HOST=<IP-LAN-PC> --dart-define=API_KEY=kasir-toko-dev-key
```

Web (uji lokal):
```bash
flutter run -d chrome --dart-define=API_KEY=kasir-toko-dev-key
```

`API_HOST` default `localhost` (cocok untuk web dan emulator dengan `10.0.2.2` perlu diisi manual). HP fisik harus satu WiFi dengan PC; isi `API_HOST` dengan IP LAN PC (contoh `192.168.1.21`).

Build APK:
```bash
flutter build apk --debug
# hasil: build\app\outputs\flutter-apk\app-debug.apk
```

## Akun Demo

| Peran | Email | Password |
| :--- | :--- | :--- |
| Admin | admin@pos.test | admin123456 |
| Kasir | kasir@pos.test | kasir123456 |

## Uji QRIS Sandbox

Checkout QRIS membuka layar pembayaran berisi QR. Bayar lewat simulator MiomiPay: <https://miomidev.com> — tempel link QR, klik **Bayar Sekarang**; webhook `PAID` dari MiomiPay (atau polling status di app sebagai fallback) menyelesaikan transaksi dan mengurangi stok.

## Keamanan

- `serviceAccountKey.json` **tidak boleh** di-commit (sudah ada di `.gitignore`)
- Kredensial MiomiPay hanya lewat env di server, tidak pernah di app
- Security Rules: default tolak; kasir hanya boleh mengurangi stok; update transaksi hanya lewat Admin SDK (webhook/server)
