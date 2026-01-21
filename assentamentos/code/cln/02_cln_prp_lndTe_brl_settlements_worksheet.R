# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RURAL SETTLEMENTS RAW DATA - WORKSHEET
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
pkgs <- c("data.table","labelled",  "sf", "tidyverse","stringr", 'openxlsx')

groundhogLibraries(
  pkgs,
  date = '2024-03-01'
)

reference.data <- "20250109"


check <- TRUE
# check <- FALSE

# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

path <- file.path(DIR.CPI.DATA, 
                   'propertyRights/assentamentos/rawData',reference.data)

files <- list.files(path, pattern = "\\.(xlsx|csv)$", full.names = TRUE)

view(files)


aux.settlements <- read_csv(files, 
                            locale = locale(encoding = "latin1"))

## There are versions in which the spreadsheet comes in xlsx and others in csv.
## If your object is xlsx, delete the “#” and run the code below:
# aux.settlements <- read.xlsx(files)

# DATA CLEANING ---------------------------------------------------------------------------------------------------------------------------------------
column_names <- c("sipra_code", "project_name", "muni_name", "area_ha",
                  "family_capacity", "family_settled", "stage_num",
                  "creation_type", "creation_number", "creation_date",
                  "obtention_method","obtention_date")


colnames(aux.settlements) <- column_names


