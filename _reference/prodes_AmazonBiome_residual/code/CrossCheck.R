# > PROJECT INFO
# NAME: BOLSA VERDE
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: clean prodes   
# AUTHOR: Adapted from Rogério Reis
#
# > NOTES: 

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
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr", "readxl", "lwgeom")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 
future.seed=TRUE
# INPUT  -------------------------------------------------------------------


files_clean = list.files(file.path(DIR.CPI.DATA, 
                                      'land/prodes_AmazonBiome_residual/cleanData/cleanOverlap'), 
                            full.names = TRUE)  #Vector with all the PRODES file paths



# small resolution input 
files_raw = list.files(file.path(DIR.CPI.DATA, 
                                     'land/prodes_AmazonBiome_residual/cleanData/mrg_amazonMuni'), 
                           full.names = TRUE)  #Vector with all the PRODES file paths

# DATA ANALYSIS --------------------------------------------------------------------
muni_clean = unique(str_extract(files_clean,pattern = "\\d{7}")) 
muni_raw = unique(str_extract(files_raw,pattern = "\\d{7}")) 

calc_area = function(i){
  
  
    # Filter the small PRODES muni path that match the municipality 
    file_muni_clean <- files_clean[grep(muni_clean[i], files_clean)]
    file_muni_raw <- files_raw[grep(muni_raw[i], files_raw)]  
    
    # Loading muni small 
    muni_clean = get(load(file_muni_clean)) 
    muni_raw = get(load(file_muni_raw))
    
    clean_df <- muni_clean %>%
      mutate(
        area_clean = st_area(geometry)) %>%
      st_drop_geometry() %>%
      group_by(muni_code, prodes_year) %>%
      summarise(
        area_clean = sum(as.numeric(area_clean))
      )
    
    raw_df <- muni_raw %>%
      mutate(area_raw = st_area(geometry)) %>%
      st_drop_geometry()%>%
      group_by(muni_code, prodes_year) %>%
      summarise(
        area_raw = sum(as.numeric(area_raw))
      )
    
    
    munis_comp <- raw_df %>%
      left_join(clean_df, by = c('muni_code', 'prodes_year'))
    
    return(munis_comp)
}

detectCores()
plan(multisession, workers = detectCores()-2) 

res <-future_lapply(1:length(muni_clean), calc_area)
res <- res %>% bind_rows()

res_year <- res %>%
  group_by(prodes_year) %>%
  summarise(area_clean_ha = sum(area_clean)/10000, 
         area_raw_ha = sum(area_raw)/10000) %>%
  mutate(dif = area_raw_ha -  area_clean_ha)
            

summary(res_year$dif)


