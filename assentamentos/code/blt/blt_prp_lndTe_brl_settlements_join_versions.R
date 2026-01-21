# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: JOINING RURAL SETTLEMENTS ALL VERSIONS
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




# check <- FALSE

# DATA INPUT AND MERGE -----------------------------------------------------------------------------------------------------------------------------------------

path_worksheets <- file.path(DIR.CPI.DATA, 
                  'propertyRights/assentamentos/cleanData/worksheet')

worksheets <- list.files(path_worksheets, pattern = "\\.(Rdata|RData)$", full.names = TRUE)

path_spatials <- file.path(DIR.CPI.DATA, 
                             'propertyRights/assentamentos/cleanData/spatial')

spatials <- list.files(path_spatials, pattern = "\\.(Rdata|RData)$", full.names = TRUE)



load_versions <- function(file) {
  

  data <- get(load(file))
  

  data <- data %>%
    mutate(source_date = str_extract(file, "\\d{8}"))
  

  if ("sf" %in% class(data)) {

    geometry_df <- data %>%
      st_make_valid() %>%
      group_by(sipra_code) %>%
      summarise(geometry = st_union(geometry), .groups = "drop")
    

    data <- data %>%
      st_drop_geometry() %>%
      distinct(sipra_code, .keep_all = TRUE) %>%
      left_join(geometry_df, by = "sipra_code")
  }
  
  return(data)
}



all_worksheets <- lapply(worksheets, load_versions)

all_worksheets <- all_worksheets %>% 
  bind_rows()

all_spatials <- lapply(spatials, load_versions)

all_spatials <- all_spatials %>%
  bind_rows()


differences_ws <- all_worksheets %>%
  group_by(sipra_code) %>%
  filter(n() > 1) %>% 
  summarise(across(everything(), ~ length(unique(.)) > 1, .names = "diff_{.col}"), .groups = "drop") %>%
  rowwise() %>%
  mutate(has_differences = any(c_across(starts_with("diff_")))) %>%
  filter(has_differences)


wkshts <- all_worksheets %>%
  arrange(sipra_code, desc(source_date))  %>% 
  distinct(sipra_code, .keep_all = TRUE)

sptls <- all_spatials %>%
  st_sf() %>%
  st_transform(st_crs(AssociateCRS(CRS_id = 'Proj_SIRGAS2000polyconic'))) %>%
  st_make_valid() %>%
  arrange(sipra_code, desc(source_date)) %>% 
  distinct(sipra_code, .keep_all = TRUE)

nonSpatial.set <- anti_join(wkshts, sptls, by = 'sipra_code')

set <- left_join(
  wkshts,  # Now the left_join its made with aux.set in the left
  # so we can keep maximum information;
  sptls, 
  by = "sipra_code"
)


set_spacial <- anti_join(set, nonSpatial.set, by = 'sipra_code') %>% 
  dplyr::select(sipra_code, project_name, subcategory, everything())   %>%
  st_sf() %>%
  st_transform(st_crs(AssociateCRS(CRS_id = 'Proj_SIRGAS2000polyconic')))%>%
  st_make_valid()

# EXPORT --------------------------------------------------------------------------------------------------------------------
save(set_spacial,
     file = file.path(
       DIR.CPI.DATA, 
       'propertyRights/assentamentos/builtData',
       "blt_prp_lndTe_brl_settlements_incra_join_versions.RData"
     )
)

#compute time
end_time <- Sys.time()
print(end_time - strt.time)



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------