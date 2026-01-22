"""
Data Loaders for FGV Clima

This module provides functions to load data from various sources
used in climate and environmental research.

Available loaders:
    - mapbiomas: Land use and land cover data
    - seeg: Greenhouse gas emissions data
    - era5: Climate reanalysis data
    - ibge: Socioeconomic and geographic data
    - prodes: Deforestation data
    - inmet: Weather station data
"""

from .mapbiomas import load_mapbiomas, load_mapbiomas_statistics
from .seeg import load_seeg, load_seeg_by_sector
from .era5 import load_era5, load_era5_variable
from .ibge import (
    load_ibge_boundaries,
    load_municipalities,
    load_states,
    load_biomes,
    load_ibge_data,
)
from .prodes import load_prodes, load_deter
from .inmet import load_inmet_stations, load_inmet_data

__all__ = [
    "load_mapbiomas",
    "load_mapbiomas_statistics",
    "load_seeg",
    "load_seeg_by_sector",
    "load_era5",
    "load_era5_variable",
    "load_ibge_boundaries",
    "load_municipalities",
    "load_states",
    "load_biomes",
    "load_ibge_data",
    "load_prodes",
    "load_deter",
    "load_inmet_stations",
    "load_inmet_data",
]
