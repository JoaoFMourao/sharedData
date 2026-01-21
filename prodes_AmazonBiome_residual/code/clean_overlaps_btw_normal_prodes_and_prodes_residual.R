# > PROJECT INFO
# NAME: BOLSA VERDE
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: clean prodes   
# AUTHOR: Adapted from Rogério Reis
#
# > NOTES: 

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
          "tictoc","labelled", "geobr", "dplyr", "readxl", "lwgeom")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# INPUT  -------------------------------------------------------------------

# big resolution input 
files_big = list.files(file.path(DIR.CPI.DATA, 
                                  "land\\prodes_AmazonBiome\\cleanData\\02_mrg_amazonMuni"), 
                            full.names = TRUE)  #Vector with all the PRODES file paths

# small resolution input 
files_residue = list.files(file.path(
                                        DIR.CPI.DATA,
                                        "land", 
                                        "prodes_AmazonBiome_residual",
                                        "cleanData",
                                        "mrg_amazonMuni"), 
                            full.names = TRUE)  #Vector with all the PRODES file paths

# Getting the code for the prodes munis 
muni_big = unique(str_extract(files_big,pattern = "\\d{7}")) 
muni_residue = unique(str_extract(files_residue,pattern = "\\d{7}")) 

only_residue = setdiff(muni_residue, muni_big) # if muni is here, there's no way to cross it with anything, so we simply save it 

# START FUNCTION  ----------------------------------------------------------------------------------------------------------------------------------------

fixing_overlap = function(muni){
  
  if(muni %in% only_residue){ 
    
    # Filter the small PRODES muni path that match the municipality 
    muni_full_residue <- files_residue[grep(muni, files_residue)]
    # Loading muni small 
    muni_residue = get(load(muni_full_residue)) 
    
    #Saving 
    save(muni_residue,
         file = file.path(paste(
             DIR.CPI.DATA, 
             'land/prodes_AmazonBiome_residual/cleanData/cleanOverlap/',
             'blt_rsd_without_overlaps_with_normal_prodes_', 
             muni, '.Rdata', sep=''))
    )
    
  }else{ 
    
  # Filter the big PRODES muni path that match the municipality 
  file_muni_big <- files_big[grep(muni, files_big)]
  
  # Filter the small PRODES muni path that match the municipality 
  file_full_residue <- files_residue[grep(muni, files_residue)]
  
  
  # load data 
  muni_big = get(load(file_muni_big)) 
  muni_residue = get(load(file_full_residue)) 


  # It is possible that the filter kills all the obs in one of the files 
  # So if this happens, we do not preceed.
  if(nrow(muni_residue) != 0){
    
    # Now, we can verify the overlaps 
    intersects = st_intersects(muni_residue, muni_big) #considers every intersection (including only touches)
    touches = st_touches(muni_residue, muni_big)  #Getting only the touches 
    
    #kicking off the intersections that only touche other polygons
    overlaps <- lapply(seq_along(intersects), function(i) {
      setdiff(intersects[[i]], touches[[i]])
    })
    
    #saving memory 
    rm(intersects) 
    rm(touches) 
    
    used = c() 
    
    # Cleaning loop 
    
    #going from 1 till the end of muni (i is each obs)
    for(i in 1:nrow(muni_residue)){ 
      
      if(length(overlaps[[i]]) != 0){
        for(j in overlaps[[i]]){ # j going through the obs (lines) that overlap i 
          
                # creating in advance the st transformation required so that we
                # only need to calculate it once 
                difference = st_difference(muni_residue$geometry[i], muni_big$geometry[j])
                
                #if i is NOT completely inside j....
                if(length(difference) != 0){
                  
                    muni_residue$geometry[i] <- difference %>%
                    
                    st_make_valid() %>%
                    
                    st_buffer(0)
                  
                }else{
                    muni_residue$geometry[i] = NULL
                  
                }
              }
            }
    }
    
  } # if the municipality is only in the small data, we simply save it 
  
    # SAVING ####
  
  save(muni_residue,
       file = file.path(paste(
           DIR.CPI.DATA, 
           'land/prodes_AmazonBiome_residual/cleanData/cleanOverlap/',
           'blt_rsd_without_overlaps_with_normal_prodes_', 
           muni, '.Rdata', sep=''))
  )
  
  }
} 

# RUN EVERYTHING #####
plan(multisession, workers = detectCores()-2)
res = future_lapply(muni_residue, fixing_overlap)

print(
  Sys.time() - str.time
)        


# END OF CODE -----------------------------------------------------------------------------------------------------------------------------
