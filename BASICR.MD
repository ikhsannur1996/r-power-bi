# R Basics — Repository Guide

> **Navigation:** [Main Project README](README.md) · [R Cheat Sheet](CHEATSEET.MD)

Panduan ini berisi dasar R yang diperlukan untuk menjalankan project **Demand & Capacity What-If Analysis**.

## 1. Project Context

Project menggunakan R untuk membuat dataset demand dan capacity, menyiapkan data dengan `tidyverse`, membuat What-If scenario, menghitung KPI operasional, membuat visualisasi, dan melakukan forecasting untuk Power BI.

```text
dataset
   ↓
Prepare & Aggregate
   ↓
What-If Scenarios
   ↓
demand_final
   ↓
Visualization & Forecasting
   ↓
Power BI
```

## 2. Prerequisites

- [R / CRAN](https://cran.r-project.org/)
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/)
- [Power BI Desktop](https://powerbi.microsoft.com/desktop/)

Install package yang digunakan project:

```r
install.packages(c("tidyverse", "lubridate", "scales"))

library(tidyverse)
library(lubridate)
library(scales)
```

`tidyverse` mencakup `dplyr`, `ggplot2`, `readr`, `tidyr`, dan `tibble` yang digunakan dalam project.

## 3. R Objects and Data Types

```r
x <- 10
values <- c(10, 20, 30)

sales <- tibble(
  Tanggal = as.Date(c("2024-01-01", "2024-02-01")),
  Demand = c(100, 120)
)

class(sales)
str(sales)
head(sales)
summary(sales)
```

## 4. Prepare and Aggregate Data

Project menggunakan kolom `Tanggal` yang sudah tersedia. Tidak ada kolom `TahunBulan` atau konversi `YYYY-MM` tambahan.

```r
step2 <- dataset |>
  mutate(DemandValue = Permintaan * Harga) |>
  group_by(
    Tanggal, Tahun, Bulan, NamaBulan, SKU, Produk,
    Kategori, Rasa, Ukuran, Packing, Lokasi
  ) |>
  summarise(
    Demand = sum(Permintaan, na.rm = TRUE),
    DemandValue = sum(DemandValue, na.rm = TRUE),
    Capacity = mean(Kapasitas, na.rm = TRUE),
    Harga = mean(Harga, na.rm = TRUE),
    .groups = "drop"
  ) |>
  ungroup()

output <- step2
```

## 5. What-If Scenarios

```r
scenarios <- tibble(
  Scenario = c("-30%", "-20%", "-10%", "Base", "+10%", "+20%", "+30%"),
  Growth = c(-0.30, -0.20, -0.10, 0, 0.10, 0.20, 0.30)
)

demand_final <- crossing(step2, scenarios) |>
  mutate(
    ScenarioDemand = Demand * (1 + Growth),
    ScenarioValue = ScenarioDemand * Harga,
    Utilization = ScenarioDemand / Capacity,
    CapacityGap = Capacity - ScenarioDemand,
    RevenueImpact = ScenarioValue - DemandValue
  )

output <- demand_final
```

## 6. Visualization

```r
library(tidyverse)

visual_data <- demand_final

ggplot(visual_data, aes(x = Produk, y = ScenarioDemand, fill = Produk)) +
  geom_col() +
  labs(title = "Demand by Product", x = NULL, y = "Demand") +
  theme_minimal()
```

Untuk Power BI R Visual, gunakan kolom `Scenario` pada slicer dan pilih `Base` sebagai default. Visual akan mengikuti scenario yang dikirim Power BI.

## 7. Forecast

```r
monthly <- visual_data |>
  group_by(Tanggal) |>
  summarise(Demand = sum(ScenarioDemand), .groups = "drop") |>
  arrange(Tanggal)

monthly <- monthly |>
  mutate(Forecast = (Demand + lag(Demand) + lag(Demand, 2)) / 3)
```

## 8. Debugging Power BI R Visual

Jika muncul `could not find function "mutate"`:

```r
library(tidyverse)
```

Jika muncul masalah tanggal, gunakan `Tanggal` secara langsung. Jangan membuat `TahunBulan` atau mengonversi ke format `YYYY-MM`.

## 9. Repository References

- [Main project README](README.md)
- [R Cheat Sheet](CHEATSEET.MD)
- [Dataset folder](dataset/)
- [Output visual folder](output/)
- [PDF cheat sheets](cheatsheet/)
