# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: import municipalities boundaries and PRODES mask for each biome; cross them and parallelize
# AUTHOR: Rogério Reis
#
# > NOTES: CAATINGA BIOME ONLY 
#
# FOR THE CAATINGA BIOME, THIS CODE HAS A MEMORY PROBLEM. THE MEMORY GETS 
# FULL AND THE CODE JAMS AND WE GET AN ERROR. SO I RECOMMEND USING A MACHINE 
# WITH A LOT OF MEMORY AND USING LESS CORES WHEN RUNNING (I recommend keeping 
# at least 8 cores available). 
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
pkgs <- c("tidyverse","sf","future.apply", "parallel", "dplyr")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Mask  ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_Caatinga", 
    "cleanData", 
    "defo_mask", 
    "cln_lcv_dfrst_mask_caatinga_biome_prodes_inpe_sf.Rdata"
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

muni_biome = muni_biome %>% filter(biomeCaatinga == TRUE) #Only the caatinga munis 

#crs
prodes_increments  <- prodes_increments %>%
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 

# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  municipality <- muni_list[i]
  
  print(municipality) 
  
  result <- muni_biome %>% 
    filter(muni_code == municipality)
  
  result <- result %>% 
    ungroup() %>% 
    st_intersection(prodes_increments) %>% 
    st_make_valid() %>%
    st_buffer(0) %>% 
    mutate(
      biome = "caatinga"
    )
  
  
  if(length(result$prodes_id) != 0) {
    
    save(result,
         file = file.path(
           DIR.CPI.DATA,
           "land", 
           "prodes_Caatinga",
           "cleanData",
           "defo_mask", 
           "02_mrg_caatingaMuni",
           paste0("prodes_mask_caat_muni_",
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

plan(multisession, workers = detectCores()-10)
future_lapply(1:length(muni_list),intersec)

print(
  Sys.time() - str.time
)

# Time difference of 35.61536 mins in 151 