# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: MERGE PRODES AMAZON BIOME 1-6.25HA WITH MUNI
# AUTHOR: MARCELO SESSIM(ADAPTED FROM: Rogério Reis)
#
# > NOTES: AMAZON BIOME ONLY 
# Time difference of 45.1986 mins 15 cores .151
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
source(file.path("_functions","convertUnits.R"))

# loading packages
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr")

groundhogLibraries(pkgs, "2023-09-28")

# Turns off scientific notation
options(scipen = 999) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    "A:/land/prodes_AmazonBiome_1-6.25ha/cleanData/cln_prodes_amzbiome_1_625ha.Rdata"
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
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 

# prodes_increments = prodes_increments %>% 
#   mutate(area_pol_prodes_ha = as.numeric(st_area(prodes_increments))/10000)


# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  municipality <- muni_list[i]
  
  df <- muni %>% 
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
           "prodes_AmazonBiome_1-6.25ha",
           "builtData",
           'mrg_muni',
           paste0("prodes_AmazonBiome_1-6.25ha_muni_",
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

plan(multisession, workers = detectCores()-1)

res = future_lapply(1:length(muni_list),intersec)

print(
  Sys.time() - str.time
)
