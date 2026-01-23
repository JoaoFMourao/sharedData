# Degradation - DEGRAD INPE

Scripts for processing forest degradation data from INPE's DEGRAD program.

## Overview

DEGRAD monitors forest degradation in the Brazilian Legal Amazon, detecting areas where forest cover is progressively being lost but not yet classified as clear-cut deforestation.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_lcv_dgrad_laz_degrad_inpe.R` | Clean degradation shapefiles (sp) |
| `r2c_lcv_dgrad_laz_degrad_inpe_sf.R` | Clean degradation shapefiles (sf) |

## Data Source

- **Provider**: INPE (Instituto Nacional de Pesquisas Espaciais)
- **Program**: DEGRAD
- **URL**: http://www.obt.inpe.br/OBT/assuntos/programas/amazonia/degrad/
- **Coverage**: Legal Amazon
- **Period**: 2007-2016 (annual)

## CRS

- **2007-2009**: SAD69 LongLat (assumed, undocumented)
- **2010-2016**: SAD69 LongLat (pre-1996 Brazil)

## Dependencies

```r
sf, sp, rgdal, rgeos, Hmisc
```
