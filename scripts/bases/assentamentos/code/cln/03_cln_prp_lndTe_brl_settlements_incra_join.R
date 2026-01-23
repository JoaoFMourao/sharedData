# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: JOIN RURAL SETTLEMENTS CLEAN DATA 
# AUTHOR: JULIA BRANDAO (ADPTED FROM DIEGO MENEZES, RAFAEL PUCCI AND MARCELO SESSIM)
#
# > NOTES
# 1: Needs to specify better dates, how and when to use each one and why
# 2: This code took 7 minutes to ran with an i7, 32 RAM, machine 149 at CPI


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

rm(list = ls())
gc()

strt.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sources config for shared data repo


# SOURCES
source("_functions/convertLatinCharsbyCharsSf.R", encoding = "UTF-8")
source("_functions/convertLatinCharsbyChars.R", encoding = "UTF-8")
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "convertUnits.R"))


#load packages
pkgs <- c("data.table","labelled",  "sf", "tidyverse","stringr")

groundhogLibraries(
  pkgs,
  date = '2024-03-01'
)

reference.data <- "20250109"


check <- TRUE
# check <- FALSE

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
path <-paste0(DIR.CPI.DATA, 
                  'propertyRights/assentamentos/cleanData')

spatial <- get(load(file.path(path, 'spatial', paste0('cln_set_spatial_', reference.data,".RData"))))
  
worksheet <-  get(load( file.path(path, 'worksheet',
                                  paste0('cln_set_worksheet_', reference.data,".RData"))))


# MERGIN DATAS -----------------------------------------------------------------------------------------------------------------------------------------
#settlement's that we do not have spatial information on
class(spatial)
class(worksheet)

nonSpatial.set <- anti_join(worksheet, spatial, by = 'sipra_code')


# merge subcategories to settlements
set <- left_join(
  worksheet,  # Now the left_join its made with aux.set in the left
  # so we can keep maximum information;
  spatial, 
  by = "sipra_code"
)


set_spacial <- anti_join(set, nonSpatial.set, by = 'sipra_code') %>% 
  dplyr::select(sipra_code, project_name, subcategory, everything())  %>% # Select columns in the desired order
  st_as_sf() %>%
  st_set_crs(4674) 

# EXPORT --------------------------------------------------------------------------------------------------------------------
save(set_spacial,
     file = file.path(
       DIR.CPI.DATA, 
       'propertyRights/assentamentos/cleanData/join_versions',
       paste0("cln_prp_lndTe_brl_settlements_incra_",reference.data,".RData")
     )
)

#compute time
end_time <- Sys.time()
print(end_time - strt.time)



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------