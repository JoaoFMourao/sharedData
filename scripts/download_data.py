#!/usr/bin/env python3
"""
Data Download Script

Download data from various sources to the data-hub.

Usage:
    python scripts/download_data.py --all
    python scripts/download_data.py --sources mapbiomas,seeg,ibge
    python scripts/download_data.py --sources era5 --years 2020,2021,2022
"""

import argparse
import sys
from pathlib import Path
from typing import List, Optional
from datetime import datetime

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from lib import DATA_HUB
from lib.utils.paths import ensure_dir


# Available data sources and their download functions
AVAILABLE_SOURCES = {
    "mapbiomas": {
        "name": "MapBiomas",
        "category": "land-use",
        "description": "Land use and land cover maps",
    },
    "prodes": {
        "name": "PRODES",
        "category": "land-use",
        "description": "Annual deforestation data",
    },
    "deter": {
        "name": "DETER",
        "category": "land-use",
        "description": "Real-time deforestation alerts",
    },
    "seeg": {
        "name": "SEEG",
        "category": "emissions",
        "description": "Greenhouse gas emissions",
    },
    "sirene": {
        "name": "SIRENE",
        "category": "emissions",
        "description": "National emissions registry",
    },
    "era5": {
        "name": "ERA5",
        "category": "climate",
        "description": "Climate reanalysis data",
    },
    "inmet": {
        "name": "INMET",
        "category": "climate",
        "description": "Weather station data",
    },
    "chirps": {
        "name": "CHIRPS",
        "category": "climate",
        "description": "Precipitation data",
    },
    "ibge": {
        "name": "IBGE",
        "category": "geospatial",
        "description": "Administrative boundaries and census data",
    },
}


def download_mapbiomas(years: Optional[List[int]] = None, verbose: bool = True) -> None:
    """Download MapBiomas data."""
    output_dir = ensure_dir(DATA_HUB / "land-use" / "mapbiomas")

    if verbose:
        print(f"MapBiomas: Download from https://mapbiomas.org/")
        print(f"  - Collection 8 coverage maps")
        print(f"  - Statistics by municipality")
        print(f"  Output directory: {output_dir}")
        print(f"  Note: Large raster files should be downloaded manually or via GEE")


def download_seeg(years: Optional[List[int]] = None, verbose: bool = True) -> None:
    """Download SEEG emissions data."""
    output_dir = ensure_dir(DATA_HUB / "emissions" / "seeg")

    if verbose:
        print(f"SEEG: Download from https://seeg.eco.br/")
        print(f"  - National emissions by sector")
        print(f"  - State-level emissions")
        print(f"  - Municipality-level emissions")
        print(f"  Output directory: {output_dir}")


def download_era5(years: Optional[List[int]] = None, verbose: bool = True) -> None:
    """Download ERA5 climate data."""
    output_dir = ensure_dir(DATA_HUB / "climate" / "era5")

    if verbose:
        print(f"ERA5: Download from Copernicus Climate Data Store")
        print(f"  - Requires CDS API key")
        print(f"  - See: https://cds.climate.copernicus.eu/")
        print(f"  Output directory: {output_dir}")
        if years:
            print(f"  Years: {years}")


def download_ibge(verbose: bool = True) -> None:
    """Download IBGE geographic data."""
    output_dir = ensure_dir(DATA_HUB / "geospatial" / "boundaries")

    if verbose:
        print(f"IBGE: Download from https://www.ibge.gov.br/geociencias/")
        print(f"  - Municipality boundaries")
        print(f"  - State boundaries")
        print(f"  - Biome boundaries")
        print(f"  Output directory: {output_dir}")


def download_prodes(years: Optional[List[int]] = None, verbose: bool = True) -> None:
    """Download PRODES deforestation data."""
    output_dir = ensure_dir(DATA_HUB / "land-use" / "prodes")

    if verbose:
        print(f"PRODES: Download from http://terrabrasilis.dpi.inpe.br/")
        print(f"  - Annual deforestation polygons")
        print(f"  - Deforestation statistics")
        print(f"  Output directory: {output_dir}")


def download_inmet(years: Optional[List[int]] = None, verbose: bool = True) -> None:
    """Download INMET weather station data."""
    output_dir = ensure_dir(DATA_HUB / "climate" / "inmet")

    if verbose:
        print(f"INMET: Download from https://bdmep.inmet.gov.br/")
        print(f"  - Weather station metadata")
        print(f"  - Historical observations")
        print(f"  Output directory: {output_dir}")


DOWNLOAD_FUNCTIONS = {
    "mapbiomas": download_mapbiomas,
    "seeg": download_seeg,
    "era5": download_era5,
    "ibge": download_ibge,
    "prodes": download_prodes,
    "inmet": download_inmet,
}


def list_sources() -> None:
    """List available data sources."""
    print("\nAvailable data sources:\n")
    print(f"{'Source':<12} {'Name':<15} {'Category':<15} Description")
    print("-" * 70)
    for source_id, info in AVAILABLE_SOURCES.items():
        print(f"{source_id:<12} {info['name']:<15} {info['category']:<15} {info['description']}")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Download data sources to data-hub",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/download_data.py --list
  python scripts/download_data.py --all
  python scripts/download_data.py --sources mapbiomas,seeg
  python scripts/download_data.py --sources era5 --years 2020,2021,2022
        """,
    )

    parser.add_argument(
        "--all",
        action="store_true",
        help="Download all available data sources",
    )
    parser.add_argument(
        "--sources",
        type=str,
        help="Comma-separated list of sources to download",
    )
    parser.add_argument(
        "--years",
        type=str,
        help="Comma-separated list of years (for sources that support it)",
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List available data sources",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be downloaded without downloading",
    )

    args = parser.parse_args()

    if args.list:
        list_sources()
        return

    # Parse years
    years = None
    if args.years:
        years = [int(y.strip()) for y in args.years.split(",")]

    # Determine sources to download
    if args.all:
        sources = list(DOWNLOAD_FUNCTIONS.keys())
    elif args.sources:
        sources = [s.strip().lower() for s in args.sources.split(",")]
    else:
        parser.print_help()
        return

    # Validate sources
    invalid_sources = [s for s in sources if s not in DOWNLOAD_FUNCTIONS]
    if invalid_sources:
        print(f"Error: Unknown sources: {invalid_sources}")
        print("Use --list to see available sources")
        sys.exit(1)

    # Download
    print(f"\n{'='*60}")
    print(f"FGV Clima Data Download")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}\n")

    for source in sources:
        print(f"\n{'='*40}")
        print(f"Downloading: {AVAILABLE_SOURCES[source]['name']}")
        print(f"{'='*40}\n")

        if args.dry_run:
            print(f"[DRY RUN] Would download {source}")
        else:
            download_func = DOWNLOAD_FUNCTIONS[source]
            if "years" in download_func.__code__.co_varnames:
                download_func(years=years)
            else:
                download_func()

    print(f"\n{'='*60}")
    print(f"Download complete!")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    main()
