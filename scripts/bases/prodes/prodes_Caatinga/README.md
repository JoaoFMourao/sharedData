# PRODES Caatinga Biome

Deforestation data processing for the Caatinga Biome.

## Scripts

| Script | Description |
|--------|-------------|
| `01_r2c_cln_lcv_dfrst_caat_biome_prodes_inpe_sf.R` | Clean raw shapefile, standardize columns |
| `02_mrg_withCaatingaMuni.R` | Merge deforestation polygons with municipality boundaries |
| `03_crossCheck.R` | Validate aggregated values against INPE totals |

### Subfolders

- `defo_mask/` — Deforestation mask processing
- `02_mrg_withCaatingaMuni_old/` — Deprecated versions

## Input

- `rawData/yearly_deforestation.shp`

## Output

- `cleanData/cln_lcv_dfrst_caatinga_biome_prodes_inpe_sf.RData`

## Authors

- Rogério Reis
