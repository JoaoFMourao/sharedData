# Industrial Sector Project - Multi-Sector Analysis

R script for analyzing multiple industrial sectors in Brazil using RAIS labor market data, supporting FGV Clima industrial reports.

## Authorship

- **Author:** Rafael Parfitt, FGV Clima
- **Date:** 22/05/2025

## Script

### Rais Data Industrial 2.R

Comprehensive multi-sector industrial analysis focusing on cement and metallurgy sectors, with comparisons across all industrial categories.

## Data Sources

- **RAIS** - Relação Anual de Informações Sociais (Annual Social Information Report)
- **VTBI** - Valor Adicionado por Empresa (Value Added by Company)
- **FINBRA** - Municipal financial data (via auxiliary file)
- **geobr** - Brazilian geographic data for mapping

## Sector Definitions

Sectors identified by CNAE 2.0 codes:

| Sector | CNAE Codes | Description |
|--------|------------|-------------|
| Óleo e Gás | 0600, 0910, 1921, 1922 | Oil & Gas extraction and refining |
| Elétrico | 351 | Electric power generation |
| Cimento | 232 | Cement manufacturing |
| Metalurgia | 24 | Metallurgy |
| Transporte | 29, 30 | Vehicle manufacturing |
| Mineração | 05, 07, 08, 09 | Mining |
| Indústria | 10-33 | All industrial sectors |

## Main Analyses

### Part 1: Main Summary Table

Cross-sector comparison with key metrics:
- Total workers (thousands)
- Share of women (%)
- Share of high-skill workers (%)
- Average salary
- Median salary

**Output:** `Table X.csv`

### Part 2: Municipal Data Preparation

**RAIS Processing:**
- Skill classification (High-skill vs Low-skill) based on CBO occupation codes
- Reclassification by education level
- Multi-sector worker identification (cement, metallurgy)

**Municipal Summary Statistics:**
- Total workers per municipality
- Sector-specific workers count (cement, metallurgy)
- Gender distribution by sector
- Skill distribution by sector
- Average salary by sector

### Part 3: Figures

| Figure | Description |
|--------|-------------|
| **Figure 1A** | Top 15 municipalities by metallurgy wage mass proportion |
| **Figure 1B** | Top 15 municipalities by cement wage mass proportion |
| **Figure XX** | Employment intensity by sector per value added (jobs per R$ 1M VA) |
| **Figure YY** | Wage mass and employment distribution by sectors |

### Part 4: State-Level Maps

Geographic visualizations at state level:
- **Employment Maps:** Distribution of sector employment by state
  - Metallurgy employment map
  - Cement employment map
- **Salary Maps:** Average salary distribution by state
  - Metallurgy salary map
  - Cement salary map

### Part 5: Skill Analysis

Detailed breakdown of workforce composition:
- Low-skill vs High-skill percentages by sector
- Gender and skill cross-tabulations

## Dependencies

```r
data.table, foreign, haven, dplyr, stargazer, ggplot2, viridis, ggrepel,
hrbrthemes, devtools, jtools, sf, geobr, stringr, scales, readr
```

## Outputs

**Data files:**
- Municipal-level consolidated dataset

**Tables (CSV):**
- `Table X.csv` - Main sector summary table

**Figure data (CSV):**
- Figure exports for each visualization

## Configuration

Update the working directory and file paths before running:

```r
setwd("C:\\path\\to\\Oleo e Gas\\directory")

# Input files
rais <- fread("path/to/RAIS/base_limpa.csv")
VA <- fread("path/to/VTBI/Valor Adicionado Empresas.csv")
Data_aux <- read.dta("path/to/final_wide.dta")
```

## Key Variables Created

| Variable | Description |
|----------|-------------|
| `trab_cimento` | Binary indicator for cement sector workers |
| `trab_metalurgia` | Binary indicator for metallurgy sector workers |
| `setor` | Categorical variable for sector classification |
| `Skill_Class` | High-skill / Low-skill classification |
| `massa_metalurgia` | Total wage mass in metallurgy sector |
| `massa_cimento` | Total wage mass in cement sector |
| `prop_massa_*` | Sector wage mass as proportion of municipal total |

## Sector Classification for Value Added Analysis

| Aggregated Sector | CNAE Codes |
|-------------------|------------|
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

## Notes

- All data used for creating the figures is stored in FGV CLIMA SharePoint
- The script requires pre-cleaned RAIS data (`base_limpa.csv`)
- Geographic visualizations use the `geobr` package for Brazilian shapefiles
- Focus sectors (cement, metallurgy) are highlighted in visualizations
