
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - DEGRAD [AMAZON DEGRADATION]
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA
# AUTHOR: CHRISTIANE SZERMAN / ANA RIBEIRO / JOAO VIEIRA / JOAO MOURAO 
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
pkgs <- c("sf","tidyverse","data.table","lubridate","sp","rgdal")

groundhogLibraries(
  pkgs,
  date = Sys.Date() - 2
)



# DATA INPUT ----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
aux.years  <- 2007:2016  # currently all available


raw.degrad <- pmap(
  
  list(aux.years),
  
  ~ st_read(
    
    dsn = file.path(
      DIR.CDR.DATA,
      "raw2clean/landCover/degradation/legalAmazon/degrad_inpe/input",
      as.character(..1)
    ),
    
    layer = file.path(
      DIR.CDR.DATA,
      "raw2clean/landCover/degradation/legalAmazon/degrad_inpe/input",
      as.character(..1)
    ) %>%
      
      dir(pattern = ".shp") %>%
      
      str_remove(pattern = ".shp"),
    
    options = "ENCODING=latin1"
    
  )
)



# EXPLORATION
# summary(raw.degrad)
# lapply(raw.degrad, summary)      # columns are not consistent throughout sample
# lapply(raw.degrad, proj4string)  # 2007-2009 yield missing CRS info; 2010-2013 yield SAD69_pre96BR; 2015-2016 yield SIRGAS2000_longlats
# View(raw.degrad[[1]])
# plot(raw.degrad[[1]])





# DATASET PREP AND CLEANUP ---------------------------------------------------------------------------------------------------------------------------

# LIST ELEMENT NAMES
names(raw.degrad) <- as.list(aux.years)



# CRS ATTRIBUTION

  #there are 3 possibilites
      #the files doesn't have a .prj file -> following INPE's guidandce we attibute unprojected SAD69longlat_pre96BR
      # The files has a .prj file and it states there that the appropriate crs is  unprojected SAD69longlat_pre96BR
      # The files has .prj file and it states there that the appropriate crs is SIRGAS 2000

  #regardless of which group the shape year is, the crs wasn't loaded with the shape. Hence we will attribute it manually.

  #the code is written in a way that it is easy to give an crs to each group, regardless of the fact that groups one and two use the same projection

for (i in 1:length(raw.degrad)) {
  
  print(aux.years[[i]]) # print the year, so you know in which any problem occur 
  
  folder <-   file.path(
      
    DIR.CDR.DATA,
      
      "raw2clean/landCover/degradation/legalAmazon/degrad_inpe/input",
      
      as.character(aux.years[i])
      
    ) #define the folder with the shapefiles of the respective year
  
  if (   #if in that folder there ain´t any .prj files (where crs information shoul be)
    

  dir(folder) %>% #get all the file names in the folder
  
  str_detect(".prj") %>%  #detect if each one has a ".prj" character
  
  sum() == 0 #if none of the files in the shape's folder has it, the sum shall be zero
  
  ){
    
    st_crs(raw.degrad[[i]]) <- st_crs(

            AssociateCRS(CRS_id = "Unproj_SAD69longlat_pre96BR")
            
    ) #hence, we attibute the unprojected sad69 pre96BR
    
  } else { #if the folder has a .prj file, read it
    
    prj_file <-  read_file( 
      
      file.path(
        
        folder, #the folder
        
        dir(
          
          folder,
          
          pattern = ".prj"
          
        ) # the name of the file
      )
    )
    
    #if SIRGAS2000 is written in the .prj file
    
    if(     
    
        str_detect( 
        
        prj_file,
        
        "SIRGAS2000"
      )
    
      ){ 
      
      #attribute the sirgas2000 unprojected coordinates
      
      st_crs(raw.degrad[[i]]) <- st_crs(AssociateCRS("Unproj_SIRGAS2000longlat"))
        
    } else {
      
      #Otherwise, attibute the unprojected sad69 pre96BR
      
      st_crs(raw.degrad[[i]]) <- st_crs(AssociateCRS("Unproj_SAD69longlat_pre96BR") ) 
      
      }
    
  }
  

  print(is.na(st_crs(raw.degrad[[i]]))) #print an FALSE just to check an crs was attibuted

  }



# COLUMN CLEANUP
# standardizes lower/upper case across column names
lapply(X   = raw.degrad,
       FUN = names)