treatAux <- function(auxDT) {
    
  
  # Filter out rows where 'cod_project' contains "Total"
  auxDT <- auxDT %>% 
    filter(str_detect(sipra_code,"Total")==FALSE)
  
  
  #conver latin charcaters
  auxDT <- ConvertLatinCharsbyChars(as.data.frame(auxDT)) %>%
    #adjust area_ha so we can convert it into numeric
    mutate(area_ha = area_ha %>% 
             str_replace_all("\\.", "") %>%
             str_replace_all(",", "\\.") %>%
             as.numeric(), 
             sipra_code = as.character(sipra_code),
             project_name = as.character(project_name),
             muni_name = as.character(muni_name),
             family_capacity = as.numeric(family_capacity),
             family_settled = as.numeric(family_settled),
             stage_num = as.character(stage_num),
             creation_type = as.character(creation_type),
             creation_number = as.numeric(creation_number),
             creation_date = as.Date(creation_date, format = "%Y-%m-%d"),
             obtention_method = as.character(obtention_method),
             obtention_date = as.Date(obtention_date, format = "%Y-%m-%d")
           )
  
  # Store the indices of rows with "SUPERINTENDÊNCIA" information
  # Given that the superintendence appears in a row but not as a variable
  indices <- grep("SUPERINTENDENCIA", auxDT$sipra_code)
  lista_dfs <- list()
  
  # Split the dataframe into smaller dataframes based on superintendence rows
  for (i in seq_along(indices)) {
    print(i)
    if (i < length(indices)) {
      df_temp <- auxDT[(indices[i]:(indices[i+1]-1)), ]
    } else {  
      df_temp <- auxDT[(indices[i]:nrow(auxDT)), ]
    }
    # Add the column "SR" and fill it with the value from the first row
    df_temp$SR <- df_temp$sipra_code[1]
    lista_dfs[[i]] <- df_temp
  }
  
  # Combine the smaller dataframes back into one dataframe
  auxDT = bind_rows(lista_dfs)
  
  # Filter out rows where 'cod_project' contains "Total" or "SUPERINTENDÊNCIA"
  auxDT <- auxDT %>% 
    filter(str_detect(sipra_code,"Total")==FALSE &
             str_detect(sipra_code,"SUPERINTENDENCIA")==FALSE & 
             str_detect(sipra_code,"00 - Em Obtencao")==FALSE)
  
  # Create categories for settlements
  auxDT <- auxDT %>%
    dplyr::mutate(project_name = toupper(project_name), # Convert 'name_project' to uppercase
                  project_name = gsub(pattern = "\\.", replacement = "", x = project_name), # Remove dots from 'name_project'
                  subcategory = gsub(" .*$", "", project_name)) %>% # Extract the first word as 'subcategory'
    dplyr::select(sipra_code, project_name, subcategory, everything()) # Select columns in the desired order
  
  cat <- auxDT %>%
    distinct(subcategory)
  
  focal_subcategory = c("PA", "RESEX", "RDS", "PAQ",
                        "PCA", "PAE", "PE", "RTRQ",
                        "PIC", "PDS", "TQ", "PFP",
                        "PRB", "PAM", "PAC", "PC",
                        "PAR", "PDAS", "PAD", "PAF",
                        "FLOE", "FLONA")
  
  
  
  auxDT <-auxDT %>%
    dplyr::mutate(subcategory = ifelse(subcategory %in% focal_subcategory, subcategory, NA)
    ) %>% # Extract the first word as 'subcategory'
    dplyr::select(sipra_code, project_name, subcategory, everything()) # Select columns in the desired order
  
  
  categories <- auxDT %>%
    st_drop_geometry() %>%
    group_by(subcategory) %>%
    dplyr::summarise(freq = n())
  
  
  # create settlements' categories full names (only 3 observation without identifiable category)
  aux.names.subcategories <- data.frame("subcategory" = c("PA", "RESEX", "RDS", "PAQ",
                                                          "PCA", "PAE", "PE", "RTRQ",
                                                          "PIC", "PDS", "TQ", "PFP",
                                                          "PRB", "PAM", "PAC", "PC",
                                                          "PAR", "PDAS", "PAD", "PAF",
                                                          "FLOE", "FLONA"),
                                        
                                        "subcategory_full" = c("PROJETO DE ASSENTAMENTO",
                                                               "RESERVA EXTRATIVISTA",
                                                               "RESERVA DE DESENVOLVIMENTO SUSTENTAVEL",
                                                               "PROJETO DE ASSENTAMENTO QUILOMBOLA",
                                                               "PROJETO DE ASSENTAMENTO CASULO",
                                                               "PROJETO DE ASSENTAMENTO AGROEXTRATIVISTA",
                                                               "PROJETO DE ASSENTAMENTO ESTADUAL",
                                                               "RECONHECIMENTO DE TERRITORIO QUILOMBOLA",
                                                               "PROJETO INTEGRADO DE COLONIZACAO",
                                                               "PROJETO DE DESENVOLVIMENTO SUSTENTAVEL",
                                                               "TERRITORIO QUILOMBOLA",
                                                               "PROJETO DE ASSENTAMENTO DE FUNDO DE PASTO",
                                                               "REASSENTAMENTO DE BARRAGEM",
                                                               "PROJETO DE ASSENTAMENTO MUNICIPAL",
                                                               "PROJETO DE ASSENTAMENTO CONJUNTO",
                                                               "PROJETO DE COLONIZACAO",
                                                               "PROJETO DE ASSENTAMENTO RAPIDO",
                                                               "PROJETO DESCENTRALIZADO DE ASSENTAMENTO SUSTENTAVEL",
                                                               "PROJETO DE ASSENTAMENTO DIRIGIDO",
                                                               "PROJETO DE ASSENTAMENTO FLORESTAL",
                                                               "FLORESTA ESTADUAL",
                                                               "FLORESTA NACIONAL")
  )
  
  
  # merge full names to subcategories
  auxDT <- left_join(
    auxDT, 
    aux.names.subcategories, 
    by = "subcategory"
  ) %>% 
    mutate(
      broad_subcategory = case_when(
        
        subcategory %in% c("PA","PE") ~  "Tradicional",
        
        subcategory %in% c("PAE","PDS","PAF") ~  "Diferenciado",
        
        TRUE ~  "Other"
      )
    )
  
  auxDT
  
}

aux.settlements <- treatAux(aux.settlements)

# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(aux.settlements,
     file = file.path(
       DIR.CPI.DATA, 
       'propertyRights/assentamentos/cleanData/worksheet',
       paste0("cln_set_worksheet_",reference.data,".RData")
     )
)

#compute time
end_time <- Sys.time()
print(end_time - strt.time)



# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
