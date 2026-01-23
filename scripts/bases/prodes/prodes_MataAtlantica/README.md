# PRODES Atlantic Forest (Mata Atlântica)

Deforestation data processing for the Atlantic Forest Biome.

## Scripts

| Script | Description |
|--------|-------------|
| `01_r2c_cln_lcv_dfrst_mt_at_biome_prodes_inpe_sf.R` | Clean raw shapefile, standardize columns |
| `02_mrg_withMataAtlanticaMuni.R` | Merge deforestation polygons with municipality boundaries |
| `03_crossCheck.R` | Validate aggregated values against INPE totals |

### Subfolders

- `defo_mask/` — Deforestation mask processing
- `old/` — Deprecated versions

## Input

- `rawData/yearly_deforestation.shp`

## Output

- `cleanData/cln_lcv_dfrst_mt_at_biome_prodes_inpe_sf.RData`

## Authors

- Rogério Reis
