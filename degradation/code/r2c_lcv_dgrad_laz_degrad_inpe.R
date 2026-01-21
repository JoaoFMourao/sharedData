
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - DEGRAD [AMAZON DEGRADATION]
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA
# AUTHOR: CHRISTIANE SZERMAN / ANA RIBEIRO / JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo



# SOURCES
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "readShape.R"))



# LIBRARIES
pkgs <- c("sp", "rgdal", "rgeos", "Hmisc", "tidyverse", "lubridate")

groundhogLibraries(
  pkgs,
  date = Sys.Date() - 2
)





# DATA INPUT ----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
aux.years  <- 2007:2016  # currently all available

raw.degrad <- lapply(X   = aux.years,
                        FUN = function(x) ReadShape(paste0("H:/CLARISSA/CDR/raw2clean/landCover/degradation/legalAmazon/degrad_inpe/input", 
                                                           "/", as.character(x))))



# EXPLORATION
# summary(raw.degrad)
# lapply(raw.degrad, summary)      # columns are not consistent throughout sample
# lapply(raw.degrad, proj4string)  # 2007-2009 yield missing CRS info; 2010-2013 yield SAD69_pre96BR; 2015-2016 yield SIRGAS2000_longlat
# View(raw.degrad[[1]])
# plot(raw.degrad[[1]])





# DATASET PREP AND CLEANUP ---------------------------------------------------------------------------------------------------------------------------

# LIST ELEMENT NAMES
names(raw.degrad) <- as.list(aux.years)



# CRS ATTRIBUTION
for (select.layer in seq_along(raw.degrad)) {
  if (is.na(proj4string(raw.degrad[[select.layer]]))) {
    proj4string(raw.degrad[[select.layer]]) <- CRS(AssociateCRS(CRS_id = "Unproj_SAD69longlat_pre96BR"))  # CRS selection as per INPE's guidance
  }
}



# COLUMN CLEANUP
# standardizes lower/upper case across column names
lapply(X   = raw.degrad,
       FUN = names)

names(raw.degrad[[which(names(raw.degrad) == 2010)]]) <- tolower(names(raw.degrad[[which(names(raw.degrad) == 2010)]]))

# change uf to state_uf and convert it to character
for (select.layer in c(1:3, 5:9)) {

  raw.degrad[[select.layer]]@data <- raw.degrad[[select.layer]]@data %>% rename(state_uf = uf)
  raw.degrad[[select.layer]]@data$state_uf <- as.character(raw.degrad[[select.layer]]@data$state_uf)
  
  
}

raw.degrad$`2010`@data <- raw.degrad$`2010`@data %>% rename(state_code = codigouf)


# translate and standardize column names
raw.degrad$`2009`@data <- raw.degrad$`2009`@data %>% rename(year = ano)
raw.degrad$`2010`@data <- raw.degrad$`2010`@data %>% rename(state_name = nome)
raw.degrad$`2012`@data <- raw.degrad$`2012`@data %>% rename(area_meters = areametros)
raw.degrad$`2013`@data <- raw.degrad$`2013`@data %>% rename(area_meters = areameters)
raw.degrad$`2014`@data <- raw.degrad$`2014`@data %>% rename(area_meters = areameters)
raw.degrad$`2015`@data <- raw.degrad$`2015`@data %>% rename(area_meters = areameters)
raw.degrad$`2016`@data <- raw.degrad$`2016`@data %>% rename(area_meters = areameters)

for (select.layer in seq_along(raw.degrad)) {
  
  raw.degrad[[select.layer]]@data <- raw.degrad[[select.layer]]@data %>% rename(degrad_type = class_name)
  
}


# change column class
for (select.layer in seq_along(raw.degrad)) {
  
  raw.degrad[[select.layer]]@data$linkcolumn <- as.numeric(as.character(raw.degrad[[select.layer]]@data$linkcolumn))
  raw.degrad[[select.layer]]@data$pathrow <- as.numeric(as.character(raw.degrad[[select.layer]]@data$pathrow))
  
}

for (select.layer in 4:length(raw.degrad)) {
  
  raw.degrad[[select.layer]]@data$view_date <- ymd(as.character(raw.degrad[[select.layer]]@data$view_date)) # change to date class

}


raw.degrad$`2010`@data$state_name <- as.character(raw.degrad$`2010`@data$state_name)
raw.degrad$`2010`@data$state_code <- as.numeric(as.character(raw.degrad$`2010`@data$state_code))




# ROW CLEANUP
# standardize degrad_type elements
raw.degrad$`2007`@data <- raw.degrad$`2007`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD2007 = "degradation"))
raw.degrad$`2008`@data <- raw.degrad$`2008`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD2008 = "degradation"))
raw.degrad$`2009`@data <- raw.degrad$`2009`@data %>% mutate(degrad_type = recode(degrad_type, DEGRADACAO = "degradation"))
raw.degrad$`2010`@data <- raw.degrad$`2010`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2011`@data <- raw.degrad$`2011`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2012`@data <- raw.degrad$`2012`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2013`@data <- raw.degrad$`2013`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2014`@data <- raw.degrad$`2014`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2015`@data <- raw.degrad$`2015`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation",
                                                                                            BLOWDOWN = "blowdown",
                                                                                            CICATRIZ_QUEIMADA = "fire_scar",
                                                                                            DEGRAD_NATURAL = "degradation_natural",
                                                                                            QUEIMADA = "fire"))
raw.degrad$`2016`@data <- raw.degrad$`2016`@data %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation",
                                                                                            CICATRIZ_INCENDIO = "fire_scar"))





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# change object name for exportation
cln.lcv.dgrad.laz.degrad.inpe <- raw.degrad



# POST-TREATMENT OVERVIEW
# summary(cln.lcv.dgrad.laz.degrad.inpe)
# View(cln.lcv.dgrad.laz.degrad.inpe@data)
# plot(cln.lcv.dgrad.laz.degrad.inpe)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.lcv.dgrad.laz.degrad.inpe,
     file = file.path("H:/CLARISSA/CDR/raw2clean/landCover/degradation/legalAmazon/degrad_inpe/output", 
                      "cln_lcv_dgrad_laz_degrad_inpe.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------