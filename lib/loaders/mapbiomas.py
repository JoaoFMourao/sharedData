"""
MapBiomas Data Loader

Functions to load MapBiomas land use and land cover data.
Supports both raster (GeoTIFF) and pre-computed statistics.
"""

from pathlib import Path
from typing import Optional, Union, List
import pandas as pd

try:
    import geopandas as gpd
    import rasterio
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

from .. import DATA_HUB


# MapBiomas Collection 8 land cover classes
MAPBIOMAS_CLASSES = {
    1: "Forest",
    3: "Forest Formation",
    4: "Savanna Formation",
    5: "Mangrove",
    6: "Floodable Forest",
    9: "Forest Plantation",
    10: "Non Forest Natural Formation",
    11: "Wetland",
    12: "Grassland",
    13: "Other Non Forest Natural Formation",
    14: "Farming",
    15: "Pasture",
    18: "Agriculture",
    19: "Temporary Crops",
    20: "Sugar Cane",
    21: "Mosaic of Agriculture and Pasture",
    22: "Non Vegetated Area",
    23: "Beach and Dune",
    24: "Urban Infrastructure",
    25: "Other Non Vegetated Area",
    26: "Water",
    27: "Non Observed",
    29: "Rocky Outcrop",
    30: "Mining",
    31: "Aquaculture",
    32: "Salt Flat",
    33: "River, Lake and Ocean",
    34: "Glacier",
    35: "Oil Palm",
    36: "Perennial Crops",
    37: "Artificial Waterbody",
    38: "Water Reservoirs",
    39: "Soy Beans",
    40: "Rice",
    41: "Other Temporary Crops",
    42: "Coffee",
    43: "Citrus",
    44: "Cashew",
    45: "Other Perennial Crops",
    46: "Cotton",
    47: "Other Non Forest Natural Formation",
    48: "Wooded Restinga",
    49: "Other Restinga",
}


def load_mapbiomas(
    year: int,
    collection: str = "collection-8",
    region: Optional[str] = None,
    data_path: Optional[Path] = None,
) -> "rasterio.DatasetReader":
    """
    Load MapBiomas land cover raster for a given year.

    Parameters
    ----------
    year : int
        Year of the land cover map (1985-2022 for Collection 8)
    collection : str
        MapBiomas collection version (default: "collection-8")
    region : str, optional
        Region to load (e.g., "amazonia", "cerrado"). If None, loads Brazil.
    data_path : Path, optional
        Custom path to data directory. If None, uses DATA_HUB.

    Returns
    -------
    rasterio.DatasetReader
        Raster dataset reader

    Examples
    --------
    >>> raster = load_mapbiomas(2020)
    >>> data = raster.read(1)
    """
    if not HAS_GEO:
        raise ImportError("rasterio is required. Install with: pip install rasterio")

    base_path = data_path or DATA_HUB / "land-use" / "mapbiomas"

    if region:
        file_pattern = f"mapbiomas_coverage_{region}_{year}_{collection.replace('-', '')}.tif"
    else:
        file_pattern = f"mapbiomas_coverage_brazil_{year}_{collection.replace('-', '')}.tif"

    raster_path = base_path / collection / "coverage" / file_pattern

    if not raster_path.exists():
        raise FileNotFoundError(
            f"MapBiomas raster not found: {raster_path}\n"
            f"Run: python scripts/download_data.py --sources mapbiomas"
        )

    return rasterio.open(raster_path)


def load_mapbiomas_statistics(
    years: Optional[List[int]] = None,
    region_type: str = "municipality",
    biome: Optional[str] = None,
    collection: str = "collection-8",
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load pre-computed MapBiomas statistics by region.

    Parameters
    ----------
    years : list of int, optional
        Years to load. If None, loads all available years.
    region_type : str
        Type of regional aggregation: "municipality", "state", "biome"
    biome : str, optional
        Filter by biome (e.g., "amazonia", "cerrado")
    collection : str
        MapBiomas collection version
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame
        Statistics with columns: year, region_code, region_name, class_id,
        class_name, area_ha

    Examples
    --------
    >>> df = load_mapbiomas_statistics(years=[2020, 2021], region_type="state")
    >>> df.groupby(["year", "class_name"])["area_ha"].sum()
    """
    base_path = data_path or DATA_HUB / "land-use" / "mapbiomas"
    stats_path = base_path / collection / "statistics"

    file_name = f"mapbiomas_statistics_{region_type}_{collection.replace('-', '')}.parquet"
    file_path = stats_path / file_name

    if not file_path.exists():
        # Try CSV fallback
        file_path = stats_path / file_name.replace(".parquet", ".csv")
        if not file_path.exists():
            raise FileNotFoundError(
                f"MapBiomas statistics not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources mapbiomas"
            )
        df = pd.read_csv(file_path)
    else:
        df = pd.read_parquet(file_path)

    # Filter by years
    if years:
        df = df[df["year"].isin(years)]

    # Filter by biome
    if biome:
        df = df[df["biome"].str.lower() == biome.lower()]

    # Add class names
    if "class_name" not in df.columns and "class_id" in df.columns:
        df["class_name"] = df["class_id"].map(MAPBIOMAS_CLASSES)

    return df


def get_class_name(class_id: int) -> str:
    """Get the class name for a MapBiomas class ID."""
    return MAPBIOMAS_CLASSES.get(class_id, f"Unknown ({class_id})")


def get_class_id(class_name: str) -> Optional[int]:
    """Get the class ID for a MapBiomas class name."""
    for id_, name in MAPBIOMAS_CLASSES.items():
        if name.lower() == class_name.lower():
            return id_
    return None
