# > PROJECT INFO
# 
#
# > THIS SCRIPT
# AIM: MERGE PRODES NONFOREST WITH MUNI
# AUTHOR: JULIA BRANDAO (ADAPTED FROM: Rogério Reis and Marcelo Sessim)
#
# > NOTES: AMAZON BIOME ONLY 
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
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 999) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

aux.name <- load(
  file.path( DIR.CPI.DATA, "land/nonforrest_terrabrasilis/cleanData/cln_lnd_lndUse_amzBiome_nonforrest.RData"
  )
)

#get the object by its names
nonforrest <- get(aux.name)

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

muni_biome = muni_biome %>% filter(biomeAmazonia == TRUE) #Only the amazon munis 

#crs
nonforrest  <- nonforrest %>%
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 

# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  municipality <- muni_list[i]
  
  df <- muni_biome %>% 
    filter(muni_code == municipality)
  
  result <- nonforrest %>% 
    ungroup() %>% 
    st_intersection(df) %>% 
    st_make_valid() %>%
    st_buffer(0) %>% 
    mutate(
      biome = "Amazon"
    )
  
  
  if(length(result$prodes_id) != 0) {
    
    save(result,
         file = file.path(
           DIR.CPI.DATA,
           "land", 
           "nonforrest_terrabrasilis",
           "builtData",
           "mrg_muni",
           paste0("prodes_nonforrest_",
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

plan(multisession, workers = detectCores()-1)

res = future_lapply(1:length(muni_list),intersec)

print(
  Sys.time() - str.time
)
