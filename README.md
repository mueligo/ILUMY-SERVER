# ILUMY-SERVER (Pumpkin Minecraft Server)

Server Minecraft modern berbasis **Pumpkin MC (Rust)** dengan tunnel **Playit.gg** dan sistem **Auto-Backup 30 Menit ke GitHub** (`ILUMY-BACKUP`).

Didesain khusus untuk di-deploy di **Hostless Cloud (Worker)** dengan resource `0.5 vCPU` dan `1 GB RAM`.

---

## 🚀 Fitur Utama
1. **Ultra Hemat RAM:** Menggunakan Pumpkin MC (ditulis native dengan Rust), hanya memakan 100-300 MB RAM.
2. **Koneksi Game Cepat:** Menggunakan Playit.gg dengan routing Anycast Singapura (~20-40 ms ping).
3. **Auto-Backup Tiap 30 Menit:** Otomatis mendeteksi perubahan world dan push commit ke repo private `ILUMY-BACKUP`.
4. **Auto-Restore saat Boot:** Jika container restart atau dideploy ulang di storage baru, world otomatis di-restore dari backup terbaru di GitHub.

---

## ⚙️ Environment Variables (Wajib di Hostless)

Tambahkan variable berikut di menu **Environment Variables** pada Worker di Hostless:

| Variable | Deskripsi | Contoh |
| :--- | :--- | :--- |
| `GITHUB_TOKEN` | Personal Access Token (PAT) GitHub dengan scope `repo` agar bisa push ke `ILUMY-BACKUP` | `ghp_xxxxxxxxxxxx` |
| `GITHUB_USERNAME` | Username GitHub pemilik repo backup | `mueligo` |
| `SECRET_KEY` | *(Opsional)* Secret key Playit.gg agar alamat server tidak pernah ganti | didapat setelah klaim Playit |

---

## 🛠️ Cara Deploy di Hostless Cloud

1. Buka [Hostless Cloud Dashboard](https://hostless.cloud/).
2. Buat Project baru, lalu ke menu **Workers** -> **Create Standalone Worker**.
3. Pilih repository ini (`mueligo/ILUMY-SERVER`).
4. Resource:
   - CPU: `0.5 vCPU`
   - Memory: `1 GB`
5. Masukkan **Environment Variables** di atas (`GITHUB_TOKEN`, `GITHUB_USERNAME`).
6. Klik **Deploy**.
7. Cek tab **Logs** di Hostless untuk melihat link klaim Playit.gg (jika pertama kali) atau status server.
