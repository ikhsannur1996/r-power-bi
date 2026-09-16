# From Demand to Decisions
## R-Powered Analytics in Power BI

> **Professional training deck outline** — from R fundamentals to demand, capacity, risk, and revenue decisions.

---

## Slide 1 — Title

### From Demand to Decisions

**R-Powered Analytics in Power BI**

A practical learning journey from R fundamentals to interactive business insight.

**Audience:** Business Analysts, Data Analysts, Demand Planners, Operations, and Power BI users

**Duration:** Half-day to one-day workshop

---

## Slide 2 — Learning Journey

```text
R Fundamentals
      ↓
Tidyverse Data Skills
      ↓
Power BI Integration
      ↓
Demand & Capacity Analysis
      ↓
What-If Scenarios
      ↓
Forecasting & Business Decisions
```

### Learning Objectives

- Understand how R and Power BI complement each other.
- Write basic R, `dplyr`, and `ggplot2` syntax.
- Prepare and transform demand data.
- Build What-If scenarios and interpret capacity risk.
- Deliver an interactive Power BI dashboard.

---

## Slide 3 — R and Power BI Overview

### R: The Analytical Engine

R is used for data preparation, transformation, scenario modeling, custom visualization, and forecasting.

### Power BI: The Decision Platform

Power BI is used for interactive reports, slicers, KPI presentation, business storytelling, and dashboard distribution.

```text
R prepares and analyzes the data.
Power BI communicates and operationalizes the insight.
```

### When to Use Each Tool

| Task | Recommended tool |
| --- | --- |
| Data cleaning and transformation | R or Power Query |
| Advanced analytics and forecasting | R |
| Interactive dashboard and slicer | Power BI |
| Executive reporting | Power BI |

---

## Slide 4 — Business Question

> **If demand changes under different scenarios, can production capacity handle it, which products are at risk, and what is the potential revenue impact?**

### Why It Matters

- Demand is uncertain.
- Production capacity is limited.
- Shortage creates operational and revenue risk.
- Management needs evidence before making capacity decisions.

---

## Slide 5 — Basic R Syntax

### Core Concepts

```r
library(tidyverse)

# Assignment
monthly_demand <- 25000

# Vector
scenarios <- c("Base", "+10%", "+20%")

# Data frame
summary_table <- tibble(
  Produk = c("Product A", "Product B"),
  Demand = c(12000, 15000)
)

head(summary_table)
str(summary_table)
summary(summary_table)
```

### Essential Operators

```r
library(tidyverse)

x <- 10
x + 5
x * 2
x > 10
is.na(x)
```

---

## Slide 6 — Basic `dplyr` Syntax

### The Core Verbs

```r
library(tidyverse)

sales |>
  select(Tanggal, Produk, Permintaan, Harga) |>
  filter(Permintaan > 1000) |>
  mutate(DemandValue = Permintaan * Harga) |>
  arrange(desc(DemandValue))
```

### Group and Summarise

```r
library(tidyverse)

sales |>
  group_by(Produk) |>
  summarise(
    Demand = sum(Permintaan, na.rm = TRUE),
    Revenue = sum(DemandValue, na.rm = TRUE),
    .groups = "drop"
  )
```

```text
select → filter → mutate → group_by → summarise → arrange
```

---

## Slide 7 — Basic `ggplot2` Syntax

### Grammar of Graphics

```r
library(tidyverse)

sales_summary <- sales |>
  group_by(Produk) |>
  summarise(Demand = sum(Permintaan), .groups = "drop")

ggplot(sales_summary, aes(x = Produk, y = Demand, fill = Produk)) +
  geom_col() +
  labs(title = "Demand by Product", x = NULL, y = "Demand") +
  theme_minimal()
```

### Common Geoms

```text
geom_col() · geom_point() · geom_line()
geom_ribbon() · geom_violin() · geom_boxplot()
geom_tile() · coord_polar()
```

---

## Slide 8 — Power BI R Visual Setup

### Configuration Steps

1. Configure the R installation in Power BI Desktop.
2. Add required fields to the R Visual Values well.
3. Add `Scenario` to a Power BI slicer.
4. Set `Base` as the default selection.
5. Use the filtered `dataset` object in the R script.

### Required Packages

```r
install.packages(c("tidyverse", "lubridate", "scales"))

library(tidyverse)
library(lubridate)
library(scales)
```

### Common Issue

```text
could not find function "mutate"
→ library(tidyverse) is missing in the R script
---

## Slide 9 — Business Case and Stakeholders

### Business Analyst Role

```text
Raw Data → Insight → Risk → Decision
```

| Stakeholder | Decision supported |
| --- | --- |
| Demand Planning | Demand pattern and scenario planning |
| Production Planning | Capacity and production scheduling |
| Operations | Product and location risk |
| Finance | Revenue impact |
| Management | Capacity investment and mitigation |

---

## Slide 10 — Data Scope and Architecture

### Dataset Scope

- January 2024 – December 2026
- 12 SKUs, 4 products, and 2 locations
- Monthly demand and capacity
- Product attributes: category, flavor, size, and packing
- Seven demand scenarios

### Analytical Architecture

```text
Data Preparation
      ↓
Data Transformation
      ↓
What-If Scenario Table
      ↓
