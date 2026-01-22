"""
Visualization Utilities for FGV Clima

This module provides visualization tools with FGV Clima styling,
including color palettes, themes, and standard plot types.

Available components:
    - theme: FGV Clima matplotlib/seaborn theme
    - colors: Color palettes for different data types
    - maps: Map plotting utilities
    - charts: Standard chart types (time series, bar charts, etc.)
"""

from .theme import (
    set_fgv_theme,
    get_fgv_colors,
    FGV_PALETTE,
)
from .colors import (
    LAND_USE_COLORS,
    BIOME_COLORS,
    SEQUENTIAL_PALETTES,
    DIVERGING_PALETTES,
)
from .maps import (
    plot_brazil_map,
    plot_choropleth,
    add_scalebar,
    add_north_arrow,
)
from .charts import (
    plot_time_series,
    plot_bar_chart,
    plot_stacked_area,
    plot_heatmap,
)

__all__ = [
    # Theme
    "set_fgv_theme",
    "get_fgv_colors",
    "FGV_PALETTE",
    # Colors
    "LAND_USE_COLORS",
    "BIOME_COLORS",
    "SEQUENTIAL_PALETTES",
    "DIVERGING_PALETTES",
    # Maps
    "plot_brazil_map",
    "plot_choropleth",
    "add_scalebar",
    "add_north_arrow",
    # Charts
    "plot_time_series",
    "plot_bar_chart",
    "plot_stacked_area",
    "plot_heatmap",
]
