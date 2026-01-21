# > PROJECT INFO
# NAME: Bolsa Verde - Evaluate and Monitor the impact of Bolsa Verde
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: MERGING BD QUEIMADAS DATA WITH BOLSA VERDE
# AUTHOR: JULIA BRANDAO
#
#
#
## SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

start.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R") # sets local dirs and sources config for shared data repo

# SOURCES
source(file.path("_functions", "associateCRS.R"))

# LIBRARIES
pkgs <-  c('sf', 'tidyverse', 'ggplot2', 'future.apply', 'parallel','sp')

groundhogLibraries(pkgs, date = '2024-02-08')

options(scipen = 999)
options(future.seed = TRUE)


# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
### Loading BD Queimadas data ###
aux.name <- load(file.path(DIR.CPI.DATA,
                           "land/active_Fires/cleanData",
                           'cln_lcv_fire_brl_activeFires_inpe_2000to2018.Rdata'))
fire_until2018 <- get(aux.name)
rm(list = aux.name)
rm(aux.name)


aux.name <- load(file.path(DIR.CPI.DATA,
                           "land/active_Fires/cleanData",
                           'cln_lcv_fire_brl_activeFires_inpe_2019to2021.Rdata'))
fire_until2021 <- get(aux.name)
rm(list = aux.name)
rm(aux.name)

aux.name <- load(file.path(DIR.CPI.DATA,
                           "land/active_Fires/cleanData",
                           'cln_lcv_fire_brl_activeFires_inpe_2022to2024.Rdata'))
fire_until2023 <- get(aux.name)
rm(list = aux.name)
rm(aux.name)

# DATA ANALYSIS --------------------------------------------------------------------------------------------------------------------------------------
#  Calculating geospatial intersections

fire_until2018 <- fire_until2018 %>%
  st_as_sf() %>% 
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  st_make_valid()

fire_until2021 <- fire_until2021 %>%
  st_as_sf() %>% 
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>%
  st_make_valid()


fire_until2023 <- fire_until2023  %>%
  filter(biome %in% c('amazon', 'cerrado', 'pantanal', 'caatinga', 'atlantic forest', 'pampa')) %>%
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic")))%>%
  st_make_valid() %>%
  mutate(date = as.Date(date), 
         year = year(date),
         month = month(date),
         prodes_year = case_when(
             month > 7 ~ year + 1,
             month < 8 ~ year))

  
fire_until2018 <- fire_until2018 %>%
  filter(satellite == 'NPP-375') %>%
  mutate(year = year(date), 
         month = month(date),
         prodes_year = case_when(
           month > 7 ~ year+1, 
           month < 8 ~ year
          
         )) %>%
  filter(prodes_year >= 2016) %>%
  select(-area_indu)


fire_until2021 <- fire_until2021 %>%
  filter(satellite == 'NPP-375') %>%
  mutate(year = year(date), 
         month = month(date),
         prodes_year = case_when(
           month > 7 ~ year+1, 
           month < 8 ~ year
           
         ))


fire <- fire_until2018 %>%
  rbind(fire_until2021) %>%
  rbind(fire_until2023)
  
save_monthly <- function(i){
  year <- years[i]
  
  for(j in 1:length(months)){
  fire_monthly <- fire %>%
    filter(month == months[j], prodes_year == year)
  
    save(fire_monthly,
         file = file.path(
           DIR.CPI.DATA,
           "land", 
           'active_Fires/builtData/fire_monthly',
           paste0("active_fires_",
                  months[j],'_',year,
                  "_sf.Rdata")
         )
    )
  }
}


years <- fire %>% st_drop_geometry()%>% distinct(year) %>% unlist() %>% as.vector()
months <- fire %>% st_drop_geometry()%>% distinct(month)%>% unlist() %>%as.vector()


result <- lapply(X= 1:length(years), FUN = save_monthly)


# END ------------------------------------------------------------------------------------------------------