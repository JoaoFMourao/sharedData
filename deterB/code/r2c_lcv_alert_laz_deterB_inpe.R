
# > PROJECT INFO
# NAME: DETER-B ALERTS
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: CLEAN RAW DATA - ALERTS SHAPEFILE
# AUTHOR: JOAO VIEIRA and RAFAEL PUCCI
#
# > NOTES
# 1: - IN THE FUTURE, UPDATE ONLY THE MOST RECENT YEAR BY CHOOSING PROPER aux.years 





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo



# SOURCES
source("_functions/associateCRS.R")
source("_functions/convertLatinCharsbyCharsSf.R")



# LIBRARIES
pkgs <- c("tidyverse","sf", "rlang", "labelled", "rgdal", "rgeos", "Hmisc", "data.table")

groundhogLibraries(pkgs, date = "2023-09-30")


# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------


# within processing due to memory allocation


# READ SHAPE
raw.alert <- st_read(file.path(DIR.CPI.DATA, "land/deterB/rawData/deter-amz-public",
                                     'deter-amz-deter-public.shp'))


# DATA EXPLORATION [disabled for speed]
# summary(raw.alert) # yields unprojected SIRGAS2000 longlat
# View(raw.alert)
# plot(raw.alert$geometry)





# DATASET CLEANUP ---------------------------------------------------------------------------------------------------------------------------

# translate CLASSNAME categories
raw.alert <-
  raw.alert %>% 
  mutate(CLASSNAME = recode(CLASSNAME, 
                            CICATRIZ_DE_QUEIMADA = "degrad_fire",
                            CORTE_SELETIVO       = "selectiveExtraction_other",
                            CS_DESORDENADO       = "selectiveExtraction_untidy",
                            CS_GEOMETRICO        = "selectiveExtraction_geometric",
                            DEGRADACAO           = "degrad_degrad",
                            DESMATAMENTO_CR      = "deforest_exposedSoil",
                            DESMATAMENTO_VEG     = "deforest_vegetation",
                            MINERACAO            = "deforest_mining"))

# change column names
raw.alert <-
  raw.alert %>% 
  rename(alertType_classname = CLASSNAME,
         quadrant = QUADRANT,
         pathrow = PATH_ROW,
         date = VIEW_DATE,
         sensor = SENSOR,
         satellite = SATELLITE,
         area_nonProtArea = AREAMUNKM,
         area_protArea = AREAUCKM,
         muni_name = MUNICIPALI,
         muni_code = GEOCODIBGE,
         protArea = UC,
         state_uf = UF)

# convert latin characters
raw.alert <- ConvertLatinCharsbyCharsSf(raw.alert)

# letters capitalization
raw.alert <-
  raw.alert %>% 
  mutate(muni_name = toupper(muni_name))


# FIX TOPOLOGY ISSUES
raw.alert <- st_make_valid(raw.alert)

# CHECK VALIDITY
all(st_is_valid(raw.alert))


# define auxiliary vector to split data into single years
aux.years <- as.character(c(2016:2024))



# START LOOP
for (y in seq_along(aux.years)) {
  
  # filter data to keep only year y
  aux.raw.alert <- 
    raw.alert %>% 
    filter(between(date, as.Date(paste0(aux.years[y], "-01-01")), as.Date(paste0(aux.years[y], "-12-31"))))
  
  
  # label columns
  var_label(aux.raw.alert) <- list(alertType_classname = "type of alert (level 1) and class name (level 2)",
                            quadrant = "satellite information - quadrant",
                            pathrow = "satellite information - pathrow",
                            date = "date - format (YYYY-MM-DD)",
                            sensor = "satellite information - sensor name",
                            satellite = "satellite information - satellite name",
                            area_nonProtArea = "polygon area in non protected areas (sq km - SIRGAS 2000)",
                            area_protArea = "polygon area in protected areas (sq km - SIRGAS 2000)",
                            muni_name = "municipality name",
                            state_uf = "state acronym",
                            protArea = "protected area name")
  
  # define object name
  return.obj <- paste0("cln.lcv.alert.laz.deterB.inpe.", aux.years[y])
  
  # change object name
  assign(value = aux.raw.alert,
         x = return.obj)
  
  # clean environment 
  rm(aux.raw.alert)
  
  # define file name
  return.file <- gsub(x = return.obj, pattern = "\\.", replacement = "_")
  
  
  
  # EXPORT
  save(list = return.obj, file = file.path(DIR.CPI.DATA, "land/deterB/cleanData", paste0(return.file, ".Rdata")))
  

  } # LOOP ENDS HERE



# clean environment 
rm(aux.years, raw.alert)





# END OF SCRIPT---------------------------------------------------------------------------------------------------------------------------------------