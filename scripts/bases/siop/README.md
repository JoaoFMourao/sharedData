# SIOP - Federal Budget System

Scripts for processing SIOP (Sistema Integrado de Planejamento e Orçamento) federal budget data.

## Overview

SIOP contains planning and budget execution data for the Brazilian federal government, including expenditures by program, action, and agency.

## Scripts

| Script | Description |
|--------|-------------|
| `01_get_and_clear_siop.R` | Download and clean SIOP data |
| `Siop_Clean_Version2.0.R` | Alternative cleaning script |

## Data Source

- **Provider**: Ministry of Planning (Ministério do Planejamento)
- **URL**: https://www1.siop.planejamento.gov.br/
- **Period**: 2000-2023 (sample: 2012-2022)

## Processing Steps

1. Standardize column names
2. Separate numeric codes from descriptions
3. Remove accents from text variables
4. Filter for desired year range

## Notes

- Sample in raw data excludes "Natureza de Despesa" (expenditure nature) detail
- Full dataset available through SIOP web interface

## Dependencies

```r
tidyverse, readxl, data.table, janitor
```
