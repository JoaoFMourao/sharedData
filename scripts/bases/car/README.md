# CAR - Cadastro Ambiental Rural

Scripts for downloading and processing CAR (Rural Environmental Registry) data from SICAR Geoserver.

## Overview

CAR is Brazil's mandatory environmental registry for rural properties, containing property boundaries and environmental compliance information. These scripts download data from SICAR's Geoserver API, cross with municipality boundaries, and add biome information.

## Directory Structure

```
car/
├── _documentation/
│   └── _metadados.txt      # Data documentation
└── code/
    ├── 01_r2c_car_geoserver.R
    ├── 02_car_muni.R
    └── 03_add_biome_info_sicar.R
```

## Scripts

| Script | Description |
|--------|-------------|
| `01_r2c_car_geoserver.R` | Download CAR data from Geoserver (shapefile + CSV), clean and merge |
| `02_car_muni.R` | Intersect CAR polygons with municipality boundaries |
| `03_add_biome_info_sicar.R` | Cross CAR with biome boundaries, calculate biome shares |

## Workflow

### Step 1: Download and Clean
- Downloads shapefiles and CSVs from SICAR Geoserver API by state
- Downloads in chunks (5,000 features for shapefiles, 50,000 for CSVs)
- Merges geometry with attribute data (CSV fixes corrupted date fields)
- Outputs clean data by state

### Step 2: Municipality Intersection
- Loads municipality boundaries (IBGE 2022)
- Transforms to SIRGAS 2000 Polyconic CRS
- Intersects CAR polygons with municipalities (parallelized)
- Outputs data chunked by municipality

### Step 3: Biome Information
- Crosses CAR data with biome boundaries (IBGE 2019)
- Calculates area and share of each CAR in each biome
- Drops geometry, consolidates into single dataset
- Creates variables: `share_in_amazon`, `share_in_cerrado`, etc.

## Data Source

- **Provider**: SICAR / Brazilian Forest Service
- **URL**: https://geoserver.car.gov.br/geoserver/web/
- **Download date**: 2023-11-08
- **Coverage**: All 27 Brazilian states

## Output Variables

| Variable | Description |
|----------|-------------|
| `cod_imovel` | CAR property code (unique identifier) |
| `area_car` | Total property area |
| `muni_code` | IBGE municipality code |
| `share_in_amazon` | % of property in Amazon biome |
| `share_in_cerrado` | % of property in Cerrado biome |
| `share_in_*` | % in other biomes |

## Dependencies

```r
sf, tidyverse, future.apply, furrr, parallel, geobr, lwgeom
```

## Authors

- Marcelo Sessim
- Rogério Reis

**Project Lead**: João Mourão, Mariana Stussi
