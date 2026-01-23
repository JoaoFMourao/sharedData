# PRODES Amazon Biome — Non-Forest Vegetation

Processing of vegetation suppression in non-forest areas within the Amazon Biome.

## Overview

Tracks loss of native non-forest vegetation (campos, savanna enclaves) that is not captured by standard forest deforestation monitoring.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_prodes_amzbiome_nonforrest.R` | Clean raw shapefile |
| `01_blt_clean_overlaps_defo_residue.R` | Remove overlaps with standard deforestation |
| `02_blt_mrg_prodes_amzbiome_nonforrest_muni.R` | Merge with municipality boundaries |
| `before_after_overlaps_check.R` | Validate overlap removal |

### Subfolders

- `old/` — Deprecated versions

## Input

- `rawData/yearly_deforestation_nf_biome.shp`

## Output

- Cleaned non-forest vegetation loss polygons by municipality

## Authors

- Julia Brandão
- Rafael Pucci (original)
