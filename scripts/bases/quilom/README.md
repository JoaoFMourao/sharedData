# Quilombolas - Quilombola Territories

Scripts for processing INCRA quilombola community data.

## Overview

Quilombola territories are areas recognized as belonging to descendants of escaped enslaved Africans (quilombos). These territories have special legal protection under the Brazilian constitution.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_prp_lndTe_brl_quilombolas_incra.R` | Clean quilombola territories shapefile |

## Data Source

- **Provider**: INCRA (Instituto Nacional de Colonização e Reforma Agrária)
- **URL**: http://acervofundiario.incra.gov.br/acervo/acv.php
- **Download**: Click "DOWNLOAD DE SHAPEFILE" → "Áreas de Quilombolas"
- **CRS**: SIRGAS 2000, LongLat

## Notes

- Data is dynamically generated from INCRA's geographic database at download time
- Some quilombola territories may also appear in settlements data as type 'RTQR TQ'

## Dependencies

```r
sf, tidyverse, Hmisc
```
