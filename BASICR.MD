# R Basics — Foundation, Data Manipulation & Visualization

> **Project guide:** [Main project README](README.md) · [R Cheat Sheet](CHEATSEET.MD)


> Panduan ini menyediakan fondasi R lengkap untuk project **Demand & Capacity What-If Analysis**, termasuk data preparation, transformation, visualization, forecasting, dan Power BI R Visual.
>
> 1. **Basic R** — pengenalan R, RStudio, sintaks dasar, tipe data, vektor, fungsi, dan logika;
> 2. **Data Manipulation** — membuat data latihan (generate), membersihkan data, dan mengolah data dengan `dplyr`;
> 3. **Data Visualization** — visualisasi data dengan `ggplot2` dari grafik sederhana hingga multi-variabel.

---

## 1. Gambaran Umum

| Komponen | Keterangan |
| --- | --- |
| **Nama proyek** | R Basics untuk Demand & Capacity |
| **Topik materi** | Basic R, Data Manipulation (dplyr, tidyr, joins, lubridate, stringr, scales), Validasi Data, dan Data Visualization |
| **Bahasa** | R, RStudio Desktop |
| **Package utama** | `tidyverse`, `lubridate`, `scales` |
| **Prerequisit** | Tidak diperlukan pengalaman sebelumnya (pemula mutlak) |
| **Luaran** | Kemampuan dasar menulis kode R, mengolah data, dan membuat grafik sebagai referensi project Demand & Capacity |

### Alur belajar (roadmap)

```text
Basic R
  -> R & RStudio
  -> Sintaks & objek
  -> Tipe data & vektor
  -> Fungsi & logika

Data Manipulation
  -> Membuat data latihan (generate, tanpa CSV)
  -> Membaca data dari file (opsional)
  -> Memahami struktur data
  -> dplyr: select, filter, mutate, arrange, group_by, summarise
  -> Pipeline dan cleaning lengkap
  -> tidyr: pivot_longer & pivot_wider
  -> Joins: left_join, inner_join, anti_join
  -> lubridate: tanggal, bulan, periode
  -> stringr & scales: label dan format angka
  -> Validasi kualitas data (audit sebelum analisis)

Data Visualization
  -> Konsep layer ggplot2
  -> Bar, line, scatter, boxplot
  -> Heatmap, stacked bar, combo bar + line
  -> Multi-variabel & formatting
  -> Menyimpan grafik
```

---

## 2. Tujuan Pembelajaran

Setelah menyelesaikan **R Basics**, Anda diharapkan mampu:

1. Menginstal dan menjalankan R serta RStudio.
2. Membuat objek, vektor, dan data frame.
3. Menggunakan operator, fungsi, dan logika dasar R.
4. Membuat data latihan dengan kode R (generate) dan memahami struktur data.
5. Melakukan cleaning dan transformasi data dengan `dplyr`.
6. Mengubah bentuk data dengan `tidyr` dan menggabungkan tabel dengan join.
7. Mengolah tanggal dengan `lubridate`, teks dengan `stringr`, dan format angka dengan `scales`.
8. Memeriksa kualitas data (validasi) sebelum menarik kesimpulan.
9. Membuat grafik dasar hingga multi-variabel dengan `ggplot2`.
10. Menyimpan hasil analisis (data bersih, ringkasan, dan grafik) untuk proyek lanjutan.

> Gunakan panduan ini sebagai referensi dasar sebelum menjalankan kode pada [README project](README.md).

---

## 3. Prerequisites and RStudio Setup

### 3.1 Instalasi

| Software | URL | Fungsi |
| --- | --- | --- |
| **R** | <https://cran.r-project.org/> | Mesin (engine) yang menjalankan kode R |
| **RStudio Desktop** | <https://posit.co/download/rstudio-desktop/> | IDE untuk menulis kode, melihat data & grafik, mengelola project |

- **R** adalah "mesin" di balik semua analisis.
- **RStudio** adalah "kokpit" yang membuat kerja jauh lebih nyaman.

### 3.2 Packages Used in This Project

Paket (package) adalah kumpulan fungsi siap pakai. Instal sekali saja:

```r
install.packages(c("tidyverse", "lubridate", "scales"))

library(tidyverse)
library(lubridate)
library(scales)
```

Aktifkan setiap awal sesi:

```r
library(tidyverse) # data manipulation, reading data, and visualization
library(lubridate) # date handling
library(scales)    # percentages and number labels
```

> Jika muncul pesan `there is no package called ...`, lakukan `install.packages()` terlebih dahulu.

**Package yang sudah termasuk di dalam `tidyverse`** (tidak perlu instalasi terpisah):

| Package | Dipakai untuk | Chapter |
| --- | --- | --- |
| `dplyr` | select, filter, mutate, group_by, summarise, join | 7 dan 9 |
| `tidyr` | `pivot_longer()`, `pivot_wider()`, penanganan `NA` | 8 |
| `stringr` | pengolahan teks dan label | 11 |
| `ggplot2` | visualisasi | 14 |
| `readr` | membaca file CSV/TSV | 6 (opsional) |

> Cukup `library(tidyverse)` untuk mengaktifkan semuanya sekaligus, atau panggil per package (`library(dplyr)`) agar jelas apa yang dipakai pada satu blok kode.

### 3.3 Working directory (folder kerja)

```r
getwd()                # lihat folder kerja saat ini
setwd("/folder/path")  # pindah folder kerja
list.files()           # lihat isi folder
```

**Cara terbaik di RStudio:** buka **File > New Project** di folder proyek, lalu seluruh data dan skrip dapat diakses dengan path relatif.

> **Windows:** jangan gunakan `\` tunggal pada path (`setwd("C:\data")` salah). Gunakan `/` atau `\\` (`setwd("C:/data")`).

---

## 4. Basic R — Dasar-Dasar

### 4.1 Komentar

Komentar dimulai dengan `#` dan tidak dijalankan oleh R.

```r
# Menghitung defect rate
defect <- 5
inspected <- 120
defect_rate <- defect / inspected
defect_rate
```

### 4.2 Operasi aritmetika

| Operator | Arti | Contoh | Hasil |
| --- | --- | --- | --- |
| `+` | Penjumlahan | `2 + 3` | `5` |
| `-` | Pengurangan | `10 - 4` | `6` |
| `*` | Perkalian | `6 * 7` | `42` |
| `/` | Pembagian | `20 / 5` | `4` |
| `^` | Pangkat | `2^3` | `8` |
| `%%` | Sisa bagi | `17 %% 5` | `2` |
| `%/%` | Pembagian bulat | `17 %/% 5` | `3` |

### 4.3 Assignment dan nama objek

Gunakan `<-` untuk menyimpan nilai ke dalam objek:

```r
inspected <- 120
defect <- 5
product_name <- "Bracket"
```

**Aturan penamaan objek:**

- gunakan nama jelas dan deskriptif;
- pisahkan kata dengan garis bawah (`_`);
- R **membedakan huruf besar-kecil** (`value` ≠ `Value`).

```r
value <- 10
Value <- 20
value  # 10
Value  # 20
```

Contoh nama yang baik:

```r
total_inspected <- 1000
average_cycle_time <- 43.5
defect_rate_by_line <- 0.04
```

### 4.4 Tipe data dasar

| Tipe | Contoh | Keterangan |
| --- | --- | --- |
| `numeric` | `12.5` | Angka desimal |
| `integer` | `12L` | Bilangan bulat |
| `character` | `"Bracket"` | Teks |
| `logical` | `TRUE` / `FALSE` | Boolean |
| `NA` | `NA` | Nilai hilang |

```r
number_value <- 12.5
integer_value <- 12L
text_value <- "Bracket"
logical_value <- TRUE
missing_value <- NA
```

Memeriksa tipe data:

```r
class(number_value)
typeof(number_value)
is.numeric(number_value)
is.character(text_value)
is.logical(logical_value)
```

### 4.5 Vector

Vector berisi **beberapa nilai dengan tipe yang sama**:

