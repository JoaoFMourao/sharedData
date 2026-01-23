# Road PNLT - Brazilian Road Network

Scripts for processing Brazilian road network data from PNLT/DNIT.

## Overview

Spatial line data representing Brazil's road network segments, including federal and state highways. Data includes road surface type, administrative jurisdiction, and segment characteristics.

## Directory Structure

```
road_pnlt/
├── documentation/
│   ├── _metadata.txt
│   ├── original_DNIT__rodovias_terminologia_v1.1.pdf
│   └── 202304/
│       ├── Guia SNV_202304A.pdf
│       └── SNV_202304A.xls
└── code/
    ├── r2c_inf_trsnp_brl_road_pnlt.R        # 2023 data
    ├── r2c_inf_trsnp_brl_road_pnlt_2010.R   # 2010 data
    └── r2c_inf_trsnp_brl_road_pnlt_2018.R   # 2018 data
```

## Scripts

| Script | Year | Source | Description |
|--------|------|--------|-------------|
| `r2c_inf_trsnp_brl_road_pnlt_2010.R` | 2010 | PNLT | Clean road segments shapefile |
| `r2c_inf_trsnp_brl_road_pnlt_2018.R` | 2018 | DNIT | Clean road segments shapefile |
| `r2c_inf_trsnp_brl_road_pnlt.R` | 2023 | DNIT | Clean SNV_202304A shapefile |

## Workflow

1. Read raw shapefile (road segments)
2. Rename columns to standardized English names
3. Convert Latin characters to ASCII
4. Adjust column types (numeric for km, extensions)
5. Add variable labels
6. Export cleaned spatial data

## Data Sources

| Year | Source | URL |
|------|--------|-----|
| 2010 | PNLT (Ministério dos Transportes) | http://pnlt.imagem-govfed.opendata.arcgis.com/ |
| 2018 | DNIT | http://servicos.dnit.gov.br/dnitcloud/ |
| 2023 | DNIT (SNV) | https://servicos.dnit.gov.br/dnitcloud/ |

## Output Variables

| Variable | Description |
|----------|-------------|
| `road_id` | Segment identifier |
| `road_number` | Road number (BR-XXX) |
| `state_uf` | State abbreviation |
| `road_code` | Segment code |
| `road_km_initial` | Segment start (km) |
| `road_km_final` | Segment end (km) |
| `road_extension` | Segment length (km) |
| `road_surface_type` | Surface type (paved, unpaved, planned) |
| `road_fed_surface_type` | Federal segment surface type |
| `road_sta_surface_type` | State segment surface type |
| `road_admin` | Administrative jurisdiction |
| `road_fed_categ` | Federal segment category |
| `road_work` | Ongoing works description |
| `road_legal_act` | Legal act reference |

## Surface Types

| Portuguese | English |
|------------|---------|
| Pavimentada | Paved |
| Duplicada | Double lane |
| Implantada | Implanted |
| Leito Natural | Unpaved |
| Planejada | Planned |
| Em obra de Pavimentação | Ongoing paving |
| Em obra de Duplicação | Ongoing lane doubling |

## CRS

- **2010**: WGS84, LongLat (not projected)
- **2018**: GRS80, LongLat (not projected)
- **2023**: WGS84, LongLat (not projected)

## Dependencies

```r
sf, sp, rgdal, rgeos, tidyverse, Hmisc
```

## Author

- João Vieira

**Project Lead**: Clarissa Gandour
