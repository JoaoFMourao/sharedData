
# > PROJECT INFO
# NAME: CPI DATA REPOSITORY
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA [DEFORESTATION POLYGONS ONLY]
# AUTHOR: JOAO MOURAO (ADAPTED FROM RAFAEL PUCCI)
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


groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
## Yearly Deforestation ####

# RAW DATA
raw.increment <- st_read(
  file.path(
    DIR.CPI.DATA,
    "land","prodes_LegalAm","rawData",
    "yearly_deforestation"
  )
)
 

# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# column names
setnames(raw.increment, "fid",         "prodes_id") # in 2021, not exactly mapping into old "id"
setnames(raw.increment, "uuid",  "prodes_uuid") # in 2021, no more "origin id"; instead, there is a completely new form of id
setnames(raw.increment, "state",      "prodes_state_uf")
setnames(raw.increment, "path_row",   "prodes_pathrow")
setnames(raw.increment, "main_class", "prodes_class")
setnames(raw.increment, "class_name", "prodes_class_name")
setnames(raw.increment, "def_cloud",  "prodes_polyg_cloud_cov")
setnames(raw.increment, "julian_day", "prodes_julday")
setnames(raw.increment, "image_date", "prodes_view_date")
setnames(raw.increment, "year",       "prodes_year")
setnames(raw.increment, "area_km",    "prodes_area_km2")
setnames(raw.increment, "scene_id",   "prodes_scene_id")
#setnames(raw.increment, "publish_ye", "prodes_publish_year") # as of 2021, no longer in database
setnames(raw.increment, "source",     "prodes_polyg_source")
setnames(raw.increment, "satellite",  "prodes_satellite")
setnames(raw.increment, "sensor",     "prodes_sensor")


# checks column classes
lapply(raw.increment, class) # every column already has its ideal class; no need to change

# ROW CLEANUP
# translation
# prodes_class
raw.increment$prodes_class <- gsub(pattern = "^DESMATAMENTO$", replacement = "deforestation", x = raw.increment$prodes_class)   

# some "prodes_view_date" columns with hour --> standardizing to YYYY-MM-DD
raw.increment$prodes_view_date <- as.Date(raw.increment$prodes_view_date, format = "%Y-%m-%d")






# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.increment$prodes_pathrow)         <- "polygon identifier: pathrow"
label(raw.increment$prodes_state_uf)        <- "state name abbreviation"
label(raw.increment$prodes_class)           <- "land cover category"
label(raw.increment$prodes_polyg_cloud_cov) <- "polygon cloud coverage history (non-observable since)"
label(raw.increment$prodes_view_date)       <- "date when the polygon was observed - format (YYYY-MM-DD)"
label(raw.increment$prodes_julday)          <- "julian day when the polygon was observed"
label(raw.increment$prodes_year)            <- "year polygon was observed"




# CHANGE FINAL OBJECT NAME
cln.lnd.prodesLegalAm.yearlyDeforestation <- raw.increment
rm(raw.increment)




# POST-TREATMENT OVERVIEW
#summary(cln.lcv.dfrst.amz.biome.prodes.inpe.sf)
#View(cln.lcv.dfrst.amz.biome.prodes.inpe.sf)
#plot(cln.lcv.dfrst.amz.biome.prodes.inpe.sf)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(
  cln.lnd.prodesLegalAm.yearlyDeforestation,
  file = file.path(
    DIR.CPI.DATA,
    "land","prodes_LegalAm","cleanData",
    "cln_lnd_prodes_laz_increm.Rdata"
  )
)


    Sys.time() - str.time



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