```r
inspected_values <- c(120, 115, 130, 125)
line_values <- c("A", "A", "B", "B")
pass_values <- c(TRUE, TRUE, FALSE, TRUE)
```

Fungsi dasar vector:

```r
length(inspected_values)  # jumlah elemen
sum(inspected_values)     # jumlah
mean(inspected_values)    # rata-rata
min(inspected_values)     # nilai terkecil
max(inspected_values)     # nilai terbesar
sort(inspected_values)    # urutkan
```

Membuat urutan angka:

```r
1:5                                   # 1 2 3 4 5
seq(from = 0, to = 10, by = 2)        # 0 2 4 6 8 10
rep("A", times = 3)                   # "A" "A" "A"
```

### 4.6 Indexing (pengindeksan)

**Index R dimulai dari 1**, bukan 0:

```r
inspected_values[1]        # elemen pertama
inspected_values[2:3]      # elemen ke-2 sampai ke-3
inspected_values[c(1, 4)]  # elemen ke-1 dan ke-4
inspected_values[-1]       # semua kecuali elemen pertama
```

Indexing berdasarkan kondisi:

```r
inspected_values[inspected_values > 120]   # hanya yang > 120
line_values[line_values == "A"]            # hanya yang "A"
```

### 4.7 Missing value (`NA`)

`NA` berarti nilai hilang. **Jangan** membandingkan dengan `== NA`.

```r
values <- c(10, 20, NA, 40)
is.na(values)              # FALSE FALSE TRUE FALSE
mean(values, na.rm = TRUE) # rata-rata tanpa NA -> 23.33
```

- Salah: `values == NA`
- Benar: `is.na(values)`, dan gunakan `na.rm = TRUE` pada fungsi agregat.

### 4.8 Factor dan tanggal

**Factor** menyimpan data kategori:

```r
line <- factor(c("A", "B", "A", "C"))
levels(line)
```

**Tanggal** sebaiknya dikonversi menjadi tipe `Date`:

```r
inspection_date <- as.Date("2026-07-01")
format(inspection_date, "%d-%m-%Y")
```

Dengan `lubridate`:

```r
ymd("2026-07-01")
year(inspection_date)
month(inspection_date)
week(inspection_date)
```

---

## 5. Fungsi dan Logika Dasar

### 5.1 Fungsi umum

```r
round(4.567, 2)   # 4.57
abs(-10)          # 10
sqrt(16)          # 4

text <- "quality inspection"
nchar(text)       # panjang teks
toupper(text)     # "QUALITY INSPECTION"
tolower(text)     # "quality inspection"
trimws("  Line A  ")  # "Line A"
```

### 5.2 Operator perbandingan dan logika

| Operator | Arti | Contoh |
| --- | --- | --- |
| `>` | lebih besar | `5 > 3` → `TRUE` |
| `<` | lebih kecil | `5 < 3` → `FALSE` |
| `==` | sama dengan | `5 == 5` → `TRUE` |
| `!=` | tidak sama | `5 != 3` → `TRUE` |
| `>=` | lebih besar atau sama | `5 >= 5` → `TRUE` |
| `<=` | lebih kecil atau sama | `5 <= 10` → `TRUE` |

Operator logika:

```r
# AND: kedua kondisi harus benar
5 > 3 & 5 < 10        # TRUE

# OR: salah satu kondisi benar
5 < 3 | 5 < 10        # TRUE

# NOT: membalikkan hasil
!(5 > 3)              # FALSE
```

### 5.3 `if` dan `ifelse`

Untuk satu nilai:

```r
defect_rate <- 0.06

if (defect_rate > 0.05) {
  print("Above target")
} else {
  print("On target")
}
```

Untuk banyak nilai sekaligus:

```r
rates <- c(0.02, 0.06, 0.04)
ifelse(rates > 0.05, "Above target", "On target")
```

### 5.4 Membuat fungsi sendiri

Fungsi membantu menghindari penulisan ulang kode:

```r
calculate_defect_rate <- function(defect, inspected) {
  defect / inspected
}

calculate_defect_rate(5, 120)   # 0.0417
```

Fungsi yang lebih aman (menangani pembagian dengan nol):

```r
calculate_defect_rate_safe <- function(defect, inspected) {
  if (inspected <= 0) {
    return(NA_real_)
  }
  defect / inspected
}

calculate_defect_rate_safe(5, 120)   # 0.0417
calculate_defect_rate_safe(5, 0)     # NA
```

---

## 6. Data Manipulation — Membaca dan Memahami Data

### 6.1 Membuat Data Latihan `quality_inspection` (generate, tanpa CSV)

Data latihan dibuat langsung dengan kode R — tidak memerlukan file eksternal. `InspectionDate` dibuat sebagai deret tanggal sungguhan (`Date`), sehingga langsung siap untuk filter, grouping, dan visualisasi time-series:

```r
library(tidyverse)

set.seed(2026)  # agar data acak selalu sama setiap dijalankan (reproducible)

n_rows <- 90  # 15 hari x 3 lini x 2 shift

quality <- tibble(
  InspectionDate = rep(
    seq(as.Date("2026-07-01"), by = "day", length.out = 15),
    times = 6
  ),
  Line = rep(rep(c("A", "B", "C"), each = 5), times = 6),
  Shift = rep(c("Pagi", "Siang"), times = 45),
  Product = sample(c("Bracket", "Housing", "Cover", "Shaft"), n_rows, replace = TRUE),
  Inspected = sample(80:150, n_rows, replace = TRUE),
  CycleTimeSec = round(rnorm(n_rows, mean = 45, sd = 8)),
  DefectType = sample(
    c("NONE", "SCRATCH", "DENT", "CRACK"),
    n_rows,
    replace = TRUE,
    prob = c(0.55, 0.20, 0.15, 0.10)
  )
) |>
  mutate(
    Defect = pmin(rpois(n_rows, lambda = Inspected * 0.04), Inspected),
    DefectType = case_when(
      Defect == 0 ~ "NONE",
      DefectType == "NONE" ~ "SCRATCH",
      TRUE ~ DefectType
    )
  )
```

Fungsi pembentuk data:

| Fungsi | Kegunaan |
| --- | --- |
| `set.seed(2026)` | mengunci hasil random agar data sama setiap dijalankan |
| `seq(as.Date(...), by = "day", length.out = 15)` | deret 15 tanggal bertipe `Date` |
| `rep()` | mengulang nilai (tanggal, lini, shift) sampai 90 baris |
| `sample()` | memilih nilai acak dari daftar pilihan |
| `rnorm()` | angka acak berdistribusi normal (cycle time) |
| `rpois()` | jumlah defect acak (distribusi Poisson) |
| `pmin()` | batas atas agar `Defect` tidak melebihi `Inspected` |
| `case_when()` | logika multi-kondisi untuk label `DefectType` |

Catatan penting:

- `InspectionDate` sudah bertipe `Date` sejak dibuat — tidak perlu konversi.
- Data generator tidak mengandung `NA`; latihan menangani `NA` pada bab 7 tetap berguna untuk data nyata.
- **Seluruh chart pada bab 14 dirender dari data generator ini** (`set.seed(2026)`), jadi hasil Anda akan persis sama dengan gambar yang ditampilkan.

> Pada pekerjaan nyata data biasanya berasal dari file. Jika tersedia `quality_inspection.csv`, cukup ganti generator di atas dengan:
>
> ```r
> quality <- read.csv("quality_inspection.csv", stringsAsFactors = FALSE)
> ```
>
> `stringsAsFactors = FALSE` membuat kolom teks dibaca sebagai `character`, bukan otomatis menjadi `factor`.

### 6.2 Melihat struktur dan isi data

```r
head(quality)     # 6 baris pertama
tail(quality)     # 6 baris terakhir
str(quality)      # struktur & tipe tiap kolom
summary(quality)  # statistik ringkas tiap kolom
nrow(quality)     # jumlah baris
ncol(quality)     # jumlah kolom
names(quality)    # nama kolom
dim(quality)      # c(nrow, ncol)
```

Kategori unik dan frekuensi:

