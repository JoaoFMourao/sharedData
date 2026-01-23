
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - FIRE 
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREATS RAW INPE DATA ON BURNINGS -- 2019 to 2021
# AUTHOR: HELENA ARRUDA; DIEGO MENEZES
#
# > EDIT DETAILS
# BY: 
# ON: 
#
# > NOTES
# 





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo




# SOURCES
source(file.path("_functions", "identifyMissingAllColumnsAndRowsSp.R"))
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions","convertUnits.R"))



# LIBRARIES
# sp, rgdal, rgeos for spatial manipulation
# Hmisc            for dataframe labelling
# data.table       for dataframe manipulation
pkgs <- c('sf', 'tidyverse', "sp", "rgdal", "rgeos", "Hmisc", "data.table")
groundhogLibraries(pkgs, date = '2024-02-08')

options(scipen = 999)
options(future.seed = TRUE)
# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
# data input inside processing due to memory allocation




# AUXILIARY LIST
# creates a list with all folders names of input directory from 2019 until 2021
aux.folder.names <- list.files(file.path(DIR.CPI.DATA, "land/active_Fires/rawData"))
aux.folder.names <- aux.folder.names[23:25]





# DATASET CONSTRUCTION ------------------------------------------------------------------------------------------------------------------------------

# START THE CLOCK
ptm <- proc.time()


read_shapes <- function(i){
  files <- list.files(file.path(paste(DIR.CPI.DATA, "land/active_Fires/rawData/", aux.folder.names[i], 
                                   sep = "")))
  files <- files[4]
  
  shape <- st_read(file.path(paste(DIR.CPI.DATA, "land/active_Fires/rawData/", aux.folder.names[i],"/", files, sep = "")))
  
  aux.name<- paste('fire_', aux.folder.names[i], sep = '')
  
  assign(aux.name, shape, envir = .GlobalEnv)
                   
  
}

lapply(1:length(aux.folder.names), read_shapes)


# CLEAN ENVIRONMENT
rm(fires, aux.folder.names, aux.files.names)




# STOP THE CLOCK
proc.time() - ptm   # around 40min of process (~2300sec)





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------


# COLUMN CLEANUP

# changes column names
# objects containing the old and new names
colnames(fire_2022)
colnames(fire_2023)
colnames(fire_2024)

new.names <- c("date", "satellite", "country", "state", "municipality", "biome", "days_wt_rain",
               "precipitation", "fire_risk", "lat", "lon", "frp", 'geometry')



# first check point: the 'amount' of arguments of both objects
if (length(colnames(fire_2022)) != length(new.names)) {
  stop("** ATTENTION: review the number of arguments of the object 'new.names'")
}
if (length(colnames(fire_2023)) != length(new.names)) {
  stop("** ATTENTION: review the number of arguments of the object 'new.names'")
}
if (length(colnames(fire_2024)) != length(new.names)) {
  stop("** ATTENTION: review the number of arguments of the object 'new.names'")
}

fire_2022 <- fire_2022 %>%
  rename('date' = 'DataHora',
         'satellite' = 'Satelite',
         'country' = 'Pais', 
         'state' = 'Estado', 
         'municipality' = 'Municipio', 
         'biome' = 'Bioma',
         'days_wt_rain' = 'DiaSemChuv', 
         'precipitation' = 'Precipitac', 
         'fire_risk' = 'RiscoFogo', 
         'lat' = 'Latitude', 
         'lon' = 'Longitude',
         'frp' = 'FRP')
    
fire_2023 <- fire_2023 %>%
  rename('date' = 'DataHora',
         'satellite' = 'Satelite',
         'country' = 'Pais', 
         'state' = 'Estado', 
         'municipality' = 'Municipio', 
         'biome' = 'Bioma',
         'days_wt_rain' = 'DiaSemChuv', 
         'precipitation' = 'Precipitac', 
         'fire_risk' = 'RiscoFogo', 
         'lat' = 'Latitude', 
         'lon' = 'Longitude',
         'frp' = 'FRP')

fire_2024 <- fire_2024 %>%
  rename('date' = 'DataHora',
         'satellite' = 'Satelite',
         'country' = 'Pais', 
         'state' = 'Estado', 
         'municipality' = 'Municipio', 
         'biome' = 'Bioma',
         'days_wt_rain' = 'DiaSemChuv', 
         'precipitation' = 'Precipitac', 
         'fire_risk' = 'RiscoFogo', 
         'lat' = 'Latitude', 
         'lon' = 'Longitude',
         'frp' = 'FRP')


fires.all = rbind(fire_2022, fire_2023, fire_2024)

# checks column classes
lapply(fires.all, class)



# sets column classes

fires.all$date <- as.POSIXct(fires.all$date, format = "%Y/%m/%d %H:%M:%S")
fires.all$date <- as.Date(fires.all$date, format = "%Y-%m-%d")


# ROW CLEANUP

# translate biomes
biomes.port <- sort(unique(fires.all$biome))
biomes.engl <- c("amazon", "caatinga", "cerrado", "atlantic forest", "pampa", "pantanal")

aux.crosscheck <- matrix(data = NA, nrow = length(biomes.port), ncol = 2)
aux.crosscheck[, 1] <- biomes.port
aux.crosscheck[, 2] <- biomes.engl
aux.crosscheck   # the visualization shows that both objects have their arguments matched correctly

for (i in seq_along(biomes.port)) {
  fires.all <-  fires.all %>%
    mutate(biome = gsub(pattern = paste0("^", biomes.port[i], "$"), replacement = biomes.engl[i], 
                                     x= biome))
}

aux.biomesTranslate.check <- sort(unique(fires.all$biome))
aux.biomesTranslate.check  # all categories were translated correctly



# duplicates treatment
# duplicates report
aux.fires.duplicates <- fires.all[duplicated(fires.all[, c("date", "satellite", "lat", "lon")]), ]  # there are some considerable duplications


# duplicates subset
fires.all.years <- fires.all[!duplicated(fires.all[, c("date", "satellite", "lat", "lon")]), ]





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
var.labels <- c(date            = "date and hour of fire",
                satellite       = "image provider satellite",
                country         = "country name",
                state           = "state name",
                municipality    = "municipality name",
                biome           = "biome name",
                days_wt_rain    = "number of days without rain until fire detection",
                precipitation   = "total precipitation volume from 00h00m (day t) through time of fire detection (day t)",
                fire_risk       = "value of Fire Risk forecasted for fire detection day",
                lat             = "latitude (decimal degrees)",
                lon             = "longitude (decimal degrees)",
                frp             = "Fire Radiative Power (megawatts)", 
                geometry        = 'Geometry')


label(fires.all.years) <- lapply(names(var.labels), 
                                      function(x) label(fires.all.years[, x]) = var.labels[x])




# POST-TREATMENT OVERVIEW
summary(fires.all.years)  
View(fires.all.years)
plot(fires.all.years)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------
cln_lcv_fire_brl_activeFires_inpe_2022to2024 <- fires.all.years

save( cln_lcv_fire_brl_activeFires_inpe_2022to2024, 
      file  = file.path(DIR.CPI.DATA, 'land/active_Fires/cleanData/cln_lcv_fire_brl_activeFires_inpe_2022to2024.RData'))



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
