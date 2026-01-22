# FGV Clima - Research Data Repository

**Centro de Estudos em Sustentabilidade da Fundação Getulio Vargas**

This repository provides a centralized infrastructure for climate and environmental research at FGV Clima. It combines shared data resources with independent, reproducible research projects.

## Repository Structure

```
fgv-clima/
├── data-hub/          # Centralized data repository
│   ├── climate/       # ERA5, CMIP6, INMET, CHIRPS
│   ├── land-use/      # MapBiomas, PRODES, DETER
│   ├── emissions/     # SEEG, SIRENE
│   ├── socioeconomic/ # IBGE, PNAD, DATASUS
│   └── geospatial/    # Shapefiles (municipalities, states, biomes)
│
├── lib/               # Shared code library
│   ├── loaders/       # Data loading functions
│   ├── processors/    # Data transformations
│   ├── viz/           # Visualization utilities
│   └── utils/         # Common helpers
│
├── projects/          # Independent research projects
├── templates/         # Templates for new projects
├── scripts/           # Utility scripts
└── docs/              # Documentation
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/fgv-clima/sharedData.git
cd sharedData
```

### 2. Set Up Your Environment

**Python:**
```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows
pip install -r requirements.txt
```

**R:**
```r
renv::restore()
```

### 3. Download Data

```bash
# Download all data sources
python scripts/download_data.py --all

# Download specific sources
python scripts/download_data.py --sources mapbiomas,seeg,ibge
```

### 4. Start Working

Navigate to an existing project or create a new one:

```bash
python scripts/create_new_project.py "2024-my-analysis"
```

## How to Create a New Project

1. **Use the project creation script:**
   ```bash
   python scripts/create_new_project.py "YYYY-project-name"
   ```

2. **Or copy the template manually:**
   ```bash
   cp -r templates/project-template projects/YYYY-my-project
   ```

3. **Update the project README** with:
   - Research objectives
   - Data sources used (reference data-hub/)
   - Methods and analysis steps
   - How to reproduce results

4. **Follow the project structure:**
   ```
   projects/YYYY-my-project/
   ├── README.md          # Project documentation
   ├── notebooks/         # Exploratory analysis
   ├── src/               # Project-specific code
   ├── results/           # Outputs (figures, tables)
   └── reports/           # Final reports, papers
   ```

## Key Principles

### Data Centralization
- All raw and processed data lives in `data-hub/`
- Projects reference data via relative paths: `../../data-hub/land-use/mapbiomas/`
- Never duplicate data inside project folders

### Project Independence
- Each project must be reproducible standalone
- Document all dependencies and data sources
- Include reproduction instructions in project README

### Shared Code
- Common functions belong in `lib/`
- Project-specific code stays in `project/src/`
- Import shared code: `from lib.loaders import mapbiomas`

### Brazilian Context
- Default CRS: SIRGAS 2000 (EPSG:4674)
- Municipality codes follow IBGE 7-digit standard
- Biome boundaries from IBGE official limits

## Data Sources

See [data-hub/README.md](data-hub/README.md) for the complete data catalog with:
- Source descriptions and URLs
- Temporal and spatial coverage
- Licenses and usage restrictions
- Data dictionaries

### Main Sources

| Category | Sources |
|----------|---------|
| Climate | ERA5, CMIP6, INMET, CHIRPS |
| Land Use | MapBiomas, PRODES, DETER |
| Emissions | SEEG, SIRENE |
| Socioeconomic | IBGE, PNAD, DATASUS |
| Geospatial | IBGE boundaries, biomes, hydrography |

## Documentation

- [Getting Started](docs/getting-started.md) - Detailed setup instructions
- [Data Catalog](docs/data-catalog.md) - Complete data documentation
- [Workflow Guide](docs/workflow.md) - Best practices for research projects
- [Contributing](CONTRIBUTING.md) - How to contribute to this repository

## Projects

See [projects/README.md](projects/README.md) for the index of all research projects.

### Active Projects

| Project | Description | Status |
|---------|-------------|--------|
| [2024-annual-climate-report](projects/2024-annual-climate-report/) | Annual climate indicators report | In progress |
| [2024-deforestation-paper](projects/2024-deforestation-paper/) | Deforestation drivers analysis | In progress |

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Git workflow and branch naming
- How to add new data sources
- How to propose new projects
- Code style guidelines

## Citation

If you use this repository in your research, please cite:

```bibtex
@misc{fgvclima2024,
  author = {{FGV Clima}},
  title = {FGV Clima Research Data Repository},
  year = {2024},
  publisher = {GitHub},
  url = {https://github.com/fgv-clima/sharedData}
}
```

See [CITATION.cff](CITATION.cff) for the complete citation file.

## License

This repository is licensed under the [MIT License](LICENSE).

Note: Individual datasets in `data-hub/` may have different licenses. See each data source's documentation for specific terms.

## Contact

- **FGV Clima**: [https://clima.fgv.br](https://clima.fgv.br)
- **Email**: clima@fgv.br
- **Issues**: [GitHub Issues](https://github.com/fgv-clima/sharedData/issues)
