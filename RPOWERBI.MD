# R + Power BI — Guide `dplyr` & `ggplot2`

> **Project guide:** [Main README](README.md) · [R Basics](BASICR.MD) · [R Cheat Sheet](CHEATSEET.MD)


> Panduan ini fokus pada **satu hal saja**: cara memakai **`dplyr`** dan **`ggplot2`** di dalam Power BI.
>
> 1. **`dplyr` di Power Query Editor** — cleaning, shaping, dan agregasi data sebelum masuk ke data model;
> 2. **`dplyr` + `ggplot2` di R Visual** — membuat chart ggplot2 di report canvas Power BI Desktop.

> **Sumber materi:** [Create Power BI visuals using R](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-r-visuals) dan [Use R in Power Query Editor](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-r-in-query-editor). Seluruh screenshot di panduan ini diambil dari kedua dokumentasi resmi Microsoft tersebut (lihat [Referensi & Attribution](#9-referensi--attribution)).

---

## 1. Gambaran Umum

| Komponen | Keterangan |
| --- | --- |
| **Fokus** | `dplyr` (data manipulation) dan `ggplot2` (data visualization) |
| **Tools** | R 64-bit, RStudio, Power BI Desktop |
| **`dplyr` dipakai di** | Power Query Editor (R script) dan R Visual |
| **`ggplot2` dipakai di** | R Visual saja |
| **Package lain** | `scales` (format persen/angka) |
| **Luaran** | Data model bersih + R Visual bergaya ggplot2 pada report |

### Dua tempat menjalankan R di Power BI

```text
Power Query Editor  → R mengubah BENTUK DATA (output = tabel)
        ↓
   Data model
        ↓
Report canvas       → R VISUAL menggambar CHART (output = gambar)
```

| Tempat | Input | Output | Package yang relevan |
| --- | --- | --- | --- |
| Power Query Editor (`Transform → Run R script`) | tabel `dataset` | tabel `output` | `dplyr` |
| R Visual (Visualization pane) | tabel `dataset` | gambar/plot | `dplyr` + `ggplot2` |

> **Penting:** Power Query Editor hanya menerima **data frame** sebagai `output`. Karena `ggplot2` menghasilkan objek plot (bukan data frame), **`ggplot2` tidak dipakai di Power Query Editor** — plot dibuat di **R Visual**.

### Roadmap belajar

```text
1. Setup R + aktifkan R di Power BI Desktop
2. Pahami dua mode (Query Editor vs R Visual)
3. dplyr di Power Query Editor
   -> mutate, filter, group_by, summarise
4. dplyr di R Visual
   -> siapkan data sebelum diplot
5. ggplot2 di R Visual
   -> geom + aes + theme
6. Slicer & interaksi dengan scenario
```

---

## 2. Setup R di Power BI Desktop

### 2.1 Install R dan package

Power BI Desktop **tidak** menyertakan engine R. Install R secara terpisah dari CRAN, lalu install `dplyr` dan `ggplot2`:

```r
install.packages(c("dplyr", "ggplot2", "scales"))
```

```r
library(dplyr)
library(ggplot2)
library(scales)
```

### 2.2 Verifikasi lokasi R di Power BI Desktop

Setelah R terinstall, Power BI Desktop mendeteksinya otomatis. Untuk memastikan path-nya benar:

1. Buka menu **File → Options and settings → Options**.
2. Di sisi kiri, pada bagian **Global**, pilih **R scripting**.
3. Pada **R script options**, pastikan path instalasi R lokal sudah muncul di **Detected R home directories**.
4. Jika R tidak terdeteksi, isi path instalasi R secara manual pada kolom yang tersedia.

![Screenshot halaman R script options dengan Detected R home directories di-highlight, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-2.png)

> Pada contoh dokumentasi Microsoft, path instalasi R adalah `C:\Program Files\R Open\R-3.4.4\`. Di komputer Anda, path akan mengikuti versi R yang terinstall.

### 2.3 Catatan versi

| Item | Versi | Keterangan |
| --- | --- | --- |
| R minimum (project ini) | R 4.1.0 | Karena kode memakai native pipe `\|>` |
| R direkomendasikan | R 4.6.1 | Versi yang diverifikasi untuk project ini |
| R pada Power BI service | R 4.3.3 | Runtime R saat R Visual di-publish ke service |
| R Visual minimum | R 3.4.4 | Versi R paling lama yang didukung R Visual |

Pastikan R yang terinstall adalah **64-bit**:

```r
R.version.string
```

---

## 3. Data Latihan

Agar contoh di panduan ini bisa langsung dijalankan, kita pakai satu data latihan bergaya project **Demand & Capacity**. Data ini sengaja dibuat **mengandung beberapa `NA`** (mirip contoh *missing values* pada dokumentasi Microsoft) supaya bagian cleaning dengan `dplyr` terasa nyata.

```r
library(dplyr)

set.seed(123)

# Data latihan demand & capacity bulanan, 4 produk, 2 lokasi.
latihan <- expand.grid(
  Tanggal = seq(as.Date("2024-01-01"), as.Date("2025-12-01"), by = "month"),
  Produk  = c("Product A", "Product B", "Product C", "Product D"),
  Lokasi  = c("Jakarta", "Bandung")
) |>
  mutate(
    Kategori   = if_else(Produk %in% c("Product A", "Product B"), "Food", "Drink"),
    Bulan      = as.integer(format(Tanggal, "%m")),
    Permintaan = round(runif(n(), 500, 5000) * if_else(Bulan %in% c(11, 12), 1.30, 1.00)),
    Harga      = sample(c(5000, 7500, 10000, 15000), n(), replace = TRUE),
    Kapasitas  = sample(c(4000, 5000, 6000), n(), replace = TRUE)
  ) |>
  select(Tanggal, Produk, Kategori, Lokasi, Permintaan, Harga, Kapasitas)

# Sisipkan beberapa missing value untuk latihan cleaning.
latihan$Permintaan[c(15, 20, 41)] <- NA

# Simpan sebagai CSV untuk di-import ke Power BI Desktop.
dir.create("dataset", showWarnings = FALSE)
write.csv(latihan, "dataset/rpowerbi_practice.csv", row.names = FALSE)

glimpse(latihan)
```

> Untuk latihan, CSV hasil generate di atas (atau file contoh Microsoft seperti `EuStockMarkets_NA.csv`) bisa langsung dipakai pada langkah import di bagian berikutnya.

---

## 4. `dplyr` di Power Query Editor

### 4.1 Kapan memakai R di Power Query Editor?

Pakai **Transform → Run R script** ketika cleaning/shaping data lebih mudah dan lebih fleksibel ditulis dengan `dplyr` daripada diklik di Power Query:

- mengisi / menandai missing value (`NA`);
- membuat kolom turunan yang melibatkan banyak kondisi;
- agregasi bertingkat (`group_by()` + `summarise()`);
- validasi kualitas data sebelum masuk data model.

> **Ingat:** di Power Query Editor, R harus mengembalikan **data frame** pada variabel bernama `output`. Plot `ggplot2` tidak bisa dikembalikan di sini.

### 4.2 Langkah-langkah

**1. Import data**

Dari tab **Home**, pilih **Get data → Text/CSV**.

![Screenshot opsi Get data dengan pilihan Text/CSV, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_1.png)

**2. Pilih file CSV**

Pilih file CSV Anda, lalu **Open**. Isi file tampil pada dialog **Text/CSV file**.

![Screenshot isi file CSV pada dialog Text/CSV, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_2.png)

**3. Load data**

Pilih **Load** untuk memuat data dari file. Setelah data dimuat, tabel baru muncul di **Fields pane**.

![Screenshot tabel baru pada Fields pane, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_3.png)

**4. Buka Power Query Editor**

Dari ribbon **Home**, pilih **Transform data**.

![Screenshot ribbon Home dengan tombol Transform data di-highlight, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_4.png)

**5. Tambahkan step R script**

Dari tab **Transform**, pilih **Run R script**. Editor **Run R script** akan terbuka, dan di situ Anda menulis script `dplyr`.

![Screenshot Power Query Editor dengan pilihan Run R script, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_5d.png)
**6. Tulis script `dplyr`**

Masukkan script berikut pada kotak **Script**. Variabel `dataset` adalah data hasil langkah sebelumnya, dan `output` adalah hasil akhir step ini.

```r
library(dplyr)

output <- dataset |>
  # 1) Tangani missing value pada Permintaan.
  filter(!is.na(Permintaan)) |>
  # 2) Bentuk tanggal dan kolom turunan.
  mutate(
    Tanggal     = as.Date(Tanggal),
    Tahun       = format(Tanggal, "%Y"),
    Bulan       = format(Tanggal, "%m"),
    NamaBulan   = format(Tanggal, "%B"),
    DemandValue = Permintaan * Harga
  ) |>
  # 3) Agregasi demand dan capacity per dimensi.
  #    Tanggal tetap dipertahankan agar chart time-series tetap bisa dibuat.
  group_by(Tanggal, Tahun, Bulan, NamaBulan, Produk, Kategori, Lokasi) |>
  summarise(
    Demand      = sum(Permintaan, na.rm = TRUE),
    DemandValue = sum(DemandValue, na.rm = TRUE),
    Capacity    = mean(Kapasitas, na.rm = TRUE),
    Harga       = mean(Harga, na.rm = TRUE),
    .groups     = "drop"
  )
```

> **Tips:** pertahankan kolom `Tanggal` pada `group_by()` (seperti pada transformation project ini). Jika `Tanggal` ikut teragregasi keluar, kolom itu hilang dari data model dan chart time-series di R Visual akan error `Column 'Tanggal' is not found`.

**7. Pilih OK**

Setelah **OK**, Power Query Editor menampilkan peringatan data privacy.

![Screenshot peringatan data privacy dengan opsi Continue, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_6.png)

**8. Set privacy level ke Public**

Di dalam peringatan, pilih **Continue**. Pada dialog **Privacy levels** yang muncul, set semua data source ke **Public** agar R script berjalan benar di Power BI service.

![Screenshot dialog Privacy levels dengan pilihan Public, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_7.png)

**9. Save untuk menjalankan script**

Pilih **Save** untuk menjalankan script, lalu lihat hasilnya:

![Screenshot hasil R script di Power Query Editor, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor-11.png)

**10. Lihat tabel Output**

Pilih **Table** di samping **Output** untuk melihat tabel hasil script. Kolom baru akan muncul di **Fields pane**.

![Screenshot tabel hasil R script, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor-12.png)

> Bandingkan dengan contoh Microsoft: pada contoh mereka, 5 baris kode dengan package `mice` mampu mengisi *missing value* dengan model prediktif. Di panduan ini, hal serupa dilakukan dengan `dplyr` — `filter()` untuk membuang `NA`, atau `mutate()` + `coalesce()` untuk mengisinya.

### 4.3 Empat pola `dplyr` yang paling sering dipakai

```r
library(dplyr)

# 1. Menandai missing value
dataset |>
  mutate(AdaMissing = is.na(Permintaan))

# 2. Mengisi missing value dengan nilai rata-rata per grup
dataset |>
  group_by(Produk) |>
  mutate(Permintaan = if_else(is.na(Permintaan), mean(Permintaan, na.rm = TRUE), Permintaan)) |>
  ungroup()

# 3. Membuat kolom turunan bersyarat
dataset |>
  mutate(Segmen = case_when(
    Permintaan > 4000 ~ "High",
    Permintaan > 2000 ~ "Medium",
    TRUE              ~ "Low"
  ))

# 4. Agregasi per kelompok
dataset |>
  group_by(Produk, Lokasi) |>
  summarise(Demand = sum(Permintaan, na.rm = TRUE), .groups = "drop")
```

### 4.4 Privacy level untuk query R

Semua data source yang dipakai query R harus diset **Public**. Jika tidak, refresh akan gagal.

1. Di Power BI Desktop, pilih **File → Options and settings → Data source settings**.
2. Pilih satu atau beberapa data source, lalu **Edit Permissions**.
3. Set **Privacy Level** ke **Public**.

![Screenshot dialog Options and Settings untuk memilih Data source settings, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_9.png)

![Screenshot dialog Data source settings untuk mengubah permissions, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_10.png)

---

## 5. `dplyr` di R Visual

Di **R Visual**, Power BI mengirim data yang Anda pilih pada panel **Values** sebagai data frame bernama `dataset`. Tugas `dplyr` di sini adalah **menyiapkan data sebelum diplot** — karena `ggplot2` bekerja paling baik dengan data yang sudah rapi dan sudah diagregasi.

### 5.1 Aturan penting input data R Visual

| Aturan | Penjelasan |
| --- | --- |
| Nama data frame | Selalu `dataset` (dibuat otomatis oleh Power BI) |
| Akses kolom | `dataset$Demand` atau `dataset$Demand` di dalam `aes()` |
| Nama kolom ber-spasi | Gunakan tanda kutip tunggal, misal `dataset$'Product Name'` |
| Default aggregation | **do not summarize** — jadi agregasi kita lakukan sendiri dengan `dplyr` |
| Rename kolom | **Tidak didukung** — kolom dirujuk dengan nama aslinya saat script berjalan |
| Baris duplikat | Digabung (muncul sekali), seperti visual tabel |

> Karena default aggregation adalah **do not summarize**, pola `group_by()` + `summarise()` dengan `dplyr` adalah cara utama untuk mengontrol level agregasi chart.

### 5.2 Tiga pola `dplyr` sebelum plot

```r
library(dplyr)

# Pola 1 — Agregasi per kategori (untuk bar chart)
plot_data <- dataset |>
  group_by(Produk) |>
  summarise(
    Demand   = sum(Demand, na.rm = TRUE),
    Capacity = sum(Capacity, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  mutate(Utilization = Demand / Capacity)

# Pola 2 — Agregasi per waktu (untuk line chart)
plot_data <- dataset |>
  mutate(Tanggal = as.Date(Tanggal)) |>
  group_by(Tanggal) |>
  summarise(Demand = sum(Demand, na.rm = TRUE), .groups = "drop") |>
  arrange(Tanggal)

# Pola 3 — Filter lalu hitung rasio (untuk highlight risiko)
plot_data <- dataset |>
  filter(Capacity > 0) |>
  mutate(
    Utilization   = Demand / Capacity,
    Status        = if_else(Utilization > 1, "Shortage", "Aman")
  ) |>
  arrange(desc(Utilization))
```

### 5.3 Mengikuti slicer Power BI tanpa hard-code

Agar R Visual mengikuti slicer `Scenario` tetapi tetap default ke `Base`, gunakan pola berikut (sama seperti pada [main README](README.md)):

```r
library(dplyr)

selected_scenario <- if ("Scenario" %in% names(dataset)) {
  scenarios_in_visual <- unique(na.omit(as.character(dataset$Scenario)))
  if (length(scenarios_in_visual) == 1) scenarios_in_visual else "Base"
} else {
  "Base"
}

visual_data <- dataset |>
  filter(Scenario == selected_scenario)
```

> Jangan gunakan `filter(Scenario == "Base")` secara hard-code pada kode visual, karena akan mematikan fungsi slicer.

### 5.4 Merapikan data dengan `tidyr` (opsional)

`dplyr` sering dipasangkan dengan `tidyr` agar bentuk data cocok untuk `ggplot2` — misalnya saat perlu `pivot_longer()` untuk beberapa series dalam satu chart:

```r
library(dplyr)
library(tidyr)

plot_data <- dataset |>
  group_by(Tanggal) |>
  summarise(
    Demand   = sum(Demand, na.rm = TRUE),
    Capacity = sum(Capacity, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  pivot_longer(
    cols      = c(Demand, Capacity),
    names_to  = "Metrik",
    values_to = "Nilai"
  )
```

---

## 6. `ggplot2` di R Visual

### 6.1 Langkah-langkah menambahkan R Visual

**1. Pilih icon R Visual**

Di **Visualization pane**, pilih icon **R Visual** untuk menambahkan R visual ke report.

![Screenshot Visualization pane dengan icon R Visual di-highlight, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-3.png)

**2. Aktifkan script visuals**

Pada jendela **Enable script visuals** yang muncul, pilih **Enable**.

![Screenshot dialog Enable script visuals dengan tombol Enable di-highlight, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-10.png)

> **Keamanan:** R Visual dibuat dari script R yang bisa mengandung risiko keamanan atau privasi. Aktifkan R Visual hanya jika Anda memercayai pembuat dan sumbernya, atau setelah membaca serta memahami script-nya.

**3. Isi field pada panel Values**

Tarik field dari **Fields pane** ke bagian **Values** — hanya field yang ada di **Values** yang bisa dipakai script Anda.

Ketika R visual ditambahkan, Power BI Desktop melakukan tiga hal:

- gambar R visual *placeholder* muncul di report canvas;
- editor R script muncul di bagian bawah panel tengah;
- kode *binding* untuk field yang dipilih dibuat otomatis di bagian abu-abu atas editor.

![Screenshot editor R script Power BI, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-4.png)

**4. Kode binding (bagian abu-abu)**

Saat Anda memilih field, editor otomatis membuat kode pendukung pada bagian abu-abu di atas editor. Contohnya, field `Demand` dan `Capacity` akan menghasilkan data frame `dataset` dengan kolom tersebut, dan Anda mengaksesnya dengan `dataset$Demand`.

![Screenshot editor R script dengan kode script di-highlight, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-5.png)

> Jika Anda menghapus sebuah field, editor R script juga otomatis menghapus kode pendukung untuk field tersebut.
### 6.2 Formula inti `ggplot2`

```text
ggplot(data, aes(x = ..., y = ...)) +
  geom_xxx()   +   # bentuk chart
  scale_xxx()  +   # skala & format
  labs()       +   # judul & label
  theme_xxx()      # tampilan
```

| Bagian | Fungsi |
| --- | --- |
| `ggplot(data, aes(...))` | Mendefinisikan data dan pemetaan variabel ke sumbu/warna |
| `geom_*()` | Menentukan bentuk visual (`geom_col()`, `geom_line()`, `geom_tile()`, `geom_point()`) |
| `scale_*()` | Mengatur skala dan format (`scale_y_continuous(labels = percent)`) |
| `labs()` | Judul, subtitle, label sumbu |
| `theme_*()` | Tema tampilan (`theme_minimal()`, `theme_bw()`) |

### 6.3 Contoh 1 — Bar chart: Utilization per Produk

```r
library(dplyr)
library(ggplot2)
library(scales)

# 1. Siapkan data dengan dplyr.
plot_data <- dataset |>
  group_by(Produk) |>
  summarise(
    Demand   = sum(Demand, na.rm = TRUE),
    Capacity = sum(Capacity, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  mutate(Utilization = Demand / Capacity)

# 2. Gambar dengan ggplot2.
ggplot(plot_data, aes(x = Produk, y = Utilization, fill = Produk)) +
  geom_col() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title = "Capacity Utilization per Produk",
    subtitle = "Garis putus-putus = 100% (batas kapasitas)",
    x = NULL,
    y = "Utilization"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

### 6.4 Contoh 2 — Line chart: tren demand bulanan

```r
library(dplyr)
library(ggplot2)

plot_data <- dataset |>
  mutate(Tanggal = as.Date(Tanggal)) |>
  group_by(Tanggal) |>
  summarise(Demand = sum(Demand, na.rm = TRUE), .groups = "drop") |>
  arrange(Tanggal)

ggplot(plot_data, aes(x = Tanggal, y = Demand)) +
  geom_line(color = "#2c7fb8", linewidth = 1) +
  geom_point(color = "#2c7fb8", size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Tren Demand Bulanan", x = NULL, y = "Demand") +
  theme_minimal()
```

### 6.5 Contoh 3 — Heatmap: Utilization per Produk per Lokasi

```r
library(dplyr)
library(ggplot2)
library(scales)

plot_data <- dataset |>
  group_by(Produk, Lokasi) |>
  summarise(
    Demand   = sum(Demand, na.rm = TRUE),
    Capacity = sum(Capacity, na.rm = TRUE),
    .groups  = "drop"
  ) |>
  mutate(Utilization = Demand / Capacity)

ggplot(plot_data, aes(x = Lokasi, y = Produk, fill = Utilization)) +
  geom_tile(color = "white") +
  geom_text(aes(label = percent(Utilization, accuracy = 1)), size = 3) +
  scale_fill_gradient(low = "#c6dbef", high = "#08519c") +
  labs(title = "Utilization per Produk & Lokasi", x = NULL, y = NULL) +
  theme_minimal()
```

### 6.6 Ringkasan `dplyr` + `ggplot2` di R Visual

| Kebutuhan chart | `dplyr` | `ggplot2` |
| --- | --- | --- |
| Bar per kategori | `group_by()` + `summarise()` | `geom_col()` |
| Tren waktu | `group_by()` + `arrange()` | `geom_line()` + `geom_point()` |
| Heatmap 2 dimensi | `group_by()` 2 kolom | `geom_tile()` + `scale_fill_gradient()` |
| Highlight risiko | `filter()` + `mutate()` | `geom_hline()` / `geom_vline()` |

### 6.7 Menangani error pada R Visual

Jika script menghasilkan error, pesan error tampil di canvas menggantikan plot. Untuk detailnya, pilih **See details** pada pesan error R visual.

![Screenshot pesan error pada canvas, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-9.png)

Penyebab paling umum:

| Gejala | Penyebab | Solusi |
| --- | --- | --- |
| `could not find function "ggplot"` | Package belum di-load | Tambahkan `library(ggplot2)` di baris atas |
| `object 'Demand' not found` | Field belum ada di **Values** | Tambahkan field ke panel **Values** |
| `object 'X' not found` pada nama ber-spasi | Nama kolom ber-spasi | Rujuk dengan kutip tunggal: `dataset$'Nama Kolom'` |
| Semua nilai jadi 1 baris | Default aggregation **do not summarize** | Agregasi sendiri dengan `dplyr` |
| Error setelah pindah ke service | Package/versi berbeda | Cek daftar package yang didukung Power BI service |
---

## 7. Alur Lengkap dari Dokumentasi Microsoft

Bagian ini menampilkan **contoh resmi Microsoft** sebagai referensi alur kerja. Contoh Microsoft memakai package `corrplot` untuk *correlation plot* — **alurnya identik** dengan pemakaian `ggplot2` pada panduan ini: tulis script → lihat hasil → modifikasi → cross-filter.

### 7.1 Tulis script, lihat hasil plot

Gambar berikut menunjukkan contoh kode *correlation plot*, yang memplot korelasi antar atribut dari beberapa tipe mobil.

![Screenshot contoh kode correlation plot, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-6.png)

### 7.2 Perbesar tampilan dan cross-filter

Seperti visual Power BI lainnya, R Visual bisa **di-cross filter** oleh visual lain — pada contoh, correlation plot bereaksi saat dipilih nilai tertentu (misal `Auto` atau `Manual`) pada visual donut chart di sebelah kanan. Untuk melihat visual lebih besar, deselect R visual atau minimize editor R script.

![Screenshot contoh correlation plot pada tampilan visual yang lebih besar, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-7.png)

### 7.3 Modifikasi script untuk mengubah tampilan

Script bisa dimodifikasi dengan menambahkan parameter pada perintah plotting. Contoh Microsoft mengubah:

```r
corrplot(M, method = "color", tl.cex = 0.6, tl.srt = 45, tl.col = "black")
```

menjadi:

```r
corrplot(M, method = "circle", tl.cex = 0.6, tl.srt = 45, tl.col = "black",
         type = "upper", order = "hclust")
```

Hasilnya, R visual sekarang memplot lingkaran, hanya mempertimbangkan separuh bagian atas matriks, dan mengurutkan ulang matriks untuk mengelompokkan atribut yang berkorelasi.

![Screenshot contoh R visual circle plot, dari dokumentasi Microsoft Learn](images/rpowerbi/r-visuals-8.png)

> **Padanan di panduan ini:** peran `corrplot` digantikan oleh `ggplot2`. Menambah/mengubah parameter pada perintah plotting tetap dilakukan dengan cara yang sama — tambahkan atau ubah `geom_*()`, `scale_*()`, dan `theme_*()` di akhir script.

### 7.4 R script juga bisa dipakai sebagai sumber visual

Pada artikel kedua (Power Query), data hasil R script dipakai untuk membuat visual. Contoh Microsoft memakai package `mice` untuk mengisi *missing value*, lalu membuat visual perbandingan antara nilai asli dan nilai hasil prediksi.

![Screenshot R script visual yang menampilkan missing values dan completed values, dari dokumentasi Microsoft Learn](images/rpowerbi/r-in-query-editor_8a.png)

---

## 8. Batasan & Catatan Penting

### 8.1 Batasan R Visual di Power BI Desktop

| Aspek | Batasan |
| --- | --- |
| Ukuran data | Maksimum **150.000 baris**. Jika lebih, hanya 150.000 baris teratas yang dipakai dan sebuah pesan tampil pada gambar |
| Ukuran output | Maksimum **2 MB** |
| Resolusi | Semua R visual ditampilkan pada **72 DPI** |
| Plotting device | Hanya plotting ke **default device** yang didukung — jangan memakai display device lain secara eksplisit |
| Waktu kalkulasi | Jika kalkulasi R visual melebihi **5 menit**, terjadi *time-out* |
| Interaktivitas | Gambar R visual **tidak interaktif** dan **tidak bisa menjadi sumber cross-filtering** |
| Highlight | R visual bereaksi saat visual lain di-highlight, tetapi elemen di dalam R visual tidak bisa dipilih untuk cross filter visual lain |
| Relationships | Error terjadi jika field dari tabel berbeda tanpa relationship dipakai bersama |
| Rename kolom | **Tidak didukung** — kolom dirujuk dengan nama aslinya saat script dijalankan |
| Refresh | R visual di-refresh saat data berubah, difilter, atau di-highlight |
| RRO 32-bit | Power BI Desktop 32-bit tidak mendeteksi instalasi RRO secara otomatis — path harus diisi manual di **Options → R Scripting** |

### 8.2 Batasan di Power BI service

| Aspek | Batasan |
| --- | --- |
| Runtime R | Power BI service memakai **R 4.3.3** |
| Ukuran payload | R visual yang dirender service dibatasi **30 MB** (total data input terkompresi + script) |
| Waktu eksekusi | Time-out eksekusi script **1 menit** |
| Publish to web | **Tidak didukung** untuk R visuals — report bisa dipublish, tetapi R visual tidak tampil (chart kosong) |
| Sovereign cloud | R visuals tidak didukung untuk pelanggan sovereign cloud dan tenant di region tanpa Fabric |
| App owns data | R visuals tidak didukung dengan Service Principal Profiles for App Owns Data |
| Embed | Sejak **Mei 2026**, Power BI mengakhiri dukungan penyematan report/dashboard berisi R atau Python visuals pada skenario *embed for your customers* (app owns data) dan *publish to web*. Tidak berdampak pada secure embedding ke SharePoint/Website/Portal dan skenario *embed for your organization* |
| Package | Hanya package CRAN publik yang didukung; package privat/custom tidak didukung di service |

> **Selalu cek kembali R visual setelah report di-publish**, untuk memastikan report tampil sesuai harapan.

### 8.3 Batasan query R di Power Query Editor

| Aspek | Batasan |
| --- | --- |
| Privacy level | Semua setting data source R **harus Public**; semua step lain di query juga harus public |
| Scheduled refresh | Perlu mengaktifkan scheduled refresh dan install **on-premises data gateway (personal mode)** di komputer yang menyimpan workbook dan R |
| Enterprise gateway | **Tidak bisa** dipakai untuk refresh data model yang berisi R script di Power Query |
| Output | Harus berupa data frame pada variabel `output` — plot tidak bisa dikembalikan |
---

## 9. Referensi & Attribution

### Sumber materi

| Topik | Sumber |
| --- | --- |
| R Visual (`dplyr` + `ggplot2` di report canvas) | [Create Power BI visuals using R](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-r-visuals) |
| R di Power Query Editor (`dplyr` untuk cleaning) | [Use R in Power Query Editor](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-r-in-query-editor) |
| Package yang didukung di service | [Learn which R packages are supported](https://learn.microsoft.com/en-us/power-bi/connect-data/service-r-packages-support) |

### Attribution gambar

Seluruh screenshot pada panduan ini berasal dari dokumentasi resmi Microsoft Learn di atas dan disimpan di folder [`images/rpowerbi/`](images/rpowerbi/) dengan nama file yang sama seperti sumbernya untuk memudahkan penelusuran.

| File gambar | Menampilkan |
| --- | --- |
| `r-visuals-2.png` | Halaman opsi **R scripting** dengan **Detected R home directories** |
| `r-visuals-3.png` | **Visualization pane** dengan icon **R Visual** |
| `r-visuals-10.png` | Dialog **Enable script visuals** |
| `r-visuals-4.png` | Editor R script Power BI |
| `r-visuals-5.png` | Editor R script dengan kode script di-highlight |
| `r-visuals-6.png` | Contoh kode correlation plot |
| `r-visuals-7.png` | Correlation plot pada tampilan visual lebih besar |
| `r-visuals-8.png` | Contoh R visual circle plot |
| `r-visuals-9.png` | Pesan error pada canvas |
| `r-in-query-editor_1.png` | **Get data → Text/CSV** |
| `r-in-query-editor_2.png` | Isi file CSV pada dialog **Text/CSV** |
| `r-in-query-editor_3.png` | Tabel baru di **Fields pane** |
| `r-in-query-editor_4.png` | Ribbon **Home** dengan **Transform data** |
| `r-in-query-editor_5d.png` | Power Query Editor dengan **Run R script** |
| `r-in-query-editor_6.png` | Peringatan data privacy dengan **Continue** |
| `r-in-query-editor_7.png` | Dialog **Privacy levels** dengan **Public** |
| `r-in-query-editor-11.png` | Hasil R script |
| `r-in-query-editor-12.png` | Tabel hasil R script |
| `r-in-query-editor_8a.png` | Visual dengan missing values dan completed values |
| `r-in-query-editor_9.png` | **Options and Settings → Data source settings** |
| `r-in-query-editor_10.png` | Dialog **Data source settings** untuk edit permissions |

> Dokumentasi Microsoft Learn dipublikasikan di bawah lisensi [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/), dengan atribusi kepada Microsoft.

### Dokumentasi terkait di repo ini

- [Main README](README.md) — business case, transformation, dan Power BI dashboard project.
- [R Basics](BASICR.MD) — fondasi R, `dplyr`, `ggplot2`, `tidyr`, dan validasi data.
- [R Cheat Sheet](CHEATSEET.MD) — ringkasan cepat sintaks R.
> **Untuk scheduled refresh:** aktifkan scheduled refresh dan install **on-premises data gateway (personal mode)** di komputer yang menyimpan file dan R. **Enterprise gateway tidak bisa** dipakai untuk refresh data model yang berisi R script di Power Query.