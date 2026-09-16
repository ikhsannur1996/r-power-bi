# 📗 CHEATSHEET Volume 0 — Basic R, dplyr & ggplot2

> Satu halaman referensi cepat untuk **menghafal dan memahami sintaks R**. Pasangkan dengan `README.md`. Salin-tempel contoh ini langsung di RStudio dan ubah datanya.

---

## 1. Objek, Assignment & Tipe Data

```r
x <- 5                 # assignment pakai <-
x = 5                  # juga bisa, tapi gunakan <- (konvensi R)
assign("x", 5)         # fungsi assignment (jarang dipakai)

class(x)               # "numeric"
is.numeric(x)          # TRUE / FALSE (cek tipe)
as.character(x)        # konversi ke character
as.integer(5.7)        # 5 (membulatkan ke bawah)
is.na(x)               # cek missing value

# Tipe utama: numeric, integer, character, logical, factor, Date, list
```

## 2. Vektor (Vector)

```r
v <- c(1, 2, 3, 4)        # kombinasi (combine)
s <- seq(1, 10, by = 2)   # 1 3 5 7 9
r <- rep("A", 3)          # "A" "A" "A"
n <- 1:10                 # urutan

length(v)   sum(v)   mean(v)   median(v)
min(v)      max(v)   sd(v)     var(v)
range(v)    sort(v)  rev(v)    unique(v)

# Operasi vektor bersifat elementwise:
v + 1   v * 2   v > 2   v %in% c(2,3)
```

## 3. Indexing (ingat: R mulai dari 1)

```r
v[1]          # elemen pertama
v[2:3]        # elemen 2-3
v[c(1, 4)]    # elemen 1 dan 4
v[-1]         # semua kecuali elemen 1
v[v > 2]      # berdasarkan kondisi
which(v > 2)  # posisi indeks yang memenuhi
names(v)      # nama elemen (jika ada)
```

## 4. NA (nilai hilang)

```r
x <- c(1, NA, 3)
is.na(x)                 # FALSE TRUE FALSE
sum(is.na(x))            # jumlah NA
mean(x, na.rm = TRUE)    # rata-rata tanpa NA
x[!is.na(x)]             # buang NA
na.omit(data_frame)      # buang baris ber-NA
```

## 5. Logika & Kondisi

```r
5 > 3 & 5 < 10    # AND  -> TRUE
5 < 3 | 5 < 10    # OR   -> TRUE
!(5 > 3)          # NOT  -> FALSE
5 %in% c(1,5,9)   # membership -> TRUE

if (x > 5) print("big") else print("small")
ifelse(condition, yes_val, no_val)          # vectorized
case_when(cond1 ~ val1, .default = val_default)  # dplyr multi-kondisi
```

## 6. String & Tanggal

```r
toupper("r")              # "R"
tolower("R")              # "r"
nchar("hello")            # 5
substr("abcdef", 2, 4)    # "bcd"
trimws("  R  ")           # "R"
gsub("a","o", "banana")   # "bonono"
strsplit("a,b,c", ",")    # list

# Tanggal
as.Date("2026-07-01")              # base
lubridate::ymd("2026-07-01")       # opsi lain
year(d)  month(d)  day(d)  wday(d)
floor_date(d, "month")             # awal bulan
```

---

## 7. `dplyr` — 5 kata kerja inti (verbs)

| Verb | Fungsi | Contoh |
| --- | --- | --- |
| `select()` | pilih kolom | `df |> select(a, b)` atau `select(-c)` |
| `filter()` | pilih baris | `df |> filter(a > 5)` |
| `mutate()` | buat/ubah kolom | `df |> mutate(y = a * 2)` |
| `arrange()` | urutkan | `df |> arrange(desc(y))` |
| `summarise()` + `group_by()` | ringkas | `df |> group_by(g) |> summarise(m = mean(y))` |

Lain: `distinct()`, `rename()`, `count()`, `left_join()`, `slice_max()`, `slice_head()`.

```r
# Pipa — baca dari kiri ke kanan
df |>
  filter(!is.na(x)) |>
  mutate(rate = d / i) |>
  group_by(line) |>
  summarise(avg = mean(rate), .groups = "drop") |>
  arrange(desc(avg))
```

### `group_by()` + `summarise()` — wajib hafal

```r
df |>
  group_by(Line, DefectType) |>
  summarise(
    total_inspected = sum(Inspected),
    total_defect   = sum(Defect),
    defect_rate    = total_defect / total_inspected,
    .groups = "drop"
  )
```

> 💡 Agregat defect rate = `total_defect/total_inspected`, **bukan** `mean(defect_rate per baris)` — volume antar kelompok berbeda.

