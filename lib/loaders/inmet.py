"""
INMET Weather Station Data Loader

Functions to load weather station data from INMET
(Instituto Nacional de Meteorologia).
"""

from pathlib import Path
from typing import Optional, List, Union
from datetime import datetime
import pandas as pd

try:
    import geopandas as gpd
    HAS_GEO = True
except ImportError:
    HAS_GEO = False

from .. import DATA_HUB


def load_inmet_stations(
    station_type: str = "automatic",
    active_only: bool = True,
    states: Optional[List[str]] = None,
    as_geodataframe: bool = False,
    data_path: Optional[Path] = None,
) -> Union[pd.DataFrame, "gpd.GeoDataFrame"]:
    """
    Load INMET weather station metadata.

    Parameters
    ----------
    station_type : str
        Station type: "automatic" or "conventional"
    active_only : bool
        If True, only returns active stations
    states : list of str, optional
        Filter by state codes (e.g., ["SP", "RJ"])
    as_geodataframe : bool
        If True, returns GeoDataFrame with point geometries
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame or gpd.GeoDataFrame
        Station metadata

    Examples
    --------
    >>> stations = load_inmet_stations(states=["SP"])
    >>> print(f"Found {len(stations)} stations in Sao Paulo")
    """
    base_path = data_path or DATA_HUB / "climate" / "inmet"

    file_name = f"inmet_stations_{station_type}.parquet"
    file_path = base_path / file_name

    if not file_path.exists():
        file_path = base_path / file_name.replace(".parquet", ".csv")
        if not file_path.exists():
            raise FileNotFoundError(
                f"INMET station data not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources inmet"
            )
        df = pd.read_csv(file_path)
    else:
        df = pd.read_parquet(file_path)

    # Filter by active status
    if active_only and "status" in df.columns:
        df = df[df["status"] == "active"]

    # Filter by states
    if states:
        states_upper = [s.upper() for s in states]
        df = df[df["uf"].isin(states_upper)]

    if as_geodataframe:
        if not HAS_GEO:
            raise ImportError("geopandas required. Install: pip install geopandas")

        gdf = gpd.GeoDataFrame(
            df,
            geometry=gpd.points_from_xy(df["longitude"], df["latitude"]),
            crs="EPSG:4674",
        )
        return gdf

    return df


def load_inmet_data(
    station_code: Union[str, List[str]],
    start_date: Union[str, datetime],
    end_date: Union[str, datetime],
    variables: Optional[List[str]] = None,
    frequency: str = "hourly",
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load INMET weather data for specific stations.

    Parameters
    ----------
    station_code : str or list of str
        INMET station code(s)
    start_date : str or datetime
        Start date in format "YYYY-MM-DD"
    end_date : str or datetime
        End date in format "YYYY-MM-DD"
    variables : list of str, optional
        Variables to load. If None, loads all available.
        Common variables: "temp_min", "temp_max", "precipitation",
        "humidity", "wind_speed", "pressure", "radiation"
    frequency : str
        Data frequency: "hourly" or "daily"
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame
        Weather data with datetime index

    Examples
    --------
    >>> df = load_inmet_data("A701", "2023-01-01", "2023-12-31")
    >>> df["temp_max"].plot()
    """
    base_path = data_path or DATA_HUB / "climate" / "inmet"

    # Parse dates
    if isinstance(start_date, str):
        start_date = datetime.strptime(start_date, "%Y-%m-%d")
    if isinstance(end_date, str):
        end_date = datetime.strptime(end_date, "%Y-%m-%d")

    # Handle single or multiple stations
    if isinstance(station_code, str):
        station_codes = [station_code]
    else:
        station_codes = station_code

    all_data = []

    for code in station_codes:
        # Find data files
        for year in range(start_date.year, end_date.year + 1):
            file_name = f"inmet_{code}_{year}_{frequency}.parquet"
            file_path = base_path / "data" / file_name

            if not file_path.exists():
                file_path = base_path / "data" / file_name.replace(".parquet", ".csv")
                if not file_path.exists():
                    continue
                df = pd.read_csv(file_path, parse_dates=["datetime"])
            else:
                df = pd.read_parquet(file_path)

            df["station_code"] = code
            all_data.append(df)

    if not all_data:
        raise FileNotFoundError(
            f"INMET data not found for stations {station_codes}\n"
            f"Run: python scripts/download_data.py --sources inmet"
        )

    df = pd.concat(all_data, ignore_index=True)

    # Filter by date
    if "datetime" in df.columns:
        df["datetime"] = pd.to_datetime(df["datetime"])
        df = df[(df["datetime"] >= start_date) & (df["datetime"] <= end_date)]

    # Filter by variables
    if variables:
        cols = ["datetime", "station_code"] + [v for v in variables if v in df.columns]
        df = df[cols]

    return df.sort_values(["station_code", "datetime"]).reset_index(drop=True)


def aggregate_daily(df: pd.DataFrame) -> pd.DataFrame:
    """
    Aggregate hourly INMET data to daily values.

    Parameters
    ----------
    df : pd.DataFrame
        Hourly weather data

    Returns
    -------
    pd.DataFrame
        Daily aggregated data
    """
    df = df.copy()
    df["date"] = pd.to_datetime(df["datetime"]).dt.date

    agg_funcs = {
        "temp_min": "min",
        "temp_max": "max",
        "temp_mean": "mean",
        "precipitation": "sum",
        "humidity": "mean",
        "wind_speed": "mean",
        "pressure": "mean",
        "radiation": "sum",
    }

    # Only use columns that exist
    agg_dict = {k: v for k, v in agg_funcs.items() if k in df.columns}

    return df.groupby(["station_code", "date"]).agg(agg_dict).reset_index()


def calculate_climatology(
    df: pd.DataFrame,
    variable: str,
    reference_period: tuple = (1991, 2020),
) -> pd.DataFrame:
    """
    Calculate climatological normals for a variable.

    Parameters
    ----------
    df : pd.DataFrame
        Weather data with datetime column
    variable : str
        Variable to calculate climatology for
    reference_period : tuple
        Start and end years for reference period

    Returns
    -------
    pd.DataFrame
        Monthly climatological normals
    """
    df = df.copy()
    df["datetime"] = pd.to_datetime(df["datetime"])
    df["year"] = df["datetime"].dt.year
    df["month"] = df["datetime"].dt.month

    # Filter to reference period
    df = df[(df["year"] >= reference_period[0]) & (df["year"] <= reference_period[1])]

    return df.groupby("month")[variable].agg(["mean", "std", "min", "max"]).reset_index()
