# PRODES Amazon Biome — Residual Deforestation

Processing of residual deforestation polygons in the Amazon Biome.

## Overview

Residual deforestation refers to areas detected in subsequent years after initial clearing — fragments missed in the original detection or secondary clearing within previously deforested areas.

## Scripts

| Script | Description |
|--------|-------------|
| `r2r_lnd_residue_amz_biome_prodes.R` | Clean raw residual shapefile |
| `clean_overlaps_btw_normal_prodes_and_prodes_residual.R` | Remove overlaps with standard PRODES |
| `mrg_prodes_rsd_amzMuni.R` | Merge with municipality boundaries |
| `CrossCheck.R` | Validate against INPE totals |

### Subfolders

- `old/` — Deprecated versions

## Input

- `rawData/residual_biome.shp`

## Output

- Cleaned residual deforestation polygons by municipality

## Authors

- Julia Brandão
- Rogério Reis (original)
