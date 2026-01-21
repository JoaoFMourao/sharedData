
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

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo




# SOURCES
source(file.path("_functions", "identifyMissingAllColumnsAndRowsSp.R"))




# LIBRARIES
# sp, rgdal, rgeos for spatial manipulation
# Hmisc            for dataframe labelling
# data.table       for dataframe manipulation
CallLibraries(c("sp", "rgdal", "rgeos", "Hmisc", "data.table"))





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
# data input inside processing due to memory allocation




# AUXILIARY LIST
# creates a list with all folders names of input directory from 2019 until 2021
aux.folder.names <- list.files(file.path(DIR.CDR.DATA, "raw2clean/landCover/fire/brazil/activeFires_inpe/input"))
aux.folder.names <- aux.folder.names[20:22]





# DATASET CONSTRUCTION ------------------------------------------------------------------------------------------------------------------------------

# START THE CLOCK
ptm <- proc.time()




# READ AND EXPLORATION
for (i in seq_along(aux.folder.names)) {
  
  # list shapefiles to be read
  aux.files.names <- list.files(path    = file.path(DIR.CDR.DATA, "raw2clean/landCover/fire/brazil/activeFires_inpe/input", aux.folder.names[i]),
                                pattern = "*.shp$")
  
  for (j in seq_along(aux.files.names)) {
    
    # read
    fires <- readOGR(dsn   = file.path(DIR.CDR.DATA, "raw2clean/landCover/fire/brazil/activeFires_inpe/input", aux.folder.names[i]),  
                     layer = substr(aux.files.names[j], 1, nchar(aux.files.names[j]) - 4))
    
    
    
    # exploration
    MissingAllColumnsAndRowsSp(x = fires) # there are no variables or lines full of missing
                                          
    
    
    # assign
    assign(x     = paste0("fires", ".", substr(aux.files.names[j], 1, nchar(aux.files.names[j]) - 4)), 
           envir = globalenv(),
           value = fires) 
    
  }
  
  
}




# CLEAN ENVIRONMENT
rm(fires, aux.folder.names, aux.files.names)




# STOP THE CLOCK
proc.time() - ptm   # around 40min of process (~2300sec)





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# MERGE
# selects all SpatialPointsDataFrame objects from the Environment
all.objects <- lapply(ls(), get)
aux.fires   <- all.objects[lapply(all.objects, attr, "class") == "SpatialPointsDataFrame"]



# merge
fires.all.years <- do.call(rbind.SpatialPointsDataFrame, aux.fires)



# clean environment
rm(list = ls(pattern = "^fires.Focos.[0-9]{4}-[0-9]{2}-[0-9]{2}.[0-9]{4}-[0-9]{2}-[0-9]{2}$"))
rm(all.objects, aux.fires)




# COLUMN CLEANUP

# changes column names
# objects containing the old and new names
old.names <- names(fires.all.years@data)
new.names <- c("date", "satellite", "country", "state", "municipality", "biome", "days_wt_rain",
               "precipitation", "fire_risk", "lat", "lon", "frp")



# first check point: the 'amount' of arguments of both objects
if (length(old.names) != length(new.names)) {
  stop("** ATTENTION: review the number of arguments of the object 'new.names'")
}



# second check point: the 'position' of arguments of both objects
aux.crosscheck <- matrix(data = NA, nrow = length(old.names), ncol = 2)
aux.crosscheck[, 1] <- old.names
aux.crosscheck[, 2] <- new.names
aux.crosscheck   # the visualization shows that both objects have their arguments matched correctly



# change
setnames(x = fires.all.years@data, old = old.names, new = new.names)



# checks column classes
lapply(fires.all.years@data, class)



# sets column classes
col.character                         <- c("date", "satellite", "country", "state", "municipality", "biome")
fires.all.years@data[, col.character] <- lapply(fires.all.years@data[, col.character], as.character)




# ROW CLEANUP

# translate biomes
biomes.port <- sort(unique(fires.all.years@data$biome))
biomes.engl <- c("amazon", "caatinga", "cerrado", "atlantic forest", "pampa", "pantanal")

aux.crosscheck <- matrix(data = NA, nrow = length(biomes.port), ncol = 2)
aux.crosscheck[, 1] <- biomes.port
aux.crosscheck[, 2] <- biomes.engl
aux.crosscheck   # the visualization shows that both objects have their arguments matched correctly

for (i in seq_along(biomes.port)) {
  fires.all.years@data$biome <- gsub(pattern = paste0("^", biomes.port[i], "$"), replacement = biomes.engl[i], 
                                     x       = fires.all.years@data$biome)
}

aux.biomesTranslate.check <- sort(unique(fires.all.years@data$biome))
aux.biomesTranslate.check  # all categories were translated correctly



# duplicates treatment
# duplicates report
aux.fires.duplicates <- fires.all.years[duplicated(fires.all.years@data[, c("date", "satellite", "lat", "lon")]), ]  # there are some considerable duplications


# duplicates subset
fires.all.years <- fires.all.years[!duplicated(fires.all.years@data[, c("date", "satellite", "lat", "lon")]), ]





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
                frp             = "Fire Radiative Power (megawatts)")


label(fires.all.years@data) <- lapply(names(var.labels), 
                                      function(x) label(fires.all.years@data[, x]) = var.labels[x])




# POST-TREATMENT OVERVIEW
# summary(fires.all.years@data)  
# View(fires.all.years@data)
# plot(fires.all.years@data)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

# PREP
return.obj <- c("cln.lcv.fire.brl.activeFires.inpe.2019to2021")

assign(x     = return.obj,
       value = fires.all.years)

return.file <- gsub(x = return.obj, pattern = "\\.", replacement = "_")




# OUTPUT WRITING
save(list = return.obj, file = file.path(DIR.CDR.DATA, "raw2clean/landCover/fire/brazil/activeFires_inpe/output", 
                                         paste0(return.file, ".Rdata")))




# CLEAN ENVIRONMENT
rm(return.obj, aux.crosscheck)





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
