# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE (IMAFLORA)
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: DEFO PRODES LEGAL AMAZON PER MUNI
# AUTHOR: MARCELO SESSIM
#
# > NOTES

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

start.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo


# SOURCES
source(file.path(DIR.PROJECT, "code/_functions", "associateCRS.R"))

# LIBRARIES
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,
               sf, 
               rlang,
               future.apply,
               furrr,
               parallel,
               tictoc,
               labelled)

groundhogLibraries(pkgs, date = "2023-09-30")
options(scipen = 999)
# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------


## load laz muni 2022 ####

aux.name <- st_read(
  file.path(
    DIR.CPI.DATA,
    "land/prodes_LegalAm",
    "rawData",
    "municipalities_legal_amazon"
  )
)

laz.muni <- aux.name

rm(aux.name)

## Load Prodes accumulated ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land/prodes_LegalAm",
    "cleanData",
    "cln_lnd_prodes_laz_acc.Rdata"
  )
)

#get the object by its names
prodes_acc <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)
## Load Prodes increment ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land/prodes_LegalAm",
    "cleanData",
    "cln_lnd_prodes_laz_increm.Rdata"
  )
)

#get the object by its names
prodes_inc <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)

# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------

prodes_acc <- prodes_acc %>% 
  select(prodes_year)

prodes_inc <- prodes_inc %>% 
  select(prodes_year)

laz.muni <- laz.muni %>% 
  select(muni_code = geocodigo)

prodes_acc <- prodes_acc %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
  
  #and make geometry clean-up
  st_make_valid() %>%
  
  st_buffer(0)

prodes_inc <- prodes_inc %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
  
  #and make geometry clean-up
  st_make_valid() %>%
  
  st_buffer(0)

laz.muni <- laz.muni %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
  
  #and make geometry clean-up
  st_make_valid() %>%
  
  st_buffer(0)


## creating an sf object that has the intersection between car and amazon municipalities####
inters_amaz <- function(i){
  
  municipality <- i
    
  
  df <- laz.muni %>% 
    filter(muni_code == municipality)
  
  result_inc <- prodes_inc %>% 
    ungroup() %>% 
    st_intersects(df,sparse = F)
  
  result_inc <- prodes_inc %>% 
    cbind(result_inc) %>% 
    filter(result_inc == T) %>% 
    select(-result_inc)
  
  result_acc <- prodes_acc %>% 
    ungroup() %>% 
    st_intersects(df, sparse = F)
  
  result_acc <- prodes_acc %>% 
    cbind(result_acc) %>% 
    filter(result_acc == T) %>% 
    select(-result_acc)
  
  result = rbind(result_acc,result_inc)
  
  rm(result_acc,result_inc)
  
  
  if(nrow(result) != 0) {
    
    result <- result %>% 
      st_intersection(df) %>% 
      st_make_valid() %>% 
      st_buffer(0)
    
    save(result,
         file = file.path(
             DIR.CPI.DATA,
             "land",
             "prodes_LegalAm",
             "cleanData",
             "prodes_laz_muni_acc",
             paste0("prodes_laz_",
                    municipality,
                    "_sf.Rdata")
         )
    )
    
  }
  
}


#creating a list of municipalities inside the amazon biome

muni_list <- laz.muni %>% st_drop_geometry() %>% select(muni_code) %>%
    distinct()

muni_list <- muni_list %>% as.vector() %>% unname() %>% unlist()

detectCores()

plan(multisession, workers = 6)

future_lapply(muni_list,inters_amaz)

print(paste(year, Sys.time() - strt.time.loop.year))

Sys.time() - strt.time

##### fim ---------------------------------------------------------------