```r
unique(quality$Line)
table(quality$Line)
table(quality$DefectType)
```

Missing value per kolom:

```r
colSums(is.na(quality))
```

### 6.3 Konversi tipe data

Jika kolom terbaca tidak sesuai:

```r
quality$InspectionDate <- as.Date(quality$InspectionDate)
quality$Inspected <- as.numeric(quality$Inspected)
quality$Defect <- as.numeric(quality$Defect)
quality$CycleTimeSec <- as.numeric(quality$CycleTimeSec)

str(quality)  # periksa kembali
```

**Pertanyaan yang harus dijawab saat eksplorasi:**

1. Apakah jumlah baris sesuai dengan observasi yang diharapkan?
2. Apakah `InspectionDate` sudah bertipe `Date`?
3. Apakah `Inspected`, `Defect`, `CycleTimeSec` bertipe numerik?
4. Apakah ada nilai `NA`?
5. Apa saja kategori di `Line`, `Product`, dan `DefectType`?

---

## 7. Data Manipulation dengan `dplyr`

`dplyr` menyediakan "kata kerja" yang mudah dibaca untuk mengolah data:

| Fungsi | Kegunaan |
| --- | --- |
| `select()` | memilih kolom |
| `filter()` | memilih baris berdasarkan kondisi |
| `mutate()` | membuat atau mengubah kolom |
| `arrange()` | mengurutkan baris |
| `distinct()` | mengambil nilai unik |
| `rename()` | mengganti nama kolom |
| `summarise()` | membuat ringkasan |
| `group_by()` | mengelompokkan sebelum diringkas |
| `count()` | menghitung jumlah baris per kategori |
| `left_join()` | menggabungkan data berdasarkan kunci |

Mulai dengan:

```r
library(dplyr)
```

### 7.1 `select()` — memilih kolom

```r
quality |> select(InspectionDate, Line, Defect, Inspected)
```

Semua kolom kecuali satu:

```r
quality |> select(-Product)
```

Pilih berdasarkan pola nama:

```r
quality |> select(contains("Defect"))
quality |> select(starts_with("Cycle"))
```

### 7.2 `filter()` — memilih baris

```r
quality |> filter(Line == "A")
quality |> filter(Defect > 5)
quality |> filter(Inspected >= 120)
```

Multiple kondisi:

```r
quality |> filter(Line == "A", Defect > 3)
quality |> filter(Line %in% c("A", "B"))
quality |> filter(DefectType != "NONE")
```

Filter berdasarkan tanggal:

```r
quality |> filter(InspectionDate >= as.Date("2026-07-15"))
```

### 7.3 `mutate()` — membuat kolom baru

```r
quality_clean <- quality |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate
  )
```

Tambahkan label kualitas:

```r
quality_clean <- quality_clean |>
  mutate(
    QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
  )
```

Tambahkan kolom bulan:

```r
quality_clean <- quality_clean |>
  mutate(
    Month = floor_date(InspectionDate, unit = "month")
  )
```

> `floor_date()` berasal dari `lubridate` dan mengubah tanggal menjadi awal bulan.

### 7.4 `arrange()` — mengurutkan

```r
quality_clean |> arrange(DefectRate)            # naik
quality_clean |> arrange(desc(DefectRate))      # turun
quality_clean |> arrange(Line, desc(DefectRate))# multi-level
```

### 7.5 `distinct()` — nilai unik

```r
quality |> distinct(Line)
quality |> distinct(Line, Product)
```

### 7.6 `rename()` — mengganti nama kolom

```r
quality_clean |>
  rename(
    Date = InspectionDate,
    LineName = Line
  )
```

### 7.7 `count()` — menghitung kategori

```r
quality |> count(Line)
quality |> count(DefectType, sort = TRUE)
quality |> count(Line, DefectType, sort = TRUE)
```
### 7.8 `summarise()` — statistik ringkas

```r
quality_clean |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    OverallDefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec)
  )
```

Jika ada nilai hilang, gunakan `na.rm = TRUE`:

```r
quality_clean |>
  summarise(
    AverageCycleTime = mean(CycleTimeSec, na.rm = TRUE),
    MaximumCycleTime = max(CycleTimeSec, na.rm = TRUE)
  )
```

### 7.9 `group_by()` — ringkasan per kelompok

> **Penting:** defect rate agregat yang benar adalah **total defect ÷ total inspected**, bukan rata-rata defect rate per baris.

```r
summary_by_line <- quality_clean |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    DefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))

summary_by_line
```

Ringkasan per jenis defect:

```r
summary_by_defect <- quality_clean |>
  group_by(DefectType) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))
```

### 7.10 Pipeline dengan pipe `|>`

Pipe `|>` meneruskan hasil dari kiri ke fungsi di kanan, sehingga kode mudah dibaca urut:

```r
quality |>
  filter(Line == "A") |>
  mutate(DefectRate = Defect / Inspected) |>
  select(InspectionDate, Line, DefectRate) |>
  arrange(desc(DefectRate))
```

Cara membacanya:

1. ambil `quality`;
2. pilih lini A;
3. buat kolom `DefectRate`;
4. pilih tiga kolom;
5. urutkan dari rate terbesar.

### 7.11 Cleaning lengkap dengan `dplyr`

Contoh alur cleaning reproducible dari data mentah → data bersih:

```r
library(dplyr)
library(lubridate)

quality_clean <- quality |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    Product = trimws(Product),
    DefectType = trimws(DefectType),
    DefectType = if_else(
      is.na(DefectType) | DefectType == "",
      "NONE",
      DefectType
    ),
    Inspected = as.numeric(Inspected),
    Defect = as.numeric(Defect),
    CycleTimeSec = as.numeric(CycleTimeSec)
  ) |>
  filter(
    !is.na(InspectionDate),
    !is.na(Inspected),
    Inspected > 0,
    !is.na(Defect),
    Defect >= 0,
    Defect <= Inspected
  ) |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, unit = "month"),
    QualityFlag = if_else(DefectRate > 0.05, "Above target", "On target")
  )
```

**Validasi hasil cleaning:**

```r
nrow(quality_clean)
summary(quality_clean$DefectRate)

any(quality_clean$Inspected <= 0)          # harus FALSE
any(quality_clean$Defect > quality_clean$Inspected)  # harus FALSE
any(quality_clean$DefectRate < 0 | quality_clean$DefectRate > 1) # FALSE
```

Jika seluruh `any()` bernilai `FALSE`, data sudah valid.

### 7.12 Ringkasan langkah data manipulation yang baik

1. **Membaca** data (CSV/Excel).
2. **Memahami** struktur (str, summary, head).
3. **Memperbaiki tipe** (Date, numeric, factor).
4. **Menstandarkan teks** (trimws, toupper, rename).
5. **Membuat metrik turunan** (mutate).
6. **Menghapus baris tidak valid** (filter).
7. **Mengelompokkan & meringkas** (group_by + summarise).
8. **Menyimpan hasil** (write.csv).

---

## 8. Reshaping Data dengan `tidyr`

`tidyr` adalah bagian dari `tidyverse` (tidak perlu instalasi terpisah). Fungsinya mengubah **bentuk** tabel tanpa mengubah isinya — keterampilan penting sebelum data dipakai untuk agregasi atau visualisasi.

| Bentuk | Ciri | Kapan dipakai |
| --- | --- | --- |
| Wide (lebar) | satu baris berisi banyak kolom pengukuran | laporan siap dibaca manusia |
| Long (panjang) | satu baris = satu pengamatan | agregasi, visualisasi, pemodelan |

### 8.1 `pivot_longer()` — lebar ke panjang

Contoh: hasil inspeksi harian yang mencatat dua jenis pengukuran dalam kolom terpisah.

```r
library(dplyr)
library(tidyr)

daily_wide <- quality_clean |>
  group_by(InspectionDate) |>
  summarise(
    Inspected = sum(Inspected),
    Defect = sum(Defect),
    .groups = "drop"
  )

daily_long <- daily_wide |>
  pivot_longer(
    cols = c(Inspected, Defect),
    names_to = "Metric",
    values_to = "Value"
  )

head(daily_long)
```

