# Data Catalog

The complete data catalog is maintained in the data-hub directory.

**See: [data-hub/README.md](../data-hub/README.md)**

## Quick Reference

### Data Categories

| Category | Directory | Description |
|----------|-----------|-------------|
| Climate | `data-hub/climate/` | ERA5, CMIP6, INMET, CHIRPS |
| Land Use | `data-hub/land-use/` | MapBiomas, PRODES, DETER |
| Emissions | `data-hub/emissions/` | SEEG, SIRENE |
| Socioeconomic | `data-hub/socioeconomic/` | IBGE, PNAD, DATASUS |
| Geospatial | `data-hub/geospatial/` | Administrative boundaries, biomes |

### Loading Data

```python
from lib.loaders import (
    load_mapbiomas,
    load_seeg,
    load_era5,
    load_ibge_boundaries,
    load_prodes,
    load_inmet_data,
)
```

### Available Loaders

See [lib/loaders/](../lib/loaders/) for all available data loading functions.
