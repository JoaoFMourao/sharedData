
# > PROJECT INFO
# NAME: DATABASE CONSTRUCTION - BRAZILIAN PROTECTED AREAS
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RAW SHAPEFILE
# AUTHOR: PEDRO PEIXOTO
#
# > NOTES
# 1. OVERLAP TREATMENT NOT INCLUDED IN THIS SCRIPT TO PRESERVE ORIGINAL DATA, BUT MAY BE RECOMMENDED DEPENDING ON PROJECT-
#    SPECIFIC NEEDS





# SETUP ---------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo




# SOURCES
source("_functions/convertLatinCharsbyCharsSf.R", encoding = "UTF-8")



# LIBRARIES

pkgs <- c("sf", "tidyverse","data.table","stringr")
groundhogLibraries(pkgs, date = Sys.Date() - 2)


start.time.script <- Sys.time()


# DATA INPUT ----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
raw.protectedAreas <- st_read(
  dsn   = file.path(
    DIR.CDR.DATA,
    "raw2clean/policy/protectedTerritory/brazil/protectedAreas_mma/input"
  ),
  
  layer = "ucstodas",
  
  options = "ENCODING=latin1"
) 


# DATA EXPLORATION - disabled for speed
# summary(raw.protectedAreas)
# View(raw.protectedAreas)
# plot(raw.protectedAreas)




# DATASET CLEANUP AND PREP --------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
colnames(raw.protectedAreas)  # reports column names; ID_WCMC is protected area id at World Database on Protected Areas (WDPA)

# renames columns considering 10-character shapefile column name limitation
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "ID_UC0")]    <- "PA_code"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "NOME_UC1")]  <- "PA_name"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "ID_WCMC2")]  <- "PA_code_wdpa"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "CATEGORI3")] <- "PA_category"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "GRUPO4")]    <- "PA_type"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "ESFERA5")]   <- "PA_jurisdiction"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "ANO_CRIA6")] <- "year_creation"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "QUALIDAD8")] <- "polygon_quality"
names(raw.protectedAreas)[which(names(raw.protectedAreas) == "ATO_LEGA9")] <- "legal_act"



# checks column classes
lapply(raw.protectedAreas, class)



# sets column classes
raw.protectedAreas <- raw.protectedAreas %>%
  mutate(
      PA_code = as.integer(PA_code), #conversion does not generate NA at 2022-03-14
      
      year_creation = 
        as.integer(year_creation)
) 



# NAs induced by coercion due to non-integer content of year_creation cells - inspection shows that these are incorrectly recorded entries
raw.protectedAreas[is.na(raw.protectedAreas$year_creation), c("PA_code", "year_creation", "legal_act")]
raw.protectedAreas[raw.protectedAreas$PA_code == 3039, ]$year_creation = 1998  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3027, ]$year_creation = 2013  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3407, ]$year_creation = 2016  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3410, ]$year_creation = 2016  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3409, ]$year_creation = 2016  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3408, ]$year_creation = 2016  # inputs 'year_creation' date based on 'legal_act' date
raw.protectedAreas[raw.protectedAreas$PA_code == 3411, ]$year_creation = 2016  # inputs 'year_creation' date based on 'legal_act' date




# LATIN CHARACTER TREATMENT
raw.protectedAreas <- raw.protectedAreas %>%
  ConvertLatinCharsbyCharsSf() 


# TRANSLATION
# removes redundant explanation of 'polygon_quality' classification
raw.protectedAreas$polygon_quality <- sub(pattern = " \\(.*\\)\\.",         # redundancy stated between brackets
                                            replacement = "",
                                            raw.protectedAreas$polygon_quality)



# translates from PT to EN
# PA type
raw.protectedAreas$PA_type <- sub(pattern = "US", replacement = "SU", raw.protectedAreas$PA_type)  # sustainable use
raw.protectedAreas$PA_type <- sub(pattern = "PI", replacement = "FP", raw.protectedAreas$PA_type)  # full protection


# PA jurisdiction
raw.protectedAreas$PA_jurisdiction <- sub(pattern = "estadual", replacement = "state", raw.protectedAreas$PA_jurisdiction)  # other categories
                                                                                                                                      # identical in PT/EN

# polygon quality
raw.protectedAreas$polygon_quality <- sub(pattern = "Aproximado",  replacement = "approximate", raw.protectedAreas$polygon_quality)
raw.protectedAreas$polygon_quality <- sub(pattern = "Correto",     replacement = "correct",     raw.protectedAreas$polygon_quality)
raw.protectedAreas$polygon_quality <- sub(pattern = "Esquemático", replacement = "schematic",   raw.protectedAreas$polygon_quality)


# PA category
raw.protectedAreas$PA_category <- sub(pattern = "Área de Proteção Ambiental",
                                           replacement = "Environmental Protection Area",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Área de Relevante Interesse Ecológico",
                                           replacement = "Area of Relevant Ecological Interest",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Estação Ecológica",
                                           replacement = "Ecological Station",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Floresta",
                                           replacement = "Forest",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Monumento Natural",
                                           replacement = "Natural Monument",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Parque",
                                           replacement = "Park",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Refúgio de Vida Silvestre",
                                           replacement = "Wildlife Refuge",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Reserva Biológica",
                                           replacement = "Biological Reserve",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Reserva de Desenvolvimento Sustentável",
                                           replacement = "Sustainable Development Reserve",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Reserva Extrativista",
                                           replacement = "Extractive Reserve",
                                           raw.protectedAreas$PA_category)
raw.protectedAreas$PA_category <- sub(pattern = "Reserva Particular do Patrimônio Natural",
                                           replacement = "Private Reserve of Natural Heritage",
                                           raw.protectedAreas$PA_category)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# change object name for exportation
cln.pol.prtTe.brl.protectedAreas.mma <- raw.protectedAreas



# POST-TREATMENT OVERVIEW
# summary(cln.pol.prtTe.brl.protectedAreas.mma)    # no indication of fully missing row
# View(cln.pol.prtTe.brl.protectedAreas.mma)
# plot(cln.pol.prtTe.brl.protectedAreas.mma)





# EXPORT --------------------------------------------------------------------------------------------------------------------------------------------

# workspace export
save(cln.pol.prtTe.brl.protectedAreas.mma,
     file = file.path(
       DIR.CDR.DATA,
       "raw2clean/policy/protectedTerritory/brazil/protectedAreas_mma/output",
       "cln_pol_prtTe_brl_protectedAreas_mma.RData"
       )
     )


Sys.time() - start.time.script


# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------