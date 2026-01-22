# Contributing to FGV Clima Research Repository

Thank you for contributing to FGV Clima's research infrastructure. This document provides guidelines for collaboration.

## Table of Contents

- [Git Workflow](#git-workflow)
- [Branch Naming](#branch-naming)
- [Adding New Data Sources](#adding-new-data-sources)
- [Creating New Projects](#creating-new-projects)
- [Code Style Guidelines](#code-style-guidelines)
- [Pull Request Process](#pull-request-process)

---

## Git Workflow

We use a simplified Git Flow workflow:

```
main (protected)
  └── develop
        ├── feature/add-chirps-loader
        ├── project/2024-climate-report
        └── fix/mapbiomas-crs-issue
```

### Branches

- **main**: Production-ready code. Protected, requires PR approval.
- **develop**: Integration branch for features.
- **feature/**: New features or data sources.
- **project/**: Project-specific work.
- **fix/**: Bug fixes.

### Basic Workflow

1. Create a branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "Add: description of changes"
   ```

3. Push and create a Pull Request:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Request review and merge to `develop`.

---

## Branch Naming

Use descriptive, lowercase names with hyphens:

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/description` | `feature/add-era5-loader` |
| Project | `project/YYYY-name` | `project/2024-climate-report` |
| Bug fix | `fix/description` | `fix/mapbiomas-crs-issue` |
| Documentation | `docs/description` | `docs/update-data-catalog` |

---

## Adding New Data Sources

### Step 1: Create Data Directory

```bash
mkdir -p data-hub/{category}/{source-name}
```

Categories: `climate`, `land-use`, `emissions`, `socioeconomic`, `geospatial`

### Step 2: Add to Data Catalog

Update `data-hub/README.md` with:

```markdown
### Source Name

**Description of the data source**

| Attribute | Value |
|-----------|-------|
| **Source** | Organization name |
| **URL** | https://source-url.com |
| **Temporal Coverage** | Start - End |
| **Spatial Coverage** | Brazil / Global / etc. |
| **Format** | CSV, Parquet, NetCDF, etc. |
| **License** | License type |

**Data Dictionary:**
| Column | Description | Unit |
|--------|-------------|------|
| col1 | Description | unit |
```

### Step 3: Create Loader Function

Add a new loader in `lib/loaders/`:

```python
# lib/loaders/new_source.py
"""
New Source Data Loader

Description of what this loader does.
"""

from pathlib import Path
from typing import Optional
import pandas as pd

from .. import DATA_HUB


def load_new_source(
    years: Optional[list] = None,
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load data from new source.

    Parameters
    ----------
    years : list of int, optional
        Years to load
    data_path : Path, optional
        Custom data path

    Returns
    -------
    pd.DataFrame
        Loaded data
    """
    base_path = data_path or DATA_HUB / "category" / "new_source"
    # Implementation...
    pass
```

### Step 4: Update Loader Init

Add imports to `lib/loaders/__init__.py`:

```python
from .new_source import load_new_source

__all__ = [
    # existing exports...
    "load_new_source",
]
```

### Step 5: Add Download Script (if applicable)

Update `scripts/download_data.py` to include the new source.

---

## Creating New Projects

### Step 1: Create Project

```bash
python scripts/create_new_project.py "YYYY-project-name"
```

Or manually:

```bash
cp -r templates/project-template projects/YYYY-my-project
```

### Step 2: Update Project README

Fill in the template with:

- Research objectives
- Data sources (with paths to data-hub)
- Methodology
- How to reproduce

### Step 3: Follow Project Structure

```
projects/YYYY-project-name/
├── README.md          # Required
├── notebooks/         # Exploratory analysis
├── src/               # Project-specific code
├── results/           # Outputs
└── reports/           # Final documents
```

### Step 4: Reference Shared Resources

```python
# Use shared data
from lib.loaders import load_mapbiomas

# Use relative paths for data
data_path = Path("../../data-hub/land-use/mapbiomas/")

# Use shared visualization
from lib.viz import set_fgv_theme
set_fgv_theme()
```

---

## Code Style Guidelines

### Python

- Follow PEP 8
- Use type hints
- Write docstrings (NumPy style)
- Maximum line length: 100 characters

```python
def calculate_emissions(
    df: pd.DataFrame,
    sector: str,
    year: int,
) -> float:
    """
    Calculate total emissions for a sector and year.

    Parameters
    ----------
    df : pd.DataFrame
        Emissions data
    sector : str
        Sector name
    year : int
        Year to calculate

    Returns
    -------
    float
        Total emissions in tCO2e
    """
    return df[(df["sector"] == sector) & (df["year"] == year)]["emissions"].sum()
```

### R

- Follow tidyverse style guide
- Use roxygen2 for documentation
- Prefer tidyverse functions

```r
#' Calculate total emissions
#'
#' @param df Emissions data frame
#' @param sector Sector name
#' @param year Year to calculate
#' @return Total emissions in tCO2e
calculate_emissions <- function(df, sector, year) {
  df |>
    filter(sector == !!sector, year == !!year) |>
    summarise(total = sum(emissions)) |>
    pull(total)
}
```

### General Guidelines

- Write clear, self-documenting code
- Add comments only when necessary
- Keep functions small and focused
- Use meaningful variable names
- Avoid hardcoded values - use constants or config files

---

## Pull Request Process

### Before Submitting

1. **Test your changes**: Ensure code runs without errors
2. **Update documentation**: Update READMEs if needed
3. **Check data paths**: Verify relative paths are correct
4. **Review diff**: Check for unintended changes

### PR Template

When creating a PR, include:

```markdown
## Description
[What does this PR do?]

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation
- [ ] New data source
- [ ] New project

## Data Sources Affected
- [ ] MapBiomas
- [ ] SEEG
- [ ] ERA5
- [ ] Other: ___

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests pass (if applicable)
- [ ] No hardcoded paths
```

### Review Process

1. Submit PR to `develop` branch
2. Request review from team member
3. Address feedback
4. Merge after approval

---

## Questions?

- Open an issue for questions
- Contact: clima@fgv.br
- Check existing issues and PRs for similar topics
