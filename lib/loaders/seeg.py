"""
SEEG Data Loader

Functions to load greenhouse gas emissions data from SEEG
(Sistema de Estimativas de Emissoes de Gases de Efeito Estufa).
"""

from pathlib import Path
from typing import Optional, List, Union
import pandas as pd

from .. import DATA_HUB


# SEEG sectors
SEEG_SECTORS = {
    1: "Energia",
    2: "Processos Industriais",
    3: "Agropecuaria",
    4: "Mudanca de Uso da Terra",
    5: "Residuos",
}

# GHG gases
GASES = ["CO2", "CH4", "N2O", "HFCs", "PFCs", "SF6", "CO2e"]


def load_seeg(
    years: Optional[List[int]] = None,
    sectors: Optional[List[Union[int, str]]] = None,
    gases: Optional[List[str]] = None,
    spatial_level: str = "national",
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load SEEG greenhouse gas emissions data.

    Parameters
    ----------
    years : list of int, optional
        Years to load. If None, loads all available years (1970-present).
    sectors : list of int or str, optional
        Sectors to include (1-5 or sector names). If None, loads all sectors.
    gases : list of str, optional
        Gases to include (CO2, CH4, N2O, etc.). If None, loads all gases.
    spatial_level : str
        Spatial aggregation level: "national", "state", or "municipality"
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame
        Emissions data with columns: year, sector, subsector, gas, emissions_tco2e,
        and spatial columns depending on level

    Examples
    --------
    >>> df = load_seeg(years=[2020, 2021], sectors=[4], gases=["CO2e"])
    >>> df.groupby("year")["emissions_tco2e"].sum()
    """
    base_path = data_path or DATA_HUB / "emissions" / "seeg"

    file_name = f"seeg_emissions_{spatial_level}.parquet"
    file_path = base_path / file_name

    if not file_path.exists():
        # Try CSV fallback
        file_path = base_path / file_name.replace(".parquet", ".csv")
        if not file_path.exists():
            raise FileNotFoundError(
                f"SEEG data not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources seeg"
            )
        df = pd.read_csv(file_path)
    else:
        df = pd.read_parquet(file_path)

    # Filter by years
    if years:
        df = df[df["year"].isin(years)]

    # Filter by sectors
    if sectors:
        sector_filter = []
        for s in sectors:
            if isinstance(s, int):
                sector_filter.append(SEEG_SECTORS.get(s, ""))
            else:
                sector_filter.append(s)
        df = df[df["sector"].isin(sector_filter)]

    # Filter by gases
    if gases:
        df = df[df["gas"].isin(gases)]

    return df


def load_seeg_by_sector(
    sector: Union[int, str],
    years: Optional[List[int]] = None,
    spatial_level: str = "national",
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load SEEG data for a specific sector with detailed subsector breakdown.

    Parameters
    ----------
    sector : int or str
        Sector number (1-5) or name
    years : list of int, optional
        Years to load
    spatial_level : str
        Spatial aggregation level
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame
        Detailed emissions by subsector

    Examples
    --------
    >>> df = load_seeg_by_sector(4)  # Land use change
    >>> df.groupby(["year", "subsector"])["emissions_tco2e"].sum()
    """
    return load_seeg(
        years=years,
        sectors=[sector],
        spatial_level=spatial_level,
        data_path=data_path,
    )


def get_sector_name(sector_id: int) -> str:
    """Get the sector name for a SEEG sector ID."""
    return SEEG_SECTORS.get(sector_id, f"Unknown ({sector_id})")


def aggregate_by_gas(df: pd.DataFrame, gas: str = "CO2e") -> pd.DataFrame:
    """
    Aggregate emissions by a single gas type.

    Parameters
    ----------
    df : pd.DataFrame
        SEEG data with multiple gases
    gas : str
        Gas to aggregate (default: CO2e for total GWP)

    Returns
    -------
    pd.DataFrame
        Aggregated data for the specified gas
    """
    return df[df["gas"] == gas].copy()


def calculate_sector_shares(df: pd.DataFrame, year: int) -> pd.DataFrame:
    """
    Calculate sector shares of total emissions for a given year.

    Parameters
    ----------
    df : pd.DataFrame
        SEEG data
    year : int
        Year for calculation

    Returns
    -------
    pd.DataFrame
        Sector shares with columns: sector, emissions_tco2e, share_pct
    """
    year_data = df[df["year"] == year].copy()

    sector_totals = year_data.groupby("sector")["emissions_tco2e"].sum().reset_index()
    total = sector_totals["emissions_tco2e"].sum()
    sector_totals["share_pct"] = (sector_totals["emissions_tco2e"] / total) * 100

    return sector_totals.sort_values("share_pct", ascending=False)
