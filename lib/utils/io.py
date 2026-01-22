"""
I/O Utilities

Functions for reading and writing data with metadata.
"""

from pathlib import Path
from typing import Optional, Union, Dict, Any
from datetime import datetime
import json
import pandas as pd


def read_parquet_lazy(
    path: Union[str, Path],
    columns: Optional[list] = None,
    filters: Optional[list] = None,
) -> pd.DataFrame:
    """
    Read a parquet file with optional column selection and filtering.

    Parameters
    ----------
    path : str or Path
        Path to parquet file
    columns : list, optional
        Columns to read
    filters : list, optional
        Row filters in pyarrow format

    Returns
    -------
    pd.DataFrame
        Data

    Examples
    --------
    >>> df = read_parquet_lazy("data.parquet", columns=["year", "value"])
    >>> df = read_parquet_lazy("data.parquet", filters=[("year", ">=", 2020)])
    """
    try:
        return pd.read_parquet(path, columns=columns, filters=filters)
    except Exception:
        # Fallback without filters
        df = pd.read_parquet(path, columns=columns)
        return df


def save_with_metadata(
    df: pd.DataFrame,
    path: Union[str, Path],
    metadata: Optional[Dict[str, Any]] = None,
    format: str = "parquet",
) -> None:
    """
    Save DataFrame with metadata sidecar file.

    Parameters
    ----------
    df : pd.DataFrame
        Data to save
    path : str or Path
        Output path
    metadata : dict, optional
        Additional metadata to include
    format : str
        Output format: "parquet" or "csv"

    Examples
    --------
    >>> save_with_metadata(df, "output.parquet", {"source": "SEEG", "version": "10"})
    """
    path = Path(path)

    # Save data
    if format == "parquet":
        df.to_parquet(path, index=False)
    elif format == "csv":
        df.to_csv(path, index=False)
    else:
        raise ValueError(f"Unknown format: {format}")

    # Create metadata
    meta = {
        "created_at": datetime.now().isoformat(),
        "rows": len(df),
        "columns": list(df.columns),
        "dtypes": {col: str(dtype) for col, dtype in df.dtypes.items()},
    }

    if metadata:
        meta.update(metadata)

    # Save metadata sidecar
    meta_path = path.with_suffix(path.suffix + ".meta.json")
    with open(meta_path, "w") as f:
        json.dump(meta, f, indent=2)


def load_config(
    config_name: str = "config.json",
    project_path: Optional[Path] = None,
) -> Dict[str, Any]:
    """
    Load configuration file.

    Parameters
    ----------
    config_name : str
        Configuration filename
    project_path : Path, optional
        Project directory

    Returns
    -------
    dict
        Configuration dictionary
    """
    if project_path:
        config_path = project_path / config_name
    else:
        config_path = Path(config_name)

    if not config_path.exists():
        return {}

    with open(config_path) as f:
        if config_path.suffix == ".json":
            return json.load(f)
        elif config_path.suffix in [".yaml", ".yml"]:
            try:
                import yaml
                return yaml.safe_load(f)
            except ImportError:
                raise ImportError("PyYAML required for YAML config files")
        else:
            raise ValueError(f"Unsupported config format: {config_path.suffix}")


def read_multiple_files(
    paths: list,
    format: str = "auto",
    concat: bool = True,
    **kwargs,
) -> Union[pd.DataFrame, list]:
    """
    Read multiple files and optionally concatenate.

    Parameters
    ----------
    paths : list
        List of file paths
    format : str
        File format: "auto", "csv", "parquet"
    concat : bool
        Whether to concatenate into single DataFrame
    **kwargs
        Arguments passed to read function

    Returns
    -------
    pd.DataFrame or list
        Combined data or list of DataFrames
    """
    dfs = []

    for path in paths:
        path = Path(path)

        if format == "auto":
            if path.suffix == ".parquet":
                fmt = "parquet"
            elif path.suffix == ".csv":
                fmt = "csv"
            else:
                raise ValueError(f"Cannot auto-detect format for {path}")
        else:
            fmt = format

        if fmt == "parquet":
            df = pd.read_parquet(path, **kwargs)
        elif fmt == "csv":
            df = pd.read_csv(path, **kwargs)
        else:
            raise ValueError(f"Unknown format: {fmt}")

        df["_source_file"] = path.name
        dfs.append(df)

    if concat:
        return pd.concat(dfs, ignore_index=True)
    return dfs


def export_for_publication(
    df: pd.DataFrame,
    base_path: Union[str, Path],
    formats: list = ["csv", "xlsx"],
    include_metadata: bool = True,
) -> None:
    """
    Export data in multiple formats for publication.

    Parameters
    ----------
    df : pd.DataFrame
        Data to export
    base_path : str or Path
        Base path (without extension)
    formats : list
        Output formats
    include_metadata : bool
        Whether to include metadata file
    """
    base_path = Path(base_path)
    base_path.parent.mkdir(parents=True, exist_ok=True)

    for fmt in formats:
        if fmt == "csv":
            df.to_csv(base_path.with_suffix(".csv"), index=False)
        elif fmt == "xlsx":
            df.to_excel(base_path.with_suffix(".xlsx"), index=False)
        elif fmt == "parquet":
            df.to_parquet(base_path.with_suffix(".parquet"), index=False)
        elif fmt == "json":
            df.to_json(base_path.with_suffix(".json"), orient="records", indent=2)

    if include_metadata:
        meta = {
            "exported_at": datetime.now().isoformat(),
            "rows": len(df),
            "columns": list(df.columns),
            "formats": formats,
        }
        with open(base_path.with_suffix(".meta.json"), "w") as f:
            json.dump(meta, f, indent=2)