Dua kolom pengukuran menjadi satu kolom `Metric` + satu kolom `Value`, sehingga jumlah baris menjadi dua kali lipat.

### 8.2 `pivot_wider()` — panjang ke lebar

Kebalikannya: dari data panjang menjadi matriks ringkas per kategori.

```r
library(dplyr)
library(tidyr)

defect_wide <- quality_clean |>
  count(Line, DefectType) |>
  pivot_wider(
    names_from = DefectType,
    values_from = n,
    values_fill = 0
  )

defect_wide
```

`values_fill = 0` penting: kombinasi kategori yang tidak muncul diisi `0`, bukan `NA`.

### 8.3 Menangani `NA` setelah reshaping

```r
library(dplyr)
library(tidyr)

quality |>
  drop_na(Defect, Inspected) |>
  replace_na(list(DefectType = "NONE")) |>
  mutate(Defect = coalesce(Defect, 0)) |>
  nrow()
```

| Fungsi | Kegunaan |
| --- | --- |
| `drop_na()` | membuang baris yang memiliki `NA` |
| `replace_na()` | mengisi `NA` dengan nilai tertentu |
| `coalesce()` | mengambil nilai pertama yang tidak `NA` dari beberapa kolom |

> Data generator di section 6.1 sengaja dibuat tanpa `NA`, sehingga `drop_na()` tidak mengubah jumlah baris. Contoh ini berguna untuk data nyata.

### 8.4 Ringkasan `tidyr`

1. Tentukan dulu bentuk akhir yang dibutuhkan analisis.
2. `pivot_longer()` untuk menyatukan banyak kolom pengukuran.
3. `pivot_wider()` untuk membuat tabel ringkas per kategori.
4. Selalu tentukan `values_fill` saat reshape ke bentuk lebar.
5. Simpan hasil dengan `write.csv()` bila akan dipakai ulang.

---

## 9. Menggabungkan Data (Joins)

Data nyata biasanya terpecah ke beberapa tabel (transaksi, master produk, target). Join menyatukannya kembali berdasarkan kolom kunci (key).

### 9.1 Konsep join

| Jenis | Baris yang dipertahankan |
| --- | --- |
| `left_join()` | semua baris tabel kiri |
| `inner_join()` | hanya baris yang cocok di kedua tabel |
| `full_join()` | semua baris dari kedua tabel |
| `anti_join()` | baris tabel kiri yang **tidak** punya pasangan |

### 9.2 `left_join()` — menambah atribut

Contoh: menambahkan target defect rate per lini.

```r
library(dplyr)

line_target <- tibble(
  Line = c("A", "B", "C"),
  TargetDefectRate = c(0.04, 0.05, 0.03)
)

summary_with_target <- summary_by_line |>
  left_join(line_target, by = "Line") |>
  mutate(OnTarget = DefectRate <= TargetDefectRate)

summary_with_target
```

### 9.3 `inner_join()` untuk menyaring, `full_join()` untuk menemukan gap

```r
library(dplyr)

# hanya lini yang punya target
summary_by_line |> inner_join(line_target, by = "Line")

# semua lini; target yang tidak terpakai tetap muncul
summary_by_line |> full_join(line_target, by = "Line")
```

### 9.4 `anti_join()` — audit kualitas relasi

`anti_join()` menjawab pertanyaan: "data mana yang tidak punya pasangan?"

```r
library(dplyr)

# lini pada data yang tidak ada di tabel target
summary_by_line |>
  anti_join(line_target, by = "Line") |>
  distinct(Line)

# target yang tidak terpakai
line_target |>
  anti_join(summary_by_line, by = "Line") |>
  distinct(Line)
```

Jika hasilnya `0 baris`, key sudah lengkap di kedua sisi.

### 9.5 Bandingkan dengan `merge()` base R

```r
merge(summary_by_line, line_target, by = "Line", all.x = TRUE)   # = left_join
merge(summary_by_line, line_target, by = "Line", all = TRUE)     # = full_join
```

`merge()` masih valid, tetapi `dplyr` lebih mudah dibaca dalam pipeline dan tidak mengubah urutan baris secara tak terduga.

> Pola inilah yang dipakai pada pipeline project: tabel agregasi demand digabung dengan tabel skenario What-If.

---

## 10. Tanggal dan Waktu dengan `lubridate`

Hampir semua analisis demand berbasis waktu, sehingga penanganan tanggal harus konsisten. `lubridate` menyediakan fungsi yang lebih aman dibanding manipulasi teks tanggal.

### 10.1 Membaca tanggal (parsing)

```r
library(lubridate)

ymd("2026-07-15")        # tahun-bulan-hari
dmy("15/07/2026")        # hari-bulan-tahun
mdy("07-15-2026")        # bulan-hari-tahun

as.Date("2026-07-15")
```

Gunakan fungsi `*ymd()` sesuai urutan komponen tanggal pada sumber data.

### 10.2 Mengambil komponen tanggal

```r
library(lubridate)

tanggal <- as.Date("2026-07-15")

year(tanggal)                 # 2026
month(tanggal)                # 7
month(tanggal, label = TRUE)  # Jul
quarter(tanggal)              # 3
wday(tanggal, label = TRUE)   # Rab
```

### 10.3 Aritmetika bulan dan pembulatan periode

```r
library(lubridate)

tanggal <- as.Date("2026-07-15")

tanggal %m+% months(1)                     # 2026-08-15
floor_date(tanggal, unit = "month")        # 2026-07-01
ceiling_date(tanggal, unit = "month") - 1  # hari terakhir bulan
```

> Gunakan `%m+%` untuk menambah bulan. Operator `+ months(1)` dapat menghasilkan tanggal tidak valid (misal 31 Februari menjadi `NA`).

### 10.4 Membuat label bulan yang bisa diurutkan

```r
library(lubridate)

# label singkat (Jan, Feb, ...)
month(quality_clean$InspectionDate, label = TRUE, abbr = TRUE)

# label aman untuk sumbu: YYYY-MM
sprintf(
  "%04d-%02d",
  year(quality_clean$InspectionDate),
  month(quality_clean$InspectionDate)
)[1:5]
```

> Hindari memakai nama bulan saja (`Jul`) sebagai sumbu tanpa tahun: urutan Januari–Desember dapat tercampur antar tahun. Gunakan `YYYY-MM` atau simpan tanggal penuh.

### 10.5 Pola harian → bulanan

```r
library(dplyr)
library(lubridate)

monthly <- quality_clean |>
  mutate(Month = floor_date(InspectionDate, unit = "month")) |>
  group_by(Month) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  ) |>
  arrange(Month)

monthly
```

Pola ini sama dengan agregasi demand pada [README project](README.md): siapkan kolom tanggal bulanan, lalu `group_by()` + `summarise()`.

---

## 11. String dan Label dengan `stringr`

`stringr` (bagian `tidyverse`) membuat pengolahan teks lebih konsisten: semua fungsi diawali `str_`, sehingga mudah diingat dan diprediksi.

### 11.1 Inspeksi dan transformasi teks

```r
library(stringr)

teks <- c("Line A", "line b ", "LINE C", "Line  D")

str_to_upper(teks)          # LINE A, LINE B, LINE C, LINE D
str_to_lower(teks)
str_to_title(teks)          # Line A, Line B, Line C, Line D
str_trim(teks)              # hapus spasi di ujung
str_squish(teks)            # rapikan spasi berlebih
```

### 11.2 Mencari, mengambil, dan mengganti

```r
library(stringr)

str_detect(teks, "LINE")           # TRUE/FALSE
str_starts(teks, "Line")
str_replace(teks, "Line", "Lini")  # ganti kemunculan pertama
str_sub(teks, 1, 4)                # ambil 4 karakter pertama
```

| Fungsi | Kegunaan |
| --- | --- |
| `str_detect()` | memfilter baris berdasarkan pola |
| `str_replace()` / `str_replace_all()` | menyeragamkan label kategori |
| `str_extract()` | mengambil bagian teks sesuai pola |
| `str_split()` | memecah teks menjadi beberapa bagian |

