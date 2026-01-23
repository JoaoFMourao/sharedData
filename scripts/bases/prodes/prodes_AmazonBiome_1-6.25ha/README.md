# PRODES Amazon Biome — Small Polygons (1-6.25 ha)

Processing of small deforestation polygons (1 to 6.25 hectares) in the Amazon Biome.

## Overview

Standard PRODES only detects deforestation polygons larger than 6.25 ha. This dataset captures smaller clearings that fall below the standard detection threshold.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_prodes_amzbiome_1-6.25ha.R` | Clean raw shapefile, standardize columns |
| `blt_mrg_prodes_amzbiome_1-6.25ha_muni.R` | Merge with municipality boundaries |

## Input

- `rawData/yearly_deforestation_smaller_than_625ha_biome_23/yearly_deforestation_smaller_than_625ha_biome.shp`

## Output

- `cleanData/cln_lcv_dfrst_1-6.25ha_amz_biome_prodes_inpe_sf.RData`

## Authors

- Marcelo Sessim
- Rogério Reis (original)
