# Mineral Project - Mining Sector Analysis

R script for analyzing mining sector data in Brazil using RAIS labor market data, supporting the FGV Clima Mineral Report.

## Authorship

- **Author:** Rafael Parfitt, FGV Clima
- **Date:** 22/05/2025

## Script

### Rais Data Mineral.R

Comprehensive analysis of the Brazilian mining sector (mineração), including employment statistics, wage analysis, and visualizations.

## Data Sources

- **RAIS** - Relação Anual de Informações Sociais (Annual Social Information Report)
- **VTBI** - Valor Adicionado por Empresa (Value Added by Company)
- **FINBRA** - Municipal financial data (via auxiliary file)
- **geobr** - Brazilian geographic data for mapping

## Sector Definition

Mining sector identified by CNAE 2.0 codes (first 2 digits):
- `05` - Coal mining
- `07` - Metal ore mining
- `08` - Non-metallic mineral mining
- `09` - Mining support activities

## Main Analyses

### Part 1: Data Preparation

**RAIS Processing:**
- Skill classification (High-skill vs Low-skill) based on CBO occupation codes
- Reclassification by education level
- Mining sector worker identification (`trab_mineral`)

**Municipal Summary Statistics:**
- Total workers per municipality
- Mining sector workers count
- Gender distribution (total and mining sector)
- Skill distribution (total and mining sector)
- Salary statistics and brackets (0-2k, 2-4k, 4-10k, 10-30k, 30k+)

### Part 2: Figures

| Figure | Description |
|--------|-------------|
| **Figure XX** | Relationship between average salary and value added by industrial sector (highlighting Mining) |
| **Figure XX** | Employment intensity by industrial sector per value added (jobs per R$ 1M VA) |
| **Figure 11** | Top 15 municipalities by mining wage mass proportion |
| **Geographic Map** | Spatial distribution of mining employment |
| **Mining-specific** | Detailed analysis particular to the mining sector |

### Part 3: Sector Comparison

The script compares mining against other industrial sectors:
- Óleo e Gás (Oil & Gas)
- Alimentos, bebidas e fumo (Food, beverages, tobacco)
- Celulose e papel (Pulp and paper)
- Químicos (Chemicals)
- Metalurgia (Metallurgy)
- Cimento (Cement)
- Cerâmica (Ceramics)
- Transporte (Transportation)
- Resto da indústria (Rest of industry)

### Part 4: Summary Table

Comprehensive table with sector-level indicators:
- Total workers (thousands)
- Share of women (%)
- Share of high-skill workers (%)
- Average salary
- Median salary

## Dependencies

```r
data.table, foreign, haven, dplyr, stargazer, ggplot2, viridis, ggrepel,
hrbrthemes, devtools, jtools, sf, geobr, stringr, scales, readr
```

## Outputs

**Data files:**
- `Final_data.dta` - Consolidated municipal dataset (Stata format)

**Figure data (CSV):**
- Figure exports for each visualization

## Configuration

Update the working directory and file paths before running:

```r
setwd("C:\\path\\to\\Mineral\\directory")

# Input files
rais <- fread("path/to/RAIS/base_limpa.csv")
VA <- fread("path/to/VTBI/Valor Adicionado Empresas.csv")
Data_aux <- read.dta("path/to/final_wide.dta")
```

## Key Variables Created

| Variable | Description |
|----------|-------------|
| `trab_mineral` | Binary indicator for mining sector workers |
| `Skill_Class` | High-skill / Low-skill classification |
| `salario_medio_oil` | Average salary in mining sector |
| `n_trab` | Number of mining workers per municipality |

## Notes

- All data used for creating the figures is stored in FGV CLIMA SharePoint
- The script requires pre-cleaned RAIS data (`base_limpa.csv`)
- Geographic visualizations use the `geobr` package for Brazilian shapefiles
- Mining sector is highlighted in orange in comparative visualizations
