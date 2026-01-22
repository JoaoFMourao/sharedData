#!/usr/bin/env python3
"""
Data Validation Script

Validate data files in the data-hub for quality and consistency.

Usage:
    python scripts/validate_data.py
    python scripts/validate_data.py --source mapbiomas
    python scripts/validate_data.py --category climate
"""

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime
import json

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from lib import DATA_HUB
from lib.utils.paths import list_available_data


def validate_directory_structure(path: Path) -> Dict[str, Any]:
    """Validate directory structure."""
    report = {
        "path": str(path),
        "exists": path.exists(),
        "is_directory": path.is_dir() if path.exists() else False,
        "has_readme": (path / "README.md").exists() if path.exists() else False,
        "file_count": 0,
        "total_size_mb": 0,
        "issues": [],
    }

    if not path.exists():
        report["issues"].append("Directory does not exist")
        return report

    # Count files and size
    files = list(path.rglob("*"))
    data_files = [f for f in files if f.is_file() and not f.name.startswith(".")]

    report["file_count"] = len(data_files)
    report["total_size_mb"] = sum(f.stat().st_size for f in data_files) / (1024 * 1024)

    # Check for common issues
    if not report["has_readme"]:
        report["issues"].append("Missing README.md")

    if report["file_count"] == 0:
        report["issues"].append("No data files found")

    return report


def validate_file_naming(path: Path) -> Dict[str, Any]:
    """Validate file naming conventions."""
    report = {
        "path": str(path),
        "files_checked": 0,
        "naming_issues": [],
    }

    if not path.exists():
        return report

    files = list(path.rglob("*"))
    data_files = [f for f in files if f.is_file() and not f.name.startswith(".")]

    report["files_checked"] = len(data_files)

    for f in data_files:
        # Check for spaces in filenames
        if " " in f.name:
            report["naming_issues"].append(f"Spaces in filename: {f.name}")

        # Check for uppercase
        if f.name != f.name.lower() and f.suffix not in [".R", ".Rmd"]:
            report["naming_issues"].append(f"Uppercase in filename: {f.name}")

        # Check for special characters
        if any(c in f.stem for c in ["#", "$", "%", "&", "!", "?"]):
            report["naming_issues"].append(f"Special characters in filename: {f.name}")

    return report


def validate_data_hub() -> Dict[str, Any]:
    """Validate the entire data-hub."""
    report = {
        "timestamp": datetime.now().isoformat(),
        "data_hub_path": str(DATA_HUB),
        "categories": {},
        "summary": {
            "total_sources": 0,
            "total_files": 0,
            "total_size_mb": 0,
            "total_issues": 0,
        },
    }

    categories = ["climate", "land-use", "emissions", "socioeconomic", "geospatial"]

    for category in categories:
        category_path = DATA_HUB / category
        report["categories"][category] = {
            "path": str(category_path),
            "exists": category_path.exists(),
            "sources": {},
        }

        if not category_path.exists():
            continue

        # Check each source in category
        for source_dir in category_path.iterdir():
            if source_dir.is_dir() and not source_dir.name.startswith("."):
                source_name = source_dir.name

                # Validate structure
                structure_report = validate_directory_structure(source_dir)
                naming_report = validate_file_naming(source_dir)

                report["categories"][category]["sources"][source_name] = {
                    "structure": structure_report,
                    "naming": naming_report,
                }

                # Update summary
                report["summary"]["total_sources"] += 1
                report["summary"]["total_files"] += structure_report["file_count"]
                report["summary"]["total_size_mb"] += structure_report["total_size_mb"]
                report["summary"]["total_issues"] += len(structure_report["issues"])
                report["summary"]["total_issues"] += len(naming_report["naming_issues"])

    return report


def print_report(report: Dict[str, Any], verbose: bool = False) -> None:
    """Print validation report."""
    print("\n" + "=" * 60)
    print("FGV Clima Data Hub Validation Report")
    print("=" * 60)
    print(f"\nTimestamp: {report['timestamp']}")
    print(f"Data Hub: {report['data_hub_path']}")

    print("\n" + "-" * 40)
    print("Summary")
    print("-" * 40)
    summary = report["summary"]
    print(f"  Total sources: {summary['total_sources']}")
    print(f"  Total files: {summary['total_files']}")
    print(f"  Total size: {summary['total_size_mb']:.2f} MB")
    print(f"  Total issues: {summary['total_issues']}")

    if verbose:
        for category, cat_data in report["categories"].items():
            print(f"\n{'-' * 40}")
            print(f"Category: {category}")
            print(f"{'-' * 40}")

            if not cat_data["exists"]:
                print("  [NOT FOUND]")
                continue

            for source, source_data in cat_data["sources"].items():
                structure = source_data["structure"]
                naming = source_data["naming"]

                status = "OK" if not structure["issues"] and not naming["naming_issues"] else "ISSUES"
                print(f"\n  {source}: [{status}]")
                print(f"    Files: {structure['file_count']}")
                print(f"    Size: {structure['total_size_mb']:.2f} MB")

                if structure["issues"]:
                    print(f"    Structure issues:")
                    for issue in structure["issues"]:
                        print(f"      - {issue}")

                if naming["naming_issues"]:
                    print(f"    Naming issues:")
                    for issue in naming["naming_issues"][:5]:  # Limit output
                        print(f"      - {issue}")
                    if len(naming["naming_issues"]) > 5:
                        print(f"      ... and {len(naming['naming_issues']) - 5} more")

    # Overall status
    print("\n" + "=" * 60)
    if summary["total_issues"] == 0:
        print("Status: ALL CHECKS PASSED")
    else:
        print(f"Status: {summary['total_issues']} ISSUES FOUND")
    print("=" * 60 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description="Validate data files in data-hub",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--source",
        type=str,
        help="Validate specific data source",
    )
    parser.add_argument(
        "--category",
        type=str,
        choices=["climate", "land-use", "emissions", "socioeconomic", "geospatial"],
        help="Validate specific category",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Show detailed report",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output report as JSON",
    )

    args = parser.parse_args()

    # Run validation
    report = validate_data_hub()

    # Output
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print_report(report, verbose=args.verbose)

    # Exit with error if issues found
    if report["summary"]["total_issues"] > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
