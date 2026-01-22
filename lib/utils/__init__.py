"""
Utility Functions for FGV Clima

This module provides common helper functions used across
FGV Clima research projects.

Available utilities:
    - paths: Path management and data discovery
    - io: File I/O operations
    - validation: Data validation and quality checks
    - brazil: Brazil-specific utilities (IBGE codes, biomes, etc.)
"""

from .paths import (
    get_data_path,
    get_project_path,
    list_available_data,
    ensure_dir,
)
from .io import (
    read_parquet_lazy,
    save_with_metadata,
    load_config,
)
from .validation import (
    validate_crs,
    validate_ibge_code,
    check_data_quality,
)
from .brazil import (
    get_state_name,
    get_state_code,
    get_region,
    get_biome,
    STATES,
    REGIONS,
    BIOMES,
)

__all__ = [
    # Paths
    "get_data_path",
    "get_project_path",
    "list_available_data",
    "ensure_dir",
    # I/O
    "read_parquet_lazy",
    "save_with_metadata",
    "load_config",
    # Validation
    "validate_crs",
    "validate_ibge_code",
    "check_data_quality",
    # Brazil
    "get_state_name",
    "get_state_code",
    "get_region",
    "get_biome",
    "STATES",
    "REGIONS",
    "BIOMES",
]
