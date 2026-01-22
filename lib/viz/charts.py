"""
Chart Visualization Functions

Standard chart types with FGV Clima styling.
"""

from typing import Optional, Union, List, Tuple
import pandas as pd
import numpy as np

try:
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

try:
    import seaborn as sns
    HAS_SNS = True
except ImportError:
    HAS_SNS = False

from .theme import FGV_PALETTE, FGV_CATEGORICAL, set_fgv_theme


def plot_time_series(
    df: pd.DataFrame,
    x: str,
    y: Union[str, List[str]],
    hue: Optional[str] = None,
    title: Optional[str] = None,
    xlabel: Optional[str] = None,
    ylabel: Optional[str] = None,
    figsize: Tuple[int, int] = (12, 6),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a time series line plot.

    Parameters
    ----------
    df : pd.DataFrame
        Input data
    x : str
        Column for x-axis (time)
    y : str or list of str
        Column(s) for y-axis
    hue : str, optional
        Column for color grouping
    title : str, optional
        Plot title
    xlabel : str, optional
        X-axis label
    ylabel : str, optional
        Y-axis label
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes
    **kwargs
        Additional arguments for plot

    Returns
    -------
    plt.Axes
        Plot axes

    Examples
    --------
    >>> plot_time_series(df, x="year", y="emissions", hue="sector")
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    # Handle multiple y columns
    if isinstance(y, list):
        for i, col in enumerate(y):
            color = FGV_CATEGORICAL[i % len(FGV_CATEGORICAL)]
            ax.plot(df[x], df[col], label=col, color=color, **kwargs)
        ax.legend()
    elif hue:
        for i, (name, group) in enumerate(df.groupby(hue)):
            color = FGV_CATEGORICAL[i % len(FGV_CATEGORICAL)]
            ax.plot(group[x], group[y], label=name, color=color, **kwargs)
        ax.legend(title=hue)
    else:
        ax.plot(df[x], df[y], color=FGV_PALETTE["primary"], **kwargs)

    # Labels
    ax.set_xlabel(xlabel or x)
    ax.set_ylabel(ylabel or y if isinstance(y, str) else "")
    if title:
        ax.set_title(title)

    # Format x-axis for dates
    if pd.api.types.is_datetime64_any_dtype(df[x]):
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
        ax.xaxis.set_major_locator(mdates.YearLocator())
        plt.xticks(rotation=45)

    return ax


def plot_bar_chart(
    df: pd.DataFrame,
    x: str,
    y: str,
    hue: Optional[str] = None,
    horizontal: bool = False,
    title: Optional[str] = None,
    xlabel: Optional[str] = None,
    ylabel: Optional[str] = None,
    figsize: Tuple[int, int] = (10, 6),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a bar chart.

    Parameters
    ----------
    df : pd.DataFrame
        Input data
    x : str
        Column for categories
    y : str
        Column for values
    hue : str, optional
        Column for color grouping
    horizontal : bool
        If True, creates horizontal bars
    title : str, optional
        Plot title
    xlabel : str, optional
        X-axis label
    ylabel : str, optional
        Y-axis label
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes
    **kwargs
        Additional arguments

    Returns
    -------
    plt.Axes
        Plot axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    if HAS_SNS:
        plot_func = sns.barplot
        orient = "h" if horizontal else "v"
        if horizontal:
            plot_func(data=df, y=x, x=y, hue=hue, ax=ax, orient=orient, palette=FGV_CATEGORICAL, **kwargs)
        else:
            plot_func(data=df, x=x, y=y, hue=hue, ax=ax, orient=orient, palette=FGV_CATEGORICAL, **kwargs)
    else:
        if horizontal:
            ax.barh(df[x], df[y], color=FGV_PALETTE["primary"], **kwargs)
        else:
            ax.bar(df[x], df[y], color=FGV_PALETTE["primary"], **kwargs)

    # Labels
    ax.set_xlabel(xlabel or (y if horizontal else x))
    ax.set_ylabel(ylabel or (x if horizontal else y))
    if title:
        ax.set_title(title)

    # Rotate x labels if needed
    if not horizontal:
        plt.xticks(rotation=45, ha="right")

    return ax


def plot_stacked_area(
    df: pd.DataFrame,
    x: str,
    y_columns: List[str],
    colors: Optional[List[str]] = None,
    title: Optional[str] = None,
    xlabel: Optional[str] = None,
    ylabel: Optional[str] = None,
    figsize: Tuple[int, int] = (12, 6),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a stacked area chart.

    Parameters
    ----------
    df : pd.DataFrame
        Input data
    x : str
        Column for x-axis
    y_columns : list of str
        Columns to stack
    colors : list of str, optional
        Colors for each area
    title : str, optional
        Plot title
    xlabel : str, optional
        X-axis label
    ylabel : str, optional
        Y-axis label
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes
    **kwargs
        Additional arguments

    Returns
    -------
    plt.Axes
        Plot axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    if colors is None:
        colors = FGV_CATEGORICAL[:len(y_columns)]

    ax.stackplot(
        df[x],
        [df[col] for col in y_columns],
        labels=y_columns,
        colors=colors,
        **kwargs,
    )

    ax.legend(loc="upper left")
    ax.set_xlabel(xlabel or x)
    ax.set_ylabel(ylabel or "")
    if title:
        ax.set_title(title)

    return ax


def plot_heatmap(
    df: pd.DataFrame,
    x: str,
    y: str,
    value: str,
    cmap: str = "Blues",
    annot: bool = True,
    fmt: str = ".1f",
    title: Optional[str] = None,
    figsize: Tuple[int, int] = (12, 8),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a heatmap.

    Parameters
    ----------
    df : pd.DataFrame
        Input data in long format
    x : str
        Column for x-axis categories
    y : str
        Column for y-axis categories
    value : str
        Column for cell values
    cmap : str
        Colormap
    annot : bool
        Whether to annotate cells
    fmt : str
        Annotation format
    title : str, optional
        Plot title
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes
    **kwargs
        Additional arguments

    Returns
    -------
    plt.Axes
        Plot axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")
    if not HAS_SNS:
        raise ImportError("seaborn is required for heatmap")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    # Pivot data
    pivot_df = df.pivot(index=y, columns=x, values=value)

    sns.heatmap(
        pivot_df,
        cmap=cmap,
        annot=annot,
        fmt=fmt,
        ax=ax,
        cbar_kws={"label": value},
        **kwargs,
    )

    if title:
        ax.set_title(title)

    return ax


def plot_pie_chart(
    df: pd.DataFrame,
    values: str,
    labels: str,
    colors: Optional[List[str]] = None,
    title: Optional[str] = None,
    figsize: Tuple[int, int] = (8, 8),
    ax: Optional["plt.Axes"] = None,
    **kwargs,
) -> "plt.Axes":
    """
    Create a pie chart.

    Parameters
    ----------
    df : pd.DataFrame
        Input data
    values : str
        Column for slice sizes
    labels : str
        Column for slice labels
    colors : list of str, optional
        Slice colors
    title : str, optional
        Plot title
    figsize : tuple
        Figure size
    ax : plt.Axes, optional
        Existing axes
    **kwargs
        Additional arguments

    Returns
    -------
    plt.Axes
        Plot axes
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    set_fgv_theme()

    if ax is None:
        fig, ax = plt.subplots(figsize=figsize)

    if colors is None:
        colors = FGV_CATEGORICAL[:len(df)]

    ax.pie(
        df[values],
        labels=df[labels],
        colors=colors,
        autopct="%1.1f%%",
        startangle=90,
        **kwargs,
    )

    ax.axis("equal")
    if title:
        ax.set_title(title)

    return ax
