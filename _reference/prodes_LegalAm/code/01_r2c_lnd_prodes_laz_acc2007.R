
# > PROJECT INFO
# NAME: CPI DATA REPOSITORY
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA [DEFORESTATION POLYGONS ONLY]
# AUTHOR: JOAO MOURAO (ADAPTED FROM RAFAEL PUCCI)
#
# > NOTES
# - Amazon Biome only 


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


groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
## Yearly Deforestation ####

# RAW DATA
raw.accumulated <- st_read(
  file.path(
    DIR.CPI.DATA,
    "land","prodes_LegalAm","rawData",
    "accumulated_deforestation_2007"
  )
)


# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# column names
setnames(raw.accumulated, "fid",         "prodes_id") # in 2021, not exactly mapping into old "id"
setnames(raw.accumulated, "uuid",  "prodes_uuid") # in 2021, no more "origin id"; instead, there is a completely new form of id
setnames(raw.accumulated, "state",      "prodes_state_uf")
setnames(raw.accumulated, "path_row",   "prodes_pathrow")
setnames(raw.accumulated, "main_class", "prodes_class")
setnames(raw.accumulated, "class_name", "prodes_class_name")
setnames(raw.accumulated, "def_cloud",  "prodes_polyg_cloud_cov")
setnames(raw.accumulated, "julian_day", "prodes_julday")
setnames(raw.accumulated, "image_date", "prodes_view_date")
setnames(raw.accumulated, "year",       "prodes_year")
setnames(raw.accumulated, "area_km",    "prodes_area_km2")
setnames(raw.accumulated, "scene_id",   "prodes_scene_id")
#setnames(raw.accumulated, "publish_ye", "prodes_publish_year") # as of 2021, no longer in database
setnames(raw.accumulated, "source",     "prodes_polyg_source")
setnames(raw.accumulated, "satellite",  "prodes_satellite")
setnames(raw.accumulated, "sensor",     "prodes_sensor")


# checks column classes
lapply(raw.accumulated, class) # every column already has its ideal class; no need to change

# ROW CLEANUP
# translation
# prodes_class
raw.accumulated$prodes_class <- gsub(pattern = "^DESMATAMENTO$", replacement = "deforestation", x = raw.accumulated$prodes_class)   

# some "prodes_view_date" columns with hour --> standardizing to YYYY-MM-DD
raw.accumulated$prodes_view_date <- as.Date(raw.accumulated$prodes_view_date, format = "%Y-%m-%d")






# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.accumulated$prodes_pathrow)         <- "polygon identifier: pathrow"
label(raw.accumulated$prodes_state_uf)        <- "state name abbreviation"
label(raw.accumulated$prodes_class)           <- "land cover category"
label(raw.accumulated$prodes_polyg_cloud_cov) <- "polygon cloud coverage history (non-observable since)"
label(raw.accumulated$prodes_view_date)       <- "date when the polygon was observed - format (YYYY-MM-DD)"
label(raw.accumulated$prodes_julday)          <- "julian day when the polygon was observed"
label(raw.accumulated$prodes_year)            <- "year polygon was observed"




# CHANGE FINAL OBJECT NAME
cln.lnd.prodesLegalAm.accumDeforestation <- raw.accumulated
rm(raw.accumulated)




# POST-TREATMENT OVERVIEW





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(
  cln.lnd.prodesLegalAm.accumDeforestation,
  file = file.path(
    DIR.CPI.DATA,
    "land","prodes_LegalAm","cleanData",
    "cln_lnd_prodes_laz_acc.Rdata"
  )
)

print(
  paste(
    "This script took",
    Sys.time() - str.time,
    "to run"
  )
)



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
