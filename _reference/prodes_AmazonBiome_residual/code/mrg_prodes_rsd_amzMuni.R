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
source(file.path("_functions", "convertUnits.R"))

# loading packages
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr")

groundhogLibraries(pkgs, "2025-01-26")

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
prodes_increments <- get(aux.name)


#remove the old object
rm(list = aux.name, aux.name)

## Load Muni Biome  ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "territory/biome/cleanData",
    "alt_biome_mrg_muni.Rdata"
  )
)

muni_biome <- get(aux.name)
# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------

muni_biome = muni_biome %>% filter(name_biome == "Amazônia") #Only the amazon munis 

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
  
  df <- muni_biome %>% 
    filter(muni_code == municipality)
  
  result <- df %>% 
      ungroup() %>% 
      st_intersection(prodes_increments %>%
                          mutate(area_pol_prodes_ha = st_area(geometry),
                                 area_pol_prodes_ha = as.numeric(area_pol_prodes_ha)*convert.sqm.to.ha) %>%
                          group_by(
                              prodes_id
                          ) %>%
                          mutate(
                              area_pol_prodes_ha = sum(area_pol_prodes_ha, na.rm = TRUE)
                          )) %>% 
      st_make_valid() %>%
      st_buffer(0) %>% 
      mutate(
          biome = "Amazon", 
          area_pol_prodes_muni_ha = st_area(geometry), 
          area_pol_prodes_muni_ha = as.numeric(area_pol_prodes_muni_ha)*convert.sqm.to.ha
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

plan(multisession, workers = detectCores()-5)

res = future_lapply(1:length(muni_list),intersec)

print(
  Sys.time() - str.time
)

# Time difference of 58.98662 secs
