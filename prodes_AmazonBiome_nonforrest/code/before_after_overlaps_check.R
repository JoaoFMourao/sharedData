# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: Get the difference between the area before and after cleaning overlaps
# AUTHOR:  SERGIO PIMENTEL
#
# > NOTES: THE DIFFERENCE IS:  0.002944753 HA
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

groundhogLibraries(pkgs, date = "2024-04-23")


# Turns off scientific notation
options(scipen = 99) 

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

## Load Prodes Increment ####

files.nonforest = list.files(file.path(DIR.CPI.DATA,
                                       "land", 
                                       "prodes_AmazonBiome_nonforrest",
                                       "builtData",
                                       "mrg_muni",
                                       "new"),
                             full.names = TRUE) 
#files.nonforest <- files.nonforest[-1]
#get the object by its names
x <-  lapply(files.nonforest, function(f) {
    env <- new.env()
    load(f, envir = env)
    get(ls(env)[1], envir = env)
})
before_prodes_increments <- bind_rows(x)
before_prodes_increments<- before_prodes_increments %>%
    mutate(prodes_area = st_area(geometry)*convert.sqm.to.ha,
           prodes_area = as.numeric(prodes_area))

prodes_area <- sum(before_prodes_increments$prodes_area)
new_area <- sum(before_prodes_increments$area_pol_prodes_ha)

rm(x)
gc()

# without overlaps 
files.path = file.path(
  DIR.CPI.DATA,
  "land", 
  "prodes_AmazonBiome_nonforrest",
  "builtData",
  "cleanOverlap",
  "new"
)

# List only the files ending in .Rdata
files <- list.files(
  files.path,
  pattern = "\\.Rdata$",
  full.names = TRUE
)
x <-  lapply(files, function(f) {
  env <- new.env()
  load(f, envir = env)
  get(ls(env)[1], envir = env)
})

after_prodes_increments <- bind_rows(x)
rm(x)
gc()

# Area diference
after_prodes_increments <- after_prodes_increments %>%
    mutate(prodes_area = st_area(geometry)*convert.sqm.to.ha,
           prodes_area = as.numeric(area_pol_prodes_ha))

difference = sum(before_prodes_increments$area_pol_prodes_ha) - sum(after_prodes_increments$area_pol_prodes_ha)
difference
difference = sum(before_prodes_increments$prodes_area) - sum(after_prodes_increments$prodes_area)
difference

