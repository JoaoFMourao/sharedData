# > PROJECT INFO
# NAME: Settlements
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: COMPARING DATASETS
# AUTHOR: JULIA BRANDAO
#
# > NOTES:


## SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()


# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo


# SOURCES
source(file.path("_functions", "associateCRS.R"))

# LIBRARIES
pkgs <- c("sf","dplyr","data.table","labelled", "rgeos", "sf", "tidyverse",
          "data.table",  "plyr", "scales", "foreach", "viridis",
          "lfe", "fixest","stringr", 'readr', 'stringi')

groundhogLibraries(
  pkgs,
  date = '2024-03-01'
)

options(scipen = 999)

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
### Loading data INCRA 28/04/2023 ###

aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20230428.Rdata'))

incra_230428 <- get(aux.name)
rm(list = aux.name)
rm(aux.name)

### Loading data INCRA 09/02/2024 ###
aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20240209.Rdata'))

incra_240209<- get(aux.name)
rm(list = aux.name)
rm(aux.name)

### Loading data INCRA 24/04/2024 ###
aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20240424.Rdata'))

incra_240424<- get(aux.name)
rm(list = aux.name)
rm(aux.name)



aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20240923.Rdata'))

incra_20240923<- get(aux.name)
rm(list = aux.name)
rm(aux.name)

# load settlements' categories
aux.settlements_20230428 <-readxl::read_xlsx(file.path(DIR.CPI.DATA,
                                              'propertyRights/assentamentos/rawData/20230428', 
                                              "planilha_relacao_assentamentos.xlsx"))

aux.settlements_20240424 <-readxl::read_xlsx(file.path(DIR.CPI.DATA,
                                                       'propertyRights/assentamentos/rawData/20240424', 
                                                       "planilha_relacao_assentamentos.xlsx")
                                             )

aux.settlements_20240923 <- read_csv(file.path(DIR.CPI.DATA, 
                                               'propertyRights/assentamentos/rawData/20240923',
                                      "assentamentosgeral.csv"), 
                            locale = locale(encoding = "latin1"))


# DATA ANALYSYS -----------------------------------------------------------------------------------------------------------------------------------------
## EXCEL CLEANUP AND PREPARE FOR MERGE WITH BIOME #####

aux_versions <- ls(pattern = 'aux.settlements_')

convert_latin_chars <- function(df) {
  df <- df %>% mutate(across(everything(), ~stri_trans_general(.x, "Latin-ASCII")))
  return(df)
}

clean_aux <- function(i){
  aux.version <- get(aux_versions[i])
  
  column_names <- c("sipra_code", "name_project", "muni_nm", "area_ha",
                    "n_families_capacity", "n_families_settled", "phase",
                    "creation_type", "creation_number", "creation_date",
                    "obtention_type","obtention_date")
  
  
  colnames(aux.version) <- column_names
  
  # Filter out rows where 'cod_project' contains "Total"
  aux.version <- aux.version %>% 
    filter(str_detect(sipra_code,"Total")==FALSE)
  
  #conver latin charcaters
  aux.version <- convert_latin_chars(as.data.frame(aux.version)) 
  
  
  # Store the indices of rows with "SUPERINTENDÊNCIA" information
  # Given that the superintendence appears in a row but not as a variable
  indices <- grep("SUPERINTENDÊNCIA", aux.version$sipra_code)

  
  # Filter out rows where 'cod_project' contains "Total" or "SUPERINTENDÊNCIA"
  aux.version <- aux.version %>% 
    filter(str_detect(sipra_code,"Total")==FALSE &
             str_detect(sipra_code,"SUPERINTENDÊNCIA")==FALSE &
             str_detect(sipra_code,"Código do Projeto")==FALSE, 
             str_detect(sipra_code,"FASE")==FALSE, 
             str_detect(sipra_code,"Assentamento")==FALSE
           )
  
  # Create categories for settlements
  aux.version <- aux.version %>%
    dplyr::mutate(name_project = toupper(name_project), # Convert 'name_project' to uppercase
                  name_project = gsub(pattern = "\\.", replacement = "", x = name_project), # Remove dots from 'name_project'
                  subcategory = gsub(" .*$", "", name_project)) %>% # Extract the first word as 'subcategory'
    dplyr::select(sipra_code, name_project, subcategory, everything()) # Select columns in the desired order
  
  cat <- aux.version %>%
    distinct(subcategory)
  
  focal_subcategory = c("PA", "RESEX", "RDS", "PAQ",
                        "PCA", "PAE", "PE", "RTRQ",
                        "PIC", "PDS", "TQ", "PFP",
                        "PRB", "PAM", "PAC", "PC",
                        "PAR", "PDAS", "PAD", "PAF",
                        "FLOE", "FLONA")
  
  aux.version <-aux.version %>%
    dplyr::mutate(subcategory = ifelse(subcategory %in% focal_subcategory, subcategory, NA))
  
  aux.name <- aux_versions[i]
  
  assign(aux.name, aux.version, envir = .GlobalEnv)
}

lapply(1:length(aux_versions), clean_aux)

## Finding sipra_codes from diferent versions in the aux.settlements dataset #####
### Checking if there is a difference between the aux versions.####
check_aux <- function(i){

  aux_1 <- get(aux_versions[i])
  other_auxs <- aux_versions[-i]
  
  for (j in 1:length(other_auxs)){
  aux_2 <-get(other_auxs[j])
  
  dif <- aux_1 %>%
    filter(!(sipra_code %in% aux_2$sipra_code))
  
  aux.name <- paste('dif_', aux_versions[i], '_',other_auxs[j], sep = '')
  assign(aux.name, dif, envir = .GlobalEnv)
  }
 
}
lapply(1:length(aux_versions), check_aux)  


### Checking if there is a difference between the clean data versions.####
versions <- ls(pattern = 'incra_')

join_geos <- function(i) {
 
  dados <- get(versions[i])
  
  dados <- dados %>%
    mutate(area_ha = as.numeric(area_ha)) %>%
    group_by(sipra_code) %>%
    dplyr::summarise(geometry = st_union(geometry))  
  

  assign(versions[i], dados, envir = .GlobalEnv)
}
lapply(1:length(versions), join_geos) 



finding_exclusives <- function(i) {
  version <- get(versions[i])
  other_versions <- versions[-i]
  
  for (j in 1:length(other_versions)) {
    version_2 <- get(other_versions[j])
    
    dif <- version %>%
      filter(!(sipra_code %in% version_2$sipra_code))
    
    # Corrigir a criação do nome da variável
    aux.name <- paste('difbases_', versions[i], '_', other_versions[j], sep = '')
    
    assign(aux.name, dif, envir = .GlobalEnv)
  }
}

# Chamar a função para cada versão
lapply(1:length(versions), finding_exclusives)

  