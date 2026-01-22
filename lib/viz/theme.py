"""
FGV Clima Visualization Theme

Matplotlib and seaborn theme settings for consistent visualizations.
"""

from typing import Optional, List

try:
    import matplotlib.pyplot as plt
    import matplotlib as mpl
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

try:
    import seaborn as sns
    HAS_SNS = True
except ImportError:
    HAS_SNS = False


# FGV Clima color palette
FGV_PALETTE = {
    "primary": "#003366",      # Dark blue
    "secondary": "#0066CC",    # Blue
    "accent": "#00A859",       # Green
    "warning": "#FF6600",      # Orange
    "danger": "#CC0000",       # Red
    "light": "#F5F5F5",        # Light gray
    "dark": "#333333",         # Dark gray
}

# Extended palette for categorical data
FGV_CATEGORICAL = [
    "#003366",  # Dark blue
    "#00A859",  # Green
    "#FF6600",  # Orange
    "#CC0000",  # Red
    "#9933CC",  # Purple
    "#0099CC",  # Cyan
    "#FFCC00",  # Yellow
    "#666666",  # Gray
]


def set_fgv_theme(
    context: str = "paper",
    style: str = "whitegrid",
    font_scale: float = 1.2,
    rc_params: Optional[dict] = None,
) -> None:
    """
    Set the FGV Clima visualization theme.

    Parameters
    ----------
    context : str
        Seaborn context: "paper", "notebook", "talk", "poster"
    style : str
        Seaborn style: "whitegrid", "darkgrid", "white", "dark"
    font_scale : float
        Font size scaling factor
    rc_params : dict, optional
        Additional matplotlib rc parameters

    Examples
    --------
    >>> set_fgv_theme()
    >>> plt.plot([1, 2, 3], [1, 2, 3])
    >>> plt.show()
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    # Default rc parameters
    default_rc = {
        "figure.figsize": (10, 6),
        "figure.dpi": 100,
        "savefig.dpi": 300,
        "savefig.bbox": "tight",
        "font.family": "sans-serif",
        "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans"],
        "axes.titlesize": 14,
        "axes.labelsize": 12,
        "axes.titleweight": "bold",
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.prop_cycle": plt.cycler(color=FGV_CATEGORICAL),
        "xtick.labelsize": 10,
        "ytick.labelsize": 10,
        "legend.fontsize": 10,
        "legend.frameon": False,
        "lines.linewidth": 2,
        "grid.alpha": 0.3,
    }

    # Update with custom rc_params
    if rc_params:
        default_rc.update(rc_params)

    # Set seaborn theme if available
    if HAS_SNS:
        sns.set_theme(context=context, style=style, font_scale=font_scale, rc=default_rc)
    else:
        plt.rcParams.update(default_rc)


def get_fgv_colors(n: int = None) -> List[str]:
    """
    Get FGV Clima color palette.

    Parameters
    ----------
    n : int, optional
        Number of colors to return. If None, returns all.

    Returns
    -------
    list of str
        Hex color codes
    """
    if n is None:
        return FGV_CATEGORICAL.copy()
    return FGV_CATEGORICAL[:n]


def reset_theme() -> None:
    """Reset matplotlib to default settings."""
    if HAS_MPL:
        plt.rcdefaults()
        if HAS_SNS:
            sns.reset_defaults()


def save_figure(
    fig: "plt.Figure",
    filename: str,
    formats: List[str] = ["png", "pdf"],
    dpi: int = 300,
) -> None:
    """
    Save figure in multiple formats.

    Parameters
    ----------
    fig : plt.Figure
        Figure to save
    filename : str
        Base filename (without extension)
    formats : list of str
        Output formats
    dpi : int
        Resolution for raster formats
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    for fmt in formats:
        fig.savefig(
            f"{filename}.{fmt}",
            format=fmt,
            dpi=dpi,
            bbox_inches="tight",
            facecolor="white",
            edgecolor="none",
        )


def add_fgv_logo(
    ax: "plt.Axes",
    position: str = "lower right",
    alpha: float = 0.5,
) -> None:
    """
    Add FGV Clima watermark/logo to plot.

    Parameters
    ----------
    ax : plt.Axes
        Axes to add logo to
    position : str
        Logo position: "lower right", "lower left", "upper right", "upper left"
    alpha : float
        Logo transparency
    """
    if not HAS_MPL:
        raise ImportError("matplotlib is required")

    positions = {
        "lower right": (0.98, 0.02),
        "lower left": (0.02, 0.02),
        "upper right": (0.98, 0.98),
        "upper left": (0.02, 0.98),
    }

    x, y = positions.get(position, (0.98, 0.02))
    ha = "right" if "right" in position else "left"
    va = "top" if "upper" in position else "bottom"

    ax.text(
        x, y,
        "FGV Clima",
        transform=ax.transAxes,
        fontsize=8,
        alpha=alpha,
        ha=ha,
        va=va,
        color=FGV_PALETTE["dark"],
        style="italic",
    )
