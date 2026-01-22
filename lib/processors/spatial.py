"""
Spatial Processing Functions

Common spatial operations for geographic data processing.
"""

from typing import Optional, Union, Tuple
import pandas as pd

try:
    import geopandas as gpd
    from shapely.geometry import box
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

from .. import DEFAULT_CRS


def clip_to_boundary(
    gdf: "gpd.GeoDataFrame",
    boundary: "gpd.GeoDataFrame",
    keep_geom_type: bool = True,
) -> "gpd.GeoDataFrame":
    """
    Clip a GeoDataFrame to a boundary.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Data to clip
    boundary : gpd.GeoDataFrame
        Boundary to clip to
    keep_geom_type : bool
        If True, keeps only geometries of the same type as input

    Returns
    -------
    gpd.GeoDataFrame
        Clipped data
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    # Ensure same CRS
    if gdf.crs != boundary.crs:
        boundary = boundary.to_crs(gdf.crs)

    return gpd.clip(gdf, boundary, keep_geom_type=keep_geom_type)


def calculate_area(
    gdf: "gpd.GeoDataFrame",
    unit: str = "km2",
    crs_for_area: str = "EPSG:5641",
) -> "gpd.GeoDataFrame":
    """
    Calculate area for each geometry in a GeoDataFrame.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Input GeoDataFrame
    unit : str
        Unit for area: "m2", "km2", "ha"
    crs_for_area : str
        Equal-area CRS for accurate calculations (default: Albers Brazil)

    Returns
    -------
    gpd.GeoDataFrame
        GeoDataFrame with 'area' column
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    gdf = gdf.copy()
    original_crs = gdf.crs

    # Project to equal-area CRS
    gdf_projected = gdf.to_crs(crs_for_area)

    # Calculate area in square meters
    area_m2 = gdf_projected.geometry.area

    # Convert to requested unit
    if unit == "m2":
        gdf["area"] = area_m2
    elif unit == "km2":
        gdf["area"] = area_m2 / 1e6
    elif unit == "ha":
        gdf["area"] = area_m2 / 1e4
    else:
        raise ValueError(f"Unknown unit: {unit}. Use 'm2', 'km2', or 'ha'")

    return gdf


def spatial_join(
    gdf: "gpd.GeoDataFrame",
    other: "gpd.GeoDataFrame",
    how: str = "inner",
    predicate: str = "intersects",
) -> "gpd.GeoDataFrame":
    """
    Perform a spatial join between two GeoDataFrames.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Left GeoDataFrame
    other : gpd.GeoDataFrame
        Right GeoDataFrame
    how : str
        Join type: "inner", "left", "right"
    predicate : str
        Spatial predicate: "intersects", "contains", "within"

    Returns
    -------
    gpd.GeoDataFrame
        Joined GeoDataFrame
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    # Ensure same CRS
    if gdf.crs != other.crs:
        other = other.to_crs(gdf.crs)

    return gpd.sjoin(gdf, other, how=how, predicate=predicate)


def reproject(
    gdf: "gpd.GeoDataFrame",
    target_crs: str = DEFAULT_CRS,
) -> "gpd.GeoDataFrame":
    """
    Reproject a GeoDataFrame to a target CRS.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Input GeoDataFrame
    target_crs : str
        Target CRS (default: SIRGAS 2000)

    Returns
    -------
    gpd.GeoDataFrame
        Reprojected GeoDataFrame
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    if gdf.crs is None:
        gdf = gdf.set_crs(DEFAULT_CRS)

    return gdf.to_crs(target_crs)


def buffer_geometry(
    gdf: "gpd.GeoDataFrame",
    distance: float,
    unit: str = "m",
    crs_for_buffer: str = "EPSG:5641",
) -> "gpd.GeoDataFrame":
    """
    Create buffer around geometries.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Input GeoDataFrame
    distance : float
        Buffer distance
    unit : str
        Distance unit: "m" or "km"
    crs_for_buffer : str
        Projected CRS for accurate buffering

    Returns
    -------
    gpd.GeoDataFrame
        Buffered GeoDataFrame
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    gdf = gdf.copy()
    original_crs = gdf.crs

    # Convert distance to meters
    if unit == "km":
        distance = distance * 1000

    # Project, buffer, and reproject back
    gdf_projected = gdf.to_crs(crs_for_buffer)
    gdf_projected["geometry"] = gdf_projected.buffer(distance)

    return gdf_projected.to_crs(original_crs)


def create_grid(
    bounds: Tuple[float, float, float, float],
    cell_size: float,
    crs: str = DEFAULT_CRS,
) -> "gpd.GeoDataFrame":
    """
    Create a regular grid over a bounding box.

    Parameters
    ----------
    bounds : tuple
        Bounding box (minx, miny, maxx, maxy)
    cell_size : float
        Grid cell size in CRS units
    crs : str
        Coordinate reference system

    Returns
    -------
    gpd.GeoDataFrame
        Grid as polygons
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    minx, miny, maxx, maxy = bounds
    cells = []

    x = minx
    while x < maxx:
        y = miny
        while y < maxy:
            cells.append(box(x, y, x + cell_size, y + cell_size))
            y += cell_size
        x += cell_size

    return gpd.GeoDataFrame({"geometry": cells}, crs=crs)


def dissolve_by_attribute(
    gdf: "gpd.GeoDataFrame",
    by: str,
    agg_dict: Optional[dict] = None,
) -> "gpd.GeoDataFrame":
    """
    Dissolve geometries by an attribute.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Input GeoDataFrame
    by : str
        Column to dissolve by
    agg_dict : dict, optional
        Aggregation functions for other columns

    Returns
    -------
    gpd.GeoDataFrame
        Dissolved GeoDataFrame
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    return gdf.dissolve(by=by, aggfunc=agg_dict or "first")
