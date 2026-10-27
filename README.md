# 📂 Asisten Perapih Folder v2.0 (Rule-Based Workspace Engine)

Asisten Perapih Folder adalah aplikasi desktop berbasis PowerShell yang dirancang untuk membersihkan dan mengorganisasi folder yang berantakan secara otomatis (*In-Place Organizing*). 

Berbeda dengan *file mover* biasa, v2.0 telah bertransformasi menjadi *Workspace Engine* cerdas yang dilengkapi Antarmuka Grafis (GUI), manajemen aturan kustom berbasis JSON, serta integrasi metodologi produktivitas PARA.

## ✨ Fitur Utama

- **In-Place Organizing:** Rapikan file langsung di dalam folder sumber tanpa perlu memindahkannya ke *drive* atau direktori luar.
- **Custom Rules Manager (UI):** Pengguna dapat membuat kategori folder dan kata kunci pencarian sendiri langsung melalui jendela aplikasi. Aturan akan tersimpan permanen di `rules.json`.
- **Metode PARA (Built-in Preset):** Mendukung pengelompokan otomatis berdasarkan standar produktivitas PARA (*Projects, Areas, Resources, Archives*).
- **Deep Scan & Cleanup:** Mampu menyedot file yang tersembunyi di dalam sub-folder dan otomatis menghapus sisa "cangkang" folder yang sudah kosong.
- **Anti-Collision (Auto-Rename):** Jika menemukan file dengan nama yang sama di folder tujuan, aplikasi akan otomatis menambahkan *postfix* (contoh: `Jadwal_1.pdf`) agar file lama tidak tertimpa.
- **Robocopy Fallback (MAX_PATH Bypass):** Kebal terhadap batasan maksimal 260 karakter bawaan Windows. File dengan nama sangat panjang (misal: laporan pemerintah/SIPD) akan ditarik paksa secara aman.

## 🚀 Cara Penggunaan (Versi Portable)

1. Unduh atau *clone* repositori ini.
2. Pastikan file `AutoSorterGUI_v2.ps1` dan `Mulai_Asisten_v2.bat` berada di folder yang sama.
3. Klik ganda (double-click) pada **`Mulai_Asisten_v2.bat`**.
4. Pilih folder yang ingin dirapikan.
5. Tambahkan aturan topik baru (opsional) atau pilih preset metode yang diinginkan.
6. Klik **Mulai Rapikan Folder** dan biarkan asisten bekerja!

## 🛠️ Tech Stack
- **Engine:** Windows PowerShell 5.1+
- **GUI:** System.Windows.Forms (.NET)
- **Database Rules:** JSON
- **Failsafe System:** CMD & Robocopy