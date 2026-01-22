"""
Brazil-Specific Utilities

Constants and functions specific to Brazilian geography and data.
"""

from typing import Optional, Dict, List


# Brazilian states
STATES: Dict[str, dict] = {
    "AC": {"code": 12, "name": "Acre", "region": "Norte"},
    "AL": {"code": 27, "name": "Alagoas", "region": "Nordeste"},
    "AM": {"code": 13, "name": "Amazonas", "region": "Norte"},
    "AP": {"code": 16, "name": "Amapa", "region": "Norte"},
    "BA": {"code": 29, "name": "Bahia", "region": "Nordeste"},
    "CE": {"code": 23, "name": "Ceara", "region": "Nordeste"},
    "DF": {"code": 53, "name": "Distrito Federal", "region": "Centro-Oeste"},
    "ES": {"code": 32, "name": "Espirito Santo", "region": "Sudeste"},
    "GO": {"code": 52, "name": "Goias", "region": "Centro-Oeste"},
    "MA": {"code": 21, "name": "Maranhao", "region": "Nordeste"},
    "MG": {"code": 31, "name": "Minas Gerais", "region": "Sudeste"},
    "MS": {"code": 50, "name": "Mato Grosso do Sul", "region": "Centro-Oeste"},
    "MT": {"code": 51, "name": "Mato Grosso", "region": "Centro-Oeste"},
    "PA": {"code": 15, "name": "Para", "region": "Norte"},
    "PB": {"code": 25, "name": "Paraiba", "region": "Nordeste"},
    "PE": {"code": 26, "name": "Pernambuco", "region": "Nordeste"},
    "PI": {"code": 22, "name": "Piaui", "region": "Nordeste"},
    "PR": {"code": 41, "name": "Parana", "region": "Sul"},
    "RJ": {"code": 33, "name": "Rio de Janeiro", "region": "Sudeste"},
    "RN": {"code": 24, "name": "Rio Grande do Norte", "region": "Nordeste"},
    "RO": {"code": 11, "name": "Rondonia", "region": "Norte"},
    "RR": {"code": 14, "name": "Roraima", "region": "Norte"},
    "RS": {"code": 43, "name": "Rio Grande do Sul", "region": "Sul"},
    "SC": {"code": 42, "name": "Santa Catarina", "region": "Sul"},
    "SE": {"code": 28, "name": "Sergipe", "region": "Nordeste"},
    "SP": {"code": 35, "name": "Sao Paulo", "region": "Sudeste"},
    "TO": {"code": 17, "name": "Tocantins", "region": "Norte"},
}

# Brazilian regions
REGIONS: Dict[str, List[str]] = {
    "Norte": ["AC", "AM", "AP", "PA", "RO", "RR", "TO"],
    "Nordeste": ["AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE"],
    "Centro-Oeste": ["DF", "GO", "MS", "MT"],
    "Sudeste": ["ES", "MG", "RJ", "SP"],
    "Sul": ["PR", "RS", "SC"],
}

# Brazilian biomes
BIOMES: Dict[str, dict] = {
    "Amazonia": {
        "name_en": "Amazon",
        "area_km2": 4196943,
        "states": ["AC", "AM", "AP", "PA", "RO", "RR", "TO", "MA", "MT"],
    },
    "Cerrado": {
        "name_en": "Savanna",
        "area_km2": 2036448,
        "states": ["BA", "DF", "GO", "MA", "MG", "MS", "MT", "PI", "PR", "SP", "TO"],
    },
    "Mata Atlantica": {
        "name_en": "Atlantic Forest",
        "area_km2": 1110182,
        "states": ["AL", "BA", "CE", "ES", "GO", "MG", "MS", "PB", "PE", "PI", "PR", "RJ", "RN", "RS", "SC", "SE", "SP"],
    },
    "Caatinga": {
        "name_en": "Caatinga",
        "area_km2": 844453,
        "states": ["AL", "BA", "CE", "MA", "MG", "PB", "PE", "PI", "RN", "SE"],
    },
    "Pampa": {
        "name_en": "Pampa",
        "area_km2": 176496,
        "states": ["RS"],
    },
    "Pantanal": {
        "name_en": "Pantanal",
        "area_km2": 150355,
        "states": ["MS", "MT"],
    },
}

