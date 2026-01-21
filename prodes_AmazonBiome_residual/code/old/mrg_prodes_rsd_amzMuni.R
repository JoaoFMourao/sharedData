# > PROJECT INFO
# NAME: BOLSA VERDE
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: MERGE DEFORESTATION RESIDUE WITH AMAZON BIOME MUNIS
# AUTHOR: Julia Brandao (adapted from Rogério Reis)
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
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_AmazonBiome_residual", 
    "cleanData", 
    "cln_lcv_rsd_amz_biome_prodes_inpe_sf.RData"
  )
)

#get the object by its names
prodes_residue <- get(aux.name)

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
prodes_residue  <- prodes_residue %>%
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 


prodes_residue = prodes_residue %>% 
  mutate(area_pol_prodes_ha = as.numeric(st_area(geometry))/10000)

# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  municipality <- muni_list[i]
  
  df <- muni_biome %>% 
    filter(muni_code == municipality)
  
  result <- df %>% 
    ungroup() %>% 
    st_intersection(prodes_residue) %>% 
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
           "prodes_AmazonBiome_residual",
           "cleanData",
           "mrg_amazonMuni",
           paste0("prodes_rsd_amz_muni_",
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

#Time difference of 35.81326 mins