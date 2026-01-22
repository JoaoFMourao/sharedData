"""
PRODES and DETER Data Loader

Functions to load deforestation data from INPE's monitoring systems.
"""

from pathlib import Path
from typing import Optional, List, Union
import pandas as pd

try:
    import geopandas as gpd
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

from .. import DATA_HUB, DEFAULT_CRS


# DETER alert classes
DETER_CLASSES = {
    "DESMATAMENTO_CR": "Clear-cut deforestation",
    "DESMATAMENTO_VEG": "Deforestation with vegetation",
    "DEGRADACAO": "Forest degradation",
    "MINERACAO": "Mining",
    "CICATRIZ_DE_QUEIMADA": "Fire scar",
    "CS_DESORDENADO": "Disordered selective cut",
    "CS_GEOMETRICO": "Geometric selective cut",
}


def load_prodes(
    years: Optional[List[int]] = None,
    biome: str = "amazonia",
    states: Optional[List[str]] = None,
    as_geodataframe: bool = False,
    data_path: Optional[Path] = None,
) -> Union[pd.DataFrame, "gpd.GeoDataFrame"]:
    """
    Load PRODES annual deforestation data.

    Parameters
    ----------
    years : list of int, optional
        Years to load. If None, loads all available years.
    biome : str
        Biome: "amazonia" or "cerrado"
    states : list of str, optional
        Filter by state codes (e.g., ["PA", "MT"])
    as_geodataframe : bool
        If True, returns GeoDataFrame with polygons
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame or gpd.GeoDataFrame
        Deforestation data

    Examples
    --------
    >>> df = load_prodes(years=[2020, 2021], biome="amazonia")
    >>> df.groupby("year")["areakm"].sum()
    """
    base_path = data_path or DATA_HUB / "land-use" / "prodes"

    if as_geodataframe:
        if not HAS_GEO:
            raise ImportError("geopandas required. Install: pip install geopandas")

        file_name = f"prodes_{biome}_polygons.gpkg"
        file_path = base_path / file_name

        if not file_path.exists():
            file_path = base_path / file_name.replace(".gpkg", ".shp")

        if not file_path.exists():
            raise FileNotFoundError(
                f"PRODES data not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources prodes"
            )

        gdf = gpd.read_file(file_path)

        if years:
            gdf = gdf[gdf["year"].isin(years)]
        if states:
            states_upper = [s.upper() for s in states]
            gdf = gdf[gdf["state"].isin(states_upper)]

        return gdf

    else:
        file_name = f"prodes_{biome}_statistics.parquet"
        file_path = base_path / file_name

        if not file_path.exists():
            file_path = base_path / file_name.replace(".parquet", ".csv")
            if not file_path.exists():
                raise FileNotFoundError(
                    f"PRODES data not found: {file_path}\n"
                    f"Run: python scripts/download_data.py --sources prodes"
                )
            df = pd.read_csv(file_path)
        else:
            df = pd.read_parquet(file_path)

        if years:
            df = df[df["year"].isin(years)]
        if states:
            states_upper = [s.upper() for s in states]
            df = df[df["state"].isin(states_upper)]

        return df


def load_deter(
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    biome: str = "amazonia",
    alert_classes: Optional[List[str]] = None,
    min_area_ha: float = 0,
    as_geodataframe: bool = False,
    data_path: Optional[Path] = None,
) -> Union[pd.DataFrame, "gpd.GeoDataFrame"]:
    """
    Load DETER real-time deforestation alerts.

    Parameters
    ----------
    start_date : str, optional
        Start date in format "YYYY-MM-DD"
    end_date : str, optional
        End date in format "YYYY-MM-DD"
    biome : str
        Biome: "amazonia" or "cerrado"
    alert_classes : list of str, optional
        Filter by alert classes (see DETER_CLASSES)
    min_area_ha : float
        Minimum area in hectares
    as_geodataframe : bool
        If True, returns GeoDataFrame with polygons
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame or gpd.GeoDataFrame
        DETER alerts

    Examples
    --------
    >>> df = load_deter("2023-01-01", "2023-12-31", biome="amazonia")
    >>> df.groupby("class_name")["areaha"].sum()
    """
    base_path = data_path or DATA_HUB / "land-use" / "deter"

    if as_geodataframe:
        if not HAS_GEO:
            raise ImportError("geopandas required. Install: pip install geopandas")

        file_name = f"deter_{biome}_alerts.gpkg"
        file_path = base_path / file_name

        if not file_path.exists():
            raise FileNotFoundError(
                f"DETER data not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources deter"
            )

        gdf = gpd.read_file(file_path)

        # Filter by date
        if "view_date" in gdf.columns:
            gdf["view_date"] = pd.to_datetime(gdf["view_date"])
            if start_date:
                gdf = gdf[gdf["view_date"] >= start_date]
            if end_date:
                gdf = gdf[gdf["view_date"] <= end_date]

        # Filter by class
        if alert_classes:
            gdf = gdf[gdf["class_name"].isin(alert_classes)]

        # Filter by area
        if min_area_ha > 0:
            gdf = gdf[gdf["areaha"] >= min_area_ha]

        return gdf

    else:
        file_name = f"deter_{biome}_statistics.parquet"
        file_path = base_path / file_name

        if not file_path.exists():
            file_path = base_path / file_name.replace(".parquet", ".csv")
            if not file_path.exists():
                raise FileNotFoundError(
                    f"DETER data not found: {file_path}\n"
                    f"Run: python scripts/download_data.py --sources deter"
                )
            df = pd.read_csv(file_path)
        else:
            df = pd.read_parquet(file_path)

        # Apply filters
        if "view_date" in df.columns:
            df["view_date"] = pd.to_datetime(df["view_date"])
            if start_date:
                df = df[df["view_date"] >= start_date]
            if end_date:
                df = df[df["view_date"] <= end_date]

        if alert_classes:
            df = df[df["class_name"].isin(alert_classes)]

        if min_area_ha > 0:
            df = df[df["areaha"] >= min_area_ha]

        return df


def get_alert_class_name(class_code: str) -> str:
    """Get human-readable name for DETER alert class."""
    return DETER_CLASSES.get(class_code, class_code)


def calculate_annual_deforestation(
    df: pd.DataFrame,
    prodes_year: bool = True,
) -> pd.DataFrame:
    """
    Calculate annual deforestation totals.

    Parameters
    ----------
    df : pd.DataFrame
        PRODES or DETER data
    prodes_year : bool
        If True, uses PRODES year (Aug-Jul). Otherwise, calendar year.

    Returns
    -------
    pd.DataFrame
        Annual deforestation totals
    """
    if prodes_year and "view_date" in df.columns:
        # PRODES year runs from August to July
        df = df.copy()
        df["view_date"] = pd.to_datetime(df["view_date"])
        df["prodes_year"] = df["view_date"].apply(
            lambda x: x.year if x.month < 8 else x.year + 1
        )
        return df.groupby("prodes_year")["areakm"].sum().reset_index()
    else:
        return df.groupby("year")["areakm"].sum().reset_index()
