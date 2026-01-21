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
          "tictoc","labelled", "geobr", "dplyr","openxlsx")

# groundhogLibraries(pkgs, "2022-04-21"
#                    # , tolerate.R.version =  "4.2.2"
#                    )

groundhogLibraries(pkgs, "2024-02-08"
                   # , tolerate.R.version =  "4.3.3"
)

DIR.DATA.PROJECT <- "A:/projects/car_a_car"

# Turns off scientific notation
options(scipen = 99) 

defo.amazom.biome <- file.path(
  DIR.CPI.DATA,
  "land/prodes_AmazonBiome/cleanData/02_mrg_amazonMuni_2019a2022"
)


### Calculate yearly defo crossed with municipalities ####

defo.files <- list.files(defo.amazom.biome)
munis <- str_extract(defo.files,pattern = "\\d{7}")



calculate.defo <- function(municipality) {
  
  load(
    file.path(
      defo.amazom.biome,
      paste0("prodes_inc_amz_muni_",
             municipality,
             "_sf.Rdata")
    )
  )
  
  result <- result %>% 
    mutate(defo_sqkm = as.numeric(st_area(geometry))*convert.sqm.to.sqkm) %>% 
    as_tibble() %>% 
    select(-geometry) %>% 
    group_by(prodes_year) %>% 
    summarize(defo_sqkm = sum(defo_sqkm))
  
}


plan(multisession, workers = detectCores()-1)

res = future_lapply(munis,calculate.defo)

answer <- bind_rows(res) %>% 
  group_by(prodes_year) %>% 
  summarize(crossedMuni = sum(defo_sqkm))


### calculate defo before crossing #####

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_AmazonBiome\\cleanData",
    "cln_lcv_dfrst_amz_biome_prodes_inpe_sf.Rdata"
  )
)

#get the object by its names
prodes_increments <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)


answer <-   prodes_increments %>% as_tibble() %>% select(-geometry) %>%
  mutate(prodes_year = as.double(prodes_year)) %>%
  group_by(prodes_year) %>%
  summarize(asWritten = sum(prodes_area_km2)) %>%
  right_join(answer, by = "prodes_year")

answer = answer %>% mutate(diff = crossedMuni - asWritten) 

#########################################################


write.xlsx(answer,file.path(
  DIR.CPI.DATA,
  "land/prodes_AmazonBiome/cleanData","03_crossCheck.xlsx"))

print(
  Sys.time() - str.time
)
