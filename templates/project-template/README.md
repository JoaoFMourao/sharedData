# [Project Title]

**Author:** [Your Name]
**Date:** [YYYY-MM-DD]
**Status:** [Planning | In Progress | Completed | Published]

## Objectives

[Describe the main research objectives and questions this project aims to address]

1. Objective 1
2. Objective 2
3. Objective 3

## Data Sources

This project uses the following data from `data-hub/`:

| Source | Category | Path | Version/Date |
|--------|----------|------|--------------|
| MapBiomas | Land Use | `../../data-hub/land-use/mapbiomas/` | Collection 8 |
| SEEG | Emissions | `../../data-hub/emissions/seeg/` | v10 |
| IBGE | Boundaries | `../../data-hub/geospatial/boundaries/` | 2022 |

## Methods

[Brief description of the methodology]

### Analysis Steps

1. Step 1: Data preparation
2. Step 2: Analysis
3. Step 3: Visualization
4. Step 4: Report generation

## Project Structure

```
project-name/
├── README.md           # This file
├── notebooks/          # Jupyter/R notebooks for exploration
│   └── 01-exploration.ipynb
├── src/                # Project-specific source code
│   └── analysis.py
├── results/            # Output files (figures, tables)
│   ├── figures/
│   └── tables/
└── reports/            # Final reports and papers
    └── report.pdf
```

## How to Reproduce

### Prerequisites

- Python 3.9+ or R 4.0+
- Access to FGV Clima data-hub

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/fgv-clima/sharedData.git
   cd sharedData
   ```

2. Install dependencies:
   ```bash
   # Python
   pip install -r requirements.txt

   # R
   renv::restore()
   ```

3. Download required data:
   ```bash
   python scripts/download_data.py --sources mapbiomas,seeg,ibge
   ```

### Running the Analysis

```bash
# Option 1: Run notebooks in order
jupyter notebook notebooks/01-exploration.ipynb

# Option 2: Run the main script
python src/main.py
```

## Results

[Summary of key findings - can be updated as project progresses]

### Key Findings

1. Finding 1
2. Finding 2
3. Finding 3

### Figures

- [Figure 1](results/figures/figure1.png): Description
- [Figure 2](results/figures/figure2.png): Description

## References

[List key references and data sources]

1. MapBiomas Project - https://mapbiomas.org/
2. SEEG - https://seeg.eco.br/

## Citation

If you use this analysis, please cite:

```bibtex
@misc{author2024project,
  author = {Author Name},
  title = {Project Title},
  year = {2024},
  publisher = {FGV Clima},
  url = {https://github.com/fgv-clima/sharedData/tree/main/projects/project-name}
}
```

## Contact

- **Author:** [Your Name] - [email@fgv.br]
- **FGV Clima:** [clima@fgv.br](mailto:clima@fgv.br)
