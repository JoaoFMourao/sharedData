# Land Tenure - Imaflora

Scripts for processing Imaflora's land tenure dataset (Atlas Agropecuário).

## Overview

Imaflora's land tenure map integrates multiple official databases to create a comprehensive view of land ownership and designation across Brazil, including public lands, private properties, protected areas, and indigenous territories.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_prp_lndTe_brl_landTenure_imaflora.R` | Clean land tenure shapefile |
| `r2c_imaflora_raster.R` | Process raster version |

## Data Source

- **Provider**: Imaflora (Atlas Agropecuário)
- **URL**: https://www.imaflora.org/atlasagropecuario
- **Coverage**: Brazil
- **Version**: 202105

## Land Tenure Categories

- Indigenous Lands
- Quilombola Territories
- Conservation Units (federal/state)
- Rural Settlements
- Public Forests
- CAR (Rural Environmental Registry)
- Undesignated Public Lands

## Dependencies

```r
sf, terra, raster, tidyverse
```
