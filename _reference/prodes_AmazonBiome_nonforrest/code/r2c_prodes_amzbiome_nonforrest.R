# > PROJECT INFO
# NAME: CPI DATA REPOSITORY
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA - INCREASED suppression in non-forests
# AUTHOR: JULIA BRANDAO (ADAPTED FROM RAFAEL PUCCI)
#
# > NOTES
# - This scrip took 2 minutes to run


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "convertUnits.R"))


# loading packages
pkgs <- c("sf", "rgdal", "rgeos", "Hmisc", "data.table")


groundhogLibraries(pkgs, "2024-02-20")

# Turns off scientific notation
options(scipen = 999) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
## Yearly Increase suppression in non-forests ####

# RAW DATA
raw.increment <- st_read(
  file.path(DIR.CPI.DATA,
      "land/prodes_AmazonBiome_nonforrest/rawData/yearly_deforestation_nf_biome.shp"))

# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

### COLUMN CLEANUP
# changing column names

colnames(raw.increment)

setnames(raw.increment, "fid",         "prodes_id") # in 2021, not exactly mapping into old "id"
setnames(raw.increment, "state",      "state_uf")
setnames(raw.increment, "path_row",   "prodes_pathrow")
setnames(raw.increment, "main_class", "prodes_main_class")
setnames(raw.increment, "class_name", "prodes_esp_class") # name of the specific class assigned to the feature (ex: deflorestation  in the year 2022- d2022)
setnames(raw.increment, "def_cloud",  "prodes_polyg_cloud_cov")
setnames(raw.increment, "julian_day", "prodes_julday")
setnames(raw.increment, "image_date", "prodes_view_date")
setnames(raw.increment, "year",       "prodes_year")
setnames(raw.increment, "area_km",    "prodes_area_km2")
setnames(raw.increment, "scene_id",   "prodes_scene_id")
setnames(raw.increment, "source",     "prodes_polyg_source")
setnames(raw.increment, "satellite",  "prodes_satellite")
setnames(raw.increment, "sensor",     "prodes_sensor")
setnames(raw.increment, "uuid",  "prodes_uuid") # in 2021, no more "origin id"; instead, there is a completely new form of id

# checks column classes
lapply(raw.increment, class) # every column already has its ideal class; no need to change

#### ROW CLEANUP
# translation of values
# prodes_main_class
raw.increment$prodes_main_class <- gsub(pattern = "^desmatamento$", replacement = "deforestation", x = raw.increment$prodes_main_class)   
raw.increment$prodes_main_class <- gsub(pattern = "^hidrografia$", replacement = "hydrography", x = raw.increment$prodes_main_class)   
raw.increment$prodes_main_class <- gsub(pattern = "^residuo$", replacement = "residue", x = raw.increment$prodes_main_class)   

raw.increment <- raw.increment %>%
    filter(prodes_main_class %in% c("deforestation", "residue"))


# prodes_class_esp
raw.increment$prodes_esp_class <- gsub(pattern = "^hidrografia$", replacement = "hydrography", x = raw.increment$prodes_esp_class)   
# As the values for deforestation and residue are only 'd-year' and 'r-year' it is 
# not necessary to change them

raw.increment$prodes_view_date <- as.Date(raw.increment$prodes_view_date, format = "%Y-%m-%d")


raw.increment <- raw.increment %>%
    
    st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
    
    st_make_valid() %>%
    
    st_buffer(0) 

# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.increment$prodes_id)              <- "polygon identifier: pathrow"
label(raw.increment$state_uf)        <- "state name abbreviation"
label(raw.increment$prodes_pathrow)         <- "polygon identifier: pathrow"
label(raw.increment$prodes_main_class)             <- "name of the main class assigned to the feature ('waste', 'hydrography', 'deforestation')"
label(raw.increment$prodes_esp_class)              <- "name of the specific class assigned to the feature ('residue','r2022','hydrography','dYYYY' where YYYY=year with 4 digits from 2000 onwards)"
label(raw.increment$prodes_polyg_cloud_cov) <- "polygon cloud coverage history (non-observable since)"
label(raw.increment$prodes_view_date)       <- "date when the polygon was observed - format (YYYY-MM-DD)"
label(raw.increment$prodes_julday)          <- "julian day when the polygon was observed"
label(raw.increment$prodes_year)            <- "year polygon was observed"






# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------
cln.bv.prodes.increm.nonflorest.sup <- raw.increment
save(
  cln.bv.prodes.increm.nonflorest.sup,
  file = "A:/land/prodes_AmazonBiome_nonforrest/cleanData/cln_prodes_amzbiome_nonforrest.RData"
)


Sys.time() - str.time



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