#for some reasion str_to_lower and tolower we generating erros with this code
raw.degrad$`2010` <- raw.degrad$`2010` %>%
  rename(

    "scene_id" = "SCENE_ID",
    "linkcolumn" = "LINKCOLUMN",
    "cell_oid" = "CELL_OID",
    "class_name" = "CLASS_NAME",
    "view_date" = "VIEW_DATE",
    "julday" = "JULDAY",
    "pathrow" = "PATHROW",
    "codigouf" = "CODIGOUF",
    "nome" = "NOME",
    "area" = "AREA"
    
    )





# change uf to state_uf and convert it to character
for (select.layer in c(1:3, 5:9)) {
  raw.degrad[[select.layer]] <- raw.degrad[[select.layer]] %>% rename(state_uf = uf)
  raw.degrad[[select.layer]]$state_uf <- as.character(raw.degrad[[select.layer]]$state_uf)
  
  
}

#change one collums name from codigouf to state_code (just using rename wasn't working with sf for some reasons)

raw.degrad$`2010` <- raw.degrad$`2010` %>% rename(state_code = codigouf)



# translate and standardize column names
raw.degrad$`2009` <- raw.degrad$`2009` %>% rename(year = ano)
raw.degrad$`2010` <- raw.degrad$`2010` %>% rename(state_name = nome)
raw.degrad$`2012` <- raw.degrad$`2012` %>% rename(area_meters = areametros)
raw.degrad$`2013` <- raw.degrad$`2013` %>% rename(area_meters = areameters)
raw.degrad$`2014` <- raw.degrad$`2014` %>% rename(area_meters = areameters)
raw.degrad$`2015` <- raw.degrad$`2015` %>% rename(area_meters = areameters)
raw.degrad$`2016` <- raw.degrad$`2016` %>% rename(area_meters = areameters)

for (select.layer in seq_along(raw.degrad)) {
print(select.layer)  
  raw.degrad[[select.layer]] <- raw.degrad[[select.layer]] %>% rename(degrad_type = class_name)
  
}


# change column class
for (select.layer in seq_along(raw.degrad)) {
  
  raw.degrad[[select.layer]]$linkcolumn <- as.numeric(as.character(raw.degrad[[select.layer]]$linkcolumn))
  raw.degrad[[select.layer]]$pathrow <- as.numeric(as.character(raw.degrad[[select.layer]]$pathrow))
  
}

for (select.layer in 4:length(raw.degrad)) {
  
  raw.degrad[[select.layer]]$view_date <- ymd(as.character(raw.degrad[[select.layer]]$view_date)) # change to date class

}


raw.degrad$`2010`$state_name <- as.character(raw.degrad$`2010`$state_name)
raw.degrad$`2010`$state_code <- as.numeric(as.character(raw.degrad$`2010`$state_code))




# ROW CLEANUP
# standardize degrad_type elements
raw.degrad$`2007` <- raw.degrad$`2007` %>% mutate(degrad_type = recode(degrad_type, DEGRAD2007 = "degradation"))
raw.degrad$`2008` <- raw.degrad$`2008` %>% mutate(degrad_type = recode(degrad_type, DEGRAD2008 = "degradation"))
raw.degrad$`2009` <- raw.degrad$`2009` %>% mutate(degrad_type = recode(degrad_type, DEGRADACAO = "degradation"))
raw.degrad$`2010` <- raw.degrad$`2010` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2011` <- raw.degrad$`2011` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2012` <- raw.degrad$`2012` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2013` <- raw.degrad$`2013` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2014` <- raw.degrad$`2014` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation"))
raw.degrad$`2015` <- raw.degrad$`2015` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation",
                                                                                            BLOWDOWN = "blowdown",
                                                                                            CICATRIZ_QUEIMADA = "fire_scar",
                                                                                            DEGRAD_NATURAL = "degradation_natural",
                                                                                            QUEIMADA = "fire"))
raw.degrad$`2016` <- raw.degrad$`2016` %>% mutate(degrad_type = recode(degrad_type, DEGRAD = "degradation",
                                                                                            CICATRIZ_INCENDIO = "fire_scar"))





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# change object name for exportation
cln.lcv.dgrad.laz.degrad.inpe <- raw.degrad



# POST-TREATMENT OVERVIEW
# summary(cln.lcv.dgrad.laz.degrad.inpe)
# View(cln.lcv.dgrad.laz.degrad.inpe)
# plot(cln.lcv.dgrad.laz.degrad.inpe)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.lcv.dgrad.laz.degrad.inpe,
     file = file.path("H:/CLARISSA/CDR/raw2clean/landCover/degradation/legalAmazon/degrad_inpe/output", 
                      "cln_lcv_dgrad_laz_degrad_inpe_sf.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------