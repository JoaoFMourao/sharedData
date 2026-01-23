# Non-Forest - TerraBrasilis

Scripts for processing non-forest vegetation mask from INPE's TerraBrasilis.

## Overview

The non-forest mask identifies areas within the Amazon biome that have vegetation typologies not classified as forest, and therefore are not monitored by PRODES deforestation mapping.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_lnd_nonforrest_amzBiome.R` | Clean non-forest shapefile |
| `blt_land_nonforrest_amzBiome_merge_muni.R` | Merge with municipality boundaries |

## Data Source

- **Provider**: INPE (TerraBrasilis)
- **URL**: https://terrabrasilis.dpi.inpe.br/
- **Coverage**: Amazon Biome

## Notes

- Shows areas excluded from PRODES forest monitoring
- Attribute structure standardized with PRODES deforestation data
- Useful for understanding PRODES coverage limitations

## Dependencies

```r
sf, tidyverse, geobr
```
