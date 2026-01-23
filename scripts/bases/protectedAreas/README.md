# Protected Areas - Conservation Units

Scripts for processing Brazilian conservation units (Unidades de Conservação) data.

## Overview

Conservation units are legally protected areas designated for biodiversity conservation, including national parks, biological reserves, environmental protection areas, and other categories at federal, state, and municipal levels.

## Scripts

| Script | Description |
|--------|-------------|
| `r2c_pol_prtTe_brl_protectedAreas_mma.R` | Clean MMA protected areas shapefile |
| `blt_pol_prtTe_amz_protectedAreas_stateFederal_sf.R` | Build Amazon state/federal PA dataset |

## Data Source

- **Provider**: MMA / CNUC (Cadastro Nacional de Unidades de Conservação)
- **URL**: https://dados.gov.br/dados/conjuntos-dados/unidadesdeconservacao
- **Download Date**: Jan/2025
- **CRS**: SIRGAS 2000 (EPSG:4674)

## Categories

**Integral Protection:**
- Biological Reserve (REBIO)
- Ecological Station (ESEC)
- National/State Park (PARNA/PE)
- Natural Monument (MN)
- Wildlife Refuge (RVS)

**Sustainable Use:**
- Environmental Protection Area (APA)
- National/State Forest (FLONA/FLOE)
- Extractive Reserve (RESEX)
- Sustainable Development Reserve (RDS)

## Dependencies

```r
sf, tidyverse, geobr
```
