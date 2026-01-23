# PRODES Legal Amazon

Deforestation data processing for the Legal Amazon administrative region.

## Overview

Legal Amazon is an administrative region comprising 9 Brazilian states, distinct from the Amazon Biome ecological boundary. This dataset includes both yearly increments and accumulated deforestation up to 2007.

## Scripts

| Script | Description |
|--------|-------------|
| `01_r2c_lnd_prodes_laz_increm.R` | Clean yearly deforestation increments |
| `01_r2c_lnd_prodes_laz_acc2007.R` | Clean accumulated deforestation up to 2007 |
| `02_r2c_prodes_municipalities.R` | Merge increments with municipality boundaries |
| `02_r2c_prodes_municipalities_acc.R` | Merge accumulated data with municipalities |

## Input

- `rawData/yearly_deforestation/`
- `rawData/accumulated_deforestation_2007/`

## Output

- Cleaned deforestation polygons (incremental and accumulated) by municipality

## Authors

- João Mourão
- Rafael Pucci (original)
