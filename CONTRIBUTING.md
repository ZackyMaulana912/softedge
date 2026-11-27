# Panduan kontribusi

Terima kasih sudah mau membantu RoundedCorners. Laporan masalah, usulan fitur, dan pull request semuanya diterima.

## Melapor masalah atau mengusulkan fitur

Buka tab [Issues](../../issues) lalu pilih formulir yang sesuai. Untuk masalah tampilan sudut, sertakan foto dari kamera ponsel, karena sudut hitamnya sengaja tidak ikut di screenshot macOS.

## Menyiapkan project

Butuh Mac dengan Apple Silicon, Xcode dengan Swift 6, dan [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
xcodebuild -project RoundedCorners.xcodeproj -scheme RoundedCorners -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/RoundedCorners.app
```

Project Xcode dibuat dari `project.yml` dan tidak disimpan di repo. Jalankan `xcodegen generate` lagi setiap kali menambah, menghapus, atau memindah file, dan jangan mengedit `.xcodeproj` secara manual.

## Menjalankan tes

```bash
scripts/test.sh
```

Tes tidak membuka app dan tidak menyentuh pengaturanmu, jadi aman dijalankan kapan saja. Tes yang sama juga dijalankan GitHub untuk setiap push dan pull request.

Tampilan sudut tidak bisa dites otomatis: cek langsung di layar MacBook.

## Aturan kode

- Swift 6 dengan pengecekan concurrency penuh. Kelas yang menyentuh tampilan ditandai `@MainActor`, dan pengecekannya jangan dimatikan hanya untuk membungkam error.
- Satu tanggung jawab per file, hindari file yang sangat besar.
- Komentar singkat, hanya untuk bagian yang tidak jelas dari kodenya.
- Tanpa dependency pihak ketiga.
- Tanpa emoji dan tanpa karakter em dash, baik di kode, komentar, maupun pesan commit.
- Teks yang tampil di app memakai bahasa Indonesia.

## Pesan commit

Singkat, dalam bahasa Indonesia, dan menjelaskan apa yang berubah dari sisi pengguna, misalnya "Sudut kiri dan kanan bisa dinyalakan sendiri-sendiri". Satu commit untuk satu perubahan.

## Merilis versi baru

Khusus pemilik repo:

1. Naikkan `CFBundleShortVersionString` dan `CFBundleVersion` di `project.yml`.
2. Tambahkan bagian `## <versi>` di `CHANGELOG.md`.
3. Commit dan push ke main.
4. Jalankan `scripts/release.sh <versi>`. Skrip ini memeriksa semuanya, menjalankan tes, membuat DMG, lalu bertanya dulu sebelum menerbitkan rilis di GitHub. Tambahkan `--draft` untuk mengecek rilisnya di GitHub sebelum dibuka untuk umum.

## Lisensi

Dengan mengirim kontribusi, kamu setuju kontribusinya dirilis dengan [lisensi MIT](LICENSE) yang sama dengan project ini.
