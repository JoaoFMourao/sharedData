"""
Data Validation Utilities

Functions for validating data quality and consistency.
"""

from typing import Optional, List, Dict, Any, Union
from pathlib import Path
import pandas as pd
import numpy as np

from .brazil import STATES


def validate_crs(
    crs: Any,
    expected: str = "EPSG:4674",
) -> bool:
    """
    Validate that a CRS matches the expected value.

    Parameters
    ----------
    crs : Any
        CRS to validate (string, pyproj CRS, etc.)
    expected : str
        Expected CRS (default: SIRGAS 2000)

    Returns
    -------
    bool
        True if CRS matches

    Raises
    ------
    ValueError
        If CRS doesn't match expected
    """
    if crs is None:
        raise ValueError("CRS is None. Expected: " + expected)

    crs_str = str(crs)

    # Normalize for comparison
    expected_normalized = expected.upper().replace(" ", "")
    crs_normalized = crs_str.upper().replace(" ", "")

    # Check for common equivalent representations
    equivalents = {
        "EPSG:4674": ["EPSG:4674", "SIRGAS2000"],
        "EPSG:4326": ["EPSG:4326", "WGS84"],
    }

    for canonical, variants in equivalents.items():
        if expected_normalized in [v.upper() for v in variants]:
            if any(v.upper() in crs_normalized for v in variants):
                return True

    if expected_normalized not in crs_normalized:
        raise ValueError(f"CRS mismatch. Expected: {expected}, Got: {crs_str}")

    return True


def validate_ibge_code(
    code: Union[int, str],
    level: str = "municipality",
) -> bool:
    """
    Validate an IBGE geographic code.

    Parameters
    ----------
    code : int or str
        IBGE code to validate
    level : str
        Code level: "state" (2 digits), "municipality" (7 digits)

    Returns
    -------
    bool
        True if valid

    Raises
    ------
    ValueError
        If code is invalid
    """
    code_str = str(code).strip()

    # Remove non-digits
    code_str = "".join(c for c in code_str if c.isdigit())

    expected_lengths = {
        "state": 2,
        "municipality": 7,
        "mesoregion": 4,
        "microregion": 5,
    }

    expected_len = expected_lengths.get(level, 7)

    if len(code_str) != expected_len:
        raise ValueError(
            f"Invalid IBGE {level} code: {code}. "
            f"Expected {expected_len} digits, got {len(code_str)}"
        )

    # Validate state code (first 2 digits)
    state_code = code_str[:2]
    valid_state_codes = [str(v["code"]).zfill(2) for v in STATES.values()]

    if state_code not in valid_state_codes:
        raise ValueError(f"Invalid state code in IBGE code: {state_code}")

    return True


def check_data_quality(
    df: pd.DataFrame,
    checks: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """
    Run data quality checks on a DataFrame.

    Parameters
    ----------
    df : pd.DataFrame
        Data to check
    checks : list of str, optional
        Specific checks to run. If None, runs all checks.

    Returns
    -------
    dict
        Quality report

    Examples
    --------
    >>> report = check_data_quality(df)
    >>> print(report["missing_pct"])
    """
    all_checks = [
        "missing",
        "duplicates",
        "dtypes",
        "range",
        "unique",
    ]

    if checks is None:
        checks = all_checks

    report = {
        "rows": len(df),
        "columns": len(df.columns),
        "memory_mb": df.memory_usage(deep=True).sum() / 1e6,
    }

    if "missing" in checks:
        missing = df.isnull().sum()
        report["missing_count"] = missing.to_dict()
        report["missing_pct"] = (missing / len(df) * 100).to_dict()
        report["total_missing_pct"] = df.isnull().sum().sum() / df.size * 100

    if "duplicates" in checks:
        report["duplicate_rows"] = df.duplicated().sum()
        report["duplicate_pct"] = df.duplicated().sum() / len(df) * 100

    if "dtypes" in checks:
        report["dtypes"] = {col: str(dtype) for col, dtype in df.dtypes.items()}

    if "range" in checks:
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        report["numeric_ranges"] = {
            col: {"min": df[col].min(), "max": df[col].max()}
            for col in numeric_cols
        }

    if "unique" in checks:
        report["unique_counts"] = {col: df[col].nunique() for col in df.columns}

    return report


def validate_time_series(
    df: pd.DataFrame,
    date_column: str,
    expected_freq: str = "Y",
) -> Dict[str, Any]:
    """
    Validate time series data for completeness.

    Parameters
    ----------
    df : pd.DataFrame
        Time series data
    date_column : str
        Name of date column
    expected_freq : str
        Expected frequency: "D" (daily), "M" (monthly), "Y" (yearly)

    Returns
    -------
    dict
        Validation report
    """
    df = df.copy()
    df[date_column] = pd.to_datetime(df[date_column])

    report = {
        "start_date": df[date_column].min(),
        "end_date": df[date_column].max(),
        "row_count": len(df),
    }

    # Check for gaps
    if expected_freq == "Y":
        years = df[date_column].dt.year.unique()
        expected_years = range(years.min(), years.max() + 1)
        missing_years = set(expected_years) - set(years)
        report["missing_periods"] = list(missing_years)
    elif expected_freq == "M":
        df["period"] = df[date_column].dt.to_period("M")
        periods = df["period"].unique()
        full_range = pd.period_range(periods.min(), periods.max(), freq="M")
        missing = set(full_range) - set(periods)
        report["missing_periods"] = [str(p) for p in missing]

    report["is_complete"] = len(report.get("missing_periods", [])) == 0

    return report


def validate_geometry(
    gdf: "gpd.GeoDataFrame",
) -> Dict[str, Any]:
    """
    Validate geometry quality in a GeoDataFrame.

    Parameters
    ----------
    gdf : gpd.GeoDataFrame
        GeoDataFrame to validate

    Returns
    -------
    dict
        Validation report
    """
    report = {
        "total_features": len(gdf),
        "geometry_types": gdf.geometry.type.value_counts().to_dict(),
        "crs": str(gdf.crs),
    }

    # Check for invalid geometries
    invalid_mask = ~gdf.geometry.is_valid
    report["invalid_geometries"] = invalid_mask.sum()

    # Check for empty geometries
    empty_mask = gdf.geometry.is_empty
    report["empty_geometries"] = empty_mask.sum()

    # Check for null geometries
    null_mask = gdf.geometry.isnull()
    report["null_geometries"] = null_mask.sum()

    report["is_valid"] = (
        report["invalid_geometries"] == 0 and
        report["empty_geometries"] == 0 and
        report["null_geometries"] == 0
    )

    return report
