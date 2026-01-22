"""
Temporal Processing Functions

Common temporal aggregations and transformations for time series data.
"""

from typing import Optional, Union, List
import pandas as pd
import numpy as np

try:
    import xarray as xr
    HAS_XARRAY = True
except ImportError:
    HAS_XARRAY = False


def aggregate_monthly(
    df: pd.DataFrame,
    date_column: str = "date",
    value_columns: Optional[List[str]] = None,
    agg_func: str = "mean",
) -> pd.DataFrame:
    """
    Aggregate data to monthly resolution.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    date_column : str
        Name of date column
    value_columns : list of str, optional
        Columns to aggregate. If None, aggregates all numeric columns.
    agg_func : str
        Aggregation function: "mean", "sum", "min", "max"

    Returns
    -------
    pd.DataFrame
        Monthly aggregated data
    """
    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])
    df["year_month"] = df[date_column].dt.to_period("M")

    if value_columns is None:
        value_columns = df.select_dtypes(include=[np.number]).columns.tolist()

    grouped = df.groupby("year_month")[value_columns].agg(agg_func)
    grouped.index = grouped.index.to_timestamp()

    return grouped.reset_index().rename(columns={"year_month": "date"})


def aggregate_annual(
    df: pd.DataFrame,
    date_column: str = "date",
    value_columns: Optional[List[str]] = None,
    agg_func: str = "mean",
) -> pd.DataFrame:
    """
    Aggregate data to annual resolution.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    date_column : str
        Name of date column
    value_columns : list of str, optional
        Columns to aggregate
    agg_func : str
        Aggregation function

    Returns
    -------
    pd.DataFrame
        Annual aggregated data
    """
    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])
    df["year"] = df[date_column].dt.year

    if value_columns is None:
        value_columns = df.select_dtypes(include=[np.number]).columns.tolist()

    return df.groupby("year")[value_columns].agg(agg_func).reset_index()


def aggregate_seasonal(
    df: pd.DataFrame,
    date_column: str = "date",
    value_columns: Optional[List[str]] = None,
    agg_func: str = "mean",
    seasons: Optional[dict] = None,
) -> pd.DataFrame:
    """
    Aggregate data to seasonal resolution.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    date_column : str
        Name of date column
    value_columns : list of str, optional
        Columns to aggregate
    agg_func : str
        Aggregation function
    seasons : dict, optional
        Custom season definitions. Default uses Brazilian seasons:
        DJF (Summer), MAM (Autumn), JJA (Winter), SON (Spring)

    Returns
    -------
    pd.DataFrame
        Seasonal aggregated data
    """
    if seasons is None:
        seasons = {
            12: "DJF", 1: "DJF", 2: "DJF",
            3: "MAM", 4: "MAM", 5: "MAM",
            6: "JJA", 7: "JJA", 8: "JJA",
            9: "SON", 10: "SON", 11: "SON",
        }

    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])
    df["year"] = df[date_column].dt.year
    df["month"] = df[date_column].dt.month
    df["season"] = df["month"].map(seasons)

    # Adjust year for DJF (December belongs to next year's summer)
    df.loc[(df["month"] == 12), "year"] = df.loc[(df["month"] == 12), "year"] + 1

    if value_columns is None:
        value_columns = df.select_dtypes(include=[np.number]).columns.tolist()
        value_columns = [c for c in value_columns if c not in ["year", "month"]]

    return df.groupby(["year", "season"])[value_columns].agg(agg_func).reset_index()


def calculate_anomaly(
    df: pd.DataFrame,
    value_column: str,
    date_column: str = "date",
    reference_period: tuple = (1991, 2020),
) -> pd.DataFrame:
    """
    Calculate anomalies relative to a reference period climatology.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    value_column : str
        Column to calculate anomalies for
    date_column : str
        Name of date column
    reference_period : tuple
        Start and end years for reference period

    Returns
    -------
    pd.DataFrame
        DataFrame with anomaly column added
    """
    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])
    df["year"] = df[date_column].dt.year
    df["month"] = df[date_column].dt.month

    # Calculate climatology
    ref_data = df[(df["year"] >= reference_period[0]) & (df["year"] <= reference_period[1])]
    climatology = ref_data.groupby("month")[value_column].mean()

    # Calculate anomaly
    df["climatology"] = df["month"].map(climatology)
    df[f"{value_column}_anomaly"] = df[value_column] - df["climatology"]

    return df.drop(columns=["climatology"])


def calculate_climatology(
    df: pd.DataFrame,
    value_column: str,
    date_column: str = "date",
    reference_period: tuple = (1991, 2020),
    include_std: bool = True,
) -> pd.DataFrame:
    """
    Calculate monthly climatological normals.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    value_column : str
        Column to calculate climatology for
    date_column : str
        Name of date column
    reference_period : tuple
        Start and end years for reference period
    include_std : bool
        If True, includes standard deviation

    Returns
    -------
    pd.DataFrame
        Monthly climatology
    """
    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])
    df["year"] = df[date_column].dt.year
    df["month"] = df[date_column].dt.month

    # Filter to reference period
    ref_data = df[(df["year"] >= reference_period[0]) & (df["year"] <= reference_period[1])]

    if include_std:
        clim = ref_data.groupby("month")[value_column].agg(["mean", "std"]).reset_index()
        clim.columns = ["month", f"{value_column}_mean", f"{value_column}_std"]
    else:
        clim = ref_data.groupby("month")[value_column].mean().reset_index()
        clim.columns = ["month", f"{value_column}_mean"]

    return clim


def rolling_average(
    df: pd.DataFrame,
    value_column: str,
    window: int,
    center: bool = True,
    min_periods: int = 1,
) -> pd.DataFrame:
    """
    Calculate rolling average.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame (must be sorted by time)
    value_column : str
        Column to calculate rolling average for
    window : int
        Window size
    center : bool
        If True, centers the window
    min_periods : int
        Minimum observations required

    Returns
    -------
    pd.DataFrame
        DataFrame with rolling average column
    """
    df = df.copy()
    df[f"{value_column}_rolling_{window}"] = (
        df[value_column].rolling(window=window, center=center, min_periods=min_periods).mean()
    )
    return df


def resample_xarray(
    ds: "xr.Dataset",
    freq: str = "M",
    method: str = "mean",
) -> "xr.Dataset":
    """
    Resample xarray Dataset to a different frequency.

    Parameters
    ----------
    ds : xr.Dataset
        Input Dataset
    freq : str
        Target frequency: "D" (daily), "M" (monthly), "Y" (yearly)
    method : str
        Resampling method: "mean", "sum", "min", "max"

    Returns
    -------
    xr.Dataset
        Resampled Dataset
    """
    if not HAS_XARRAY:
        raise ImportError("xarray is required")

    resampler = ds.resample(time=freq)

    if method == "mean":
        return resampler.mean()
    elif method == "sum":
        return resampler.sum()
    elif method == "min":
        return resampler.min()
    elif method == "max":
        return resampler.max()
    else:
        raise ValueError(f"Unknown method: {method}")
