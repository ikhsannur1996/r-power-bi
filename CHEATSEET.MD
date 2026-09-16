# R Cheat Sheet — Demand & Capacity Project

> **Navigation:** [Main Project README](README.md) · [R Basics](BASICR.MD)

Cheat sheet ini hanya memuat syntax yang digunakan dalam repository **Demand & Capacity What-If Analysis**.

## 1. Setup

```r
install.packages(c("tidyverse", "lubridate", "scales"))

library(tidyverse)
library(lubridate)
library(scales)
```

## 2. Read and Inspect Data

```r
dataset <- read_csv("dataset/dataset.csv", show_col_types = FALSE)

head(dataset)
str(dataset)
summary(dataset)
nrow(dataset)
names(dataset)
```

## 3. Common Data Types

```r
as.Date("2024-01-01")
as.character(x)
as.numeric(x)
as.integer(x)
is.na(x)
```

## 4. Tidyverse Data Manipulation

```r
# Select columns
sales |> select(Tanggal, SKU, Produk, Permintaan)

# Filter rows
sales |> filter(Permintaan > 1000)

# Create columns
sales |> mutate(DemandValue = Permintaan * Harga)

# Sort rows
sales |> arrange(desc(Permintaan))

# Group and summarize
sales |>
  group_by(Produk) |>
  summarise(
    Demand = sum(Permintaan, na.rm = TRUE),
    AveragePrice = mean(Harga, na.rm = TRUE),
    .groups = "drop"
  )
```

## 5. Prepare and Aggregate

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
  )
```

## 6. What-If Scenario

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
```

## 7. Visualization

```r
ggplot(demand_final, aes(Produk, ScenarioDemand, fill = Produk)) +
  geom_violin(trim = FALSE) +
  geom_boxplot(width = .12, fill = "white") +
  theme_minimal()
```

Common geoms used in this project:

```r
geom_col()
geom_point()
geom_line()
geom_ribbon()
geom_violin()
geom_boxplot()
geom_tile()
geom_hline()
geom_vline()
coord_polar()
```

## 8. Scenario Filter for Power BI

```r
selected_scenario <- if ("Scenario" %in% names(demand_final)) {
  scenarios_in_visual <- unique(na.omit(as.character(demand_final$Scenario)))
  if (length(scenarios_in_visual) == 1) scenarios_in_visual else "Base"
} else {
  "Base"
}

visual_data <- demand_final |>
  filter(Scenario == selected_scenario)
```

Atur slicer `Scenario` di Power BI dengan default selection `Base`.

## 9. Forecast

```r
monthly <- visual_data |>
  group_by(Tanggal) |>
  summarise(Demand = sum(ScenarioDemand), .groups = "drop") |>
  arrange(Tanggal)

monthly <- monthly |>
  mutate(Forecast = (Demand + lag(Demand) + lag(Demand, 2)) / 3)
```

## 10. Export

```r
write_csv(demand_final, "dataset/demand_final.csv")
ggsave("output/visual.png", width = 10, height = 6, dpi = 150)
```

## 11. PDF References

- [Base R](cheatsheet/base-r.pdf)
- [Data Transformation](cheatsheet/data-transformation.pdf)
- [Data Visualization](cheatsheet/data-visualization.pdf)
- [RStudio IDE](cheatsheet/rstudio-ide.pdf)