### 11.3 Menyusun label gabungan

```r
library(dplyr)
library(stringr)

quality_clean |>
  mutate(
    LineLabel = str_squish(paste("Lini", Line)),
    ProductLabel = paste0(Product, " - ", Line)
  ) |>
  select(Line, Product, LineLabel, ProductLabel) |>
  head(5)
```

`sprintf()` untuk menyisipkan angka berformat ke dalam label:

```r
sprintf(
  "%s: %.1f%% defect rate",
  summary_by_line$Line,
  summary_by_line$DefectRate * 100
)
```

> `paste0()` merekatkan tanpa pemisah, `paste()` memakai spasi sebagai pemisah default, dan `sprintf()` paling tepat saat angka harus berformat tertentu.

### 11.4 Ringkasan `stringr`

1. Gunakan `str_trim()` / `str_squish()` sebelum membandingkan kategori.
2. Gunakan `str_to_upper()` / `str_to_title()` agar kategori konsisten.
3. Gunakan `str_detect()` untuk filter berbasis pola, bukan `==` pada teks panjang.
4. Gunakan `paste()` / `paste0()` / `sprintf()` untuk label yang dibaca manusia.

---

## 12. Memformat Angka dengan `scales`

Angka mentah sulit dibaca di laporan (`0.0432`, `1250000`). Package `scales` mengubahnya menjadi format siap presentasi, dan langsung terhubung ke sumbu `ggplot2`.

### 12.1 Fungsi format utama

```r
library(scales)

percent(0.0432)                   # "4.32%"
percent(0.0432, accuracy = 0.1)   # "4.3%"
comma(1250000)                    # "1,250,000"
number(1250000, big.mark = ".", decimal.mark = ",")   # "1.250.000"
dollar(1250000)                   # "$1,250,000"
unit_format(unit = "k", scale = 1e-3)(1250000)
```

### 12.2 Menerapkan pada sumbu `ggplot2`

```r
library(ggplot2)
library(scales)

ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate")
```

Varian label sumbu yang paling sering dipakai:

| Kebutuhan sumbu | Fungsi label |
| --- | --- |
| persentase | `percent_format(accuracy = 0.1)` |
| ribuan | `comma_format()` |
| satuan (k, juta) | `unit_format(unit = "k", scale = 1e-3)` |
| mata uang | `dollar_format()` |

### 12.3 Format di dalam kolom teks

```r
library(dplyr)
library(scales)

summary_by_line |>
  mutate(Label = percent(DefectRate, accuracy = 0.01)) |>
  select(Line, DefectRate, Label)
```

> Pilih satu format dan pakai konsisten di seluruh dashboard. Persentase satu angka desimal biasanya lebih jelas dibaca daripada empat angka desimal.

---

## 13. Validasi Data (Data Quality Checks)

Sebelum angka dipakai untuk keputusan, pastikan datanya sehat. Bab ini berisi pemeriksaan cepat yang selalu dijalankan seorang analyst.

### 13.1 Cek ukuran dan kelengkapan

```r
library(dplyr)

nrow(quality)                 # jumlah baris
ncol(quality)                 # jumlah kolom
colSums(is.na(quality))       # jumlah NA per kolom
sum(is.na(quality$Defect))    # NA pada kolom kunci
```

### 13.2 Cek duplikat

```r
library(dplyr)

quality |>
  count(InspectionDate, Line, Shift) |>
  filter(n > 1)          # kombinasi kunci yang muncul lebih dari sekali

quality |> duplicated() |> sum()
```

### 13.3 Cek keseimbangan kelompok

```r
library(dplyr)

quality |> count(Line)          # apakah jumlah baris per lini seimbang?
quality |> count(Shift)
quality |> count(Line, Shift)
```

Jumlah yang tidak seimbang bukan selalu error, tetapi harus punya penjelasan.

### 13.4 Cek konsistensi nilai dan kunci

```r
library(dplyr)

summary(quality_clean$DefectRate)                      # rentang wajar?

quality_clean |> filter(Defect > Inspected) |> nrow()  # harus 0
quality_clean |> filter(Inspected <= 0) |> nrow()      # harus 0

# kesamaan kunci antar tabel
setequal(unique(summary_by_line$Line), unique(line_target$Line))
```

### 13.5 Checklist audit singkat

| Pemeriksaan | Fungsi | Hasil yang diharapkan |
| --- | --- | --- |
| jumlah baris | `nrow()` | sesuai ekspektasi periode x kategori |
| NA | `colSums(is.na())` | 0 pada kolom kunci |
| duplikat | `count()` + `filter(n > 1)` | 0 baris |
| keseimbangan grup | `count()` | seimbang atau dapat dijelaskan |
| rentang nilai | `summary()` / `filter()` | tidak ada nilai mustahil |
| kunci relasi | `setequal()` / `anti_join()` | 0 baris tanpa pasangan |

> Jalankan pemeriksaan ini setiap kali data baru masuk, bukan hanya di awal project.

---

## 14. Data Visualization dengan `ggplot2`

### 14.1 Struktur dasar (layer)

`ggplot2` membangun grafik dengan menambahkan lapisan (layer) menggunakan `+`:

```r
library(ggplot2)

ggplot(data = quality_clean, aes(x = Line, y = DefectRate)) +
  geom_col()
```

Hasil chart:

![Struktur dasar ggplot2](images/basicr/01_basic_bar.png)

Anatomi:

- `data` → data frame yang dipakai;
- `aes()` → hubungan kolom dengan sumbu (`x`, `y`), warna, bentuk;
- `geom_*()` → bentuk visual (bar, titik, garis, kotak).

### 14.2 Bar chart (defect rate per lini)

```r
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Defect rate per lini",
    x = "Lini",
    y = "Defect rate"
  )
```

Format sumbu Y sebagai persentase:

```r
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate")
```

Hasil chart:

![Bar chart dengan format persentase](images/basicr/02_bar_percent.png)

### 14.3 Line chart (tren per tanggal)

```r
trend_by_date <- quality_clean |>
  group_by(InspectionDate) |>
  summarise(
    TotalDefect = sum(Defect),
    TotalInspected = sum(Inspected),
    DefectRate = TotalDefect / TotalInspected,
    .groups = "drop"
  )

ggplot(trend_by_date, aes(x = InspectionDate, y = DefectRate)) +
  geom_line(color = "firebrick", linewidth = 1) +
  geom_point(color = "firebrick") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Tren defect rate", x = "Tanggal", y = "Defect rate")
```

Hasil chart:

![Line chart tren defect rate](images/basicr/03_line_trend.png)

### 14.4 Scatter plot (hubungan dua variabel numerik)

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate, color = Line)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Hubungan cycle time dan defect rate",
    x = "Cycle time (detik)",
    y = "Defect rate"
  )
