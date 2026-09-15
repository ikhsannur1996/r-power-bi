#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(lubridate)
  library(readr)
  library(tidyr)
})

root <- normalizePath(getwd(), mustWork = TRUE)
dataset_dir <- file.path(root, "dataset")
output_dir <- file.path(root, "output")
dir.create(dataset_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

set.seed(123)
dataset <- expand.grid(
  Tanggal = seq(as.Date("2024-01-01"), as.Date("2026-12-01"), by = "month"),
  SKU = paste0("SKU", sprintf("%02d", 1:12))
) |>
  as_tibble() |>
  mutate(
    Tahun = year(Tanggal), Bulan = month(Tanggal), NamaBulan = format(Tanggal, "%B"),
    Produk = rep(c("Product A", "Product B", "Product C", "Product D"), length.out = n()),
    Kategori = if_else(Produk %in% c("Product A", "Product B"), "Food", "Drink"),
    Rasa = sample(c("Chocolate", "Berry", "Vanilla", "Original"), n(), replace = TRUE),
    Ukuran = sample(c("Small", "Medium", "Large"), n(), replace = TRUE),
    Packing = sample(c("Box", "Bottle"), n(), replace = TRUE),
    Lokasi = sample(c("Jakarta", "Bandung"), n(), replace = TRUE),
    Permintaan = round(runif(n(), 500, 5000) * case_when(
      Bulan %in% c(11, 12) ~ 1.30,
      Bulan %in% c(6, 7) ~ 1.15,
      TRUE ~ 1
    )),
    Harga = sample(c(5000, 7500, 10000, 15000), n(), replace = TRUE),
    Kapasitas = sample(c(4000, 5000, 6000), n(), replace = TRUE)
  )

step1 <- dataset |>
  mutate(TahunBulan = as.Date(sprintf("%d-%02d-01", Tahun, Bulan)),
         DemandValue = Permintaan * Harga)

step2 <- step1 |>
  group_by(TahunBulan, Tahun, Bulan, NamaBulan, SKU, Produk,
           Kategori, Rasa, Ukuran, Packing, Lokasi) |>
  summarise(Demand = sum(Permintaan, na.rm = TRUE),
            DemandValue = sum(DemandValue, na.rm = TRUE),
            Capacity = mean(Kapasitas, na.rm = TRUE),
            Harga = mean(Harga, na.rm = TRUE), .groups = "drop")

scenarios <- tibble(
  Scenario = c("-30%", "-20%", "-10%", "Base", "+10%", "+20%", "+30%"),
  Growth = c(-0.30, -0.20, -0.10, 0.00, 0.10, 0.20, 0.30)
)

demand_final <- crossing(step2, scenarios) |>
  mutate(ScenarioDemand = Demand * (1 + Growth),
         ScenarioValue = ScenarioDemand * Harga,
         Utilization = ScenarioDemand / Capacity,
         CapacityGap = Capacity - ScenarioDemand,
         RevenueImpact = ScenarioValue - DemandValue) |>
  arrange(TahunBulan, SKU, Scenario)

write_csv(dataset, file.path(dataset_dir, "dataset.csv"), na = "")
write_csv(step1, file.path(dataset_dir, "step1_prepared.csv"), na = "")
write_csv(step2, file.path(dataset_dir, "step2_aggregated.csv"), na = "")
write_csv(demand_final, file.path(dataset_dir, "demand_final.csv"), na = "")
write_csv(scenarios, file.path(dataset_dir, "scenarios.csv"), na = "")

base <- demand_final |> filter(Scenario == "Base")


# Modern, cohesive palette: deep blue, violet, aqua, coral, gold and slate.
COLORS <- list(
  navy = "#253B6E", violet = "#6C5CE7", aqua = "#16B8A6", blue = "#3F8EFC",
  sky = "#8EC5FC", coral = "#F26B5E", gold = "#F2B134", plum = "#9B6DFF",
  slate = "#64748B", grid = "#E6EAF0", text = "#334155", white = "#FFFFFF"
)
PRODUCT_COLORS <- c("Product A" = "#3F8EFC", "Product B" = "#6C5CE7", "Product C" = "#16B8A6", "Product D" = "#F26B5E")
theme_project <- theme_minimal(base_size = 11) +
  theme(
    plot.background = element_rect(fill = COLORS$white, color = NA),
    panel.background = element_rect(fill = COLORS$white, color = NA),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = COLORS$grid, linewidth = .35),
    axis.text = element_text(color = COLORS$text), axis.title = element_text(color = COLORS$text),
    plot.title = element_text(face = "bold", size = 15, color = COLORS$navy),
    plot.subtitle = element_text(size = 10, color = COLORS$slate), legend.position = "bottom",
    legend.key.width = unit(1.3, "cm"), legend.key.height = unit(.45, "cm"),
    legend.spacing.x = unit(.25, "cm"), legend.box.spacing = unit(4, "pt"),
    legend.margin = margin(0, 0, 0, 0),
    legend.title = element_text(face = "bold", color = COLORS$text),
    legend.text = element_text(color = COLORS$text),
    plot.margin = margin(12, 16, 10, 12)
  )
