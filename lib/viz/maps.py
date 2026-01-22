"""
Map Visualization Functions

Utilities for creating maps with FGV Clima styling.
"""

from typing import Optional, Union, Tuple, List
import numpy as np

try:
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyArrowPatch
    from mpl_toolkits.axes_grid1.anchored_artists import AnchoredSizeBar
    import matplotlib.font_manager as fm
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

try:
    import geopandas as gpd
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

from .theme import FGV_PALETTE, set_fgv_theme
from .colors import get_sequential_palette, BIOME_COLORS


def plot_brazil_map(
    gdf: "gpd.GeoDataFrame",
    column: Optional[str] = None,
    cmap: str = "Blues",
    legend: bool = True,
    title: Optional[str] = None,
    figsize: Tuple[int, int] = (12, 10),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a choropleth map of Brazil.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        GeoDataFrame with geometries
    column : str, optional
        Column to visualize
    cmap : str
        Colormap name
    legend : bool
        Whether to show legend
    title : str, optional
        Map title
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes to plot on
    **kwargs
        Additional arguments passed to gdf.plot()

    Returns
    -------
    plt.Axes
        Map axes

    Examples
    --------
    >>> states = load_states()
    >>> ax = plot_brazil_map(states, column="pop_2022", title="Population by State")
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    # Plot
    gdf.plot(
        column=column,
        cmap=cmap,
        legend=legend,
        ax=ax,
        edgecolor="white",
        linewidth=0.5,
        **kwargs,
    )

    # Styling
    ax.set_axis_off()
    if title:
        ax.set_title(title, fontsize=14, fontweight="bold", pad=10)

    return ax


def plot_choropleth(
    gdf: "gpd.GeoDataFrame",
    column: str,
    boundary: Optional["gpd.GeoDataFrame"] = None,
    scheme: str = "quantiles",
    k: int = 5,
    cmap: Optional[str] = None,
    legend: bool = True,
    legend_title: Optional[str] = None,
    title: Optional[str] = None,
    figsize: Tuple[int, int] = (12, 10),
    ax: Optional["plt.Axes"] = None,
) -> "plt.Axes":
    """
    Create a choropleth map with classification scheme.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        GeoDataFrame with data
    column : str
        Column to visualize
    boundary : gpd.GeoDataFrame, optional
        Boundary to overlay
    scheme : str
        Classification scheme: "quantiles", "equal_interval", "natural_breaks"
    k : int
        Number of classes
    cmap : str, optional
        Colormap name
    legend : bool
        Whether to show legend
    legend_title : str, optional
        Legend title
    title : str, optional
        Map title
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes

    Returns
    -------
    plt.Axes
        Map axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    if cmap is None:
        cmap = "Blues"

    # Plot choropleth
    gdf.plot(
        column=column,
        scheme=scheme,
        k=k,
        cmap=cmap,
        legend=legend,
        legend_kwds={"title": legend_title or column, "loc": "lower left"},
        ax=ax,
        edgecolor="white",
        linewidth=0.3,
    )

    # Add boundary overlay
    if boundary is not None:
        boundary.boundary.plot(ax=ax, color="black", linewidth=1)

    ax.set_axis_off()
    if title:
        ax.set_title(title, fontsize=14, fontweight="bold", pad=10)

    return ax


def add_scalebar(
    ax: "plt.Axes",
    length: float = 500,
    location: str = "lower right",
    units: str = "km",
) -> None:
    """
    Add a scale bar to a map.

    Parameters
    ----------
    ax : plt.Axes
        Map axes
    length : float
        Scale bar length in specified units
    location : str
        Scale bar location
    units : str
        Distance units
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    # Location mapping
    loc_map = {
        "lower right": 4,
        "lower left": 3,
        "upper right": 1,
        "upper left": 2,
    }

    scalebar = AnchoredSizeBar(
        ax.transData,
        length * 1000 if units == "km" else length,  # Convert to meters
        f"{length} {units}",
        loc_map.get(location, 4),
        pad=0.5,
        color="black",
        frameon=False,
        size_vertical=length * 10,
        fontproperties=fm.FontProperties(size=10),
    )

    ax.add_artist(scalebar)


def add_north_arrow(
    ax: "plt.Axes",
    location: Tuple[float, float] = (0.95, 0.95),
    size: float = 0.05,
) -> None:
    """
    Add a north arrow to a map.

    Parameters
    ----------
    ax : plt.Axes
        Map axes
    location : tuple
        Arrow location in axes coordinates (0-1)
    size : float
        Arrow size relative to axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    x, y = location

    # Draw arrow
    ax.annotate(
        "N",
        xy=(x, y - size),
        xytext=(x, y),
        fontsize=12,
        fontweight="bold",
        ha="center",
        va="center",
        xycoords="axes fraction",
        arrowprops=dict(arrowstyle="->", color="black", lw=2),
    )


def plot_biomes(
    biomes_gdf: "gpd.GeoDataFrame",
    highlight: Optional[List[str]] = None,
    show_labels: bool = True,
    figsize: Tuple[int, int] = (12, 10),
    ax: Optional["plt.Axes"] = None,
) -> "plt.Axes":
    """
    Plot Brazilian biomes with standard colors.

    Parameters
    ----------
    biomes_gdf : gpd.GeoDataFrame
        Biome boundaries
    highlight : list of str, optional
        Biomes to highlight
    show_labels : bool
        Whether to show biome labels
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes

    Returns
    -------
    plt.Axes
        Map axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    # Map biome names to colors
    biomes_gdf = biomes_gdf.copy()
    biomes_gdf["color"] = biomes_gdf["nome_bioma"].map(
        lambda x: BIOME_COLORS.get(x, "#CCCCCC")
    )

    # Adjust alpha for non-highlighted biomes
    if highlight:
        biomes_gdf["alpha"] = biomes_gdf["nome_bioma"].apply(
            lambda x: 1.0 if x in highlight else 0.3
        )
    else:
        biomes_gdf["alpha"] = 1.0

    # Plot each biome
    for _, row in biomes_gdf.iterrows():
        gpd.GeoDataFrame([row], crs=biomes_gdf.crs).plot(
            ax=ax,
            color=row["color"],
            alpha=row["alpha"],
            edgecolor="white",
            linewidth=0.5,
        )

    # Add labels
    if show_labels:
        for _, row in biomes_gdf.iterrows():
            centroid = row.geometry.centroid
            ax.annotate(
                row["nome_bioma"],
                xy=(centroid.x, centroid.y),
                ha="center",
                va="center",
                fontsize=10,
                fontweight="bold",
                color="white",
                path_effects=[
                    plt.matplotlib.patheffects.withStroke(linewidth=2, foreground="black")
                ],
            )

    ax.set_axis_off()
    ax.set_title("Brazilian Biomes", fontsize=14, fontweight="bold")

    return ax
