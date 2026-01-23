# Mapa de Solos do Brasil - Embrapa

Scripts for processing Embrapa's Brazilian Soil Map data.

## Overview

The soil map represents the geographical distribution of soils in Brazil according to the Brazilian Soil Classification System (SiBCS, 2006), classified up to the third categorical level. Scale 1:5,000,000.

## Directory Structure

```
Mapa de solos do Brasil - Embrapa/
├── _documentation/
│   └── _readme.txt
└── code/
    └── treat_embrapa.R
```

## Script

### treat_embrapa.R

Processes Embrapa soil shapefiles and calculates soil type areas by municipality.

**Workflow:**

1. Load soil type shapefile (`brasil_solos_5m_20201104.shp`)
2. Load AMC (Comparable Minimum Areas) boundaries using `geobr`
3. Transform CRS to SIRGAS 2000 (EPSG:4674)
4. Intersect soil polygons with AMC boundaries
5. Calculate area (hectares) of each soil type per AMC
6. Export wide-format dataset (rows = AMC, columns = soil types)

**Output:** `fixed_effects_amc_soil_type.Rds`

## Data Source

- **Provider**: Embrapa Solos (CNPS)
- **URL**: http://geoinfo.cnps.embrapa.br/layers/geonode%3Abrasil_solos_5m_20201104
- **Scale**: 1:5,000,000
- **Classification**: SiBCS 2006 (up to 3rd categorical level)
- **Reference Year**: 2020

## Soil Classification

Uses the most aggregated level (`ORDEM1` column) from SiBCS:
- ARGISSOLOS
- CAMBISSOLOS
- CHERNOSSOLOS
- ESPODOSSOLOS
- GLEISSOLOS
- LATOSSOLOS
- LUVISSOLOS
- NEOSSOLOS
- NITOSSOLOS
- ORGANOSSOLOS
- PLANOSSOLOS
- PLINTOSSOLOS
- VERTISSOLOS

## Additional Resources

- Metadata: http://geoinfo.cnps.embrapa.br/layers/geonode%3Abrasil_solos_5m_20201104/metadata_read
- SiBCS Classification: https://www.embrapa.br/solos/sibcs/classificacao-de-solos

## Dependencies

```r
tidyverse, data.table, janitor, geobr, sf, viridis
```

## Author

- Mariana Stussi
