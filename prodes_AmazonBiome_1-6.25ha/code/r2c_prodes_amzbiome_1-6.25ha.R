# > PROJECT INFO
# NAME: CAR A CAR (CARB)
# LEAD: João Mourão e Mariana Stussi
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA [DEFORESTATION POLYGONS ONLY FOR AMAZON BIOME POLYGONS FROM 1-6.25 HA]
# AUTHOR: MARCELO SESSIM (ADAPTED FROM:Rogério Reis)
#
# > NOTES


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

rm(list = ls())

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo

# SOURCES
source(file.path("_functions", "associateCRS.R"))

# LIBRARIES
pkgs <- c("tidyverse","sf", "rlang", "labelled", "rgdal", "rgeos", "Hmisc", "data.table")

groundhogLibraries(pkgs, date = "2023-09-30")

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
raw.prodes <- st_read(file.path(DIR.CPI.DATA, 'land/prodes_AmazonBiome_1-6.25ha/rawData/yearly_deforestation_smaller_than_625ha_biome_23',
                        'yearly_deforestation_smaller_than_625ha_biome.shp'))


# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
colnames(raw.prodes)
# column names
setnames(raw.prodes, "fid",    "prodes_id") # in 2021, not exactly mapping into old "id"
setnames(raw.prodes, "uuid",  "prodes_uuid") # in 2021, no more "origin id"; instead, there is a completely new form of id
setnames(raw.prodes, "state",      "prodes_state_uf")
setnames(raw.prodes, "path_row",   "prodes_pathrow")
setnames(raw.prodes, "main_class", "prodes_class")
setnames(raw.prodes, "class_name", "prodes_class_name")
setnames(raw.prodes, "def_cloud",  "prodes_polyg_cloud_cov")
setnames(raw.prodes, "julian_day", "prodes_julday")
setnames(raw.prodes, "image_date", "prodes_view_date")
setnames(raw.prodes, "year",       "prodes_year")
setnames(raw.prodes, "area_km",    "prodes_area_km2")
setnames(raw.prodes, "scene_id",   "prodes_scene_id")
#setnames(raw.prodes, "publish_ye", "prodes_publish_year") # as of 2021, no longer in database
setnames(raw.prodes, "source",     "prodes_polyg_source")
setnames(raw.prodes, "satellite",  "prodes_satellite")
setnames(raw.prodes, "sensor",     "prodes_sensor")


# checks column classes
lapply(raw.prodes, class) # every column already has its ideal class; no need to change

# ROW CLEANUP
# translation
# prodes_class
raw.prodes$prodes_class <- gsub(pattern = "^DESMATAMENTO$", replacement = "deforestation", x = raw.prodes$prodes_class)   
unique(raw.prodes$prodes_class)

# some "prodes_view_date" columns with hour --> standardizing to YYYY-MM-DD
raw.prodes$prodes_view_date <- as.Date(raw.prodes$prodes_view_date, format = "%Y-%m-%d")






# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.prodes$prodes_pathrow)         <- "polygon identifier: pathrow"
label(raw.prodes$prodes_state_uf)        <- "state name abbreviation"
label(raw.prodes$prodes_class)           <- "land cover category"
label(raw.prodes$prodes_polyg_cloud_cov) <- "polygon cloud coverage history (non-observable since)"
label(raw.prodes$prodes_view_date)       <- "date when the polygon was observed - format (YYYY-MM-DD)"
label(raw.prodes$prodes_julday)          <- "julian day when the polygon was observed"
label(raw.prodes$prodes_year)            <- "year polygon was observed"




# CHANGE FINAL OBJECT NAME
cln_prodes_amzbiome_1_625ha_23 <- raw.prodes
rm(raw.prodes)



# POST-TREATMENT OVERVIEW
# summary(cln_prodes_amzbiome_1_625ha_23)
# View(cln_prodes_amzbiome_1_625ha_23)
# plot(cln_prodes_amzbiome_1_625ha_23)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln_prodes_amzbiome_1_625ha_23, 
     file = file.path(DIR.CPI.DATA, "land/prodes_AmazonBiome_1-6.25ha/cleanData",
                      "cln_prodes_amzbiome_1_625ha.RData"))




# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------

