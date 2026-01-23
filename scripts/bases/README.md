# Bases - Data Cleaning Scripts

Reusable scripts for cleaning and processing datasets of general interest across multiple projects.

## Available Datasets

### Land & Environment

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `prodes/` | PRODES Deforestation | INPE | Annual deforestation polygons by biome |
| `deter/` | DETER Alerts | INPE | Real-time deforestation/degradation detection |
| `degradation/` | DEGRAD | INPE | Forest degradation mapping (2007-2016) |
| `queimadas - inpe/` | Active Fires | INPE | Fire hotspots from satellite imagery |
| `landUse_terraclass/` | TerraClass | INPE/Embrapa | Land use in deforested areas |
| `secondary_Vegetation/` | FLORESER | Imazon | Secondary vegetation age (1986-2019) |
| `nonforrest_terrabrasilis/` | Non-Forest Mask | INPE | Non-forest vegetation in Amazon |
| `Mapa de solos do Brasil - Embrapa/` | Soil Map | Embrapa | Soil types (SiBCS classification) |

### Property & Land Tenure

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `car/` | CAR | SICAR | Rural Environmental Registry |
| `lndTenure_imaflora/` | Land Tenure | Imaflora | Integrated land tenure atlas |
| `assentamentos/` | Rural Settlements | INCRA | Agrarian reform settlements |
| `quilom/` | Quilombola Territories | INCRA | Traditional community areas |
| `protectedAreas/` | Conservation Units | MMA/CNUC | Federal/state protected areas |
| `public_Forests/` | Public Forests | SFB | National public forest registry |

### Infrastructure

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `road_pnlt/` | Road Network | DNIT/PNLT | Brazilian highway segments |

### Energy

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `epe/` | Energy Data | EPE | Generation and consumption statistics |
| `ons/` | Grid Operations | ONS | Power plant generation data |

### Finance & Economy

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `sicor/` | Rural Credit | BCB | SICOR rural credit operations |
| `finbra/` | Municipal Finance | Tesouro Nacional | Municipal revenues (FINBRA) |
| `siop/` | Federal Budget | Min. Planejamento | Federal budget execution |

### Labor & Trade

| Directory | Dataset | Source | Description |
|-----------|---------|--------|-------------|
| `rais/` | Labor Market | MTE | Formal employment statistics |
| `secex/` | Foreign Trade | MDIC | Import/export data |

## Directory Structure

Each base typically follows this structure:

```
base_name/
├── _documentation/     # Metadata, manuals, data dictionaries
├── code/              # R scripts for data processing
│   ├── r2c_*.R        # Raw to clean scripts
│   ├── blt_*.R        # Build/merge scripts
│   └── old/           # Deprecated versions
└── _functions/        # Helper functions (if needed)
```

## Script Naming Conventions

| Prefix | Meaning |
|--------|---------|
| `r2c_` | Raw to Clean — initial data processing |
| `cln_` | Clean — data cleaning operations |
| `blt_` | Build — merge/aggregate datasets |
| `mrg_` | Merge — join with other data (e.g., municipalities) |

## Usage Notes

1. Each base has its own README with specific documentation
2. Check `_documentation/` folders for metadata and data dictionaries
3. Update file paths and reference dates before running scripts
4. Raw data should be stored on SharePoint (`input/`), not in this repo

## Data Management

All raw and processed data should be stored on SharePoint:

```
Gestão de projetos > Técnico > 05-Base de dados
├── input/      # Raw data by source
└── output/
    ├── data/   # Cleaned datasets
    ├── figures/
    └── tables/
```

See the main repository [README](../../README.md) for full data management guidelines.
