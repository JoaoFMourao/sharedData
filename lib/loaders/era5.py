"""
ERA5 Climate Reanalysis Data Loader

Functions to load ERA5 climate data from the Copernicus Climate Data Store.
"""

from pathlib import Path
from typing import Optional, List, Union, Tuple
from datetime import datetime
import pandas as pd

try:
    import xarray as xr
    HAS_XARRAY = True
except ImportError:
    HAS_XARRAY = False

from .. import DATA_HUB


# Common ERA5 variables
ERA5_VARIABLES = {
    "t2m": {
        "name": "2m temperature",
        "unit": "K",
        "description": "Temperature at 2 meters above surface",
    },
    "tp": {
        "name": "Total precipitation",
        "unit": "m",
        "description": "Accumulated precipitation",
    },
    "u10": {
        "name": "10m u-component of wind",
        "unit": "m/s",
        "description": "Eastward wind at 10 meters",
    },
    "v10": {
        "name": "10m v-component of wind",
        "unit": "m/s",
        "description": "Northward wind at 10 meters",
    },
    "sp": {
        "name": "Surface pressure",
        "unit": "Pa",
        "description": "Pressure at the surface",
    },
    "ssrd": {
        "name": "Surface solar radiation downwards",
        "unit": "J/m2",
        "description": "Accumulated solar radiation",
    },
    "r": {
        "name": "Relative humidity",
        "unit": "%",
        "description": "Relative humidity at various levels",
    },
}


def load_era5(
    variable: str,
    start_date: Union[str, datetime],
    end_date: Union[str, datetime],
    bounds: Optional[Tuple[float, float, float, float]] = None,
    data_path: Optional[Path] = None,
) -> "xr.Dataset":
    """
    Load ERA5 data for a given variable and time period.

    Parameters
    ----------
    variable : str
        ERA5 variable name (e.g., "t2m", "tp")
    start_date : str or datetime
        Start date in format "YYYY-MM-DD"
    end_date : str or datetime
        End date in format "YYYY-MM-DD"
    bounds : tuple of float, optional
        Geographic bounds (west, south, east, north) in degrees.
        If None, returns data for Brazil.
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    xr.Dataset
        xarray Dataset with the requested variable

    Examples
    --------
    >>> ds = load_era5("t2m", "2020-01-01", "2020-12-31")
    >>> ds["t2m"].mean(dim="time")
    """
    if not HAS_XARRAY:
        raise ImportError("xarray is required. Install with: pip install xarray netcdf4")

    base_path = data_path or DATA_HUB / "climate" / "era5"

    # Parse dates
    if isinstance(start_date, str):
        start_date = datetime.strptime(start_date, "%Y-%m-%d")
    if isinstance(end_date, str):
        end_date = datetime.strptime(end_date, "%Y-%m-%d")

    # Find relevant files
    files = []
    for year in range(start_date.year, end_date.year + 1):
        for month in range(1, 13):
            if year == start_date.year and month < start_date.month:
                continue
            if year == end_date.year and month > end_date.month:
                continue

            file_name = f"era5_{variable}_brazil_{year}-{month:02d}.nc"
            file_path = base_path / "processed" / "brazil" / file_name

            if file_path.exists():
                files.append(file_path)

    if not files:
        raise FileNotFoundError(
            f"ERA5 data not found for {variable} between {start_date} and {end_date}\n"
            f"Run: python scripts/download_data.py --sources era5"
        )

    # Load and concatenate
    ds = xr.open_mfdataset(files, combine="by_coords")

    # Filter by time
    ds = ds.sel(time=slice(start_date, end_date))

    # Filter by bounds
    if bounds:
        west, south, east, north = bounds
        ds = ds.sel(longitude=slice(west, east), latitude=slice(north, south))

    return ds


def load_era5_variable(
    variable: str,
    year: int,
    month: Optional[int] = None,
    data_path: Optional[Path] = None,
) -> "xr.DataArray":
    """
    Load a single ERA5 variable for a specific time period.

    Parameters
    ----------
    variable : str
        ERA5 variable name
    year : int
        Year to load
    month : int, optional
        Month to load. If None, loads entire year.
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    xr.DataArray
        Data array for the requested variable
    """
    if month:
        start_date = f"{year}-{month:02d}-01"
        if month == 12:
            end_date = f"{year + 1}-01-01"
        else:
            end_date = f"{year}-{month + 1:02d}-01"
    else:
        start_date = f"{year}-01-01"
        end_date = f"{year + 1}-01-01"

    ds = load_era5(variable, start_date, end_date, data_path=data_path)
    return ds[variable]


def get_variable_info(variable: str) -> dict:
    """Get metadata for an ERA5 variable."""
    return ERA5_VARIABLES.get(variable, {"name": variable, "unit": "unknown"})


def convert_temperature(data: "xr.DataArray", to_unit: str = "C") -> "xr.DataArray":
    """
    Convert temperature from Kelvin to Celsius or Fahrenheit.

    Parameters
    ----------
    data : xr.DataArray
        Temperature data in Kelvin
    to_unit : str
        Target unit: "C" for Celsius, "F" for Fahrenheit

    Returns
    -------
    xr.DataArray
        Temperature in the requested unit
    """
    if to_unit.upper() == "C":
        return data - 273.15
    elif to_unit.upper() == "F":
        return (data - 273.15) * 9 / 5 + 32
    else:
        raise ValueError(f"Unknown temperature unit: {to_unit}")


def convert_precipitation(data: "xr.DataArray", to_unit: str = "mm") -> "xr.DataArray":
    """
    Convert precipitation from meters to millimeters.

    Parameters
    ----------
    data : xr.DataArray
        Precipitation data in meters
    to_unit : str
        Target unit: "mm" for millimeters

    Returns
    -------
    xr.DataArray
        Precipitation in the requested unit
    """
    if to_unit.lower() == "mm":
        return data * 1000
    else:
        raise ValueError(f"Unknown precipitation unit: {to_unit}")
