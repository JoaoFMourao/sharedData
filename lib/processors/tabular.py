"""
Tabular Data Processing Functions

Common DataFrame transformations and aggregations.
"""

from typing import Optional, List, Dict, Union
import pandas as pd
import numpy as np

try:
    import geopandas as gpd
    HAS_GEO = True
except ImportError:
    HAS_GEO = False


def aggregate_by_region(
    df: pd.DataFrame,
    region_column: str,
    value_columns: List[str],
    agg_func: Union[str, Dict[str, str]] = "sum",
) -> pd.DataFrame:
    """
    Aggregate data by geographic region.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    region_column : str
        Column with region identifiers
    value_columns : list of str
        Columns to aggregate
    agg_func : str or dict
        Aggregation function(s)

    Returns
    -------
    pd.DataFrame
        Aggregated data

    Examples
    --------
    >>> df = aggregate_by_region(data, "state", ["emissions"], "sum")
    """
    if isinstance(agg_func, str):
        agg_dict = {col: agg_func for col in value_columns}
    else:
        agg_dict = agg_func

    return df.groupby(region_column).agg(agg_dict).reset_index()


def pivot_long_to_wide(
    df: pd.DataFrame,
    index: Union[str, List[str]],
    columns: str,
    values: str,
    fill_value: Optional[float] = None,
) -> pd.DataFrame:
    """
    Pivot DataFrame from long to wide format.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame in long format
    index : str or list of str
        Column(s) for index
    columns : str
        Column to pivot
    values : str
        Column with values
    fill_value : float, optional
        Value to fill missing cells

    Returns
    -------
    pd.DataFrame
        Wide format DataFrame
    """
    pivoted = df.pivot_table(
        index=index,
        columns=columns,
        values=values,
        aggfunc="first",
        fill_value=fill_value,
    )

    # Flatten column names if multi-index
    if isinstance(pivoted.columns, pd.MultiIndex):
        pivoted.columns = ["_".join(str(c) for c in col) for col in pivoted.columns]

    return pivoted.reset_index()


def merge_with_geometry(
    df: pd.DataFrame,
    gdf: "gpd.GeoDataFrame",
    left_on: str,
    right_on: str,
    how: str = "left",
) -> "gpd.GeoDataFrame":
    """
    Merge tabular data with geometry.

    Parameters
    ----------
    df : pd.DataFrame
        Tabular data
    gdf : gpd.GeoDataFrame
        GeoDataFrame with geometries
    left_on : str
        Column in df to merge on
    right_on : str
        Column in gdf to merge on
    how : str
        Merge type: "left", "right", "inner", "outer"

    Returns
    -------
    gpd.GeoDataFrame
        Merged GeoDataFrame
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required")

    return gdf.merge(df, left_on=right_on, right_on=left_on, how=how)


def standardize_ibge_codes(
    df: pd.DataFrame,
    code_column: str,
    output_length: int = 7,
) -> pd.DataFrame:
    """
    Standardize IBGE codes to consistent format.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    code_column : str
        Column with IBGE codes
    output_length : int
        Desired code length (7 for municipality, 2 for state)

    Returns
    -------
    pd.DataFrame
        DataFrame with standardized codes
    """
    df = df.copy()

    def standardize(code):
        code_str = str(code).strip()
        # Remove non-digits
        code_str = "".join(c for c in code_str if c.isdigit())
        # Pad or truncate
        if len(code_str) < output_length:
            code_str = code_str.zfill(output_length)
        return code_str[:output_length]

    df[code_column] = df[code_column].apply(standardize)
    return df


def calculate_growth_rate(
    df: pd.DataFrame,
    value_column: str,
    time_column: str = "year",
    group_column: Optional[str] = None,
) -> pd.DataFrame:
    """
    Calculate year-over-year growth rate.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    value_column : str
        Column to calculate growth for
    time_column : str
        Time column
    group_column : str, optional
        Column to group by before calculating growth

    Returns
    -------
    pd.DataFrame
        DataFrame with growth rate column
    """
    df = df.copy().sort_values(time_column)

    if group_column:
        df[f"{value_column}_growth"] = df.groupby(group_column)[value_column].pct_change() * 100
    else:
        df[f"{value_column}_growth"] = df[value_column].pct_change() * 100

    return df


def calculate_share(
    df: pd.DataFrame,
    value_column: str,
    group_column: str,
    total_column: Optional[str] = None,
) -> pd.DataFrame:
    """
    Calculate share/percentage within groups.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    value_column : str
        Column to calculate share for
    group_column : str
        Column defining groups
    total_column : str, optional
        Column with totals. If None, calculates from data.

    Returns
    -------
    pd.DataFrame
        DataFrame with share column
    """
    df = df.copy()

    if total_column:
        df[f"{value_column}_share"] = df[value_column] / df[total_column] * 100
    else:
        totals = df.groupby(group_column)[value_column].transform("sum")
        df[f"{value_column}_share"] = df[value_column] / totals * 100

    return df


def interpolate_missing(
    df: pd.DataFrame,
    value_columns: List[str],
    method: str = "linear",
    limit: Optional[int] = None,
) -> pd.DataFrame:
    """
    Interpolate missing values in time series.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame (sorted by time)
    value_columns : list of str
        Columns to interpolate
    method : str
        Interpolation method: "linear", "quadratic", "cubic"
    limit : int, optional
        Maximum consecutive NaN values to fill

    Returns
    -------
    pd.DataFrame
        DataFrame with interpolated values
    """
    df = df.copy()

    for col in value_columns:
        df[col] = df[col].interpolate(method=method, limit=limit)

    return df


def normalize_column(
    df: pd.DataFrame,
    column: str,
    method: str = "minmax",
    group_column: Optional[str] = None,
) -> pd.DataFrame:
    """
    Normalize a column.

    Parameters
    ----------
    df : pd.DataFrame
        Input DataFrame
    column : str
        Column to normalize
    method : str
        Normalization method: "minmax" (0-1), "zscore" (standardization)
    group_column : str, optional
        Normalize within groups

    Returns
    -------
    pd.DataFrame
        DataFrame with normalized column
    """
    df = df.copy()

    def minmax_norm(x):
        return (x - x.min()) / (x.max() - x.min())

    def zscore_norm(x):
        return (x - x.mean()) / x.std()

    norm_func = minmax_norm if method == "minmax" else zscore_norm

    if group_column:
        df[f"{column}_normalized"] = df.groupby(group_column)[column].transform(norm_func)
    else:
        df[f"{column}_normalized"] = norm_func(df[column])

    return df