# Legal Amazon states
LEGAL_AMAZON_STATES = ["AC", "AM", "AP", "MA", "MT", "PA", "RO", "RR", "TO"]


def get_state_name(uf: str) -> str:
    """
    Get the full name of a Brazilian state.

    Parameters
    ----------
    uf : str
        State abbreviation (e.g., "SP")

    Returns
    -------
    str
        State name
    """
    uf = uf.upper()
    if uf not in STATES:
        raise ValueError(f"Unknown state: {uf}")
    return STATES[uf]["name"]


def get_state_code(uf: str) -> int:
    """
    Get the IBGE code for a Brazilian state.

    Parameters
    ----------
    uf : str
        State abbreviation

    Returns
    -------
    int
        IBGE state code
    """
    uf = uf.upper()
    if uf not in STATES:
        raise ValueError(f"Unknown state: {uf}")
    return STATES[uf]["code"]


def get_region(uf: str) -> str:
    """
    Get the region of a Brazilian state.

    Parameters
    ----------
    uf : str
        State abbreviation

    Returns
    -------
    str
        Region name
    """
    uf = uf.upper()
    if uf not in STATES:
        raise ValueError(f"Unknown state: {uf}")
    return STATES[uf]["region"]


def get_biome(biome_name: str) -> dict:
    """
    Get information about a Brazilian biome.

    Parameters
    ----------
    biome_name : str
        Biome name (Portuguese or English)

    Returns
    -------
    dict
        Biome information
    """
    # Normalize name
    name_map = {
        "amazon": "Amazonia",
        "amazonia": "Amazonia",
        "cerrado": "Cerrado",
        "savanna": "Cerrado",
        "atlantic forest": "Mata Atlantica",
        "mata atlantica": "Mata Atlantica",
        "caatinga": "Caatinga",
        "pampa": "Pampa",
        "pantanal": "Pantanal",
    }

    normalized = name_map.get(biome_name.lower(), biome_name)

    if normalized not in BIOMES:
        raise ValueError(f"Unknown biome: {biome_name}")

    return BIOMES[normalized]


def get_states_in_region(region: str) -> List[str]:
    """
    Get all states in a region.

    Parameters
    ----------
    region : str
        Region name

    Returns
    -------
    list of str
        State abbreviations
    """
    if region not in REGIONS:
        raise ValueError(f"Unknown region: {region}. Valid: {list(REGIONS.keys())}")
    return REGIONS[region]


def get_states_in_biome(biome_name: str) -> List[str]:
    """
    Get all states that intersect with a biome.

    Parameters
    ----------
    biome_name : str
        Biome name

    Returns
    -------
    list of str
        State abbreviations
    """
    biome_info = get_biome(biome_name)
    return biome_info["states"]


def is_in_legal_amazon(uf: str) -> bool:
    """
    Check if a state is in the Legal Amazon.

    Parameters
    ----------
    uf : str
        State abbreviation

    Returns
    -------
    bool
        True if state is in Legal Amazon
    """
    return uf.upper() in LEGAL_AMAZON_STATES


def municipality_code_to_state(code: str) -> str:
    """
    Extract state abbreviation from municipality code.

    Parameters
    ----------
    code : str
        7-digit IBGE municipality code

    Returns
    -------
    str
        State abbreviation
    """
    code_str = str(code).zfill(7)
    state_code = int(code_str[:2])

    for uf, info in STATES.items():
        if info["code"] == state_code:
            return uf

    raise ValueError(f"Invalid state code: {state_code}")
