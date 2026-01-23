# Queimadas - INPE Active Fires

Scripts for processing active fire (hot spots) data from INPE's BD Queimadas program.

## Overview

BD Queimadas is INPE's fire monitoring program that detects active fires from satellite imagery. Data consists of spatial points representing fire detections across Brazil, available daily since 2000.

## Directory Structure

```
queimadas - inpe/
├── _documentation/
│   ├── _metadata.txt
│   ├── inpe_contacts_queimadas.jpg
│   ├── inpe_fire_doubts.docx
│   ├── inpe_fire_FAQ.docx
│   └── justificativa_lancamento_base2.pdf
└── code/
    ├── r2c_lcv_fire_brl_activeFires_inpe_2000to2018.R
    ├── r2c_lcv_fire_brl_activeFires_inpe_2019to2021.R
    ├── r2c_lcv_fire_brl_activeFires_inpe_2020to2024.R
    └── blt_lnd_activeFires_sf_monthly.R
```

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_*_2000to2018.R` | Clean raw fire data 2000-2018 (13 columns) |
| `r2c_*_2019to2021.R` | Clean raw fire data 2019-2021 (different schema) |
| `r2c_*_2020to2024.R` | Clean raw fire data 2020-2024 |
| `blt_lnd_activeFires_sf_monthly.R` | Merge all periods, export monthly files |

## Workflow

1. **Raw to Clean**: Read shapefiles by year, standardize column names, translate biomes to English, remove duplicates
2. **Build Monthly**: Combine all periods, filter by satellite (NPP-375), create PRODES year variable, export monthly files

## Data Source

- **Provider**: INPE (Instituto Nacional de Pesquisas Espaciais)
- **Program**: BD Queimadas
- **URL**: https://queimadas.dgi.inpe.br/queimadas/bdqueimadas
- **Contact**: queimadas@inpe.br
- **CRS**: WGS84 (EPSG:4326)

## Satellites

| Period | Reference Satellite | Resolution |
|--------|---------------------|------------|
| 1998-07 to 2002-07 | NOAA-12 | — |
| 2002-07 onwards | AQUA_M-T | 1 km² |
| — | NPP-375 (VIIRS) | 375 m² |

## Output Variables

| Variable | Description |
|----------|-------------|
| `date` | Date and hour of fire detection |
| `satellite` | Image provider satellite |
| `state` | State name |
| `municipality` | Municipality name |
| `biome` | Biome (amazon, cerrado, caatinga, atlantic forest, pampa, pantanal) |
| `days_wt_rain` | Days without rain until detection |
| `precipitation` | Precipitation volume on detection day |
| `fire_risk` | Fire risk forecast value |
| `lat`, `lon` | Coordinates (decimal degrees) |
| `frp` | Fire Radiative Power (megawatts) |

## Notes

- Schema changed in 2019 (one column dropped), requiring separate processing scripts
- Variables `days_wt_rain`, `precipitation`, `fire_risk` missing in early years
- `frp` (Fire Radiative Power) available from 2017 onwards

## Dependencies

```r
sf, sp, rgdal, rgeos, tidyverse, Hmisc, data.table, future.apply
```

## Authors

- Helena Arruda
- Diego Menezes
- Julia Brandão

**Project Lead**: Clarissa Gandour, João Mourão
