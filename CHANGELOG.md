# Catatan perubahan

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