save_plot <- function(name, plot, width = 10, height = 6) {
  ggsave(file.path(output_dir, name), plot, width = width, height = height, dpi = 150, bg = COLORS$white)
}

monthly <- base |>
  group_by(TahunBulan) |>
  summarise(Demand = sum(ScenarioDemand), Capacity = sum(Capacity), .groups = "drop") |>
  mutate(
    GapType = if_else(Demand > Capacity, "Production Shortage", "Available Capacity"),
    BandLow = pmin(Demand, Capacity),
    BandHigh = pmax(Demand, Capacity)
  )
p1 <- ggplot(monthly, aes(TahunBulan)) +
  geom_ribbon(aes(ymin = BandLow, ymax = BandHigh, fill = GapType), alpha = .22) +
  geom_line(aes(y = Demand, color = "Demand", linetype = "Demand"), linewidth = 1.15) +
  geom_line(aes(y = Capacity, color = "Capacity", linetype = "Capacity"), linewidth = 1.1) +
  scale_color_manual(values = c(Demand = COLORS$navy, Capacity = COLORS$aqua), name = NULL) +
  scale_linetype_manual(values = c(Demand = "solid", Capacity = "dashed"), name = NULL) +
  scale_fill_manual(values = c("Production Shortage" = COLORS$coral, "Available Capacity" = COLORS$sky), name = "Capacity Status") +
  labs(title = "Demand vs Capacity", subtitle = "Monthly production pressure | Base scenario", x = NULL, y = "Units") +
  guides(fill = guide_legend(order = 2, override.aes = list(alpha = .35))) +
  theme_project
save_plot("01_demand_vs_capacity.png", p1)

p2 <- ggplot(base, aes(Produk, ScenarioDemand, fill = Produk)) +
  geom_boxplot(color = COLORS$white, alpha = .9, outlier.color = COLORS$gold, outlier.alpha = .7) +
  scale_fill_manual(values = PRODUCT_COLORS, name = "Product") +
  labs(title = "Demand Variability", subtitle = "Distribution of demand by product", x = NULL, y = "Scenario Demand") + theme_project
save_plot("02_demand_variability_boxplot.png", p2)

p3 <- ggplot(base, aes(Produk, ScenarioDemand, fill = Produk)) +
  geom_violin(color = COLORS$white, alpha = .85, trim = FALSE) +
  geom_boxplot(width = .12, fill = COLORS$white, color = COLORS$navy,
               outlier.shape = 21, outlier.fill = COLORS$gold,
               outlier.color = COLORS$navy, outlier.size = 2.4,
               outlier.stroke = .5) +
  scale_fill_manual(values = PRODUCT_COLORS, name = "Product") +
  labs(title = "Demand Distribution", subtitle = "Demand shape with outliers highlighted by product", x = NULL, y = "Scenario Demand") + theme_project
save_plot("03_demand_distribution_violin.png", p3)


seasonality <- base |> group_by(Bulan) |> summarise(Demand = sum(ScenarioDemand), .groups = "drop") |>
  mutate(AverageDemand = mean(Demand),
         DemandLevel = if_else(Demand >= AverageDemand, "Above Average", "Below Average"))
p4 <- ggplot(seasonality, aes(Bulan, Demand)) +
  geom_col(aes(fill = DemandLevel), width = .9) +
  geom_hline(aes(yintercept = AverageDemand, linetype = "Monthly Average"), color = COLORS$slate, linewidth = .7) +
  scale_fill_manual(values = c("Above Average" = COLORS$navy, "Below Average" = COLORS$sky), name = "Demand Level") +
  scale_linetype_manual(values = c("Monthly Average" = "dashed"), name = NULL) +
  coord_polar() + scale_x_continuous(breaks = 1:12) +
  labs(title = "Monthly Demand Pattern", subtitle = "Demand compared with monthly average | Base scenario", x = NULL, y = NULL) + theme_project
save_plot("04_monthly_demand_polar.png", p4)

sku_demand <- base |> group_by(SKU) |> summarise(Demand = sum(ScenarioDemand), .groups = "drop")
p5 <- ggplot(sku_demand, aes(Demand, reorder(SKU, Demand))) +
  geom_segment(aes(x = 0, xend = Demand, y = reorder(SKU, Demand), yend = reorder(SKU, Demand)), color = COLORS$grid, linewidth = 1.4) +
  geom_point(size = 3.5, color = COLORS$navy) +
  labs(title = "SKU Demand Distribution", subtitle = "Total demand by SKU | Base scenario", x = "Demand", y = NULL) + theme_project
