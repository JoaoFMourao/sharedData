# Secondary Vegetation - Imazon FLORESER

Scripts for processing secondary vegetation (forest regrowth) data from Imazon.

## Overview

FLORESER tracks the occurrence and age of secondary vegetation in the Amazon, mapping forest regrowth in previously deforested areas from 1986 to 2019.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_lcv_regen_amz_floreser_imazon.R` | Process FLORESER raster data |

## Data Source

- **Provider**: Imazon
- **Platform**: Google Earth Engine (restricted access)
- **Asset**: `projects/imazon-simex/FLORESER/floreser-collection-50-6-ages`
- **Coverage**: Amazon
- **Period**: 1986-2019 (annual)
- **Format**: Raster (408 files: 34 years × 12 tiles each)

## Raster Values

Values 1-34 represent the age (in years) of secondary vegetation at each pixel.

## Access

1. Contact Imazon for access permission
2. Access data via Google Earth Engine link
3. Export using provided GEE script

## Dependencies

```r
terra, raster, sf, tidyverse
```
