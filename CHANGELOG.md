# Catatan perubahan

## 0.2.0

### Baru

- Shortcut keyboard dari app mana saja: `⌃⌥⌘R` menyalakan atau mematikan sudut, `⌃⌥⌘P` membuka pengaturan (juga saat ikon disembunyikan), `⌃⌥⌘+` dan `⌃⌥⌘−` mengubah radius. Tidak butuh izin Accessibility, dan bisa dimatikan.
- Keterangan singkat di bagian bawah layar setiap kali shortcut atau klik kanan mengubah sudut.
- Pilihan cepat radius: Kecil, Sedang, dan Besar.
- Slider radius berhenti sebentar di ukuran bawaan (28 pt), disertai getaran halus di trackpad.
- Jeda sementara selama 1 jam atau sampai jam 06.00 berikutnya. Sudut menyala lagi sendiri, dan ikon menu bar menunjukkan kapan jedanya selesai.
- Pilih sudut mana yang melengkung: kiri, kanan, atau keduanya.
- Cek pembaruan langsung di popover, dengan tombol unduh kalau ada versi baru. App hanya menghubungi GitHub saat tombolnya diklik.
- Sambutan singkat saat app pertama kali dibuka.
- Popover yang menutup sendiri saat kursor menjauh sekarang bisa dimatikan.

### Perubahan

- Tombol untuk mengembalikan radius ke ukuran bawaan diganti pilihan cepat radius.
- Gambar laptop kecil di popover ikut menunjukkan sudut yang dipilih.

### Untuk pengembang

- Tes otomatis untuk nomor versi, jadwal jeda, bentuk lengkungan, dan pengaturan. Jalankan dengan `scripts/test.sh`.
- GitHub menjalankan build dan tes untuk setiap push dan pull request.
- Skrip DMG menjalankan tes dulu dan berhenti kalau ada yang gagal.
- Skrip rilis `scripts/release.sh` yang memeriksa semuanya lalu menerbitkan rilis setelah dikonfirmasi.
- Lisensi MIT, panduan kontribusi, formulir issue, dan template pull request.

## 0.1.1

### Baru

- Klik kanan ikon menu bar untuk langsung menyalakan atau mematikan sudut, tanpa membuka popover.
- Tombol untuk mengembalikan radius sudut ke ukuran bawaan (28 pt). Tombolnya hanya muncul kalau radius sedang diubah.
- Versi app dan tombol "Cek pembaruan" di bagian bawah popover. Tombolnya membuka halaman rilis terbaru di GitHub.
- Popover memberi tahu kalau layar MacBook tidak terdeteksi, misalnya saat lid ditutup dan memakai monitor eksternal.

### Perubahan

- Semua teks di popover dan keterangan ikon menu bar sekarang dalam bahasa Indonesia.
- Tombol switch di popover rata kanan, apa pun panjang teksnya.
- Sudut dipasang ulang otomatis setelah Mac bangun dari sleep.
- Animasi tombol nyala/mati dimatikan kalau Reduce motion di macOS menyala.
- Keterangan hak cipta diisi di info app.

### Untuk pengembang

- Skrip DMG memberi pesan jelas kalau XcodeGen atau Xcode belum terpasang.
- Skrip DMG otomatis membuat file checksum SHA-256.

## 0.1.0

Rilis pertama: sudut bawah layar MacBook terlihat melengkung, popover pengaturan di menu bar, buka otomatis saat login, sembunyikan ikon menu bar, dan popover yang menutup sendiri setelah kursor menjauh 2 detik.