save_plot("05_sku_demand_dotplot.png", p5)

utilization <- base |> group_by(Produk, Lokasi) |> summarise(Utilization = sum(ScenarioDemand) / sum(Capacity), .groups = "drop")
p6 <- ggplot(utilization, aes(Lokasi, Produk, fill = Utilization)) +
  geom_tile(color = COLORS$white, linewidth = .8) + geom_text(aes(label = paste0(round(Utilization * 100), "%")), color = COLORS$navy, fontface = "bold") +
  scale_fill_gradient(low = "#EEF2FF", high = COLORS$aqua, labels = scales::percent, name = "Utilization") +
  labs(title = "Capacity Utilization by Location", subtitle = "Product and location utilization | Base scenario", x = NULL, y = NULL) + theme_project
save_plot("06_capacity_utilization_heatmap.png", p6)

risk <- base |> group_by(SKU) |> summarise(Shortage = sum(pmax(-CapacityGap, 0)), .groups = "drop") |> arrange(desc(Shortage)) |> mutate(CumPct = if (sum(Shortage) > 0) cumsum(Shortage) / sum(Shortage) * 100 else rep(0, n()))
max_shortage <- max(risk$Shortage, 1)
p7 <- ggplot(risk, aes(reorder(SKU, Shortage), Shortage)) +
  geom_col(fill = COLORS$coral, width = .7) +
  geom_line(aes(y = CumPct / 100 * max_shortage, group = 1, color = "Cumulative %"), linewidth = 1) +
  geom_point(aes(y = CumPct / 100 * max_shortage, color = "Cumulative %"), size = 2.5) +
  scale_color_manual(values = c("Cumulative %" = COLORS$aqua), name = NULL) +
  labs(title = "SKU Capacity Risk Pareto", subtitle = "Shortage contribution by SKU | Base scenario", x = NULL, y = "Shortage Units") + theme_project
save_plot("07_sku_capacity_risk_pareto.png", p7)

# Recursive 3-month moving average, projected 12 months forward.
df <- monthly |> arrange(TahunBulan) |> mutate(Forecast = (Demand + lag(Demand) + lag(Demand, 2)) / 3)
future <- tibble(TahunBulan = seq(max(df$TahunBulan) %m+% months(1), max(df$TahunBulan) %m+% months(12), by = "month"), Forecast = NA_real_)
for (i in seq_len(nrow(future))) {
  values <- c(tail(df$Demand, 3), future$Forecast[seq_len(i - 1)])
  future$Forecast[i] <- mean(tail(values, 3), na.rm = TRUE)
}
sd_demand <- sd(df$Demand, na.rm = TRUE)
future <- future |> mutate(Upper = Forecast + sd_demand, Lower = Forecast - sd_demand)
forecast_plot <- ggplot() +
  geom_ribbon(data = future, aes(TahunBulan, ymin = Lower, ymax = Upper, fill = "Forecast Range"), alpha = .2) +
  geom_line(data = df |> filter(!is.na(Forecast)), aes(TahunBulan, Forecast, color = "3-Month Moving Average", linetype = "3-Month Moving Average"), linewidth = .95) +
  geom_line(data = df, aes(TahunBulan, Demand, color = "Actual Demand", linetype = "Actual Demand"), linewidth = 1.1) +
  geom_line(data = future, aes(TahunBulan, Forecast, color = "12-Month Forecast", linetype = "12-Month Forecast"), linewidth = 1.1) +
  geom_vline(xintercept = max(df$TahunBulan), linetype = "dotted", color = COLORS$slate) +
  scale_color_manual(values = c("Actual Demand" = COLORS$navy, "3-Month Moving Average" = COLORS$violet, "12-Month Forecast" = COLORS$aqua), name = NULL) +
  scale_linetype_manual(values = c("Actual Demand" = "solid", "3-Month Moving Average" = "dashed", "12-Month Forecast" = "dashed"), name = NULL) +
  scale_fill_manual(values = c("Forecast Range" = COLORS$sky), name = NULL) +
  labs(title = "Demand Forecast Band", subtitle = "Actual demand and 12-month forward forecast", x = NULL, y = "Demand") + theme_project
save_plot("08_demand_forecast_band.png", forecast_plot)

forecast_export <- bind_rows(df |> mutate(Lower = NA_real_, Upper = NA_real_, Type = "Historical"), future |> mutate(Demand = NA_real_, Type = "Forecast")) |> select(TahunBulan, Demand, Forecast, Lower, Upper, Type)
write_csv(forecast_export, file.path(dataset_dir, "demand_forecast.csv"), na = "")
cat("Generated", nrow(dataset), "dataset rows and", nrow(demand_final), "demand_final rows.\n")
cat("CSV directory:", dataset_dir, "\nPNG directory:", output_dir, "\n")
