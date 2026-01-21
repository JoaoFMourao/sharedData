# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - MAPBIOMAS FIRE COLLECTION 1.0
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: GET MUNI CODE FROM DICTIONARY
# AUTHOR: PATRICK ALEIXO
#
#
#
# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

rm(list = ls())
gc()



# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo



# LIBRARIES
pkgs <- c("tidyverse")

groundhogLibraries(pkgs, date = Sys.Date() - 3)



## amazon deforestation mapbiomas dataframe ####

fire <- read.csv(
  file.path(
    DIR.CDR.DATA,
    "raw2clean/landCover/fire/amazonBiome/mapbiomas/dataframe/colecaoFogo_1/yearly/output",
    "01_cln_lcv_fire_amz_yearlyBurnedArea_mapbiomas.csv"
  )
)


## deforestation mapbiomas dictionary ####

dic <- read.csv(
  file.path(
    DIR.CDR.DATA,
    "raw2clean/landCover/fire/amazonBiome/mapbiomas/dataframe/colecaoFogo_1/yearly/output",
    "cln_lcv_fire_amz_yearlyBurnedArea_mapbiomas_dic.csv"
  )
)


## deal with `system:index` to get only id from municipality ####

fire$system.index <- str_extract(fire$system.index, pattern =  "[:alnum:]{20}")



## merge with dic to get code from municipality ####

fire <- fire %>%
  
  left_join(
    dic %>%
      select(-id)
  )


## select and order columns ####

fire <- fire %>%
  
  select(-system.index) %>%
  
  relocate(c(mun_code,uf,year), .before = class) %>%
  
  relocate(area, .after = class_name)



# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------



write.csv(fire, file = file.path(DIR.CDR.DATA,
                                   "raw2clean/landCover/fire/amazonBiome/mapbiomas/dataframe/colecaoFogo_1/yearly/output",
                                   "02_cln_lcv_fire_amz_yearlyBurnedArea_mapbiomas.csv"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------



