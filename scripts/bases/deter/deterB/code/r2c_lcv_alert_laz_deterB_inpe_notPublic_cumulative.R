
# > PROJECT INFO
# NAME: DETER-B ALERTS
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: CLEAN RAW DATA - ALERTS SHAPEFILE (CUMULATIVE ALERTS)
# AUTHOR: RAFAEL PUCCI
#
# > NOTES
# 1: This database is not publicly available in TerraBrasilis. Please refer to documentation
# 2: IN THE FUTURE, UPDATE ONLY THE MOST RECENT YEAR BY CHOOSING PROPER aux.years 





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo



# SOURCES
source("_functions/associateCRS.R")
source("_functions/convertLatinCharsbyCharsSf.R")



# LIBRARIES
CallLibraries(c("sf", "labelled", "tidyverse", "rgdal"))





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------


# within processing due to memory allocation


# READ SHAPE
raw.alert <- st_read(dsn = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterB_inpe/input/deter_degradations"),
                  layer = "deter_degradationsPolygon",
                  options = "ENCODING=WINDOWS-1252")


# DATA EXPLORATION [disabled for speed]
# st_crs(raw.alert) # yields unprojected SIRGAS2000 longlat
# View(raw.alert)
# plot(raw.alert$geometry)



# DATASET CLEANUP ---------------------------------------------------------------------------------------------------------------------------

# translate CLASSNAME categories
raw.alert <-
  raw.alert %>% 
  mutate(classname = recode(classname, 
                            CICATRIZ_DE_QUEIMADA = "degrad_fire",
                            CORTE_SELETIVO       = "selectiveExtraction_other",
                            CS_DESORDENADO       = "selectiveExtraction_untidy",
                            CS_GEOMETRICO        = "selectiveExtraction_geometric",
                            DEGRADACAO           = "degrad_degrad"))

# change column names
raw.alert <-
  raw.alert %>% 
  rename(alertType_classname = classname,
         date = view_date,
         area_total = areatotalk,
         area_nonProtArea = areamunkm,
         area_protArea = areauckm,
         muni_name = county,
         protArea = uc,
         state_uf = uf)

# convert latin characters
raw.alert <- ConvertLatinCharsbyCharsSf(raw.alert)

# capitalize names
raw.alert <-
  raw.alert %>% 
  mutate(muni_name = toupper(muni_name))


# FIX TOPOLOGY ISSUES
raw.alert <- st_make_valid(raw.alert)

# CHECK VALIDITY
all(st_is_valid(raw.alert))


# label columns
var_label(raw.alert) <- list(alertType_classname = "type of alert (level 1) and class name (level 2)",
                          quadrant = "satellite information - quadrant",
                          orbitpoint = "satellite information - orbit point",
                          date = "date - format (YYYY-MM-DD)",
                          date_audit = "date of confirmation - format (YYYY-MM-DD)",
                          sensor = "satellite information - sensor name",
                          satellite = "satellite information - satellite name",
                          area_total = "polygon area (sq km - SIRGAS 2000)",
                          area_nonProtArea = "polygon area in non protected areas (sq km - SIRGAS 2000)",
                          area_protArea = "polygon area in protected areas (sq km - SIRGAS 2000)",
                          muni_name = "municipality name",
                          state_uf = "state acronym",
                          protArea = "protected area name")


# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

# define object name
return.obj <- paste0("cln.lcv.alert.laz.deterB.inpe.notPublic.cumulative")

# change object name
assign(value = raw.alert,
       x = return.obj)

# clean environment 
rm(raw.alert)

# define file name
return.file <- gsub(x = return.obj, pattern = "\\.", replacement = "_")



# EXPORT
save(list = return.obj, file = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterB_inpe/output", paste0(return.file, ".Rdata")))


# END OF SCRIPT---------------------------------------------------------------------------------------------------------------------------------------