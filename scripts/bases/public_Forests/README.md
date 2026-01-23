# Public Forests - SFB

Scripts for processing Brazilian public forests data from the National Public Forest Registry.

## Overview

Public forests are areas of native vegetation on public lands designated for sustainable forest management, managed by the Brazilian Forest Service (SFB).

## Scripts

| Script | Description |
|--------|-------------|
| `cln_prp_lndTe_brl_publicForests_sfb_2020_sf.R` | Clean 2020 public forests data |
| `cln_prp_lndTe_brl_publicForests_sfb_2022_sf.R` | Clean 2022 public forests data |

## Data Source

- **Provider**: SFB (Serviço Florestal Brasileiro)
- **URL**: https://www.gov.br/agricultura/pt-br/assuntos/servico-florestal-brasileiro/cadastro-nacional-de-florestas-publicas
- **CRS**: SIRGAS 2000, LongLat

## Notes

- Public forests often overlap with Indigenous Lands and other protected areas
- `_functions/` folder contains utility scripts for data processing

## Dependencies

```r
sf, tidyverse, geobr
```
