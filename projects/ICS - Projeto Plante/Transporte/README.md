# 2024 Annual Climate Report

**Author:** FGV Clima Team
**Date:** 2024-01-01
**Status:** In Progress

## Objectives

Annual climate indicators report for Brazil, including:

1. Temperature and precipitation anomalies
2. Greenhouse gas emissions trends
3. Land use change and deforestation
4. Climate policy analysis

## Data Sources

| Source | Category | Path | Version |
|--------|----------|------|---------|
| ERA5 | Climate | `../../data-hub/climate/era5/` | 2023 |
| SEEG | Emissions | `../../data-hub/emissions/seeg/` | v10 |
| MapBiomas | Land Use | `../../data-hub/land-use/mapbiomas/` | Collection 8 |
| PRODES | Deforestation | `../../data-hub/land-use/prodes/` | 2023 |
| IBGE | Boundaries | `../../data-hub/geospatial/boundaries/` | 2022 |

## Methods

### Climate Analysis
- Temperature and precipitation anomalies relative to 1991-2020 baseline
- Seasonal analysis (DJF, MAM, JJA, SON)
- Regional breakdown by biome

### Emissions Analysis
- Sectoral emissions trends (1990-2023)
- Land use change contribution
- Comparison with NDC targets

### Land Use Analysis
- Annual deforestation rates by biome
- Land cover transitions
- Protected area effectiveness

## Project Structure

```
2024-annual-climate-report/
├── README.md
├── notebooks/
│   ├── 01-climate-analysis.ipynb
│   ├── 02-emissions-analysis.ipynb
│   └── 03-land-use-analysis.ipynb
├── src/
│   ├── climate.py
│   ├── emissions.py
│   └── figures.py
├── results/
│   ├── figures/
│   └── tables/
└── reports/
    └── annual-report-2024.pdf
```

## How to Reproduce

```bash
# 1. Setup environment
cd projects/2024-annual-climate-report
pip install -r requirements.txt

# 2. Download data
python ../../scripts/download_data.py --sources era5,seeg,mapbiomas,prodes,ibge

# 3. Run analysis
python src/main.py

# 4. Generate report
jupyter nbconvert --execute notebooks/*.ipynb
```

## Contact

- FGV Clima: clima@fgv.br
