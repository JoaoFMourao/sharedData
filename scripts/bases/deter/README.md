# DETER - Real-Time Deforestation Detection

Scripts for processing DETER (Detecção do Desmatamento em Tempo Real) data from INPE.

## Overview

DETER is INPE's near real-time deforestation alert system for the Legal Amazon. It provides rapid detection of deforestation and degradation hotspots to support enforcement actions.

## Directory Structure

```
deter/
├── deterA/     # Original DETER system (2004-2016)
└── deterB/     # Updated DETER-B system (2015+)
```

## DETER-A (2004-2016)

| Script | Description |
|--------|-------------|
| `r2c_lcv_alert_laz_deterAAlert_inpe.R` | Clean DETER-A alerts and cloud masks |

- Monthly aggregated data (generated daily)
- Includes both deforestation alerts and cloud coverage
- CRS varies by period (SAD69 → SIRGAS2000)

## DETER-B (2015+)

| Script | Description |
|--------|-------------|
| `r2c_lcv_alert_laz_deterB_inpe.R` | Clean DETER-B alerts |
| `r2c_lcv_alert_laz_deterB_inpe_notPublic_cumulative.R` | Process non-public cumulative data |

- Improved methodology with degradation classification
- Higher spatial resolution
- Distinguishes deforestation from degradation classes

## Data Source

- **Provider**: INPE (Instituto Nacional de Pesquisas Espaciais)
- **URL**: http://terrabrasilis.dpi.inpe.br/
- **Coverage**: Legal Amazon
- **Frequency**: Daily (published monthly for DETER-A)

## CRS History

| Period | CRS |
|--------|-----|
| 2006-2010 | SAD69 LongLat |
| 2011 - Jul/2015 | SAD69 LongLat (pre-1996 BR) |
| Aug/2015+ | SIRGAS 2000 LongLat |

## Dependencies

```r
sf, sp, rgdal, rgeos, tidyverse, Hmisc
```