---

## 8. `ggplot2` — Formula Inti

```r
ggplot(data = df, aes(x = ..., y = ..., color = ..., fill = ...)) +
  geom_xxx() +
  labs(title, x, y, color, fill) +
  scale_*_* +        # misal scale_y_continuous(labels = percent_format())
  theme_minimal() +
  facet_wrap(~ kolom)
```

### Geom paling sering dipakai

| Geom | Grafik |
| --- | --- |
| `geom_col()` | bar chart (data sudah diagregat) |
| `geom_bar()` | bar chart (hitung otomatis) |
| `geom_point()` | scatter plot |
| `geom_line()` | line chart |
| `geom_smooth(method = "lm")` | garis regresi |
| `geom_boxplot()` | boxplot |
| `geom_histogram()` | histogram |
| `geom_density()` | density curve |
| `geom_hline(yintercept = ..)` | garis horizontal (target) |

### Aesthetics (aes) — petakan variabel ke visual

```r
aes(x, y,           # sumbu
    color = kat,    # warna titik/garis
    fill   = kat,   # warna isi (bar, boxplot)
    size   = num,   # ukuran titik
    shape  = grup,  # bentuk titik
    group  = grup)  # grup garis (untuk geom_line)
```

### Skala & label

```r
scale_y_continuous(labels = percent_format(accuracy = 0.1))
scale_y_continuous(labels = comma)        # pemisah ribuan
scale_y_log10()
scale_color_viridis_d()
scale_color_brewer(palette = "Set2")
coord_flip()
labs(title, subtitle, x, y, color, fill, size)
theme_minimal(base_size = 11)
theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1))
```

---

## 9. Simpan Hasil

```r
write.csv(df, "nama.csv", row.names = FALSE)     # data
ggsave("plot.png", plot, width = 8, height = 5, dpi = 300)  # grafik
```

---

## 10. Shortcut RStudio yang Wajib Dikenal

| Shortcut (macOS) | Windows/Linux | Fungsi |
| --- | --- | --- |
| `Cmd + Enter` | `Ctrl + Enter` | Jalankan baris/seleksi |
| `Cmd + Shift + Enter` | `Ctrl + Shift + Enter` | Jalankan seluruh skrip |
| `Alt + -` | `Alt + -` | Menulis `<-` |
| `Cmd + Shift + C` | `Ctrl + Shift + C` | Komentar/un-comment blok |
| `Cmd + Shift + M` | `Ctrl + Shift + M` | Menulis pipe `%>%` (config) |
| `Tab` | `Tab` | Autocomplete |
| `Cmd + Shift + F10` | `Ctrl + Shift + F10` | Restart R session |
| `Cmd + L` | `Ctrl + L` | Hapus Console |
| `View(df)` | `View(df)` | Lihat data frame di viewer |

---

## 11. Tips & Trik (untuk mengingat sintaks)

1. Selalu mulai skrip dengan `library()` + komentar tujuan.
2. Satu baris satu operasi per pipa — mudah dibaca & di-debug.
3. Nama kolom pakai `snake_case_` (garis bawah).
4. Cek data dulu: `head()`, `str()`, `summary()`, `nrow()`.
5. `.groups = "drop"` di `summarise()` untuk menghindari grouping tersisa.
6. `NA` menyebar: jika `mean()` jadi `NA`, tambahkan `na.rm = TRUE`.
7. Persentase di ggplot: `percent_format(accuracy = 0.1)` dari `scales`.
8. Agregat defect rate = total ÷ total, bukan rata-rata rate.
9. `unique()` dan `table()` sebelum `group_by()` agar kategori bersih.
10. Pipe `|>` membuat urutan eksekusi = urutan bacaan.
11. `View()`/klik data frame di Environment untuk memeriksa cepat.
12. Re-run skrip dari atas bila hasil terlihat aneh (environment basi).
13. Bekerja dengan **New Project** RStudio agar path relatif aman.
14. Package error → `install.packages("dplyr")` dulu, baru `library()`.
15. Plot kosong → cek tipe data kolom (`str()`).
16. Tanggal selalu `as.Date()`/`ymd()` sebelum dipakai di grafik.
17. Label tanggal: `format(d, "%d-%b-%Y")`.
18. `Tab` di RStudio setelah `$` → autocomplete nama kolom.
19. Angka tak terlihat → curiga character, lakukan `as.numeric()`.
20. Cek dimensi hilang setelah filter: `nrow()` sebelum dan sesudah.

---

*Cheatsheet Volume 0 — salin, tempel, dan ingat: `dplyr` + `ggplot2` menyelesaikan hampir semua kebutuhan dasar.*
