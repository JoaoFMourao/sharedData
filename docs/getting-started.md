# Getting Started with FGV Clima Research Repository

This guide will help you set up your environment and start working with the FGV Clima research infrastructure.

## Prerequisites

### Required Software

- **Git**: Version control
- **Python 3.9+** or **R 4.0+** (or both)
- **Code editor**: VS Code, RStudio, or your preference

### Recommended

- **GDAL**: For geospatial data processing
- **Jupyter**: For interactive notebooks

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/fgv-clima/sharedData.git
cd sharedData
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv .venv

# Activate (Linux/Mac)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Set Up R Environment (if using R)

```r
# Install renv if needed
install.packages("renv")

# Restore environment
renv::restore()
```

### 4. Download Data

```bash
# See available data sources
python scripts/download_data.py --list

# Download specific sources
python scripts/download_data.py --sources ibge,mapbiomas

# Download all
python scripts/download_data.py --all
```

## Repository Structure

```
sharedData/
├── data-hub/           # Centralized data (do not duplicate!)
│   ├── climate/
│   ├── land-use/
│   ├── emissions/
│   ├── socioeconomic/
│   └── geospatial/
├── lib/                # Shared code library
│   ├── loaders/        # Data loading functions
│   ├── processors/     # Data transformations
│   ├── viz/            # Visualization utilities
│   └── utils/          # Helper functions
├── projects/           # Research projects
└── templates/          # Project templates
```

## Quick Start Examples

### Loading Data

```python
# Import loaders
from lib.loaders import load_mapbiomas, load_seeg, load_ibge_boundaries

# Load MapBiomas statistics
mapbiomas = load_mapbiomas_statistics(years=[2020, 2021])

# Load SEEG emissions
emissions = load_seeg(years=[2020], sectors=[4])  # Land use change

# Load state boundaries
states = load_ibge_boundaries("estados")
```

### Using Visualization Theme

```python
from lib.viz import set_fgv_theme, plot_brazil_map
import matplotlib.pyplot as plt

# Apply FGV theme
set_fgv_theme()

# Create a map
ax = plot_brazil_map(states, column="pop_2022", title="Population by State")
plt.savefig("map.png")
```

### Creating a New Project

```bash
# Use the creation script
python scripts/create_new_project.py "2024-my-analysis"

# Or copy template manually
cp -r templates/project-template projects/2024-my-analysis
```

## Working with Projects

### Project Structure

Each project should follow this structure:

```
projects/2024-my-project/
├── README.md          # Required: objectives, methods, reproduction steps
├── notebooks/         # Exploratory analysis
├── src/               # Project-specific code
├── results/           # Outputs (figures, tables)
└── reports/           # Final documents
```

### Accessing Shared Data

From within a project, reference data-hub using relative paths:

```python
from pathlib import Path

# Get path to data
data_path = Path("../../data-hub/land-use/mapbiomas/")

# Or use the utility function
from lib.utils import get_data_path
data_path = get_data_path("mapbiomas")
```

### Importing Shared Code

```python
# Import loaders
from lib.loaders import load_mapbiomas

# Import processors
from lib.processors import zonal_statistics, aggregate_annual

# Import visualization
from lib.viz import set_fgv_theme, plot_time_series

# Import utilities
from lib.utils import validate_ibge_code, get_state_name
```

## Common Tasks

### Adding a New Data Source

1. Create directory: `mkdir -p data-hub/category/new-source`
2. Add documentation to `data-hub/README.md`
3. Create loader in `lib/loaders/new_source.py`
4. Update `lib/loaders/__init__.py`

See [CONTRIBUTING.md](../CONTRIBUTING.md) for detailed guidelines.

### Running Quality Checks

```bash
# Validate data
python scripts/validate_data.py

# Validate with verbose output
python scripts/validate_data.py --verbose
```

## Troubleshooting

### Import Errors

If you get import errors for `lib`:

```python
import sys
from pathlib import Path

# Add repo root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
```

### CRS Issues

The default CRS is SIRGAS 2000 (EPSG:4674). To convert:

```python
from lib.processors import reproject

gdf = reproject(gdf, "EPSG:4674")
```

### Missing Data

If data files are missing:

```bash
# Check what's available
python scripts/download_data.py --list

# Download specific source
python scripts/download_data.py --sources source_name
```

## Getting Help

- Check the [data catalog](../data-hub/README.md)
- Read the [workflow guide](workflow.md)
- See [CONTRIBUTING.md](../CONTRIBUTING.md) for collaboration guidelines
- Open an issue on GitHub
- Contact: clima@fgv.br
