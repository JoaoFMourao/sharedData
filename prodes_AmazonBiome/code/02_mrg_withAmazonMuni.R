# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: import municipalities boundaries and PRODES increments for each biome; cross them and parallelize
# AUTHOR: Rogério Reis
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
source(file.path("_functions","convertUnits.R"))

# loading packages
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr")

#groundhogLibraries(pkgs, "2023-09-30")
groundhogLibraries(pkgs, "2025-02-02")


# Turns off scientific notation
options(scipen = 99) 
check = TRUE
# check = FALSE

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_AmazonBiome", 
    "cleanData", 
    "cln_lcv_dfrst_amz_biome_prodes_inpe_sf.RData"
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
rm(muni_clean)
gc()
# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------


#crs
prodes_increments  <- prodes_increments %>%
  
  dplyr::select(prodes_year,geometry, prodes_id) %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) 
    

# if(check){
#     
#     total_amazon <- prodes_increments %>%
#         mutate(area_defo_km2 = as.numeric(st_area(geometry)) * convert.sqm.to.sqkm) %>%
#         st_drop_geometry() %>%
#         group_by(prodes_year) %>%
#         summarise(
#             area_defo_km2 = sum(area_defo_km2, na.rm = TRUE)
#         )
# }




prodes_increments <- prodes_increments %>%
    mutate(area_pol_prodes_ha = st_area(geometry),
           area_pol_prodes_ha = as.numeric(area_pol_prodes_ha)*convert.sqm.to.ha) %>%
    group_by(
        prodes_id
        ) %>%
    mutate(
        area_pol_prodes_ha = sum(area_pol_prodes_ha, na.rm = TRUE)
    )


# MAKING THE SPATIAL CROSSING ####

## Preparing the function to parallel with  ####
intersec <- function(i){
  
  df <- muni %>% 
    filter(muni_code == muni_list[i])
  
  result <- df %>% 
    ungroup() %>% 
    st_intersection(prodes_increments) %>% 
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
           "prodes_AmazonBiome",
           "cleanData",
           "02_mrg_amazonMuni",
           "new",
           paste0("prodes_inc_amz_muni_",
                  muni_list[i],
                  "_sf.Rdata")
         )
    )
    rm(result)
    gc()
  }  

}

muni_list <- muni %>%
    st_drop_geometry() %>%
    distinct(muni_code) %>%
    as.vector() %>% 
    unname() %>%
    unlist()
gc()
#length(unique(result$prodes_id))


#detectCores()

plan(multisession, workers = 8)
options(future.globals.maxSize = 950 * 1024^2)

res = future_lapply(1:length(muni_list),intersec)


print(
  Sys.time() - str.time
)
plan(sequential)

#Time difference of 35.81326 mins
