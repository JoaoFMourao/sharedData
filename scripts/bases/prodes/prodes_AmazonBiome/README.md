# PRODES Amazon Biome

Deforestation data processing for the Amazon Biome.

## Scripts

| Script | Description |
|--------|-------------|
| `01_r2c_lcv_dfrst_amz_biome_prodes_inpe_sf.R` | Clean raw shapefile, standardize columns |
| `02_mrg_withAmazonMuni.R` | Merge deforestation polygons with municipality boundaries |
| `03_crossCheck.R` | Validate aggregated values against INPE totals |

### Subfolders

- `defo_mask/` — Deforestation mask processing
- `old/` — Deprecated versions

## Input

- `rawData/yearly_deforestation_biome_23/yearly_deforestation_biome.shp`

## Output

- `cleanData/cln_lcv_dfrst_amz_biome_prodes_inpe_sf.RData`
- `cleanData/02_mrg_amazonMuni_*/prodes_inc_amz_muni_[IBGE]_sf.Rdata`

## Authors

- Rogério Reis
- João Mourão
