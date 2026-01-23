# Oil & Gas Project - Data Analysis

R scripts for analyzing oil and gas sector data in Brazil, supporting the FGV Clima Oil & Gas Report.

## Authorship

- **Author:** Rafael Parfitt, FGV Clima
- **Date:** 22/05/2025

## Script

### Data Oleo e Gas.R

Comprehensive analysis script that processes RAIS (labor market) and FINBRA (municipal finance) data to generate figures and tables for the Oil & Gas report.

## Data Sources

- **RAIS** - Relação Anual de Informações Sociais (Annual Social Information Report)
- **FINBRA** - Finanças do Brasil (Brazilian Municipal Finances)
- **VTBI** - Valor Adicionado por Empresa (Value Added by Company)
- **geobr** - Brazilian geographic data for mapping

## Main Analyses

### Part 1: Data Preparation

**RAIS Processing:**
- Skill classification (High-skill vs Low-skill) based on CBO occupation codes
- Reclassification by education level (higher education → High-skill; low education → Low-skill)
- Oil & Gas sector identification via CNAE codes: `0600`, `0910`, `1910`, `1921`, `1922`

**Municipal Summary Statistics:**
- Total workers per municipality
- O&G sector workers count
- Gender distribution (total and O&G sector)
- Skill distribution (total and O&G sector)
- Salary statistics and brackets (0-2k, 2-4k, 4-10k, 10-30k, 30k+)

### Part 2: Figures

| Figure | Description |
|--------|-------------|
| **Figure 9** | Top 20 municipalities most dependent on O&G sector (% of revenue from petroleum royalties) |
| **Figure 10** | Top 20 municipalities with highest absolute petroleum revenue (R$ millions) |
| **Figure 11** | Relationship between average salary and value added by industrial sector |
| **Figure 12** | Employment intensity by industrial sector per value added (jobs per R$ 1M VA) |
| **Figure 13** | Wage mass and employment by sectors |
| **Figure 14** | Top 15 municipalities by total wage mass |

### Part 3: Maps

- **State-level map:** O&G employment distribution by Brazilian state
- **Municipal maps:**
  - Employment proportions in O&G sector
  - Average relative salary in O&G sector
  - Municipal data visualization

### Part 4: Tables

- Main summary table with municipal-level O&G indicators
- Salary tables by sector

## Sector Classification

The script groups CNAE codes into aggregated sectors:

| Sector | CNAE Codes |
|--------|------------|
| Óleo e Gás | 06, 09.1, 19 |
| Mineração | 05, 07, 08, 09 |
| Alimentos, bebidas e fumo | 10, 11, 12 |
| Celulose e papel | 17, 18 |
| Químicos | 20, 21 |
| Metalurgia | 24 |
| Cimento | 23.2 |
| Cerâmica | 23.4 |
| Transporte | 29, 30 |
| Resto da indústria | 13-16, 22, 25-28, 31-33 |

## Dependencies

```r
data.table, foreign, haven, dplyr, stargazer, ggplot2, viridis, ggrepel,
hrbrthemes, devtools, jtools, sf, geobr, stringr, scales, readr
```

## Outputs

**Data files:**
- `Final_data.dta` - Consolidated municipal dataset (Stata format)

**Figure data (CSV):**
- `Figure 9.csv` - O&G dependency ratios
- `Figure 10.csv` - Petroleum revenue rankings
- `Figure 11.csv` - Salary vs Value Added
- `Figure 12.csv` - Employment intensity
- Additional figure exports

## Configuration

Update the working directory and file paths before running:

```r
setwd("C:\\path\\to\\your\\directory")

# Input files
rais <- fread("path/to/RAIS/base_limpa.csv")
Finbra <- fread("path/to/Finbra/finbra.csv")
VA <- fread("path/to/VTBI/Valor Adicionado Empresas.csv")
```

## Key Variables Created

| Variable | Description |
|----------|-------------|
| `trab_oil_gas` | Binary indicator for O&G sector workers |
| `Skill_Class` | High-skill / Low-skill classification |
| `ratio_petroleo` | Petroleum revenue as share of total revenue |
| `salario_medio_oil` | Average salary in O&G sector |
| `n_trab` | Number of O&G workers per municipality |

## Notes

- All data used for creating the figures is stored in FGV CLIMA SharePoint
- The script requires pre-cleaned RAIS data (`base_limpa.csv`)
- Geographic visualizations use the `geobr` package for Brazilian shapefiles
