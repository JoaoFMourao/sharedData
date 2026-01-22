"""
Raster Processing Functions

Common raster operations for geospatial analysis.
"""

from pathlib import Path
from typing import Optional, Union, List, Dict
import numpy as np
import pandas as pd

try:
    import rasterio
    from rasterio.mask import mask
    from rasterio.warp import reproject, Resampling
    HAS_RASTERIO = True
except ImportError:
    HAS_RASTERIO = False

try:
    import geopandas as gpd
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

try:
    from rasterstats import zonal_stats as _zonal_stats
    HAS_RASTERSTATS = True
except ImportError:
    HAS_RASTERSTATS = False


def zonal_statistics(
    raster_path: Union[str, Path],
    zones: "gpd.GeoDataFrame",
    stats: List[str] = ["mean", "sum", "count"],
    categorical: bool = False,
    nodata: Optional[float] = None,
) -> pd.DataFrame:
    """
    Calculate zonal statistics for a raster using polygon zones.

    Parameters
    ----------
    raster_path : str or Path
        Path to raster file
    zones : gpd.GeoDataFrame
        Polygon zones for statistics
    stats : list of str
        Statistics to calculate: "mean", "sum", "min", "max", "count", "std"
    categorical : bool
        If True, calculates category counts (for land cover maps)
    nodata : float, optional
        NoData value to exclude

    Returns
    -------
    pd.DataFrame
        Statistics for each zone

    Examples
    --------
    >>> stats = zonal_statistics("mapbiomas_2020.tif", municipalities)
    >>> stats[["name", "mean", "sum"]]
    """
    if not HAS_RASTERSTATS:
        raise ImportError("rasterstats is required. Install: pip install rasterstats")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    # Ensure zones have the same CRS as raster
    with rasterio.open(raster_path) as src:
        raster_crs = src.crs
        if zones.crs != raster_crs:
            zones = zones.to_crs(raster_crs)

    # Calculate statistics
    if categorical:
        results = _zonal_stats(
            zones,
            str(raster_path),
            categorical=True,
            nodata=nodata,
        )
    else:
        results = _zonal_stats(
            zones,
            str(raster_path),
            stats=stats,
            nodata=nodata,
        )

    # Convert to DataFrame and merge with zone attributes
    stats_df = pd.DataFrame(results)
    zones_df = zones.drop(columns="geometry").reset_index(drop=True)

    return pd.concat([zones_df, stats_df], axis=1)


def resample_raster(
    input_path: Union[str, Path],
    output_path: Union[str, Path],
    target_resolution: float,
    method: str = "bilinear",
) -> None:
    """
    Resample a raster to a different resolution.

    Parameters
    ----------
    input_path : str or Path
        Path to input raster
    output_path : str or Path
        Path for output raster
    target_resolution : float
        Target resolution in CRS units
    method : str
        Resampling method: "nearest", "bilinear", "cubic"
    """
    if not HAS_RASTERIO:
        raise ImportError("rasterio is required")

    resampling_methods = {
        "nearest": Resampling.nearest,
        "bilinear": Resampling.bilinear,
        "cubic": Resampling.cubic,
    }

    with rasterio.open(input_path) as src:
        # Calculate new dimensions
        scale_factor = src.res[0] / target_resolution
        new_width = int(src.width * scale_factor)
        new_height = int(src.height * scale_factor)

        # Create new transform
        new_transform = src.transform * src.transform.scale(
            src.width / new_width,
            src.height / new_height,
        )

        # Read and resample
        data = src.read(
            out_shape=(src.count, new_height, new_width),
            resampling=resampling_methods.get(method, Resampling.bilinear),
        )

        # Update metadata
        kwargs = src.meta.copy()
        kwargs.update({
            "transform": new_transform,
            "width": new_width,
            "height": new_height,
        })

        # Write output
        with rasterio.open(output_path, "w", **kwargs) as dst:
            dst.write(data)


def rasterize_vector(
    gdf: "gpd.GeoDataFrame",
    output_path: Union[str, Path],
    value_column: str,
    resolution: float,
    bounds: Optional[tuple] = None,
    nodata: float = -9999,
) -> None:
    """
    Convert vector data to raster.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        Input vector data
    output_path : str or Path
        Path for output raster
    value_column : str
        Column with values to rasterize
    resolution : float
        Output resolution in CRS units
    bounds : tuple, optional
        Output bounds (minx, miny, maxx, maxy)
    nodata : float
        NoData value
    """
    if not HAS_RASTERIO:
        raise ImportError("rasterio is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    from rasterio.features import rasterize as rio_rasterize
    from rasterio.transform import from_bounds

    # Get bounds
    if bounds is None:
        bounds = gdf.total_bounds

    minx, miny, maxx, maxy = bounds

    # Calculate dimensions
    width = int((maxx - minx) / resolution)
    height = int((maxy - miny) / resolution)

    # Create transform
    transform = from_bounds(minx, miny, maxx, maxy, width, height)

    # Create shapes iterator
    shapes = ((geom, value) for geom, value in zip(gdf.geometry, gdf[value_column]))

    # Rasterize
    raster = rio_rasterize(
        shapes,
        out_shape=(height, width),
        transform=transform,
        fill=nodata,
        dtype="float32",
    )

    # Write output
    with rasterio.open(
        output_path,
        "w",
        driver="GTiff",
        height=height,
        width=width,
        count=1,
        dtype="float32",
        crs=gdf.crs,
        transform=transform,
        nodata=nodata,
    ) as dst:
        dst.write(raster, 1)


def extract_values(
    raster_path: Union[str, Path],
    points: "gpd.GeoDataFrame",
    band: int = 1,
) -> pd.DataFrame:
    """
    Extract raster values at point locations.

    Parameters
    ----------
    raster_path : str or Path
        Path to raster file
    points : gpd.GeoDataFrame
        Point locations
    band : int
        Raster band to extract from

    Returns
    -------
    pd.DataFrame
        Points with extracted values
    """
    if not HAS_RASTERIO:
        raise ImportError("rasterio is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    points = points.copy()

    with rasterio.open(raster_path) as src:
        # Ensure same CRS
        if points.crs != src.crs:
            points = points.to_crs(src.crs)

        # Extract coordinates
        coords = [(p.x, p.y) for p in points.geometry]

        # Sample raster
        values = [val[0] for val in src.sample(coords)]

    points["raster_value"] = values
    return points.drop(columns="geometry")


def clip_raster_to_boundary(
    raster_path: Union[str, Path],
    boundary: "gpd.GeoDataFrame",
    output_path: Union[str, Path],
    crop: bool = True,
) -> None:
    """
    Clip a raster to a boundary polygon.

    Parameters
    ----------
    raster_path : str or Path
        Path to input raster
    boundary : gpd.GeoDataFrame
        Boundary polygon
    output_path : str or Path
        Path for output raster
    crop : bool
        If True, crops raster extent to boundary
    """
    if not HAS_RASTERIO:
        raise ImportError("rasterio is required")
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    with rasterio.open(raster_path) as src:
        # Ensure same CRS
        if boundary.crs != src.crs:
            boundary = boundary.to_crs(src.crs)

        # Clip
        out_image, out_transform = mask(
            src,
            boundary.geometry,
            crop=crop,
            filled=True,
        )

        # Update metadata
        out_meta = src.meta.copy()
        out_meta.update({
            "height": out_image.shape[1],
            "width": out_image.shape[2],
            "transform": out_transform,
        })

        # Write output
        with rasterio.open(output_path, "w", **out_meta) as dst:
            dst.write(out_image)
