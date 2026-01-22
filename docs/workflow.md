# Research Workflow Guide

Best practices for conducting research using the FGV Clima infrastructure.

## Workflow Overview

```
1. Plan          2. Explore        3. Analyze        4. Document       5. Publish
   │                │                 │                 │                 │
   ▼                ▼                 ▼                 ▼                 ▼
Create project   Load data       Write analysis    Update README    Share results
Define goals     Explore in      Use shared lib    Create figures   Archive code
List data needs  notebooks       Version control   Write report     Cite properly
```

## Phase 1: Project Planning

### Create Your Project

```bash
python scripts/create_new_project.py "2024-your-project"
cd projects/2024-your-project
```

### Define Objectives

Update your `README.md` with:

1. **Research questions**: What are you trying to answer?
2. **Data requirements**: Which sources from data-hub?
3. **Methods**: What analytical approach?
4. **Expected outputs**: Papers, reports, visualizations?

### Check Data Availability

```python
from lib.utils import list_available_data

# See what's in data-hub
available = list_available_data()
for source in available:
    print(f"{source['source']}: {source['file_count']} files")
```

If you need data that's not available:
- Open a data source request issue
- Or add it yourself following CONTRIBUTING.md

## Phase 2: Data Exploration

### Use Notebooks for Exploration

Create notebooks in `notebooks/` for initial exploration:

```
notebooks/
├── 01-data-exploration.ipynb
├── 02-spatial-analysis.ipynb
└── 03-preliminary-results.ipynb
```

### Loading Data

```python
# In your notebook
from lib.loaders import load_mapbiomas, load_seeg, load_ibge_boundaries
from lib.viz import set_fgv_theme

# Set visualization theme
set_fgv_theme()

# Load data
mapbiomas = load_mapbiomas_statistics(years=[2018, 2019, 2020, 2021, 2022])
emissions = load_seeg(spatial_level="state")
states = load_ibge_boundaries("estados")
```

### Exploring Relationships

```python
from lib.processors import merge_with_geometry, aggregate_by_region

# Aggregate emissions by state
state_emissions = aggregate_by_region(
    emissions,
    region_column="uf",
    value_columns=["emissions_tco2e"],
    agg_func="sum"
)

# Merge with geometry for mapping
state_data = merge_with_geometry(
    state_emissions,
    states,
    left_on="uf",
    right_on="sigla_uf"
)
```

## Phase 3: Analysis

### Move Code to src/

Once your analysis is refined, move reusable code to `src/`:

```
src/
├── __init__.py
├── analysis.py       # Main analysis functions
├── preprocessing.py  # Data preparation
└── figures.py        # Figure generation
```

### Write Modular Functions

```python
# src/analysis.py
from lib.loaders import load_seeg
from lib.processors import aggregate_annual

def calculate_emission_trends(start_year: int, end_year: int):
    """Calculate annual emission trends by sector."""
    emissions = load_seeg(
        years=list(range(start_year, end_year + 1)),
        spatial_level="national"
    )

    return aggregate_annual(
        emissions,
        date_column="year",
        value_columns=["emissions_tco2e"],
        agg_func="sum"
    )
```

### Use Version Control

```bash
# Create a branch for your work
git checkout -b project/2024-your-project

# Commit regularly
git add .
git commit -m "Add: emission trend analysis"

# Push to remote
git push origin project/2024-your-project
```

## Phase 4: Documentation

### Update Project README

Your README should answer:
- What was the objective?
- What data was used?
- How can results be reproduced?
- What are the key findings?

### Generate Results

Save outputs to `results/`:

```
results/
├── figures/
│   ├── fig1_emission_trends.png
│   ├── fig2_spatial_distribution.png
│   └── fig3_sector_comparison.png
└── tables/
    ├── table1_summary_statistics.csv
    └── table2_regression_results.csv
```

### Create Figures Script

```python
# src/figures.py
from lib.viz import set_fgv_theme, plot_time_series, save_figure
import matplotlib.pyplot as plt

def generate_all_figures():
    """Generate all publication-ready figures."""
    set_fgv_theme()

    # Figure 1: Emission trends
    fig, ax = plt.subplots()
    # ... plotting code ...
    save_figure(fig, "results/figures/fig1_emission_trends", formats=["png", "pdf"])

    # Figure 2: etc.
```

## Phase 5: Publication

### Prepare for Sharing

1. **Clean up code**: Remove debugging, add comments
2. **Test reproduction**: Can someone else run your code?
3. **Update README**: Final documentation
4. **Create requirements**: List all dependencies

### Cite Data Sources

Include citations for all data sources used:

```markdown
## Data Sources

- MapBiomas Collection 8 (mapbiomas.org)
- SEEG v10 (seeg.eco.br)
- IBGE Census 2022 (ibge.gov.br)
```

### Archive Your Work

```bash
# Merge to develop
git checkout develop
git merge project/2024-your-project

# Tag the release
git tag -a v1.0-your-project -m "Final version of analysis"
```

## Best Practices

### Data Management

- Never duplicate data from data-hub into your project
- Use relative paths: `../../data-hub/source/`
- Document data versions in your README

### Code Quality

- Write docstrings for functions
- Use type hints
- Keep functions focused and small
- Use shared code from `lib/` when possible

### Reproducibility

- List all dependencies
- Set random seeds if applicable
- Document environment setup
- Include step-by-step reproduction instructions

### Collaboration

- Use meaningful commit messages
- Create pull requests for review
- Document decisions and changes
- Share intermediate results with team

## Example Workflow

```python
# Complete example workflow

# 1. Setup
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from lib.loaders import load_seeg, load_ibge_boundaries
from lib.processors import aggregate_by_region, merge_with_geometry
from lib.viz import set_fgv_theme, plot_choropleth
import matplotlib.pyplot as plt

# 2. Load data
emissions = load_seeg(years=[2022], sectors=[4])  # Land use change
states = load_ibge_boundaries("estados")

# 3. Process
state_emissions = aggregate_by_region(
    emissions,
    region_column="uf",
    value_columns=["emissions_tco2e"],
    agg_func="sum"
)

geo_data = merge_with_geometry(
    state_emissions,
    states,
    left_on="uf",
    right_on="sigla_uf"
)

# 4. Visualize
set_fgv_theme()
fig, ax = plt.subplots(figsize=(12, 10))
plot_choropleth(
    geo_data,
    column="emissions_tco2e",
    title="Land Use Change Emissions by State (2022)",
    ax=ax
)

# 5. Save
fig.savefig("results/figures/emissions_map.png", dpi=300, bbox_inches="tight")
```

## Questions?

- Check documentation in `docs/`
- See example projects in `projects/`
- Open an issue or contact clima@fgv.br