demand_final
      ↓
Visualization & Forecasting
      ↓
Power BI Dashboard
```

> `demand_final` is the single analytical source for Power BI.

---

## Slide 11 — Data Preparation and Transformation

### Key Rule

Use the existing monthly date column `Tanggal`. Do not create an additional `TahunBulan` column.

```r
library(tidyverse)

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

output <- step2
```

### Quality Checks

- Row count after aggregation
- Date type on `Tanggal`
- Missing values
- Distribution of demand and capacity

---

## Slide 12 — What-If Scenario Analysis

```text
-30% | -20% | -10% | Base | +10% | +20% | +30%
```

```text
Scenario Demand = Demand × (1 + Growth)
Utilization     = Scenario Demand ÷ Capacity
Capacity Gap    = Capacity − Scenario Demand
Revenue Impact  = Scenario Value − Demand Value
```

### Business Interpretation

```text
Capacity Gap > 0  → Available Capacity
Capacity Gap = 0  → Fully Utilized
Capacity Gap < 0  → Production Shortage
```

> What happens to operations and revenue when demand moves away from the Base scenario?

---

## Slide 13 — Dynamic Scenario Filter in Power BI

### R Visual Pattern

```r
library(tidyverse)

selected_scenario <- if ("Scenario" %in% names(dataset)) {
  selected <- unique(na.omit(as.character(dataset$Scenario)))
  if (length(selected) == 1) selected else "Base"
} else {
  "Base"
}

visual_data <- dataset |>
  filter(Scenario == selected_scenario)
```

**Default:** Base  
**Dynamic behavior:** the visual follows the Power BI slicer selection.

---

## Slide 14 — Visual Analytics with ggplot2

### Design Principles

- Use color to communicate business status.
- Keep legends meaningful and concise.
- Titles should answer business questions.
- Use consistent colors across all visuals.

### Project Visuals

- Demand Distribution with outliers
- Monthly Demand Pattern
- Capacity Utilization Heatmap
- SKU Capacity Risk Pareto
- Demand Forecast Band

### Color Language

| Color | Meaning |
| --- | --- |
| Navy | Demand or primary metric |
| Aqua | Available capacity or positive status |
| Coral | Production shortage or risk |
| Violet | Moving average |
| Sky blue | Forecast range |
| Slate | Benchmark or reference line |
---

## Slide 15 — Forecasting

### Forecast Method

- Historical demand aggregated by `Tanggal`
- Three-month moving average
- Recursive 12-month forecast
- Forecast range based on demand variability

```r
library(tidyverse)
library(lubridate)

monthly <- visual_data |>
  group_by(Tanggal) |>
  summarise(Demand = sum(ScenarioDemand), .groups = "drop") |>
  arrange(Tanggal)

monthly <- monthly |>
  mutate(Forecast = (Demand + lag(Demand) + lag(Demand, 2)) / 3)
```

Forecast results support production scheduling, capacity planning, inventory planning, revenue planning, and risk mitigation.

---

## Slide 16 — Capstone Business Challenge

> **Can the business handle a 20% increase in demand next quarter?**

### Participant Tasks

1. Select the `+20%` scenario.
2. Compare demand with capacity.
3. Identify risky products or SKUs.
4. Estimate utilization and revenue impact.
5. Review the demand forecast.
6. Present a recommendation in Power BI.

### Expected Deliverables

- Prepared analytical table
- Scenario analysis
- Risk visualization
- Forecast visualization
- Management recommendation

---

## Slide 17 — Management Recommendation

### Possible Actions

- Increase production capacity.
- Reallocate capacity across locations.
- Prioritize high-value SKUs.
- Adjust production schedules.
- Monitor demand before investing in new capacity.

### Recommendation Structure

```text
Finding → Business Impact → Recommended Action → Expected Outcome
```

---

## Slide 18 — Guided Practice

### Practice Sequence

```text
1. Load the dataset
2. Inspect the columns
3. Calculate DemandValue
4. Aggregate by product
5. Create What-If scenarios
6. Build one ggplot2 visual
7. Add Scenario to a Power BI slicer
8. Present one business recommendation
```

### Success Criteria

- Code runs without errors.
- Output has a clear analytical grain.
- Visual uses an appropriate chart type.
- Scenario selection changes the insight.
- Recommendation is supported by evidence.

---

## Slide 19 — Key Takeaways and Next Steps

### Key Takeaways

1. A clear business question guides the analysis.
2. `Tanggal` remains the single date field.
3. `demand_final` connects demand, capacity, scenarios, risk, and revenue.
4. Power BI slicers make scenario analysis interactive.
5. Visuals should support decisions, not only display data.
6. Forecasting connects historical demand with future planning.

### Next Steps

- Connect the model to actual production data.
- Add inventory and lead-time metrics.
- Improve forecasting with advanced models.
- Add automated refresh and data quality checks.
- Deploy the dashboard for management decision-making.

---

## Slide 20 — References and Closing

### Reference Materials

- [Main Project README](../README.md)
- [R Basics](../BASICR.MD)
- [R Cheat Sheet](../CHEATSEET.MD)
- [Cheat Sheet PDFs](../cheatsheet/)

### Closing Message

> **Better code creates better analysis. Better analysis creates better decisions.**
```