"""
Color Palettes for FGV Clima Visualizations

Standard color palettes for different data types.
"""

from typing import Dict, List, Optional

# Land use colors (MapBiomas compatible)
LAND_USE_COLORS: Dict[str, str] = {
    # Forest
    "Forest": "#006400",
    "Forest Formation": "#006400",
    "Savanna Formation": "#00FF00",
    "Mangrove": "#687537",
    "Floodable Forest": "#6B9932",
    "Forest Plantation": "#935132",
    # Non-forest natural
    "Wetland": "#45C2A5",
    "Grassland": "#B8AF4F",
    "Other Non Forest Natural Formation": "#BDB76B",
    "Rocky Outcrop": "#AA0000",
    # Agriculture
    "Pasture": "#FFD966",
    "Agriculture": "#E974ED",
    "Temporary Crops": "#C27BA0",
    "Sugar Cane": "#C71585",
    "Soy Beans": "#FFD700",
    "Rice": "#7B68EE",
    "Cotton": "#FF69B4",
    "Coffee": "#8B4513",
    "Citrus": "#FFA500",
    "Mosaic of Agriculture and Pasture": "#FFEFC3",
    "Forest Plantation": "#935132",
    # Non-vegetated
    "Urban Infrastructure": "#AF2A2A",
    "Mining": "#8B0000",
    "Beach and Dune": "#FAD8D8",
    "Other Non Vegetated Area": "#EA9999",
    # Water
    "Water": "#0000FF",
    "River, Lake and Ocean": "#0000FF",
    "Aquaculture": "#29EEE4",
    # Other
    "Non Observed": "#FFFFFF",
}

# Biome colors
BIOME_COLORS: Dict[str, str] = {
    "Amazonia": "#006400",
    "Amazon": "#006400",
    "Cerrado": "#B8860B",
    "Savanna": "#B8860B",
    "Mata Atlantica": "#228B22",
    "Atlantic Forest": "#228B22",
    "Caatinga": "#DEB887",
    "Pampa": "#90EE90",
    "Pantanal": "#4682B4",
}

# Emission sector colors
EMISSION_SECTOR_COLORS: Dict[str, str] = {
    "Energia": "#333333",
    "Energy": "#333333",
    "Processos Industriais": "#666666",
    "Industrial Processes": "#666666",
    "Agropecuaria": "#FFD700",
    "Agriculture": "#FFD700",
    "Mudanca de Uso da Terra": "#006400",
    "Land Use Change": "#006400",
    "Residuos": "#8B4513",
    "Waste": "#8B4513",
}

# Sequential palettes for continuous data
SEQUENTIAL_PALETTES: Dict[str, List[str]] = {
    "green": ["#f7fcf5", "#e5f5e0", "#c7e9c0", "#a1d99b", "#74c476", "#41ab5d", "#238b45", "#006d2c", "#00441b"],
    "blue": ["#f7fbff", "#deebf7", "#c6dbef", "#9ecae1", "#6baed6", "#4292c6", "#2171b5", "#08519c", "#08306b"],
    "red": ["#fff5f0", "#fee0d2", "#fcbba1", "#fc9272", "#fb6a4a", "#ef3b2c", "#cb181d", "#a50f15", "#67000d"],
    "orange": ["#fff5eb", "#fee6ce", "#fdd0a2", "#fdae6b", "#fd8d3c", "#f16913", "#d94801", "#a63603", "#7f2704"],
    "purple": ["#fcfbfd", "#efedf5", "#dadaeb", "#bcbddc", "#9e9ac8", "#807dba", "#6a51a3", "#54278f", "#3f007d"],
}

# Diverging palettes for anomalies
DIVERGING_PALETTES: Dict[str, List[str]] = {
    "temp_anomaly": ["#2166ac", "#4393c3", "#92c5de", "#d1e5f0", "#f7f7f7", "#fddbc7", "#f4a582", "#d6604d", "#b2182b"],
    "precip_anomaly": ["#8c510a", "#bf812d", "#dfc27d", "#f6e8c3", "#f5f5f5", "#c7eae5", "#80cdc1", "#35978f", "#01665e"],
    "emission_change": ["#1a9850", "#66bd63", "#a6d96a", "#d9ef8b", "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027"],
}


def get_land_use_color(class_name: str) -> str:
    """Get color for a land use class."""
    return LAND_USE_COLORS.get(class_name, "#CCCCCC")


def get_biome_color(biome_name: str) -> str:
    """Get color for a biome."""
    return BIOME_COLORS.get(biome_name, "#CCCCCC")


def get_sequential_palette(name: str, n: Optional[int] = None) -> List[str]:
    """
    Get a sequential color palette.

    Parameters
    ----------
    name : str
        Palette name: "green", "blue", "red", "orange", "purple"
    n : int, optional
        Number of colors. If None, returns full palette.

    Returns
    -------
    list of str
        Color palette
    """
    palette = SEQUENTIAL_PALETTES.get(name, SEQUENTIAL_PALETTES["blue"])
    if n is not None and n < len(palette):
        # Sample evenly from the palette
        indices = [int(i * (len(palette) - 1) / (n - 1)) for i in range(n)]
        return [palette[i] for i in indices]
    return palette


def get_diverging_palette(name: str, n: Optional[int] = None) -> List[str]:
    """
    Get a diverging color palette.

    Parameters
    ----------
    name : str
        Palette name: "temp_anomaly", "precip_anomaly", "emission_change"
    n : int, optional
        Number of colors

    Returns
    -------
    list of str
        Color palette
    """
    palette = DIVERGING_PALETTES.get(name, DIVERGING_PALETTES["temp_anomaly"])
    if n is not None and n < len(palette):
        indices = [int(i * (len(palette) - 1) / (n - 1)) for i in range(n)]
        return [palette[i] for i in indices]
    return palette


def create_land_use_cmap():
    """
    Create a matplotlib colormap for MapBiomas land use data.

    Returns
    -------
    matplotlib.colors.ListedColormap
        Colormap for land use visualization
    """
    try:
        from matplotlib.colors import ListedColormap
    except ImportError:
        raise ImportError("matplotlib is required")

    # MapBiomas class IDs and colors
    class_colors = {
        0: "#FFFFFF",   # No data
        1: "#006400",   # Forest
        3: "#006400",   # Forest Formation
        4: "#00FF00",   # Savanna Formation
        5: "#687537",   # Mangrove
        9: "#935132",   # Forest Plantation
        12: "#B8AF4F",  # Grassland
        15: "#FFD966",  # Pasture
        18: "#E974ED",  # Agriculture
        21: "#FFEFC3",  # Mosaic
        23: "#FAD8D8",  # Beach and Dune
        24: "#AF2A2A",  # Urban
        25: "#EA9999",  # Other Non Vegetated
        26: "#0000FF",  # Water
        27: "#FFFFFF",  # Non Observed
        33: "#0000FF",  # Water
    }

    # Create color list for all possible values (0-50)
    colors = ["#CCCCCC"] * 51
    for class_id, color in class_colors.items():
        if class_id < len(colors):
            colors[class_id] = color

    return ListedColormap(colors)
