"""
FGV Clima Shared Library

This library provides common functions for data loading, processing,
visualization, and utilities used across FGV Clima research projects.

Modules:
    loaders: Functions to load data from various sources
    processors: Data transformation and spatial operations
    viz: Visualization utilities with FGV Clima styling
    utils: Common helper functions
"""

from pathlib import Path

# Library version
__version__ = "0.1.0"

# Root paths
LIB_ROOT = Path(__file__).parent
REPO_ROOT = LIB_ROOT.parent
DATA_HUB = REPO_ROOT / "data-hub"

# Default CRS for Brazil
DEFAULT_CRS = "EPSG:4674"  # SIRGAS 2000
