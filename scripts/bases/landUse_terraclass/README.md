# Land Use - TerraClass

Scripts for processing TerraClass land use data for the Legal Amazon.

## Overview

TerraClass maps land use and land cover in deforested areas of the Legal Amazon, classifying cleared areas into pasture, agriculture, secondary vegetation, and other categories.

## Scripts

| Script | Description |
|--------|-------------|
| `lnd_lTC_r2c.R` | Clean TerraClass raster data |

## Data Source

- **Provider**: TerraClass Project (INPE/Embrapa)
- **URL**: http://terrabrasilis.dpi.inpe.br/
- **Coverage**: Legal Amazon
- **Available Years**: 2004, 2008, 2010, 2012, 2014, 2020
- **Format**: Raster

## Land Use Categories (2020)

| Value | Category |
|-------|----------|
| 1 | Primary Forest |
| 2 | Secondary Forest |
| 3 | Silviculture |
| 4 | Shrub/Tree Pasture |
| 5 | Herbaceous Pasture |
| 6 | Perennial Crop |
| 7 | Semi-perennial Crop |
| 8 | Temporary Crop (>1 cycle) |
| 9 | Mining |
| 10 | Urban |
| 13 | Deforestation (current year) |
| 14 | Non-Forest |
| 15 | Water Body |

## Dependencies

```r
terra, raster, sf, tidyverse
```
