
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND COVER
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: DOWNLOAD AND INCLUDE MUNICIPALITY CODE TO THE MAPBIOMAS`S DEFORESTATION DATA`
# AUTHOR: MARCELO SESSIM
#
# > NOTES
# 1: -

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()
# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo


#FUNCTIONS
source("_functions/exclude_accent.R")

#PACKAGES
pkgs <-  c('tidyverse', 'data.table', 'readxl','tidyr', 'dplyr', 'lubridate')
groundhogLibraries(pkgs, date = Sys.Date()-2)


#####################################################

#DOWNLOAD 

# #set the folder to download from
 path.end <- "raw2clean/landCover/deforestation/amazonBiome/deforestation_mapbiomas"
# 
# 
# # url definition
#  url <- "https://mapbiomas-br-site.s3.amazonaws.com/Estat%C3%ADsticas/TABELA_GERAL_COL7_MAPBIOMAS_DESMAT_VEGSEC_UF.xlsx"
# #
# 
# # #Determine the location and name of the file
#  destiny <- file.path(DIR.CDR.DATA, path.end,"input","deforestation.xlsx")
# #
# # #download the update file
#  # if (getOption('timeout') < 6000) {
#  #   options(timeout = 6000000)
#  # }
#  
#  download.file(url,destiny)
# #

#LOAD

#load the data
map7 <- read_excel(file.path(DIR.CDR.DATA, path.end, 
                             "input","TABELA_GERAL_COL7_MAPBIOMAS_DESMAT_VEGSEC_UF.xlsx"), 
                             sheet = 3) %>% 
  
  #transform o  os anos em uma coluna
  pivot_longer(cols = "1986":"2021", names_to = "year", values_to = "area")

# map7 <- read_excel(
#   destiny, sheet = 3) %>%
#   #transfo anos em uma coluna
#   pivot_longer(cols = "1986":"2021", names_to = "year", values_to = "area")

mapbiomas_muni_code <- map7 %>% select(city, feature_id) %>% distinct()

city <- map7 %>% select(city) %>% distinct()

clean = city[['city']]
city = city[['city']]


clean <- str_split_fixed(clean, " - ", Inf)

clean <- cbind(clean, city)

clean <- as.data.frame(clean)

map7 <- map7 %>% left_join(clean) %>% select(-city) %>% rename(muni_name = V1, state = V2, biome = V3)


#primeiro, vou colocar o codigo das UF, como esta na minha base com o codigo do IBGE dos municipios
mun <- file.path(DIR.CDR.DATA, path.end, "input","Cod_UF.xlsx")
 
UFs <- read_excel(mun, sheet = 1)

colnames(UFs) <- c("Cod_UF","state")

map7 <- map7 %>% left_join(UFs, by = "state")                 


#Baixar o codigo dos municipios
codigos <- read_excel( file.path( DIR.CDR.DATA, path.end, "input", "RELATORIO_DTB_BRASIL_MUNICIPIO.xls"), sheet = 1) %>%
  select(UF,"Código Município Completo", Nome_Município)

colnames(codigos) <- c("Cod_UF","Cod.Mun", "muni_name")

codigos$Cod_UF <- as.double(codigos$Cod_UF)

map7 <- map7 %>% mutate(muni_name = exclude_accent(muni_name))
codigos <- codigos %>% mutate(muni_name = exclude_accent(muni_name))

map7 <- map7 %>% left_join(codigos, by = c("Cod_UF","muni_name"))

map7 <- map7 %>% left_join(mapbiomas_muni_code, by = "feature_id")

## testing how many municipalities left without a muni_code match
tmp <- map7 %>% filter(is.na(Cod.Mun)) %>% select(muni_name, Cod_UF) %>% distinct()

# two municipalities missing muni_code. will add them by hand

map7 <- map7 %>% 
  mutate( Cod.Mun = 
            ifelse(muni_name == "lagoa dos patos", 4300002,
          ifelse(muni_name == "lagoa mirim", 4300001, Cod.Mun)))
  

## Export Prep ----------------------------------------------------------------------------------------------------------------------------

raw2clean.landCover.deforestation.amazonBiome.mapbiomas7 <- map7

## Export  ----------------------------------------------------------------------------------------------------------------------------

save(raw2clean.landCover.deforestation.amazonBiome.mapbiomas7,
     file = file.path(DIR.CDR.DATA, path.end, "output", 
                      "raw2clean_landCover_deforestation_amazonBiome_mapbiomas7.Rdata"))

rm(list = ls())
gc()

# End of Script --------------------------------------------------------------------------------------------------------------------- 