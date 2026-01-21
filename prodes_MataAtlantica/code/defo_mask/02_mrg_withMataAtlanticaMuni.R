# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: import municipalities boundaries and PRODES mask for each biome; cross them and parallelize
# AUTHOR: Rogério Reis
#
# > NOTES: MATA ATLANTICA BIOME ONLY 
#
#
#
# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))

# loading packages
pkgs <- c("tidyverse","sf","future.apply","furrr", "parallel", "dplyr")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes mask ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_MataAtlantica", 
    "cleanData", 
    "defo_mask", 
    "cln_lcv_dfrst_mask_mt_at_biome_prodes_inpe_sf.Rdata"
  )
)

#get the object by its names
prodes_increments <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)

## Load Muni Biome  ####

load(
  file.path(
    DIR.CPI.DATA,
    "territory/biome/cleanData",
    "alt_biome_mrg_muni.Rdata"
  )
)

# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------

muni_biome = muni_biome %>% filter(biomeMataAtlantica == TRUE) #Only the cerrado munis 

#crs
prodes_increments  <- prodes_increments %>%
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0)

# MAKING THE SPATIAL CROSSING ####

# # Section destined to process the files that haven't been crossed yet #### 
# 
# muni_list <- muni_biome %>% st_drop_geometry() %>% select(muni_code) %>%
#     distinct()
# 
# muni_list <- muni_list %>% as.vector() %>% unname() %>% unlist()
# 
# # Getting the municipalities that have already been  crossed
# 
# files_full <- list.files(
#   path = file.path(
#     DIR.CPI.DATA,
#     "land", 
#     "prodes_MataAtlantica",
#     "cleanData",
#     "defo_mask", 
#     "02_mrg_mataAtlanticaMuni"
#   )
# )
# 
# # Getting the code for the prodes munis 
# loaded_munis = unique(str_extract(files_full, pattern = "\\d{7}")) #we only have unique munis in this vector
# municipality = muni_list %>% setdiff(loaded_munis)

#### 

## Preparing the function to parallel with  ####

intersec <- function(i){
# intersec <- function(municipality){
  
 municipality <- muni_list[i]
  
  result <- muni_biome %>% 
    filter(muni_code == municipality)
  
  result <- result %>% 
    ungroup() %>% 
    st_intersection(prodes_increments) %>% 
    st_make_valid() %>%
    st_buffer(0) %>% 
    mutate(
      biome = "mata_atlantica"
    )
  
  
  if(length(result$prodes_id) != 0) {
    
    save(result,
         file = file.path(
           DIR.CPI.DATA,
           "land", 
           "prodes_MataAtlantica",
           "cleanData",
           "defo_mask", 
           "02_mrg_mataAtlanticaMuni",
           paste0("prodes_mask_mt_at_muni_",
                  municipality,
                  "_sf.Rdata")
         )
    )
  }  
}

muni_list <- muni_biome %>% st_drop_geometry() %>% select(muni_code) %>%
  distinct()

muni_list <- muni_list %>% as.vector() %>% unname() %>% unlist()

detectCores()

plan(multisession, workers = detectCores()-15)

future_lapply(1:length(muni_list),intersec)
# future_lapply(municipality,intersec)

print(
  Sys.time() - str.time
)

# Time difference of 3.163697 hoursger
