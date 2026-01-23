# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: MRG PRODES NON FORREST AMAZON BIOME WITH MUNI
# AUTHOR:  MARCELO SESSIM(ADAPTED FROM: Rogério Reis)
#
# > NOTES: AMAZON BIOME ONLY. This code took 5.48455 mins to run
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

groundhogLibraries(pkgs, "2024-02-08")

# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    "A:/land/prodes_AmazonBiome_nonforrest/cleanData/cln_prodes_amzbiome_nonforrest.Rdata"
  )
)

#get the object by its names
prodes_increments <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)

## Load Muni Biome  ####

muni <- get(load(
    file.path(
        DIR.CPI.DATA,
        'territory/municipalities/cleanData/2022',
        "01_cln_trt_muni_no_overlap_ibge_2022_sf.Rdata"
    )
)
)

# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------


#crs
prodes_increments  <- prodes_increments %>%
  
  dplyr::select(prodes_year,geometry, prodes_id, prodes_main_class) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 

# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  municipality <- muni_list[i]
  
  df <- muni %>% 
    filter(muni_code == municipality)
  
  result <- df %>% 
    ungroup() %>% 
    st_intersection(prodes_increments) %>% 
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
           "prodes_AmazonBiome_nonforrest",
           "builtData",
           "mrg_muni",
           paste0("prodes_AmazonBiome_nonforrest_muni_",
                  municipality,
                  "_sf.Rdata")
         )
    )
  }  
}

muni_list <- muni %>% st_drop_geometry() %>% select(muni_code) %>%
  distinct()

muni_list <- muni_list %>% as.vector() %>% unname() %>% unlist()

detectCores()

plan(multisession, workers = detectCores()-2)

res = future_lapply(1:length(muni_list),intersec)

print(
  Sys.time() - str.time
)

