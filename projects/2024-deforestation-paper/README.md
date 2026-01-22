# 2024 Deforestation Drivers Analysis

**Author:** FGV Clima Team
**Date:** 2024-01-01
**Status:** In Progress

## Objectives

Analysis of deforestation drivers in the Brazilian Amazon:

1. Identify spatial patterns of deforestation
2. Analyze socioeconomic and environmental drivers
3. Evaluate effectiveness of protected areas
4. Model future deforestation scenarios

## Data Sources

| Source | Category | Path | Version |
|--------|----------|------|---------|
| PRODES | Deforestation | `../../data-hub/land-use/prodes/` | 2023 |
| DETER | Alerts | `../../data-hub/land-use/deter/` | 2023 |
| MapBiomas | Land Use | `../../data-hub/land-use/mapbiomas/` | Collection 8 |
| IBGE | Census | `../../data-hub/socioeconomic/ibge/` | 2022 |
| IBGE | Boundaries | `../../data-hub/geospatial/boundaries/` | 2022 |

## Methods

### Spatial Analysis
- Hot spot analysis of deforestation clusters
- Distance to roads, rivers, and urban centers
- Protected area buffer analysis

### Statistical Modeling
- Panel regression with municipality fixed effects
- Spatial econometric models
- Random forest for driver importance

### Scenario Analysis
- Business-as-usual projection
- Policy intervention scenarios
- Climate change impacts

## Project Structure

```
2024-deforestation-paper/
├── README.md
├── notebooks/
│   ├── 01-data-preparation.ipynb
│   ├── 02-spatial-analysis.ipynb
│   ├── 03-econometric-model.ipynb
│   └── 04-scenarios.ipynb
├── src/
│   ├── preprocessing.py
│   ├── spatial.py
│   ├── models.py
│   └── scenarios.py
├── results/
│   ├── figures/
│   └── tables/
└── reports/
    └── manuscript.pdf
```

## How to Reproduce

```bash
# 1. Setup environment
cd projects/2024-deforestation-paper
pip install -r requirements.txt

# 2. Download data
python ../../scripts/download_data.py --sources prodes,deter,mapbiomas,ibge

# 3. Run preprocessing
python src/preprocessing.py

# 4. Run analysis notebooks
jupyter nbconvert --execute notebooks/*.ipynb
```

## Contact

- FGV Clima: clima@fgv.br
