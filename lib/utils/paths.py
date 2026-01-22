"""
Path Management Utilities

Functions for managing data paths and project structure.
"""

from pathlib import Path
from typing import Optional, List, Union
import os

from .. import REPO_ROOT, DATA_HUB


def get_data_path(
    source: str,
    category: Optional[str] = None,
    filename: Optional[str] = None,
) -> Path:
    """
    Get the path to a data source in data-hub.

    Parameters
    ----------
    source : str
        Data source name (e.g., "mapbiomas", "seeg", "era5")
    category : str, optional
        Data category (e.g., "climate", "land-use", "emissions")
    filename : str, optional
        Specific filename

    Returns
    -------
    Path
        Path to data directory or file

    Examples
    --------
    >>> path = get_data_path("mapbiomas", "land-use")
    >>> path = get_data_path("seeg", filename="seeg_emissions_national.csv")
    """
    # Map sources to categories
    source_categories = {
        "mapbiomas": "land-use",
        "prodes": "land-use",
        "deter": "land-use",
        "seeg": "emissions",
        "sirene": "emissions",
        "era5": "climate",
        "cmip6": "climate",
        "inmet": "climate",
        "chirps": "climate",
        "ibge": "socioeconomic",
        "pnad": "socioeconomic",
        "datasus": "socioeconomic",
    }

    if category is None:
        category = source_categories.get(source.lower())

    if category:
        base_path = DATA_HUB / category / source.lower()
    else:
        base_path = DATA_HUB / source.lower()

    if filename:
        return base_path / filename

    return base_path


def get_project_path(project_name: str) -> Path:
    """
    Get the path to a project directory.

    Parameters
    ----------
    project_name : str
        Name of the project

    Returns
    -------
    Path
        Path to project directory
    """
    return REPO_ROOT / "projects" / project_name


def list_available_data(category: Optional[str] = None) -> List[dict]:
    """
    List available data sources in data-hub.

    Parameters
    ----------
    category : str, optional
        Filter by category (e.g., "climate", "land-use")

    Returns
    -------
    list of dict
        List of available data sources with metadata
    """
    data_sources = []

    categories = ["climate", "land-use", "emissions", "socioeconomic", "geospatial"]

    if category:
        categories = [category]

    for cat in categories:
        cat_path = DATA_HUB / cat
        if cat_path.exists():
            for source_dir in cat_path.iterdir():
                if source_dir.is_dir() and not source_dir.name.startswith("."):
                    # Count files
                    files = list(source_dir.rglob("*"))
                    file_count = len([f for f in files if f.is_file() and not f.name.startswith(".")])

                    data_sources.append({
                        "source": source_dir.name,
                        "category": cat,
                        "path": str(source_dir),
                        "file_count": file_count,
                    })

    return data_sources


def ensure_dir(path: Union[str, Path]) -> Path:
    """
    Ensure a directory exists, creating it if necessary.

    Parameters
    ----------
    path : str or Path
        Directory path

    Returns
    -------
    Path
        The directory path
    """
    path = Path(path)
    path.mkdir(parents=True, exist_ok=True)
    return path


def get_relative_data_path(from_project: str, to_source: str) -> str:
    """
    Get relative path from a project to a data source.

    Parameters
    ----------
    from_project : str
        Project name
    to_source : str
        Data source name

    Returns
    -------
    str
        Relative path string

    Examples
    --------
    >>> path = get_relative_data_path("2024-climate-report", "mapbiomas")
    >>> # Returns: "../../data-hub/land-use/mapbiomas"
    """
    project_path = get_project_path(from_project)
    data_path = get_data_path(to_source)

    try:
        return os.path.relpath(data_path, project_path)
    except ValueError:
        # Different drives on Windows
        return str(data_path)


def find_files(
    pattern: str,
    path: Optional[Path] = None,
    recursive: bool = True,
) -> List[Path]:
    """
    Find files matching a pattern.

    Parameters
    ----------
    pattern : str
        Glob pattern (e.g., "*.csv", "**/*.parquet")
    path : Path, optional
        Directory to search (default: DATA_HUB)
    recursive : bool
        Whether to search recursively

    Returns
    -------
    list of Path
        Matching files
    """
    search_path = path or DATA_HUB

    if recursive:
        return list(search_path.rglob(pattern))
    else:
        return list(search_path.glob(pattern))
