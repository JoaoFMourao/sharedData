# > PROJECT INFO
# NAME: Bolsa Verde - Evaluate and Monitor the impact of Bolsa Verde
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
pkgs <- c("tidyverse","sf","parallel","future","future.apply",
          "tictoc","labelled","geobr","openxlsx")



groundhogLibraries(pkgs, date = "2023-09-30")

options(scipen = 999)

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------
### Loading data INCRA 28/04/2023 ###

aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20230428.Rdata'))

incra_0 <- get(aux.name)

rm(aux.name)

### Loading data INCRA 09/02/2024 ###
aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20240209.Rdata'))

incra_1<- get(aux.name)

rm(aux.name)

### Loading data INCRA 24/04/2024 ###
aux.name <- load(file.path(DIR.CPI.DATA, 
                           'propertyRights/assentamentos',
                           'cleanData/cln_prp_lndTe_brl_settlements_incra_20240424.Rdata'))

incra_2<- get(aux.name)

rm(aux.name)
# DATA ANALYSYS -----------------------------------------------------------------------------------------------------------------------------------------

incra_0 <- incra_0 %>%
    st_make_valid()

incra_1 <- incra_1 %>%
    st_make_valid()

incra_2 <- incra_2 %>%
    st_make_valid()

### 28/04/2023
cod_0 <- incra_0 %>%
    st_drop_geometry()%>%
    distinct(sipra_code)

freq_cod_0 <- incra_0 %>%
    group_by(sipra_code)%>%
    dplyr::summarise(freq = n()) %>%
    filter(freq>1)

dif_btw_ids_0<-incra_0 %>%
    st_drop_geometry() %>%
    group_by(sipra_code) %>%
    summarise_all(~length(unique(.))) %>%
    summarise_all(~sum(. > 1))

subcategory_0<-incra_0 %>%
    st_drop_geometry() %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())



### 24/04/2024
cod_1 <- incra_1 %>%
    st_drop_geometry()%>%
    distinct(sipra_code)

freq_cod_1 <- incra_1 %>%
    group_by(sipra_code)%>%
    dplyr::summarise(freq = n()) %>%
    filter(freq>1)

dif_btw_ids_1<-incra_1 %>%
    st_drop_geometry() %>%
    group_by(sipra_code) %>%
    summarise_all(~length(unique(.))) %>%
    summarise_all(~sum(. > 1))

subcategory_1<-incra_1 %>%
    st_drop_geometry() %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())


### 28/04/2023
cod_2 <- incra_2 %>%
    st_drop_geometry()%>%
    distinct(sipra_code)

freq_cod_2 <- incra_2 %>%
    group_by(sipra_code)%>%
    dplyr::summarise(freq = n()) %>%
    filter(freq>1)

dif_btw_ids_2<-incra_2 %>%
    st_drop_geometry() %>%
    group_by(sipra_code) %>%
    summarise_all(~length(unique(.))) %>%
    summarise_all(~sum(. > 1))

subcategory_2<-incra_2 %>%
    st_drop_geometry() %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())


# COMPARING DATA  -----------------------------------------------------------------------------------------------------------------------------------------

## 28/04/2023 x 09/02/2024

# Exclusive Codes 28/04/23
cods_exc_0 <-anti_join(cod_0, cod_1, by = 'sipra_code')
qnt_subcat_exc_0 <- incra_0 %>%
    filter(sipra_code %in% cods_exc_0$sipra_code) %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())


# Exclusive Codes 09/02/24
cods_exc_1 <-anti_join(cod_1, cod_0, by = 'sipra_code')
qnt_subcat_exc_1 <- incra_1 %>%
    filter(sipra_code %in% cods_exc_1$sipra_code) %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())

# Exclusive Codes 24/04/24
cods_exc_2 <- incra_2 %>%
    filter(!(sipra_code %in% cod_0$sipra_code) & !(sipra_code %in% cod_1$sipra_code))%>%
    distinct(sipra_code)
    

qnt_subcat_exc_2 <- incra_2 %>%
    filter(sipra_code %in% cods_exc_2$sipra_code) %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())

# Exclusive subcategories 28/04/23
subcat_exc_0 <- subcategory_0 %>%
    filter(!(subcategory %in% subcategory_1$subcategory))

# Exclusive subcategories 09/02/2024
subcat_exc_1 <- subcategory_1 %>%
    filter(!(subcategory %in% subcategory_0$subcategory))

# DATA EXPORT --------------------------------------------------------------------------------------------------------------------------------------------------

prp_settlements_test_cods_exc_20230428 <- cods_exc_0

prp_settlements_test_cods_exc_20240209 <- cods_exc_1

prp_settlements_test_cods_exc_20240424 <-cods_exc_2



save(prp_settlements_test_cods_exc_20230428, 
     file = file.path(DIR.CPI.DATA, 'propertyRights/assentamentos',
                      'cleanData/crosschecks', 'prp_settlements_test_cods_exc_20230428.Rdata'))

save(prp_settlements_test_cods_exc_20240209, 
     file = file.path(DIR.CPI.DATA, 'propertyRights/assentamentos',
                      'cleanData/crosschecks', 'prp_settlements_test_cods_exc_20240209.Rdata'))

save(prp_settlements_test_cods_exc_20240424, 
     file = file.path(DIR.CPI.DATA, 'propertyRights/assentamentos',
                      'cleanData/crosschecks', 'prp_settlements_test_cods_exc_20240424.Rdata'))




