# From Demand to Decisions
## R-Powered Analytics in Power BI

> **Professional training deck outline** — turning demand uncertainty into capacity, risk, and revenue decisions.

---

## Slide 1 — Title

### From Demand to Decisions

**R-Powered Analytics in Power BI**

**Subtitle:** A practical demand, capacity, and What-If analysis case study

**Audience:** Business Analysts, Data Analysts, Demand Planners, Operations, and Power BI users

---

## Slide 2 — Executive Business Question

> **If demand changes under different scenarios, can production capacity handle it, which products are at risk, and what is the potential revenue impact?**

### Why It Matters

- Demand is uncertain.
- Production capacity is limited.
- Shortage creates operational and revenue risk.
- Management needs evidence before making capacity decisions.

---

## Slide 3 — Business Case and Stakeholders

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

## Slide 4 — Analytical Scope

- January 2024 – December 2026
- 12 SKUs
- 4 products
- 2 locations: Jakarta and Bandung
- Monthly demand and capacity
- Product attributes: category, flavor, size, and packing
- Seven scenarios: `-30%` to `+30%`

### Core Measures

```text
Demand · Capacity · Utilization · Capacity Gap · Revenue Impact
```

---

## Slide 5 — End-to-End Analytical Architecture

```text
Data Preparation
      ↓
Data Transformation
      ↓
What-If Scenario Table
      ↓
demand_final
      ↓
R Visualization & Forecasting
      ↓
Power BI Dashboard
      ↓
Business Decision
```

> `demand_final` is the single analytical source for Power BI.

---

## Slide 6 — R and Power BI Technology Stack

| Tool | Role |
| --- | --- |
| R | Flexible data preparation, analysis, visualization, and forecasting |
| tidyverse | Data import, manipulation, tidying, and visualization |
| lubridate | Date operations and forecasting periods |
| scales | Business-friendly number and percentage labels |
| Power BI | Interactive slicers, reporting, and decision communication |

```r
install.packages(c("tidyverse", "lubridate", "scales"))

library(tidyverse)
library(lubridate)
library(scales)
```

---

## Slide 7 — Data Preparation and Transformation

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
```

---

## Slide 8 — What-If Scenario Analysis

```text
-30% | -20% | -10% | Base | +10% | +20% | +30%
```

```text
Scenario Demand = Demand × (1 + Growth)
Utilization     = Scenario Demand ÷ Capacity
Capacity Gap    = Capacity − Scenario Demand
Revenue Impact  = Scenario Value − Demand Value
```

> What happens to operations and revenue when demand moves away from the Base scenario?

---

## Slide 9 — Dynamic Scenario Filter in Power BI

1. Add `Scenario` to a slicer.
2. Set `Base` as the default selection.
3. Add required fields to the R Visual Values well.
4. Allow Power BI to pass filtered data to R.

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
**Dynamic behavior:** changes when the slicer changes.

---

## Slide 10 — Visual Analytics with ggplot2

### Suggested Title

> **Make Risk Visible**

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

## Slide 11 — Power BI R Visual

### Suggested Title

> **Turn R Analysis into an Interactive Dashboard**

### Power BI Configuration

1. Add `Scenario` to a slicer.
2. Set `Base` as the default selection.
3. Add required fields to the R Visual Values well.
4. Use the filtered `dataset` object in the R script.
5. Keep the visual code free from a hard-coded `Scenario == "Base"` filter.

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

---

## Slide 12 — Forecasting

### Suggested Title

> **Look Ahead: From Historical Demand to Future Planning**

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

## Slide 13 — Capstone Business Challenge

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

## Slide 14 — Management Recommendation

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

## Slide 15 — Key Takeaways and Next Steps

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

### References

- [Main Project README](../README.md)

---

## Slide 16 — R and Power BI Overview

### R: The Analytical Engine

R is used for:

- Data preparation
- Statistical analysis
- Scenario modeling
- Custom visualization
- Forecasting

### Power BI: The Decision Platform

Power BI is used for:

- Interactive reports
- Slicers and filters
- KPI presentation
- Business storytelling
- Dashboard distribution

```text
R prepares and analyzes the data.
Power BI communicates and operationalizes the insight.
```

---

## Slide 17 — Basic R Syntax

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

# Inspect data
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

## Slide 18 — Basic `dplyr` Syntax

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

### Mental Model

```text
select → filter → mutate → group_by → summarise → arrange
```

---

## Slide 19 — Basic `ggplot2` Syntax

### Grammar of Graphics

```r
library(tidyverse)

sales_summary <- sales |>
  group_by(Produk) |>
  summarise(Demand = sum(Permintaan), .groups = "drop")

ggplot(sales_summary, aes(x = Produk, y = Demand, fill = Produk)) +
  geom_col() +
  labs(
    title = "Demand by Product",
    x = NULL,
    y = "Demand"
  ) +
  theme_minimal()
```

### Common Geoms in This Project

```text
geom_col()       → bar chart
geom_point()     → scatter plot
geom_line()      → trend line
geom_ribbon()    → forecast range
geom_violin()    → distribution
geom_boxplot()   → outlier and quartile view
geom_tile()      → heatmap
coord_polar()    → circular seasonality chart
```

---

## Slide 20 — Guided Practice and Learning Path

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

### Continue Learning

- [Main Project README](../README.md)
- [R Basics](../BASICR.MD)
- [R Cheat Sheet](../CHEATSEET.MD)
- [Cheat Sheet PDFs](../cheatsheet/)

> **Final message:** Better code creates better analysis. Better analysis creates better decisions.

- [R Basics](../BASICR.MD)
- [R Cheat Sheet](../CHEATSEET.MD)
- [Cheat Sheet PDFs](../cheatsheet/)