```

Hasil chart:

![Scatter plot berwarna per lini](images/basicr/04_scatter_color.png)

Tambahkan garis kecenderungan:

```r
ggplot(quality_clean, aes(x = CycleTimeSec, y = DefectRate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Kecenderungan cycle time dan defect rate")
```

Hasil chart:

![Scatter plot dengan garis kecenderungan](images/basicr/05_scatter_smooth.png)

### 14.5 Boxplot (sebaran per kelompok)

```r
ggplot(quality_clean, aes(x = Line, y = CycleTimeSec, fill = Line)) +
  geom_boxplot() +
  labs(
    title = "Sebaran cycle time per lini",
    x = "Lini",
    y = "Cycle time (detik)"
  ) +
  theme_minimal()
```

Hasil chart:

![Boxplot cycle time per lini](images/basicr/06_boxplot.png)

**Cara membaca boxplot:**

- garis tengah = **median**;
- kotak = **kuartil 1 sampai kuartil 3** (IQR);
- titik di luar whisker = kandidat **outlier**;
- kotak yang lebih tinggi = variasi lebih besar.

### 14.6 Grafik multi-variabel & formatting

**Grafik multi-variabel** menyampaikan lebih dari dua dimensi data. Kuncinya: petakan setiap variabel ke satu estetika visual (warna, ukuran, bentuk).

Warna per lini + ukuran per volume:

```r
library(ggplot2)
library(scales)

ggplot(quality_clean, aes(x = InspectionDate, y = DefectRate, color = Line)) +
  geom_point(aes(size = Inspected), alpha = 0.75) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 0.8) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(
    title = "Pola defect rate menurut waktu",
    x = "Tanggal inspeksi", y = "Defect rate",
    color = "Lini", size = "Unit diperiksa"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

Hasil chart:

![Grafik multi-variabel warna dan ukuran](images/basicr/07_multi_variable.png)

Facet (multi-panel) untuk banyak lini:

```r
ggplot(quality_clean, aes(x = InspectionDate, y = DefectRate)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ Line) +
  theme_minimal()
```

Hasil chart:

![Facet multi-panel per lini](images/basicr/08_facet.png)

### 14.7 Heatmap (`geom_tile()`)

Heatmap menampilkan nilai pada kombinasi dua kategori (misal tanggal x lini) menggunakan intensitas warna:

```r
library(dplyr)
library(ggplot2)
library(scales)

heat_data <- quality_clean |>
  group_by(InspectionDate, Line) |>
  summarise(
    DefectRate = sum(Defect) / sum(Inspected),
    .groups = "drop"
  )

ggplot(heat_data, aes(x = InspectionDate, y = Line, fill = DefectRate)) +
  geom_tile(color = "white", linewidth = 0.8) +
  scale_fill_gradient(
    low = "#16B8A6",
    high = "#F26B5E",
    labels = percent_format(accuracy = 1)
  ) +
  labs(
    title = "Heatmap defect rate per lini",
    subtitle = "Warna lebih merah = defect rate lebih tinggi",
    x = "Tanggal inspeksi",
    y = "Lini",
    fill = "Defect rate"
  ) +
  theme_minimal(base_size = 11) +
  theme(panel.grid = element_blank())
```

Hasil chart:

![Heatmap defect rate per lini](images/basicr/09_heatmap.png)

Cara membaca:

- satu kotak = satu kombinasi tanggal dan lini;
- `panel.grid = element_blank()` menghapus grid agar warna terbaca jelas;
- `scale_fill_gradient()` mengatur dua warna ujung (rendah → tinggi);
- tambahkan `geom_text()` bila nilai ingin ditulis di dalam kotak.

### 14.8 Stacked bar (komposisi)

Stacked bar menunjukkan komposisi kategori di dalam setiap kelompok:

```r
library(dplyr)
library(ggplot2)

defect_mix <- quality_clean |>
  filter(Defect > 0) |>
  count(Line, DefectType)

ggplot(defect_mix, aes(x = Line, y = n, fill = DefectType)) +
  geom_col(width = 0.72) +
  scale_fill_manual(
    values = c(
      "SCRATCH" = "#2E7CF6",
      "DENT" = "#8B5CF6",
      "CRACK" = "#F26B5E"
    )
  ) +
  labs(
    title = "Komposisi jenis defect per lini",
    subtitle = "Hanya baris dengan defect > 0",
    x = "Lini",
    y = "Jumlah kasus",
    fill = "Jenis defect"
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

Hasil chart:

![Stacked bar komposisi jenis defect](images/basicr/10_stacked_bar.png)

Variasi bobot proporsional (setiap tumpukan 100%):

```r
library(ggplot2)
library(scales)

ggplot(defect_mix, aes(x = Line, y = n, fill = DefectType)) +
  geom_col(position = "fill", width = 0.72) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(title = "Proporsi jenis defect per lini", y = "Proporsi")
```

`position = "fill"` membuat proporsi antar lini mudah dibandingkan, sementara `position = "dodge"` memisahkan setiap batang untuk perbandingan nilai absolut.

### 14.9 Combo chart bar + line (dua sumbu)

Combo chart memadukan volume (bar) dengan rasio (garis). Karena satuannya berbeda, gunakan `sec_axis()`:

```r
library(dplyr)
library(ggplot2)
library(scales)

daily <- quality_clean |>
  group_by(InspectionDate) |>
  summarise(
    TotalDefect = sum(Defect),
    DefectRate = sum(Defect) / sum(Inspected),
    .groups = "drop"
  )

scale_factor <- max(daily$TotalDefect) / max(daily$DefectRate)

ggplot(daily, aes(x = InspectionDate)) +
  geom_col(aes(y = TotalDefect), fill = "#253B6E", alpha = 0.85, width = 0.6) +
  geom_line(
    aes(y = DefectRate * scale_factor, color = "Defect rate"),
    linewidth = 1.1
  ) +
  geom_point(
    aes(y = DefectRate * scale_factor, color = "Defect rate"),
    size = 2.5
  ) +
  scale_y_continuous(
    name = "Total defect (unit)",
    sec.axis = sec_axis(
      ~ . / scale_factor,
      name = "Defect rate",
      labels = percent_format(accuracy = 0.1)
    )
  ) +
  scale_color_manual(values = c("Defect rate" = "#F26B5E")) +
  labs(
    title = "Total defect dan defect rate harian",
    subtitle = "Bar = jumlah unit cacat, garis = defect rate (sumbu kanan)",
    x = "Tanggal inspeksi",
    color = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
```

Hasil chart:

![Combo chart total defect dan defect rate](images/basicr/11_combo_barline.png)

Catatan penting:

- `sec.axis` hanya menampilkan skala kedua, bukan menambah data baru;
- nilai garis dikalikan `scale_factor` agar sejajar dengan bar, lalu dibagi kembali saat diberi label;
- hindari dua sumbu bila kedua seri sebenarnya memakai satuan yang sama — satu sumbu sudah cukup.

### 14.10 Labels, theme, dan simpan grafik

```r
labs(
  title = "Judul",
  subtitle = "Subjudul",
  x = "Sumbu X",
  y = "Sumbu Y",
  color = "Judul legend"
)
```

Theme:

```r
theme_minimal()
theme_minimal(base_size = 11)
theme(legend.position = "bottom")
```

Simpan grafik:

```r
quality_plot <- ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col()

ggsave(
  filename = "defect_rate_by_line.png",
  plot = quality_plot,
  width = 8,
  height = 5,
  dpi = 300
)
```

### 14.11 Prinsip visualisasi yang efektif

| # | Prinsip | Cara |
| --- | --- | --- |
| 1 | Judul berbentuk pertanyaan | "Lini mana yang paling perlu investigasi?" |
| 2 | Sumbu berlabel jelas | x = "Tanggal", y = "Defect rate (%)" |
| 3 | Bar chart mulai dari nol | perbandingan proporsional jujur |
| 4 | Warna bermakna | warna = kategori penting, bukan pelangi |
| 5 | Batasi volume informasi | agregat + label, bukan 10.000 titik tanpa makna |
| 6 | Ambang/target jelas | garis dashed pada target 5% |
| 7 | Legenda jelas | label per lini dengan bahasa bisnis |
| 8 | Grafik menjawab pertanyaan | satu grafik → minimal satu pertanyaan |

---

## 15. Contoh Alur Lengkap (Basic R + Manipulasi + Visualisasi)

```r
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)

# 1. Data latihan — dibuat dengan generator di section 6.1
#    (objek `quality` sudah tersedia di environment)

# 2. Cleaning + metrik
quality_clean <- quality |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    Line = trimws(toupper(Line)),
    DefectType = if_else(DefectType == "", "NONE", DefectType),
    Inspected = as.numeric(Inspected),
    Defect = as.numeric(Defect),
    CycleTimeSec = as.numeric(CycleTimeSec)
  ) |>
  filter(Inspected > 0, Defect >= 0, Defect <= Inspected) |>
  mutate(
    DefectRate = Defect / Inspected,
    FirstPassYield = 1 - DefectRate,
    Month = floor_date(InspectionDate, "month")
  )

# 3. Ringkasan per lini
summary_by_line <- quality_clean |>
  group_by(Line) |>
  summarise(
    TotalInspected = sum(Inspected),
    TotalDefect = sum(Defect),
    DefectRate = TotalDefect / TotalInspected,
    AverageCycleTime = mean(CycleTimeSec),
    .groups = "drop"
  ) |>
  arrange(desc(DefectRate))

# 4. Grafik
ggplot(summary_by_line, aes(x = Line, y = DefectRate)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(title = "Defect rate per lini", x = "Lini", y = "Defect rate") +
  theme_minimal()

# 5. Ekspor
write.csv(quality_clean, "quality_inspection_clean.csv", row.names = FALSE)
write.csv(summary_by_line, "quality_summary_by_line.csv", row.names = FALSE)
ggsave("defect_rate_by_line.png", width = 8, height = 5, dpi = 300)
```

---

## 16. Export Hasil Analisis

| Data/Luaran | Fungsi |
| --- | --- |
| Data bersih | `write.csv(quality_clean, "quality_inspection_clean.csv", row.names = FALSE)` |
| Ringkasan | `write.csv(summary_by_line, "quality_summary_by_line.csv", row.names = FALSE)` |
| Grafik | `ggsave("defect_rate_by_line.png", width = 8, height = 5, dpi = 300)` |

---

## 17. Kesalahan Umum dan Solusinya

| Kesalahan | Solusi |
| --- | --- |
| File tidak ditemukan | `getwd()` + `list.files()`; periksa path dan nama |
| Kolom terbaca sebagai character | `quality$Defect <- as.numeric(quality$Defect)` |
| `object not found` | Cek penulisan dan apakah objek dibuat: `names(quality)` |
| `could not find function` | Panggil package: `library(dplyr)`, `library(ggplot2)` |
| Hasil `mean()` menjadi `NA` | Gunakan `mean(x, na.rm = TRUE)` |
| Grafik kosong/error | Cek `str()` dan `names()`; tipe data kolom |
| RStudio masih menyimpan hasil lama | Jalankan ulang dari atas, atau `rm(list = ls())` |

> `rm(list = ls())` menghapus semua objek Environment — gunakan dengan hati-hati.

---

## 18. Latihan Mandiri

### Level 1 — Basic R

1. Buat vektor 5 angka, hitung `mean`, `sum`, `min`, `max`.
2. Buat vektor lini, tampilkan elemen 2 sampai 4 (`[2:4]`).
3. Gunakan `ifelse` untuk menandai nilai di atas ambang.

### Level 2 — Data Manipulation

5. Buat kolom `DefectRate` dan `QualityFlag` (ambang 5%).
6. Filter data dengan `Defect > 5`.
7. Hitung total inspected dan total defect per lini.
8. Urutkan lini dari defect rate terbesar.

### Level 3 — Visualisasi

9. Buat bar chart defect rate per lini.
10. Buat line chart defect rate per tanggal.
11. Buat boxplot cycle time per lini.
12. Buat scatter plot cycle time vs defect rate + garis regresi.
13. Tambahkan judul, label sumbu, format persentase, simpan PNG.

### Level 4 — Reshaping, Joins, dan Validasi

14. Ubah `summary_by_line` menjadi bentuk panjang dengan `pivot_longer()`.
15. Buat tabel ringkas jumlah `DefectType` per lini dengan `pivot_wider()` dan `values_fill = 0`.
16. Tambahkan target per lini dengan `left_join()`, lalu tandai `OnTarget` menggunakan `mutate()`.
17. Temukan lini yang tidak memiliki target menggunakan `anti_join()`.
18. Hitung defect rate bulanan dengan `floor_date()` + `group_by()` + `summarise()`.
19. Jalankan checklist validasi bab 13 pada data Anda dan tuliskan temuannya.

---

## 19. Checklist Penyelesaian R Basics

- [ ] R dan RStudio terpasang.
- [ ] Package `tidyverse`, `lubridate`, dan `scales` terpasang.
- [ ] Data latihan digenerate (section 6.1) dan tipe data diperiksa.
- [ ] Missing values diperiksa (`colSums(is.na())`).
- [ ] Data invalid difilter.
- [ ] Kolom `DefectRate` dibuat.
- [ ] Ringkasan per kelompok dibuat (group_by + summarise).
- [ ] Data diubah bentuk dengan `pivot_longer()` / `pivot_wider()`.
- [ ] Tabel digabungkan dengan `left_join()` dan relasi diaudit dengan `anti_join()`.
- [ ] Kolom tanggal diolah dengan `floor_date()` / `month()`.
- [ ] Label dan angka diformat dengan `stringr` dan `scales`.
- [ ] Checklist validasi data (bab 13) dijalankan tanpa temuan kritis.
- [ ] Minimal 4 jenis grafik dibuat.
- [ ] Minimal 1 grafik multi-variabel dibuat.
- [ ] Minimal 1 heatmap atau stacked bar dibuat.
- [ ] Data bersih dan grafik diekspor ke file.

---

## 20. Keterkaitan dengan Volume Lain

| Volume | Fokus | Prasyarat dari R Basics |
| --- | --- | --- |
| **R Basics (ini)** | Basic R · Data Manipulation · Visualisasi | — |
| Main project | [README project](README.md) |

---

## 21. Tips & Trik R Basics

### 21.1 Kebiasaan kerja yang membuat belajar R cepat

1. **Mulai kecil**: jalankan satu baris → baca hasil → lanjut. Jangan jalankan seluruh skrip sebelum memahami tiap blok.
2. **Gunakan project RStudio**: `File > New Project` di folder materi. Semua path menjadi relatif dan aman.
3. **Beri nama objek seperti cerita**: `defect_rate_by_line` lebih baik daripada `dr`.
4. **Tulis komentar dulu, kode kemudian**: tulis apa yang ingin dilakukan, lalu isi dengan kode.
5. **Cek data sebelum analisis**: `head()`, `str()`, `summary()`, `nrow()` adalah ritual wajib.
6. **Ulangi skrip dari atas** bila ragu; environment bisa "basi" karena objek lama tertinggal.
7. **Rapi dan konsisten**: satu operasi per baris pipa, nama kolom penggaris bawah `_`.

### 21.2 Pola sintaks yang paling sering dipakai

```r
# Pola 1: data latihan -> bersihkan -> metrik
clean <- quality |>
  mutate(
    InspectionDate = as.Date(InspectionDate),
    DefectRate = Defect / Inspected
  ) |>
  filter(Inspected > 0, Defect >= 0, Defect <= Inspected)

# Pola 2: ringkas per kelompok
ringkasan <- clean |>
  group_by(Line) |>
  summarise(
    n = n(),
    total_defect = sum(Defect),
    defect_rate = total_defect / sum(Inspected),
    .groups = "drop"
  )

# Pola 3: visualkan hasil
ggplot(ringkasan, aes(x = Line, y = defect_rate)) +
  geom_col() +
  scale_y_continuous(labels = percent_format())
```

### 21.3 "Cheat mental" menghafal fungsi

| Jika ingin... | Ingat... |
| --- | --- |
| Pilih kolom | `select()` |
| Pilih baris | `filter()` |
| Buat kolom | `mutate()` |
| Urutkan | `arrange(desc())` |
| Ringkas per grup | `group_by()` → `summarise()` |
| Gabung data | `left_join()` |
| Plot bar/garis/titik | `geom_col()` / `geom_line()` / `geom_point()` |
| Persentase di sumbu | `percent_format()` (dari `scales`) |
| Simpan grafik | `ggsave()` |

> Trik ingatan: **S–F–M–A–G** = `select` → `filter` → `mutate` → `arrange` → `group/summarise`.

### 21.4 Tips teknis RStudio

- `Cmd/Ctrl + Shift + M` untuk mengetik pipe (`%>%` atau `|>`).
- `Alt + -` (Option + minus) untuk `<-`.
- `Cmd/Ctrl + Shift + C` untuk komentar cepat pada blok.
- `Tab` setelah `df$` → autocomplete nama kolom.
- Klik nama data frame di **Environment** = `View()`.
- `str(df)` lebih cepat daripada `View()` untuk memahami struktur besar.

---

## 22. Bank Latihan Tambahan (Exercise Bank) — R Basics

### 22.1 Soal Essai / Latihan Terbuka

**A. Basic R**
1. Buat objek `total_inspected <- 5000` dan `total_defect <- 320`. Hitung `defect_rate`.
2. Buat vektor `cycle <- c(38, 42, 45, 41, 39)` lalu hitung `mean`, `sd`, `min`, `max`.
3. Tampilkan elemen ke-2 sampai ke-4 dari vektor `line <- c("A","B","C","D","E")`.
4. Gunakan `ifelse()` untuk membuat label `"Above"` jika `DefectRate > 0.05`, selain itu `"OK"`.

**B. Data Manipulation**
6. Buat kolom `FirstPassYield = 1 - Defect/Inspected`.
7. Hitung defect rate per `Line`, urutkan menurun.
8. Hitung jumlah baris dan total defect per `DefectType` (gunakan `count()`/`summarise()`).
9. Gabungkan ringkasan per lini dengan tabel harga produk (opsional/imaginer) menggunakan `left_join()`.

**C. Visualisasi**
10. Buat bar chart defect rate per lini, warna `steelblue`, judul berbentuk pertanyaan.
11. Buat line chart defect rate dari waktu ke waktu (`InspectionDate`).
12. Buat scatter plot `CycleTimeSec` vs `DefectRate` + `geom_smooth(method="lm")`.
13. Buat boxplot `CycleTimeSec` per `Line`.
14. Tambahkan `facet_wrap(~ Line)` pada line chart, lalu simpan PNG dengan `ggsave()`.

### 22.2 Kunci jawaban singkat

```r
# 1
total_inspected <- 5000; total_defect <- 320
defect_rate <- total_defect / total_inspected

# 2
a <- c(38, 42, 45, 41, 39)
mean(a); sd(a); min(a); max(a)

# 3
line <- c("A","B","C","D","E"); line[2:4]

# 4
ifelse(defect_rate > 0.05, "Above", "OK")   # ambang sesuai kebutuhan

# 5
quality |> filter(Line == "A", Defect > 5) |> head(10)

# 6
quality |> mutate(FirstPassYield = 1 - Defect / Inspected)

# 7
quality |>
  mutate(DefectRate = Defect / Inspected) |>
  group_by(Line) |>
  summarise(DefectRate = sum(Defect) / sum(Inspected), .groups = "drop") |>
  arrange(desc(DefectRate))

# 8
quality |> count(DefectType, sort = TRUE)

# 9  (contoh, harga_inspeksi = data tambahan dengan kolom Line & Biaya)
ringkasan |> left_join(harga_produk, by = "Line")

# 10-14 (lihat Bab 14; pakai ringkasan/topik dari README)
```

> Catatan: nomor 4 gunakan `case_when()` bila perlu multi-kondisi. Untuk soal 7, defect rate agregat sebaiknya `sum(Defect)/sum(Inspected)`.

---

## 23. Glossary Fungsi R

Tabel ringkas fungsi yang dibahas di dokumen ini, diurutkan per chapter untuk memudahkan pencarian.

| Chapter | Fungsi | Kegunaan |
| --- | --- | --- |
| 4 | `<-` | assignment objek |
| 4 | `c()`, `seq()`, `rep()` | membuat dan mengulang vektor |
| 4 | `class()`, `as.numeric()`, `as.Date()` | memeriksa dan mengubah tipe data |
| 4 | `is.na()` | mendeteksi missing value |
| 5 | `mean()`, `sum()`, `min()`, `max()`, `sd()` | statistik deskriptif |
| 5 | `ifelse()`, `case_when()` | logika bercabang |
| 5 | `function()` | membuat fungsi sendiri |
| 6 | `tibble()`, `set.seed()`, `rnorm()`, `rpois()` | membuat data latihan reproducible |
| 6 | `str()`, `head()`, `glimpse()`, `summary()`, `nrow()` | inspeksi struktur data |
| 7 | `select()`, `filter()`, `mutate()`, `arrange()`, `rename()` | manipulasi kolom dan baris |
| 7 | `distinct()`, `count()` | nilai unik dan hitungan kategori |
| 7 | `group_by()`, `summarise()` | ringkasan per kelompok |
| 7 | `\|>` | pipe antar langkah |
| 7 | `trimws()`, `toupper()` | merapikan teks sebelum analisis |
| 8 | `pivot_longer()`, `pivot_wider()` | mengubah bentuk tabel |
| 8 | `drop_na()`, `replace_na()`, `coalesce()` | menangani nilai `NA` |
| 9 | `left_join()`, `inner_join()`, `full_join()`, `anti_join()` | menggabungkan dan mengaudit relasi tabel |
| 10 | `ymd()`, `dmy()`, `mdy()` | membaca tanggal |
| 10 | `floor_date()`, `ceiling_date()`, `%m+%` | pembulatan dan aritmetika bulan |
| 10 | `year()`, `month()`, `quarter()`, `wday()` | komponen tanggal |
| 11 | `str_detect()`, `str_replace()`, `str_to_title()`, `str_squish()` | pengolahan teks |
| 11 | `paste()`, `paste0()`, `sprintf()` | menyusun label gabungan |
| 12 | `percent()`, `comma()`, `number()`, `dollar()` | format angka untuk laporan |
| 12 | `percent_format()`, `comma_format()`, `unit_format()` | label sumbu `ggplot2` |
| 13 | `setequal()`, `duplicated()`, `colSums(is.na())` | validasi kualitas data |
| 14 | `ggplot()`, `aes()`, `geom_*()`, `facet_wrap()` | membangun grafik |
| 14 | `labs()`, `theme_minimal()`, `ggsave()` | label, tema, dan simpan grafik |
| 16 | `write.csv()` | mengekspor hasil analisis |

> Setiap fungsi di atas dibahas lengkap pada chapter yang tertulis. Gunakan tabel ini sebagai rujukan cepat saat menulis kode.

---

## 24. Topik Lanjutan (Next Steps)

Setelah R Basics selesai, tiga topik berikut adalah lanjutan yang paling sering dibutuhkan analyst:

| Topik | Package / Fungsi | Kapan dipakai |
| --- | --- | --- |
| Iterasi dan fungsi berulang | `purrr::map()`, `map_dbl()`, `map_df()` | menghitung banyak segmen atau skenario sekaligus |
| Membaca file Excel | `readxl::read_excel()` | sumber data berupa spreadsheet, bukan CSV |
| Laporan otomatis | R Markdown / Quarto | menyusun laporan PDF/HTML yang dapat di-render ulang |

Contoh iterasi dengan `purrr`:

```r
library(purrr)
library(dplyr)

line_list <- split(quality_clean, quality_clean$Line)

line_list |>
  map_dbl(~ sum(.x$Defect) / sum(.x$Inspected))
```

Contoh membaca Excel (instal sekali dengan `install.packages("readxl")`):

```r
library(readxl)

quality_xlsx <- read_excel("quality_inspection.xlsx", sheet = 1)
```

> Lanjutkan ke [README project](README.md) untuk melihat bagaimana kode yang sama dipakai pada analisis demand dan capacity di Power BI, serta [CHEATSEET.MD](CHEATSEET.MD) untuk ringkasan sintaks.

---

## 25. Referensi dan Berkas

| Berkas/Materi | Lokasi |
| --- | --- |
| **Cheatsheet R Basics (sintaks cepat)** | [CHEATSEET.MD](CHEATSEET.MD) |
| Main project | [README project](README.md) |
| Dokumentasi R | <https://cran.r-project.org/> |
| tidyverse documentation | <https://www.tidyverse.org/> |
| dplyr documentation | <https://dplyr.tidyverse.org/> |
| ggplot2 documentation | <https://ggplot2.tidyverse.org/> |

---

*README R Basics — fondasi Basic R, Data Manipulation, dan Data Visualization untuk rangkaian pelatihan "Insight to Impact".*
