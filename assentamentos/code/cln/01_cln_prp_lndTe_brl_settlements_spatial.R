# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RURAL SETTLEMENTS RAW DATA - SHAPEFILE
# AUTHOR: JULIA BRANDAO (ADPTED FROM DIEGO MENEZES, RAFAEL PUCCI AND MARCELO SESSIM)
#
# > NOTES
# 1: Needs to specify better dates, how and when to use each one and why
# 2: This code took 7 minutes to ran with an i7, 32 RAM, machine 149 at CPI


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

rm(list = ls())
gc()

strt.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sources config for shared data repo


# SOURCES
source("_functions/convertLatinCharsbyCharsSf.R", encoding = "UTF-8")
source("_functions/convertLatinCharsbyChars.R", encoding = "UTF-8")
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "convertUnits.R"))


#load packages
pkgs <- c("data.table","labelled",  "sf", "tidyverse","stringr")

groundhogLibraries(
  pkgs,
  date = '2024-03-01'
)

reference.data <- "20250109"


check <- TRUE
# check <- FALSE

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
settlements.BR_ref <- st_read(file.path(
  DIR.CPI.DATA, 
  'propertyRights/assentamentos/rawData',
  paste0(reference.data,'/Assentamento Brasil.shp')))


# DATA CLEANING ---------------------------------------------------------------------------------------------------------------------------------------

## CRS adjusts ####
#ISSUE: 2 of most recent databased do not came with ".prj" file and associated crs
#SOLUTION: we will use the crs from a dataset download in february of 2024
#Becase it has similatiries with area
st_crs(settlements.BR_ref) 

#The only one with 
# sum(st_area(settlements.BR_ref$geometry)*convert.sqm.to.ha)

shape_cleanup <- function(df){
  # COLUMN CLEANUP
  # changes column names
  colnames(df)
  setnames(df, "cd_sipra"   , "sipra_code")
  setnames(df, "uf"         , "state_uf")
  setnames(df, "nome_proje" , "project_name")
  setnames(df, "municipio"  , "muni_name")
  setnames(df, "area_hecta" , "area_ha")
  setnames(df, "capacidade" , "family_capacity")
  setnames(df, "num_famili" , "family_settled")
  setnames(df, "fase"       , "stage_num")          
  setnames(df, "data_de_cr" , "creation_date")  
  setnames(df, "forma_obte" , "obtention_method")     
  setnames(df, "data_obten" , "obtention_date")
  setnames(df, "area_calc_" , "shape_area_unknown")
  setnames(df, "sr"         , "jur_code")
  setnames(df, "descricao_" , "stage_description")
  
  # checks column classes
  lapply(df, class) # every column already has its ideal class; no need to change
  
  #check for na variables
  pmap(list(colnames(df)), ~ prevalent_values(df, ..1))
  
  #Adjust geometires
  df<-df %>% 
    st_make_valid() %>% 
    #both variables are all NA
    select(-c(jur_code, stage_description))
  
  # ROW CLEANUP
  # latin characters treatment
  df <- ConvertLatinCharsbyCharsSf(df)
  
  #confirm that shape_area_unkown is the area of the geometry we are going to use
  #to create a new combined geometry
  if (check == TRUE){
    tmp <- df %>% 
      mutate(area = st_area(geometry) %>% as.numeric(),
             dif = shape_area_unknown - area*convert.sqm.to.ha)
    
    summary(tmp$dif)
  }
  
  # typo fixes
  df <- df %>%
    #there is an issue with the state uf variable, so lets take it away
    select(-c(state_uf, shape_area_unknown))
  
  #Explanation
  #In this code, maybe it should be done in another, we join the geometries by
  #sipra code. We do this because it sipracode correspond to one settlement
  #Nonetheless, this settlement geometry is divided into different lines. Each 
  #with is own geometry. We believe the INCRA did this for two reasons:
  # 1) to deal with disjoin geometries, albeit it would not be needed
  # 2) in cases where the settlement is divided into different plots, each plot
  #with its own geometry
  
  #Now let's check that, besides the geometry, all the data is the same for each 
  #sipra code
  if(check == TRUE){
    a <- df %>% 
      as_tibble() %>% 
      dplyr::select(-geometry) %>% 
      distinct(.keep_all = TRUE) %>% 
      prevalent_values("sipra_code") %>% 
      filter(n > 1)
    
    if(length(a$sipra_code) > 0){
      print("There are repetitions in the data")
      print(a)
    } else{
      print("There ain't repetititions in the data")
    }
    
  }
  
  # Each settlement is uniquely identified by the sipra_code, but the dataset contains 
  #multiple observations per sipra_code.
  set.geom <- df %>% 
    ungroup() %>% 
    dplyr::select(sipra_code) %>% 
    dplyr::group_by(sipra_code) %>%
    dplyr::summarize() %>%
    mutate(aux = 1) 
  
  df <- df %>% 
    as_tibble() %>% 
    dplyr::select(-geometry) %>% 
    distinct(.keep_all = TRUE) %>%
    left_join(set.geom, by = "sipra_code")
  
  #albeit we use the same original data, NA's and other issues generating the u
  #union polygons can cause some sipra_codes to appear without a geometry, we got
  #to check if this happens
  if(check == TRUE){
    
    print(
      paste(
        "A total of",
        sum(is.na(df$aux)),
        "sipra codes appear without a geometry"
      )
    )
    
  }
  
  df <-  df %>%
    select(sipra_code,
           geometry) 
  
  return(df)
}


set <- shape_cleanup(settlements.BR_ref)  %>%
  st_as_sf() %>%
  st_set_crs(4674) 


# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(set,
     file = file.path(
       DIR.CPI.DATA, 
       'propertyRights/assentamentos/cleanData/spatial',
       paste0("cln_set_spatial_",reference.data,".RData")
     )
)

#compute time
end_time <- Sys.time()
print(end_time - strt.time)



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------