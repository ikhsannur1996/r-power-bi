# R + Power BI — Panduan Singkat `dplyr` & `ggplot2`

> **Project guide:** [Main README](README.md) · [R Basics](BASICR.MD) · [R Cheat Sheet](CHEATSEET.MD)


> **Sumber:** [Create Power BI visuals using R](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-r-visuals) · [Use R in Power Query Editor](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-r-in-query-editor). Semua screenshot di panduan ini berasal dari kedua artikel tersebut.

---

## 1. Ringkasan

| Tempat | Fungsi | Package |
| --- | --- | --- |
| Power Query Editor (`Transform → Run R script`) | mengubah bentuk data → tabel `output` | `dplyr` |
| R Visual (Visualization pane) | menggambar chart → gambar | `dplyr` + `ggplot2` |

```text
Power Query Editor  ->  data bersih  ->  Data model  ->  R Visual  ->  chart
```

> Power Query Editor hanya menerima **data frame** (`output`), sehingga `ggplot2` hanya dipakai di **R Visual**.

Data latihan: [`dataset/rpowerbi_practice.csv`](dataset/rpowerbi_practice.csv).

Contoh report: [`Demand & Capacity.pbix`](Demand%20%26%20Capacity.pbix) — satu halaman berisi 6 R Visual (`ggplot2`) dan slicer `Scenario`, `Kategori`, `Ukuran`, serta `Packing`.

---

## 2. Setup

Power BI Desktop tidak menyertakan engine R, jadi install R terpisah dari CRAN:

```r
install.packages(c("dplyr", "ggplot2", "scales"))
```

Aktifkan R di Power BI Desktop: **File → Options and settings → Options → Global → R scripting**, lalu pastikan path R muncul di **Detected R home directories**.

![R scripting options](images/rpowerbi/r-visuals-2.png)

---

## 3. `dplyr` di Power Query Editor

**Alur:** Get data → Text/CSV → Load → Transform data → Transform → Run R script.

![Get data](images/rpowerbi/r-in-query-editor_1.png)
![Dialog Text/CSV](images/rpowerbi/r-in-query-editor_2.png)
![Fields pane](images/rpowerbi/r-in-query-editor_3.png)
![Transform data](images/rpowerbi/r-in-query-editor_4.png)
![Run R script](images/rpowerbi/r-in-query-editor_5d.png)

**Script** — `dataset` adalah input, `output` adalah hasil step ini:

```r
library(dplyr)

output <- dataset |>
  mutate(DemandValue = Permintaan * Harga) |>
  group_by(Tanggal, Produk) |>
  summarise(
    Demand      = sum(Permintaan, na.rm = TRUE),
    DemandValue = sum(DemandValue, na.rm = TRUE),
    .groups     = "drop"
  )
```

> Pertahankan `Tanggal` di `group_by()` jika ingin membuat chart time-series, agar kolomnya tidak hilang.

**Setelah OK:** pilih **Continue**, lalu set **Privacy levels = Public**.

![Peringatan privacy](images/rpowerbi/r-in-query-editor_6.png)
![Privacy levels](images/rpowerbi/r-in-query-editor_7.png)
![Hasil R script](images/rpowerbi/r-in-query-editor-11.png)
![Tabel Output](images/rpowerbi/r-in-query-editor-12.png)

**Privacy level:** semua data source query R harus **Public** (File → Options and settings → Data source settings → Edit Permissions).

![Data source settings](images/rpowerbi/r-in-query-editor_9.png)
![Edit permissions](images/rpowerbi/r-in-query-editor_10.png)

---

## 4. `dplyr` + `ggplot2` di R Visual

Tambah R Visual: pilih icon **R Visual**, lalu **Enable**.

![Icon R Visual](images/rpowerbi/r-visuals-3.png)
![Enable script visuals](images/rpowerbi/r-visuals-10.png)

Field yang dipilih di **Values** dikirim sebagai data frame bernama `dataset`. Editor script dan kode binding tampil otomatis.

![Editor R script](images/rpowerbi/r-visuals-4.png)
![Kode binding](images/rpowerbi/r-visuals-5.png)

| Aturan | Keterangan |
| --- | --- |
| Nama data frame | selalu `dataset` |
| Agregasi | default **do not summarize** → agregasi sendiri dengan `dplyr` |
| Nama kolom | dirujuk dengan nama asli, mis. `dataset$Demand` |

### Contoh

**Bar — demand per produk**

```r
library(dplyr); library(ggplot2)

dataset |>
  group_by(Produk) |>
  summarise(Demand = sum(Demand, na.rm = TRUE), .groups = "drop") |>
  ggplot(aes(Produk, Demand)) +
  geom_col(fill = "#2c7fb8") +
  theme_minimal()
```

**Line — tren demand**

```r
dataset |>
  group_by(Tanggal) |>
  summarise(Demand = sum(Demand, na.rm = TRUE), .groups = "drop") |>
  ggplot(aes(as.Date(Tanggal), Demand)) +
  geom_line(color = "#2c7fb8") +
  theme_minimal()
```

**Heatmap — demand per produk & lokasi**

```r
dataset |>
  group_by(Produk, Lokasi) |>
  summarise(Demand = sum(Demand, na.rm = TRUE), .groups = "drop") |>
  ggplot(aes(Lokasi, Produk, fill = Demand)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#c6dbef", high = "#08519c") +
  theme_minimal()
```

**Ikuti slicer** (default `Base`):

```r
sc <- unique(dataset$Scenario)
dataset <- dataset |> filter(Scenario == if (length(sc) == 1) sc else "Base")
```

Jika script error, pesan tampil di canvas — pilih **See details**.

![Error pada canvas](images/rpowerbi/r-visuals-9.png)

---

## 5. Contoh Resmi Microsoft

Alurnya sama seperti di atas; contoh Microsoft memakai package `corrplot` (padanan `ggplot2`).

![Contoh correlation plot](images/rpowerbi/r-visuals-6.png)
![Cross-filter](images/rpowerbi/r-visuals-7.png)
![Hasil modifikasi](images/rpowerbi/r-visuals-8.png)

Data hasil R script juga bisa dipakai untuk membuat visual:

![Missing vs completed values](images/rpowerbi/r-in-query-editor_8a.png)

---

## 6. Batasan Singkat

| Area | Batasan |
| --- | --- |
| R Visual | maks 150.000 baris, output 2 MB, 72 DPI, timeout 5 menit, tidak bisa menjadi sumber cross-filter |
| Power BI service | R 4.3.3, payload 30 MB, timeout 1 menit, *publish to web* tidak didukung |
| Power Query | semua data source harus **Public**; refresh butuh **personal gateway** (enterprise gateway tidak bisa) |

---

## 7. Referensi

| Topik | Sumber |
| --- | --- |
| R Visual | [Create Power BI visuals using R](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-r-visuals) |
| R di Power Query Editor | [Use R in Power Query Editor](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-r-in-query-editor) |
| Package di service | [Supported R packages](https://learn.microsoft.com/en-us/power-bi/connect-data/service-r-packages-support) |

Semua screenshot di `images/rpowerbi/` berasal dari dua artikel Microsoft Learn di atas (lisensi CC BY 4.0), dengan nama file sama seperti sumbernya.

- [Main README](README.md) — business case & dashboard.
- [R Basics](BASICR.MD) — fondasi R, `dplyr`, `ggplot2`.
- [R Cheat Sheet](CHEATSEET.MD) — ringkasan sintaks.
