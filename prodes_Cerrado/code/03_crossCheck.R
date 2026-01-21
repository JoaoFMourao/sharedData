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

groundhogLibraries(pkgs, "2022-04-21"
                   # , tolerate.R.version =  "4.2.2"
)

DIR.DATA.PROJECT <- "A:/projects/car_a_car"

# Turns off scientific notation
options(scipen = 99) 

defo.biome <- file.path(
  DIR.CPI.DATA,
  "land/prodes_Cerrado/cleanData/02_mrg_cerradoMuni"
)


### Calculate yearly defo crossed with municipalities ####

defo.files <- list.files(defo.biome)
munis <- str_extract(defo.files,pattern = "\\d{7}")



calculate.defo <- function(municipality) {
  
  load(
    file.path(
      defo.biome,
      paste0("prodes_inc_cerrado_muni_",
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



# ### Calculate yearly defo crossed with municipalities - slow ####
# 
# defo.biome <- file.path(
#   DIR.DATA.PROJECT,
#   "blt_amz_prodes_inc_mrgMuni"
# )
# 
# defo.files <- list.files(defo.biome)
# munis <- str_extract(defo.files,pattern = "\\d{7}")
# 
# 
# 
# plan(multisession, workers = detectCores()-2)
# 
# res = future_lapply(munis,calculate.defo)
# 
# answer <- bind_rows(res) %>%
#   group_by(prodes_year) %>%
#   summarize(crossedMuni_slow = sum(defo_sqkm)) %>% 
#   right_join(answer, by = "prodes_year")
# 
# ### Calculate yaerly defo crossed with municipalities - fast####
# 
# defo.biome <- file.path(
#   DIR.DATA.PROJECT,
#   "testeAmz"
# )
# 
# defo.files <- list.files(defo.biome)
# munis <- str_extract(defo.files,pattern = "\\d{7}")
# 
# 
# 
# plan(multisession, workers = detectCores()-2)
# 
# res = future_lapply(munis,calculate.defo)
# 
# answer <- bind_rows(res) %>%
#   group_by(prodes_year) %>%
#   summarize(crossedMuni_fast = sum(defo_sqkm)) %>% 
#   right_join(answer, by = "prodes_year")
# 

### calculate defo before crossing #####

## Load Prodes Increment ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "land",
    "prodes_Cerrado\\cleanData",
    "cln_lcv_dfrst_cerrado_biome_prodes_inpe_sf.Rdata"
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

# states <- unique(prodes_increments$prodes_state_uf)
# 
# calculate.defo.2 <- function(uf) {
# 
#   prodes_increments %>%
#     filter(prodes_state_uf == uf) %>%
#     st_make_valid() %>%
#     st_buffer(0) %>%
#     mutate(defo_sqkm = as.numeric(st_area(geometry))*convert.sqm.to.sqkm) %>%
#     as_tibble() %>% select(-geometry) %>%
#     mutate(prodes_year = as.double(prodes_year)) %>%
#     group_by(prodes_year) %>%
#     summarize(BaselineGeom = sum(prodes_area_km2))
# 
# }
# 
# plan(multisession, workers = detectCores()-2)
# 
# res = future_lapply(states,calculate.defo.2) %>%
#   bind_rows()
# 
# 
# 
# answer <- res %>%
#   group_by(prodes_year) %>%
#   summarise(BaselineGeom = sum(BaselineGeom)) %>%
#   right_join(answer, by = "prodes_year")

### Returning to orinal CRS ####

defo.files <- list.files(defo.biome)
munis <- str_extract(defo.files,pattern = "\\d{7}")



calculate.defo <- function(municipality) {
  
  load(
    file.path(
      defo.biome,
      paste0("prodes_inc_cerrado_muni_",
             municipality,
             "_sf.Rdata")
    )
  )
  
  result  <- result %>%
    
  st_transform(crs = st_crs(4674)) %>%
    
    st_make_valid() %>%
    
    st_buffer(0)
  
  result <- result %>% 
    mutate(defo_sqkm = as.numeric(st_area(geometry))*convert.sqm.to.sqkm) %>% 
    as_tibble() %>% 
    select(-geometry) %>% 
    group_by(prodes_year) %>% 
    summarize(defo_sqkm = sum(defo_sqkm))
  
}


plan(multisession, workers = detectCores()-1)

res = future_lapply(munis,calculate.defo)

answer2 <- bind_rows(res) %>% 
  group_by(prodes_year) %>% 
  summarize(crossedMuni_org_crs = sum(defo_sqkm))

#########################################################


write.xlsx(answer,file.path(
  DIR.CPI.DATA,
  "land/prodes_AmazonBiome/cleanData","04_crossCheck.xlsx"))

print(
  Sys.time() - str.time
)
