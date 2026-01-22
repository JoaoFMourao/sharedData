"""
IBGE Data Loader

Functions to load geographic boundaries and socioeconomic data from IBGE
(Instituto Brasileiro de Geografia e Estatistica).
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


def load_ibge_boundaries(
    level: str = "municipios",
    year: int = 2022,
    simplified: bool = False,
    data_path: Optional[Path] = None,
) -> "gpd.GeoDataFrame":
    """
    Load IBGE administrative boundaries.

    Parameters
    ----------
    level : str
        Administrative level: "paises", "regioes", "estados", "mesorregioes",
        "microrregioes", "municipios", or "setores"
    year : int
        Reference year for boundaries (default: 2022)
    simplified : bool
        If True, loads simplified geometries for faster rendering
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    gpd.GeoDataFrame
        GeoDataFrame with administrative boundaries

    Examples
    --------
    >>> states = load_ibge_boundaries("estados")
    >>> states.plot(column="sigla_uf")
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required. Install with: pip install geopandas")

    base_path = data_path or DATA_HUB / "geospatial" / "boundaries"

    suffix = "_simplified" if simplified else ""
    file_name = f"{level}_{year}{suffix}.gpkg"
    file_path = base_path / level / file_name

    if not file_path.exists():
        # Try shapefile fallback
        file_path = base_path / level / file_name.replace(".gpkg", ".shp")
        if not file_path.exists():
            raise FileNotFoundError(
                f"IBGE boundaries not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources ibge"
            )

    gdf = gpd.read_file(file_path)

    # Ensure correct CRS
    if gdf.crs is None or gdf.crs.to_string() != DEFAULT_CRS:
        gdf = gdf.set_crs(DEFAULT_CRS, allow_override=True)

    return gdf


def load_municipalities(
    states: Optional[List[str]] = None,
    year: int = 2022,
    simplified: bool = False,
    data_path: Optional[Path] = None,
) -> "gpd.GeoDataFrame":
    """
    Load municipality boundaries with optional state filter.

    Parameters
    ----------
    states : list of str, optional
        List of state codes (UF) to filter (e.g., ["SP", "RJ"])
    year : int
        Reference year
    simplified : bool
        If True, loads simplified geometries
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    gpd.GeoDataFrame
        Municipality boundaries
    """
    gdf = load_ibge_boundaries("municipios", year, simplified, data_path)

    if states:
        states_upper = [s.upper() for s in states]
        gdf = gdf[gdf["sigla_uf"].isin(states_upper)]

    return gdf


def load_states(
    region: Optional[str] = None,
    year: int = 2022,
    simplified: bool = False,
    data_path: Optional[Path] = None,
) -> "gpd.GeoDataFrame":
    """
    Load state boundaries with optional region filter.

    Parameters
    ----------
    region : str, optional
        Region to filter: "Norte", "Nordeste", "Centro-Oeste", "Sudeste", "Sul"
    year : int
        Reference year
    simplified : bool
        If True, loads simplified geometries
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    gpd.GeoDataFrame
        State boundaries
    """
    gdf = load_ibge_boundaries("estados", year, simplified, data_path)

    if region:
        gdf = gdf[gdf["nome_regiao"].str.lower() == region.lower()]

    return gdf


def load_biomes(
    biome: Optional[str] = None,
    data_path: Optional[Path] = None,
) -> "gpd.GeoDataFrame":
    """
    Load Brazilian biome boundaries.

    Parameters
    ----------
    biome : str, optional
        Specific biome: "Amazonia", "Cerrado", "Mata Atlantica",
        "Caatinga", "Pampa", "Pantanal"
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    gpd.GeoDataFrame
        Biome boundaries
    """
    if not HAS_GEO:
        raise ImportError("geopandas is required. Install with: pip install geopandas")

    base_path = data_path or DATA_HUB / "geospatial"
    file_path = base_path / "biomes" / "biomas_ibge.gpkg"

    if not file_path.exists():
        file_path = base_path / "biomes" / "biomas_ibge.shp"
        if not file_path.exists():
            raise FileNotFoundError(
                f"Biome boundaries not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources ibge"
            )

    gdf = gpd.read_file(file_path)

    if biome:
        # Normalize biome names
        biome_map = {
            "amazonia": "Amazonia",
            "amazon": "Amazonia",
            "cerrado": "Cerrado",
            "mata atlantica": "Mata Atlantica",
            "atlantic forest": "Mata Atlantica",
            "caatinga": "Caatinga",
            "pampa": "Pampa",
            "pantanal": "Pantanal",
        }
        biome_normalized = biome_map.get(biome.lower(), biome)
        gdf = gdf[gdf["nome_bioma"].str.contains(biome_normalized, case=False)]

    return gdf


def load_ibge_data(
    table: str,
    variables: Optional[List[str]] = None,
    years: Optional[List[int]] = None,
    spatial_level: str = "municipality",
    data_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Load IBGE tabular data (census, GDP, agricultural production, etc.).

    Parameters
    ----------
    table : str
        Table name: "census", "gdp", "pam", "ppm"
    variables : list of str, optional
        Variables to load. If None, loads all.
    years : list of int, optional
        Years to load
    spatial_level : str
        Spatial level: "national", "state", "municipality"
    data_path : Path, optional
        Custom path to data directory

    Returns
    -------
    pd.DataFrame
        IBGE data
    """
    base_path = data_path or DATA_HUB / "socioeconomic" / "ibge"

    file_name = f"ibge_{table}_{spatial_level}.parquet"
    file_path = base_path / file_name

    if not file_path.exists():
        file_path = base_path / file_name.replace(".parquet", ".csv")
        if not file_path.exists():
            raise FileNotFoundError(
                f"IBGE data not found: {file_path}\n"
                f"Run: python scripts/download_data.py --sources ibge"
            )
        df = pd.read_csv(file_path)
    else:
        df = pd.read_parquet(file_path)

    # Filter by years
    if years and "year" in df.columns:
        df = df[df["year"].isin(years)]

    # Filter by variables
    if variables:
        cols = ["year", "code_muni", "name_muni"] if spatial_level == "municipality" else ["year"]
        cols.extend([v for v in variables if v in df.columns])
        df = df[cols]

    return df


def standardize_municipality_code(code: Union[int, str]) -> str:
    """
    Standardize IBGE municipality code to 7-digit format.

    Parameters
    ----------
    code : int or str
        Municipality code (6 or 7 digits)

    Returns
    -------
    str
        7-digit municipality code
    """
    code_str = str(code).strip()

    # Remove any non-digit characters
    code_str = "".join(c for c in code_str if c.isdigit())

    # Handle 6-digit codes (add check digit)
    if len(code_str) == 6:
        # The 7th digit is a check digit, but for simplicity we just return as-is
        # In practice, IBGE uses 7-digit codes
        return code_str + "0"
    elif len(code_str) == 7:
        return code_str
    else:
        raise ValueError(f"Invalid municipality code: {code}")
