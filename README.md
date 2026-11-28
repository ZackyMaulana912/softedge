# RoundedCorners

[![Build dan tes](https://github.com/ZackyMaulana912/softedge/actions/workflows/test.yml/badge.svg)](https://github.com/ZackyMaulana912/softedge/actions/workflows/test.yml)

App kecil di menu bar macOS yang membuat sudut bawah layar MacBook terlihat melengkung, mirip sudut layar laptop OLED terbaru.

Caranya dengan menggambar lapisan hitam pekat di dua sudut bawah layar. Di layar mini-LED atau OLED, piksel hitam menyatu dengan bingkai layar, jadi sudutnya terlihat melengkung. Ini hanya efek visual, panel fisiknya tetap persegi.

## Fitur

- Lapisan hitam hanya di dua sudut bawah layar bawaan MacBook, tidak pernah di monitor eksternal
- Bentuk lengkungan kontinu ala Apple (squircle), bukan busur lingkaran biasa
- Sudut tetap terlihat saat berpindah desktop dengan swipe dan saat memakai app layar penuh
- Popover di menu bar dengan tombol nyala/mati dan slider radius sudut (8 sampai 40 pt) yang langsung terlihat di layar
- Pilihan cepat radius: Kecil (18 pt), Sedang (28 pt), dan Besar (38 pt)
- Pilih sudut mana yang melengkung: kiri, kanan, atau keduanya
- Jeda sementara selama 1 jam atau sampai pagi (jam 06.00 berikutnya). Sudut menyala lagi sendiri, juga kalau Mac sempat sleep
- Shortcut keyboard dari app mana saja, tanpa perlu izin Accessibility:

  | Shortcut | Fungsi |
  | --- | --- |
  | `⌃⌥⌘R` | nyalakan atau matikan sudut |
  | `⌃⌥⌘P` | buka atau tutup pengaturan, juga saat ikon disembunyikan |
  | `⌃⌥⌘+` dan `⌃⌥⌘−` | perbesar atau perkecil radius |

  Setiap shortcut memunculkan keterangan singkat di bagian bawah layar. Shortcut bisa dimatikan di pengaturan.
- Klik kanan ikon menu bar untuk langsung menyalakan atau mematikan sudut tanpa membuka popover. Saat dijeda, ikonnya berubah dan klik kanan melanjutkan
- Cek pembaruan langsung dari popover. App hanya menghubungi GitHub saat tombolnya diklik, tidak pernah diam-diam
- Sambutan singkat saat app pertama kali dibuka
- Ekspor dan impor pengaturan ke file JSON, misalnya untuk dibawa ke Mac lain. Jeda dan buka otomatis saat login tidak ikut, karena hanya berlaku di Mac ini
- Bisa dipakai dengan VoiceOver: setiap tombol dan switch punya nama, dan keterangan di layar saat shortcut ditekan ikut dibacakan
- Popover menutup sendiri kalau kursor menjauh selama 2 detik. Bisa dimatikan
- Popover memberi tahu kalau layar MacBook tidak terdeteksi, misalnya saat lid ditutup dan memakai monitor eksternal
- Sudut dipasang ulang otomatis setelah Mac bangun dari sleep
- Sangat ringan: sekitar 2 MB (sebagian besar untuk ikon app), CPU 0% saat diam, memori sekitar 15 MB saat mulai dan sekitar 35 MB setelah pengaturan dibuka

## Kebutuhan

- Mac dengan Apple Silicon dan macOS 15 atau lebih baru
- Dibuat untuk MacBook dengan notch dan layar mini-LED. Sudah diuji di MacBook Pro 14 inci (M5). MacBook Apple Silicon lain seharusnya juga bisa, tetapi di layar LCD sudut hitamnya bisa terlihat sedikit abu-abu.

## Cara pasang

1. Unduh `RoundedCorners-<versi>.dmg` dari halaman [Releases](../../releases).
2. Buka DMG-nya, lalu seret `RoundedCorners` ke folder `Applications`.
3. Buka app-nya. Saat pertama kali dibuka, macOS akan memblokirnya karena app ini tidak ditandatangani dengan Apple Developer ID berbayar. Untuk mengizinkannya:
   - buka **System Settings > Privacy & Security**, gulir ke bawah, lalu klik **Open Anyway** di samping pesan RoundedCorners, atau
   - jalankan perintah ini sekali di Terminal:

     ```bash
     xattr -dr com.apple.quarantine /Applications/RoundedCorners.app
     ```

App ini tidak muncul di Dock. Klik ikonnya di menu bar untuk mengubah pengaturan atau menutup app, atau klik kanan untuk langsung menyalakan atau mematikan sudut.

Saat pertama kali dibuka, pengaturannya muncul sendiri bersama sambutan singkat. Panelnya tetap terbuka sampai kamu klik **Mengerti**.

Kalau ikon menu bar disembunyikan, tekan `⌃⌥⌘P` atau buka lagi RoundedCorners dari Spotlight atau Launchpad untuk memunculkan pengaturannya.

Kalau menu bar penuh, macOS menyembunyikan ikon yang tidak muat di samping notch. Kalau ikonnya tidak kelihatan, tutup beberapa app menu bar lain.

## Build dari kode sumber

Butuh Xcode dengan Swift 6 dan [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). Project Xcode dibuat dari `project.yml` dan tidak disimpan di repo.

```bash
xcodegen generate
xcodebuild -project RoundedCorners.xcodeproj -scheme RoundedCorners -configuration Debug -derivedDataPath build build
open build/Build/Products/Debug/RoundedCorners.app
```

Untuk menjalankan tes otomatis (tidak membuka app dan tidak menyentuh pengaturanmu):

```bash
./scripts/test.sh
```

GitHub juga menjalankan tes yang sama untuk setiap push ke main dan setiap pull request.

Untuk membuat DMG rilis (tesnya dijalankan dulu, DMG tidak dibuat kalau ada yang gagal):

```bash
./scripts/make-dmg.sh
```

DMG akan dibuat di `build/RoundedCorners-<versi>.dmg`, bersama file `.sha256` berisi checksum-nya. Nomor versinya diambil dari `CFBundleShortVersionString` di `project.yml`.

Untuk memeriksa DMG yang sudah diunduh, taruh file `.sha256` di folder yang sama lalu jalankan `shasum -c RoundedCorners-<versi>.dmg.sha256`.

Untuk merilis versi baru ke GitHub, jalankan `./scripts/release.sh <versi>`. Langkah lengkapnya ada di [CONTRIBUTING.md](CONTRIBUTING.md).

Daftar perubahan per versi ada di [CHANGELOG.md](CHANGELOG.md).

## Cara kerja

- Setiap sudut adalah window kecil tanpa bingkai yang tidak menangkap klik dan berada di atas window lain. Tidak ada window selebar layar.
- Lengkungannya diambil dari `RoundedRectangle(cornerRadius:style: .continuous)` milik SwiftUI, jadi bentuknya sama dengan yang dipakai Apple. Lengkungan kontinu mulai menekuk lebih awal daripada lingkaran, jadi setiap window berukuran sekitar 1,53 kali radius.
- Window sudut meminta macOS agar tidak ikut terekam di screenshot dan rekaman layar.
- Lapisan hanya muncul di layar bawaan MacBook (dideteksi dengan `CGDisplayIsBuiltin`) dan ikut menyesuaikan saat resolusi atau scaling diubah.
- Pengaturan disimpan di `UserDefaults`. Buka otomatis saat login memakai `SMAppService`, dan statusnya dibaca langsung dari sistem.
- Shortcut keyboard memakai `RegisterEventHotKey` dari Carbon, jadi tidak butuh izin Accessibility.
- Cek pembaruan meminta rilis terbaru dari GitHub API (`releases/latest`) lalu membandingkan nomor versinya. Tidak ada data lain yang dikirim.

Konstanta untuk membandingkan varian:

| Konstanta | File | Fungsi |
| --- | --- | --- |
| `CornerStyle.current` | `Sources/Overlay/CornerStyle.swift` | `.continuous` (squircle) atau `.circular` (busur lingkaran) |
| `OverlaySpace.isEnabled` | `Sources/Overlay/OverlaySpace.swift` | Memakai space khusus (lihat keterbatasan di bawah) |
| `PopoverAutoClose.delay` | `Sources/MenuBar/PopoverAutoClose.swift` | Jeda sebelum popover menutup sendiri |

## Keterbatasan

- **Memakai fungsi tersembunyi macOS.** Secara bawaan, macOS menyembunyikan sebentar window yang tampil di semua desktop saat kamu swipe antar-desktop. Untuk mencegahnya, window sudut ditaruh di space khusus yang dibuat dengan fungsi SkyLight yang tidak didokumentasikan (`CGSSpaceCreate` dan sejenisnya). Fungsi ini bisa berhenti bekerja di update macOS mendatang. Fungsinya dimuat saat app berjalan, jadi kalau suatu saat hilang, app tetap jalan dan sudutnya hanya berkedip lagi saat swipe.
- **Belum dinotarisasi.** Tanpa akun Apple Developer berbayar, app tidak bisa dinotarisasi, jadi macOS meminta izin saat pertama kali dibuka (lihat Cara pasang).
- **Buka otomatis saat login terikat ke satu salinan app.** Yang didaftarkan adalah salinan app tempat opsi itu dinyalakan. Kalau pindah ke salinan lain, matikan dulu opsinya di salinan lama, atau hapus entri lamanya di System Settings > General > Login Items.
- **Ikon tersembunyi dan buka otomatis saat login.** Kalau ikon disembunyikan dan buka otomatis saat login menyala, membuka app dari Spotlight saat app belum berjalan akan menjalankannya diam-diam. Buka sekali lagi untuk melihat pengaturannya.
- **Tidak dijamin hilang dari screenshot.** macOS versi terbaru tidak selalu menuruti permintaan untuk menyembunyikan window dari screenshot.
- **Sudut atas tidak ditutup.** Di MacBook dengan notch, sudut atas layar sudah melengkung dari panelnya.

## Struktur project

```
project.yml          spesifikasi XcodeGen (sumber utama project Xcode)
scripts/
  test.sh            menjalankan semua tes otomatis
  make-dmg.sh        tes, build rilis, lalu dibungkus jadi DMG
  release.sh         memeriksa, membuat DMG, lalu menerbitkan rilis di GitHub
Sources/
  App/               titik awal app, app delegate, timer jeda, pemantau perubahan
  Overlay/           window sudut, penggambaran, dan space khusus
  MenuBar/           ikon menu bar, popover pengaturan, sambutan, tombol custom
  HUD/               keterangan singkat di layar saat shortcut ditekan
  Shortcuts/         shortcut keyboard global
  Settings/          pengaturan tersimpan, jadwal jeda, buka otomatis saat login
  Updates/           cek pembaruan dari GitHub
Tests/               tes otomatis (Swift Testing)
Resources/
  Info.plist         dibuat XcodeGen dari project.yml
  Assets.xcassets    ikon app
.github/             build otomatis, formulir issue, template pull request
```

## Lisensi

[MIT](LICENSE). Kamu boleh memakai, mengubah, dan membagikan kode ini, termasuk untuk keperluan komersial, asalkan keterangan hak cipta dan lisensinya tetap disertakan.
