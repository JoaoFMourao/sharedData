
# > PROJECT INFO
# NAME: CPI DATA REPOSITORY 
# LEAD: JOAO MOURAO
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA [DEFORESTATION POLYGONS ONLY]
# AUTHOR: JULIA BRANDAO
#
# > NOTES
# 


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()


# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source(file.path("_functions", "associateCRS.R"))


# loading packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  terra, # handle raster data
  raster, # handle raster data 
  sf, # vector data operations
  dplyr, # data wrangling
  tidyr, # data wrangling
  data.table, # data wrangling
  stringr, # string manipulation
  tictoc,
  future.apply, 
  parallel
)


# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
#--Loading Raster throughout the years

TC_years <- c(2004,2008,2010,2012,2014,2020)

load_raster <- function(i){
    raster_path <- file.path(DIR.CPI.DATA, 
                             paste('land/landUse_terraclass/rawData/TC_AMZ_',i,'/TC_AMZ_', i,'.tif', sep = ''))
    raster<-rast(raster_path)
    aux.name <- paste('TC_AMZ_', i, sep ='')
    assign(aux.name, raster, envir = .GlobalEnv)
    
}

lapply(TC_years, load_raster)

# ANALYSING DATA -----------------------------------------------------------------------------------------------------------------------------------------
raster_names <- ls(pattern = "TC_AMZ_")
rasters <- mget(raster_names)
# Verificar se todos os raster têm o mesmo CRS
crs_list <- sapply(rasters, function(r) st_crs(r))
#Todos tem mesmo crs!



# EXPORTING DATA -----------------------------------------------------------------------------------------------------------------------------------------

rasterList = ls(pattern = 'TC_AMZ_')

savingRaster<-function(i){
   #Changing names
   lnd.lTC.clean<-get(rasterList[i])
   
   #Saving clean raster as Rdata
   writeRaster(lnd.lTC.clean,
               filename = file.path(DIR.CPI.DATA,'land/landUse_terraclass/cleanData', paste('lnd_lTC_clean_TC_AMZ', TC_years[i], '.tif', sep='')))
   
}

lapply(1:length(TC_years), savingRaster)


# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------