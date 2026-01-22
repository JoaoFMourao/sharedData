# Data Catalog - FGV Clima Data Hub

This document catalogs all data sources available in the FGV Clima shared data repository. Each dataset includes metadata about coverage, licensing, and structure.

## Table of Contents

- [Climate Data](#climate-data)
  - [ERA5](#era5)
  - [CMIP6](#cmip6)
  - [INMET](#inmet)
  - [CHIRPS](#chirps)
- [Land Use Data](#land-use-data)
  - [MapBiomas](#mapbiomas)
  - [PRODES](#prodes)
  - [DETER](#deter)
- [Emissions Data](#emissions-data)
  - [SEEG](#seeg)
  - [SIRENE](#sirene)
- [Socioeconomic Data](#socioeconomic-data)
  - [IBGE](#ibge)
  - [PNAD](#pnad)
  - [DATASUS](#datasus)
- [Geospatial Data](#geospatial-data)
  - [Administrative Boundaries](#administrative-boundaries)
  - [Biomes](#biomes)
  - [Hydrography](#hydrography)

---

## Climate Data

### ERA5

**ECMWF Reanalysis v5 - Global Climate Reanalysis**

| Attribute | Value |
|-----------|-------|
| **Source** | Copernicus Climate Data Store |
| **URL** | https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels |
| **Temporal Coverage** | 1940 - present |
| **Temporal Resolution** | Hourly |
| **Spatial Coverage** | Global |
| **Spatial Resolution** | 0.25 x 0.25 degrees (~31 km) |
| **Format** | NetCDF (.nc) |
| **License** | Copernicus License - Free for research |
| **Update Frequency** | Monthly (5-day delay) |

**Available Variables:**
- `t2m` - 2m temperature (K)
- `tp` - Total precipitation (m)
- `u10`, `v10` - 10m wind components (m/s)
- `sp` - Surface pressure (Pa)
- `ssrd` - Surface solar radiation (J/m2)
- `r` - Relative humidity (%)

**Directory Structure:**
```
climate/era5/
├── raw/
│   ├── temperature/
│   ├── precipitation/
│   └── wind/
└── processed/
    └── brazil/
```

---

### CMIP6

**Coupled Model Intercomparison Project Phase 6**

| Attribute | Value |
|-----------|-------|
| **Source** | ESGF (Earth System Grid Federation) |
| **URL** | https://esgf-node.llnl.gov/projects/cmip6/ |
| **Temporal Coverage** | Historical (1850-2014), Projections (2015-2100) |
| **Temporal Resolution** | Monthly / Daily |
| **Spatial Coverage** | Global |
| **Spatial Resolution** | Model-dependent (typically 1-2 degrees) |
| **Format** | NetCDF (.nc) |
| **License** | CMIP6 Data License - Free for research |

**Scenarios (SSPs):**
- `SSP1-2.6` - Sustainability pathway
- `SSP2-4.5` - Middle of the road
- `SSP3-7.0` - Regional rivalry
- `SSP5-8.5` - Fossil-fueled development

**Directory Structure:**
```
climate/cmip6/
├── historical/
├── ssp126/
├── ssp245/
├── ssp370/
└── ssp585/
```

---

### INMET

**Instituto Nacional de Meteorologia - Weather Stations**

| Attribute | Value |
|-----------|-------|
| **Source** | INMET / BDMEP |
| **URL** | https://bdmep.inmet.gov.br/ |
| **Temporal Coverage** | 1961 - present |
| **Temporal Resolution** | Hourly / Daily |
| **Spatial Coverage** | Brazil (600+ stations) |
| **Format** | CSV |
| **License** | Public domain (Brazilian government) |
| **Update Frequency** | Daily |

**Available Variables:**
- Temperature (min, max, mean)
- Precipitation
- Relative humidity
- Wind speed and direction
- Solar radiation
- Atmospheric pressure

**Data Dictionary:**

| Column | Description | Unit |
|--------|-------------|------|
| `DC_NOME` | Station name | - |
| `CD_ESTACAO` | Station code (INMET) | - |
| `DT_MEDICAO` | Measurement date | YYYY-MM-DD |
| `HR_MEDICAO` | Measurement hour | HH:MM |
| `TEMP_MIN` | Minimum temperature | C |
| `TEMP_MAX` | Maximum temperature | C |
| `PRECIPITACAO` | Precipitation | mm |

---

### CHIRPS

**Climate Hazards Group InfraRed Precipitation with Station**

| Attribute | Value |
|-----------|-------|
| **Source** | UC Santa Barbara Climate Hazards Center |
| **URL** | https://www.chc.ucsb.edu/data/chirps |
| **Temporal Coverage** | 1981 - present |
| **Temporal Resolution** | Daily / Pentad / Monthly |
| **Spatial Coverage** | 50S - 50N |
| **Spatial Resolution** | 0.05 degrees (~5.5 km) |
| **Format** | GeoTIFF (.tif), NetCDF (.nc) |
| **License** | Public domain |

---

## Land Use Data

### MapBiomas

**Annual Land Use and Land Cover Maps of Brazil**

| Attribute | Value |
|-----------|-------|
| **Source** | MapBiomas Project |
| **URL** | https://mapbiomas.org/ |
| **Temporal Coverage** | 1985 - present |
| **Temporal Resolution** | Annual |
| **Spatial Coverage** | Brazil |
| **Spatial Resolution** | 30m (Landsat-based) |
| **Format** | GeoTIFF (.tif), Google Earth Engine |
| **License** | CC BY-SA 4.0 |
| **Update Frequency** | Annual |

**Land Cover Classes (Collection 8):**

| Code | Class | Description |
|------|-------|-------------|
| 1 | Forest | Native forest formations |
| 3 | Forest Formation | Dense, open, and mixed forests |
| 4 | Savanna Formation | Cerrado sensu stricto |
| 5 | Mangrove | Coastal mangrove forests |
| 9 | Forest Plantation | Silviculture (eucalyptus, pine) |
| 12 | Grassland | Natural grasslands (campos) |
| 15 | Pasture | Planted pasture |
| 18 | Agriculture | Annual and perennial crops |
| 21 | Mosaic Agric./Pasture | Mixed agriculture/pasture |
| 23 | Beach and Dune | Coastal sand formations |
| 24 | Urban Infrastructure | Cities, roads, built areas |
| 25 | Other Non-Vegetated | Mining, bare soil |
| 26 | Water | Rivers, lakes, reservoirs |
| 27 | Non Observed | Clouds, no data |
| 33 | River, Lake, Ocean | Water bodies |

**Directory Structure:**
```
land-use/mapbiomas/
├── collection-8/
│   ├── coverage/           # Annual land cover maps
│   ├── transitions/        # Land use transition matrices
│   └── statistics/         # Pre-computed statistics by region
└── fire/                   # MapBiomas Fire collection
```

---

### PRODES

**Projeto de Monitoramento do Desmatamento na Amazonia Legal**

| Attribute | Value |
|-----------|-------|
| **Source** | INPE (National Institute for Space Research) |
| **URL** | http://terrabrasilis.dpi.inpe.br/downloads/ |
| **Temporal Coverage** | 1988 - present |
| **Temporal Resolution** | Annual (August to July) |
| **Spatial Coverage** | Legal Amazon, Cerrado |
| **Spatial Resolution** | 60m (minimum mapping unit: 6.25 ha) |
| **Format** | Shapefile (.shp), GeoPackage (.gpkg) |
| **License** | Public domain (Brazilian government) |
| **Update Frequency** | Annual |

**Data Dictionary:**

| Column | Description |
|--------|-------------|
| `state` | Brazilian state (UF) |
| `county` | Municipality name |
| `geocode` | IBGE municipality code |
| `year` | Deforestation year |
| `areakm` | Deforested area (km2) |
| `biome` | Biome (Amazonia, Cerrado) |

---

### DETER

**Sistema de Deteccao do Desmatamento em Tempo Real**

| Attribute | Value |
|-----------|-------|
| **Source** | INPE |
| **URL** | http://terrabrasilis.dpi.inpe.br/downloads/ |
| **Temporal Coverage** | 2004 - present |
| **Temporal Resolution** | Daily (near real-time) |
| **Spatial Coverage** | Legal Amazon, Cerrado |
| **Spatial Resolution** | Variable (min: 3 ha Amazon, 1 ha Cerrado) |
| **Format** | Shapefile (.shp), GeoPackage (.gpkg) |
| **License** | Public domain (Brazilian government) |
| **Update Frequency** | Daily |

**Alert Classes:**
- `DESMATAMENTO_CR` - Clear-cut deforestation
- `DESMATAMENTO_VEG` - Deforestation with vegetation
- `DEGRADACAO` - Forest degradation
- `MINERACAO` - Mining
- `CICATRIZ_DE_QUEIMADA` - Fire scar

---

## Emissions Data

### SEEG

**Sistema de Estimativas de Emissoes de Gases de Efeito Estufa**

| Attribute | Value |
|-----------|-------|
| **Source** | Observatorio do Clima |
| **URL** | https://seeg.eco.br/ |
| **Temporal Coverage** | 1970 - present |
| **Temporal Resolution** | Annual |
| **Spatial Coverage** | Brazil (national, state, municipality) |
| **Format** | CSV, Excel |
| **License** | CC BY 4.0 |
| **Update Frequency** | Annual |

**Sectors:**
1. **Energy** - Fuel combustion, fugitive emissions
2. **Industrial Processes** - Cement, chemicals, metals
3. **Agriculture** - Enteric fermentation, manure, soils
4. **Land Use Change** - Deforestation, forest fires
5. **Waste** - Landfills, wastewater

**Gases:**
- CO2 - Carbon dioxide
- CH4 - Methane
- N2O - Nitrous oxide
- HFCs - Hydrofluorocarbons
- PFCs - Perfluorocarbons
- SF6 - Sulfur hexafluoride

**Data Dictionary:**

| Column | Description | Unit |
|--------|-------------|------|
| `ano` | Year | YYYY |
| `nivel_1` | Sector | - |
| `nivel_2` | Subsector | - |
| `nivel_3` | Category | - |
| `uf` | State (if applicable) | - |
| `municipio` | Municipality (if applicable) | - |
| `emissao` | Emissions | t CO2e |
| `gas` | Gas type | - |

---

### SIRENE

**Sistema de Registro Nacional de Emissoes**

| Attribute | Value |
|-----------|-------|
| **Source** | Ministry of Environment (MMA) |
| **URL** | https://sirene.mctic.gov.br/ |
| **Temporal Coverage** | 1990 - present |
| **Temporal Resolution** | Annual |
| **Spatial Coverage** | Brazil |
| **Format** | CSV, PDF |
| **License** | Public domain (Brazilian government) |

**Note:** Official government GHG inventory, complementary to SEEG.

---

## Socioeconomic Data

### IBGE

**Instituto Brasileiro de Geografia e Estatistica**

| Attribute | Value |
|-----------|-------|
| **Source** | IBGE |
| **URL** | https://www.ibge.gov.br/ |
| **Coverage** | Brazil (national to census tract) |
| **Format** | CSV, JSON (SIDRA API) |
| **License** | Public domain (Brazilian government) |

**Main Datasets:**

#### Population Census (Censo Demografico)
- Years: 1970, 1980, 1991, 2000, 2010, 2022
- Variables: Population, demographics, education, income, housing

#### Agricultural Census (Censo Agropecuario)
- Years: 1970, 1975, 1980, 1985, 1996, 2006, 2017
- Variables: Farms, area, production, livestock, labor

#### GDP (PIB dos Municipios)
- Years: 2002 - present
- Variables: GDP by sector, per capita GDP

#### PAM (Producao Agricola Municipal)
- Years: 1974 - present
- Variables: Crop area, production, yield

**IBGE Codes:**
- **State (UF):** 2 digits (e.g., 33 = Rio de Janeiro)
- **Municipality:** 7 digits (e.g., 3304557 = Rio de Janeiro city)
- **Census tract:** 15 digits

---

### PNAD

**Pesquisa Nacional por Amostra de Domicilios**

| Attribute | Value |
|-----------|-------|
| **Source** | IBGE |
| **URL** | https://www.ibge.gov.br/estatisticas/sociais/trabalho/9171-pesquisa-nacional-por-amostra-de-domicilios-continua-mensal.html |
| **Temporal Coverage** | 2012 - present (Continua) |
| **Temporal Resolution** | Quarterly / Annual |
| **Spatial Coverage** | Brazil, regions, states |
| **Format** | CSV, microdata |
| **License** | Public domain |

**Key Variables:**
- Employment and labor force
- Income distribution
- Education levels
- Housing conditions

---

### DATASUS

**Departamento de Informatica do SUS**

| Attribute | Value |
|-----------|-------|
| **Source** | Ministry of Health |
| **URL** | https://datasus.saude.gov.br/ |
| **Temporal Coverage** | 1979 - present (varies by system) |
| **Spatial Coverage** | Brazil (national to municipality) |
| **Format** | DBC, CSV |
| **License** | Public domain (Brazilian government) |

**Main Systems:**
- **SIM** - Mortality Information System
- **SINASC** - Live Births Information System
- **SIH** - Hospital Information System
- **SINAN** - Notifiable Diseases Information System

---

## Geospatial Data

### Administrative Boundaries

**Official Boundaries from IBGE**

| Attribute | Value |
|-----------|-------|
| **Source** | IBGE Geociencias |
| **URL** | https://www.ibge.gov.br/geociencias/downloads-geociencias.html |
| **CRS** | SIRGAS 2000 (EPSG:4674) |
| **Format** | Shapefile (.shp), GeoPackage (.gpkg) |
| **License** | Public domain |

**Available Layers:**
```
geospatial/boundaries/
├── paises/           # Countries (South America)
├── regioes/          # Regions (5)
├── estados/          # States (27)
├── mesorregioes/     # Mesoregions (137)
├── microrregioes/    # Microregions (558)
├── municipios/       # Municipalities (5,570)
└── setores/          # Census tracts (~300,000)
```

---

### Biomes

**Brazilian Biome Boundaries**

| Attribute | Value |
|-----------|-------|
| **Source** | IBGE |
| **URL** | https://www.ibge.gov.br/geociencias/informacoes-ambientais/vegetacao.html |
| **CRS** | SIRGAS 2000 (EPSG:4674) |
| **Format** | Shapefile (.shp) |
| **License** | Public domain |

**Biomes:**
1. Amazonia (Amazon)
2. Cerrado (Savanna)
3. Mata Atlantica (Atlantic Forest)
4. Caatinga (Semi-arid)
5. Pampa (Grasslands)
6. Pantanal (Wetlands)

---

### Hydrography

**Water Bodies and Watersheds**

| Attribute | Value |
|-----------|-------|
| **Source** | ANA (National Water Agency) |
| **URL** | https://metadados.snirh.gov.br/geonetwork/ |
| **CRS** | SIRGAS 2000 (EPSG:4674) |
| **Format** | Shapefile (.shp), GeoPackage (.gpkg) |
| **License** | Public domain |

**Available Layers:**
- River networks
- Watersheds (Otto-Pfafstetter coding)
- Reservoirs
- Aquifers

---

## Data Management Guidelines

### File Naming Convention

```
{source}_{variable}_{spatial}_{temporal}_{version}.{ext}

Examples:
- mapbiomas_coverage_brazil_2022_col8.tif
- era5_temperature_brazil_2020-01_v1.nc
- seeg_emissions_brazil_1970-2022_v10.csv
```

### Coordinate Reference Systems

| Use Case | CRS | EPSG |
|----------|-----|------|
| Default (Brazil) | SIRGAS 2000 | 4674 |
| Web mapping | WGS 84 | 4326 |
| Area calculations | Albers Equal Area Brazil | 5641 |
| UTM (regional) | SIRGAS 2000 UTM | 31981-31985 |

### Data Updates

- Check for updates before starting new projects
- Document data version in project README
- Use data validation scripts: `python scripts/validate_data.py`

---

## Adding New Data Sources

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding new data sources to the catalog.

Required information:
1. Source name and organization
2. URL and access method
3. Temporal and spatial coverage
4. License and usage restrictions
5. Data dictionary
6. Loader function in `lib/loaders/`
