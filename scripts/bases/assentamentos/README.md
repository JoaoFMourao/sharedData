# Assentamentos - Rural Settlements

Scripts for processing INCRA rural settlement data.

## Overview

Rural settlements (assentamentos) are agrarian reform areas created by INCRA. Data includes polygons and spreadsheet information about settlement projects across Brazil.

## Scripts

| Script | Description |
|--------|-------------|
| `01_cln_prp_lndTe_brl_settlements_spatial.R` | Clean spatial data (shapefile) |
| `02_cln_prp_lndTe_brl_settlements_worksheet.R` | Clean Excel spreadsheet data |
| `03_cln_prp_lndTe_brl_settlements_incra_join.R` | Merge shapefile and spreadsheet |
| `blt_prp_lndTe_brl_settlements_join_versions.R` | Join different data versions |

## Data Source

- **Provider**: INCRA (Instituto Nacional de Colonização e Reforma Agrária)
- **URL**: http://acervofundiario.incra.gov.br/acervo/acv.php
- **CRS**: SIRGAS 2000, LongLat

## Notes

- Each observation may not correspond to one settlement; use `sipra_code` to group
- Observations with type 'RTQR TQ' are Quilombola Territories
- File names include download date (YYYYMMDD) — update `reference.data` parameter accordingly
- `crosschecks/` folder contains version comparison scripts

## Dependencies

```r
sf, tidyverse, Hmisc, readxl
```
