# > PROJECT INFO
# NAME: Bolsa Verde - Evaluate and Monitor the impact of Bolsa Verde
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: R2C HIDOGRAPHY AMAZON BIOME
# AUTHOR: JULIA BRANDAO
#
#
#

## SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

# GLOBAL SETTINGS
source("config.R") # sets local dirs and sources config for shared data repo

# SOURCES
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions","convertUnits.R"))

# LIBRARIES
pkgs <- c("tidyverse","sf", "rlang", "labelled", "rgdal", "rgeos", "Hmisc", "data.table")
groundhogLibraries(pkgs, date = '2024-02-08')

options(scipen = 999)
options(future.seed = TRUE)


# DATA INPUT ------------------------------------------------------------------------------------------------------------------------------------------

nonforrest.raw <-st_read(file.path(DIR.CPI.DATA, 'land/nonforrest_terrabrasilis/rawData', 
                              'no_forest_biome.shp'))


# DATA CLEAN -----------------------------------------------------------------------------------------------------------------------------------------
colnames(nonforrest.raw)
# COLUMN CLEANUP
# column names
setnames(nonforrest.raw, "fid",         "prodes_id")
setnames(nonforrest.raw, "state",      "prodes_state_uf")
setnames(nonforrest.raw, "path_row",   "prodes_pathrow")
setnames(nonforrest.raw, "main_class", "prodes_class")
setnames(nonforrest.raw, "class_name", "prodes_class_name")
setnames(nonforrest.raw, "def_cloud",  "prodes_polyg_cloud_cov")
setnames(nonforrest.raw, "julian_day", "prodes_julday")
setnames(nonforrest.raw, "image_date", "prodes_view_date")
setnames(nonforrest.raw, "year",       "prodes_year")
setnames(nonforrest.raw, "area_km",    "prodes_area_km2")
setnames(nonforrest.raw, "scene_id",   "prodes_scene_id")
setnames(nonforrest.raw, "source",     "prodes_polyg_source")
setnames(nonforrest.raw, "satellite",  "prodes_satellite")
setnames(nonforrest.raw, "sensor",     "prodes_sensor")
setnames(nonforrest.raw, "uuid",  "prodes_uuid")

#setnames(raw.prodes, "publish_ye", "prodes_publish_year") # as of 2021, no longer in database





# checks column classes
lapply(nonforrest.raw, class) # every column already has its ideal class; no need to change

# ROW CLEANUP
# translation
# prodes_class
nonforrest.raw %>%
  st_drop_geometry() %>%
  distinct(prodes_class)

nonforrest.raw %>%
  st_drop_geometry() %>%
  distinct(prodes_class_name)

nonforrest.raw$prodes_class <- gsub(pattern = "^NAO_FLORESTA$", replacement = "non_forest", x = nonforrest.raw$prodes_class)   
nonforrest.raw$prodes_class_name <- gsub(pattern = "^NAO_FLORESTA.*$", replacement = "non_forest", x = nonforrest.raw$prodes_class_name)   

# some "prodes_view_date" columns with hour --> standardizing to YYYY-MM-DD
nonforrest.raw$prodes_view_date <- as.Date(nonforrest.raw$prodes_view_date, format = "%Y-%m-%d")






# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(nonforrest.raw$prodes_pathrow)         <- "polygon identifier: pathrow"
label(nonforrest.raw$prodes_state_uf)        <- "state name abbreviation"
label(nonforrest.raw$prodes_class)           <- "land cover category"
label(nonforrest.raw$prodes_polyg_cloud_cov) <- "polygon cloud coverage history (non-observable since)"
label(nonforrest.raw$prodes_view_date)       <- "date when the polygon was observed - format (YYYY-MM-DD)"
label(nonforrest.raw$prodes_julday)          <- "julian day when the polygon was observed"
label(nonforrest.raw$prodes_year)            <- "year polygon was observed"




# CHANGE FINAL OBJECT NAME
cln.lnd.lndUse.amzBiome.nonforest  <- nonforrest.raw
rm(nonforrest.raw)




# POST-TREATMENT OVERVIEW
#summary(cln.lnd.lndUse.amzBiome.hydrography)
#View(cln.lnd.lndUse.amzBiome.hydrography)
#plot(cln.lnd.lndUse.amzBiome.hydrography)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.lnd.lndUse.amzBiome.nonforest, 
     file = file.path(DIR.CPI.DATA, 'land/nonforrest_terrabrasilis/cleanData', 
                      'cln_lnd_lndUse_amzBiome_nonforrest.RData'))




