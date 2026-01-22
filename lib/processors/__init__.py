"""
Data Processors for FGV Clima

This module provides functions for data transformation, spatial operations,
and temporal aggregations commonly used in climate research.

Available processors:
    - spatial: Spatial operations (clip, buffer, overlay, area calculations)
    - temporal: Temporal aggregations (monthly, annual, seasonal)
    - raster: Raster operations (zonal statistics, resampling)
    - tabular: DataFrame transformations and aggregations
"""

from .spatial import (
    clip_to_boundary,
    calculate_area,
    spatial_join,
    reproject,
    buffer_geometry,
)
from .temporal import (
    aggregate_monthly,
    aggregate_annual,
    aggregate_seasonal,
    calculate_anomaly,
    calculate_climatology,
)
from .raster import (
    zonal_statistics,
    resample_raster,
    rasterize_vector,
    extract_values,
)
from .tabular import (
    aggregate_by_region,
    pivot_long_to_wide,
    merge_with_geometry,
    standardize_ibge_codes,
)

__all__ = [
    # Spatial
    "clip_to_boundary",
    "calculate_area",
    "spatial_join",
    "reproject",
    "buffer_geometry",
    # Temporal
    "aggregate_monthly",
    "aggregate_annual",
    "aggregate_seasonal",
    "calculate_anomaly",
    "calculate_climatology",
    # Raster
    "zonal_statistics",
    "resample_raster",
    "rasterize_vector",
    "extract_values",
    # Tabular
    "aggregate_by_region",
    "pivot_long_to_wide",
    "merge_with_geometry",
    "standardize_ibge_codes",
]
