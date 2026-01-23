# FGV Clima - Shared Data Repository

Scripts for data processing and analysis supporting FGV Clima research projects.

## Repository Structure

```
sharedData/
├── scripts/
│   ├── bases/          # Data cleaning scripts (reusable)
│   │   ├── epe/        # Energy data (EPE)
│   │   ├── finbra/     # Municipal finances
│   │   ├── ons/        # National Grid Operator
│   │   ├── prodes/     # Deforestation data (INPE)
│   │   ├── rais/       # Labor market data
│   │   └── secex/      # Foreign trade data
│   │
│   └── projects/       # Project-specific scripts
│       ├── Indústria/  # Industrial sector analysis
│       ├── Mineral/    # Mining sector
│       ├── O&G/        # Oil & Gas
│       └── Transporte/ # Transportation sector
│
└── _reference/         # Reference materials
```

---

## Organization: `bases/` vs `projects/`

### `bases/` — Reusable Data Cleaning

Scripts for cleaning and processing datasets that:
- Are not yet tied to a specific project
- Serve multiple projects (general-purpose)
- Transform raw data into analysis-ready formats

### `projects/` — Project-Specific Code

Scripts that generate final outputs (figures, tables, analyses) for specific reports.

**Key rule:** Each project folder must contain **all code needed to reproduce its outputs**. Code duplication across projects is acceptable.

> The distinction can be subtle. Use judgment: data cleaning/preparation code goes in `bases/`; code generating report outputs goes in `projects/`.

---

## Data Management (SharePoint)

All datasets must be stored on SharePoint:

```
Gestão de projetos > Técnico > 05-Base de dados
```

### Folder Structure

```
05-Base de dados/
├── input/              # Raw data (unmodified)
│   ├── RAIS/
│   ├── FINBRA/
│   ├── ONS/
│   └── [Project Name]/
│
└── output/
    ├── data/           # Cleaned datasets ready for analysis
    ├── figures/        # Generated charts and visualizations
    └── tables/         # Exported tables
```

### Guidelines

- **input/**: Store raw data only — never modify original files
- **output/data/**: Cleaned datasets (`.rds`, `.dta`, `.csv`, `.parquet`)
- **output/figures/**: Visualizations (`.png`, `.pdf`, `.svg`)
- **output/tables/**: Tables (`.csv`, `.xlsx`)

---

## Available Datasets

| Dataset | Description |
|---------|-------------|
| **EPE** | Energy generation and consumption (11 scripts) |
| **FINBRA** | Municipal revenues and petroleum royalties |
| **ONS** | Power plant generation data |
| **PRODES** | Deforestation polygons by biome (INPE) |
| **RAIS** | Formal labor market statistics |
| **SECEX** | Import/export trade data (2000-2024) |

## Projects

| Project | Description |
|---------|-------------|
| **Indústria** | Multi-sector industrial analysis (cement, metallurgy) |
| **Mineral** | Mining sector employment and wages |
| **O&G** | Oil & Gas sector analysis and municipal dependency |
| **Transporte** | Transportation sector report (14 figures) |

---

## Contact

- **FGV Clima**: https://clima.fgv.br
- **Email**: clima@fgv.br
