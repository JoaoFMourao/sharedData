# PRODES - Deforestation Monitoring Data

Scripts for processing PRODES (Projeto de Monitoramento do Desmatamento na Amazônia Legal por Satélite) data from INPE.

## Overview

PRODES is Brazil's official deforestation monitoring program, providing annual deforestation polygons across all Brazilian biomes. These scripts clean raw shapefiles and merge them with municipality boundaries for analysis.

## Directory Structure

```
prodes/
├── prodes_AmazonBiome/           # Amazon biome deforestation
├── prodes_AmazonBiome_1-6.25ha/  # Small polygons (1-6.25 ha)
├── prodes_AmazonBiome_nonforrest/# Non-forest vegetation loss
├── prodes_AmazonBiome_residual/  # Residual deforestation
├── prodes_Caatinga/              # Caatinga biome
├── prodes_Cerrado/               # Cerrado biome
├── prodes_LegalAm/               # Legal Amazon region
├── prodes_MataAtlantica/         # Atlantic Forest biome
├── prodes_Pampa/                 # Pampa biome
└── prodes_Pantanal/              # Pantanal biome
```

## Standard Workflow

Each biome folder follows a consistent pipeline:

| Script | Purpose |
|--------|---------|
| `01_r2c_*.R` | **Raw to Clean**: Read shapefiles, rename columns, standardize formats |
| `02_mrg_*.R` | **Merge**: Cross deforestation polygons with municipality boundaries |
| `03_crossCheck.R` | **Validation**: Compare aggregated values against official INPE totals |

### Additional Scripts

- `defo_mask/` — Deforestation mask processing
- `old/` — Deprecated script versions

## Column Standardization

All scripts apply consistent column renaming:

| Original | Standardized | Description |
|----------|--------------|-------------|
| `fid` | `prodes_id` | Polygon identifier |
| `uuid` | `prodes_uuid` | Unique identifier |
| `state` | `prodes_state_uf` | State abbreviation |
| `year` | `prodes_year` | Detection year |
| `area_km` | `prodes_area_km2` | Polygon area (km²) |
| `main_class` | `prodes_class` | Land cover class |
| `image_date` | `prodes_view_date` | Observation date |

## Special Datasets

### Amazon Biome Variants

- **Standard**: Main deforestation polygons (>6.25 ha)
- **1-6.25ha**: Small deforestation polygons
- **Residual**: Deforestation detected in subsequent years
- **Non-forest**: Loss of non-forest native vegetation

### Legal Amazon vs Amazon Biome

- **Legal Amazon** (`prodes_LegalAm`): Administrative region (9 states)
- **Amazon Biome** (`prodes_AmazonBiome`): Ecological boundary

## Dependencies

```r
sf, tidyverse, data.table, geobr, Hmisc, labelled,
future.apply, furrr, parallel
```

## Data Source

- **Provider**: INPE (Instituto Nacional de Pesquisas Espaciais)
- **URL**: http://terrabrasilis.dpi.inpe.br/downloads/
- **CRS**: SIRGAS 2000 Polyconic

## Authors

- Rogério Reis
- João Mourão
- Julia Brandão
- Rafael Pucci

**Project Lead**: João Mourão, Mariana Stussi
