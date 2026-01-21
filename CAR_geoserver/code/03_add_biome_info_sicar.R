# > PROJECT INFO
# NAME: CAR A CAR (CAR-B)
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: cross SICAR data and biome boundaries to get the share of each biome each CAR occupies 
# AUTHOR: Rogério Reis
#
# > NOTES: 
# We are droppping the geometry in the end and putting everything in one single file 

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "convertUnits.R"))

# loading packages
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr", "readxl", "patchwork", "lwgeom")

groundhogLibraries(pkgs, "2023-09-30")

# Turns off scientific notation
options(scipen = 99) 

# import ---------------------------------------------------------------------------------------

## Load biomes for the last available year ##

biome = read_biomes(
  year= 2019,
  simplified = FALSE) 

# Adjust crs 
biome <- biome  %>% 
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% 
  
  st_make_valid() %>%
  
  st_buffer(0) %>% 
  
  filter(name_biome != "Sistema Costeiro")


# Getting file paths for CAR Data 
estado = c("ac", "al", "am", "ap",
           "ce", "df", "es", "go", 
           "ma", "ms", "mt", "pa",
           "pb", "pe", "pi", "pr",
           "rj", "rn", "ro", "rr", 
           "rs", "sc", "se", "sp", 
           "to", "ba", "mg"
)

  # Getting all the files 
  files_full <- estado %>%
    map(~file.path(DIR.CPI.DATA, 
                   "propertyRights",
                   "CAR_Geoserver",
                   "built_muni", 
                   "2023-11-08", .)) %>%
    map(~list.files(.x, full.names = TRUE)) %>%
      unlist() %>% as.vector() 
 
  #Getting the car muni list (only unique obs) and prodes muni list 
  municipality <- unique(str_extract(files_full, pattern = "\\d{7}"))
  
  # In case you stop the loading in the middle of the process 
  
  # # Getting files not yet loaded
  # files_loaded = estado %>%
  #     map(~file.path(DIR.CPI.DATA,
  #                    "propertyRights",
  #                    "CAR_Geoserver",
  #                    "built_muni",
  #                    "car_biome", .)) %>%
  #     map(~list.files(.x))
  # 
  # files_loaded = files_loaded %>% unlist() %>% as.vector()
  # 
  # #files that are in file_names (all files) but are not yet loaded
  # files_diff = setdiff(file_names, files_loaded)
  # 
  # municipality <- unique(str_extract(files_diff, pattern = "\\d{7}"))

  ### Running the crossing --------------------------------------------------------------
  
  car_crossing = function(municipality) {
    
    # Filter the CAR muni that match the municipality 
    car_files_muni <- files_full[grep(municipality, files_full)]
    
    #loading CAR and crossing with biomas (one crossing per muni) 
    car <- lapply(car_files_muni, function(file_path) {
        # Carregue o arquivo
        aux <- get(load(file_path))
        
    })
    
    #Putting all the chuncks together 
    car = bind_rows(car)
    
     # It is possible to have duplicates in the CAR file, so we kick them off before doing anything 
     car <- car %>% distinct(cod_imovel, FID, status_imovel, dat_criacao,
                              area, condicao, uf, municipio,
                              cod_municipio_ibge, m_fiscal,
                              tipo_imovel, area_car, muni_code,  .keep_all = TRUE)
      
      # Crossing
      car =  car %>% st_intersection(biome) %>%

        st_make_valid() %>%

        st_buffer(0)
      
      # Creating the area that each geometry takes in each biome 
      car = car %>% mutate(

        area_in_amazon = case_when(
        name_biome == "Amazônia" ~ as.numeric(st_area(car)),
        TRUE ~ 0),

        area_in_caatinga = case_when(
          name_biome == "Caatinga" ~ as.numeric(st_area(car)),
          TRUE ~ 0
        ),

        area_in_cerrado = case_when(
          name_biome == "Cerrado" ~ as.numeric(st_area(car)),
          TRUE ~ 0
        ),

        area_in_mata_atlantica = case_when(
          name_biome == "Mata Atlântica" ~ as.numeric(st_area(car)),
          TRUE ~ 0
        ),

        area_in_pampa = case_when(
          name_biome == "Pampa" ~ as.numeric(st_area(car)),
          TRUE ~ 0
        ),

        area_in_pantanal = case_when(
          name_biome == "Pantanal" ~ as.numeric(st_area(car)),
          TRUE ~ 0
        )
      )

      # Dropping geometry and creating the shares of each car in
      # in each biome 
      car = car %>% st_drop_geometry() %>%

          select(-c(name_biome, code_biome, year)) %>%

          group_by(cod_imovel, FID, status_imovel, dat_criacao,
                                       area, condicao, uf, municipio,
                                       cod_municipio_ibge, m_fiscal,
                                       tipo_imovel, area_car, muni_code) %>%

          summarize_all(sum) %>%

          mutate(share_in_amazon = (area_in_amazon/as.numeric(area_car))*100,
                 share_in_caatinga = (area_in_caatinga/as.numeric(area_car))*100,
                 share_in_cerrado = (area_in_cerrado/as.numeric(area_car))*100,
                 share_in_mata_atlantica = (area_in_mata_atlantica/as.numeric(area_car))*100,
                 share_in_pampa = (area_in_pampa/as.numeric(area_car))*100,
                 share_in_pantanal = (area_in_pantanal/as.numeric(area_car))*100
                 ) %>%

          select(-c(area_in_amazon,
                    area_in_caatinga,
                    area_in_cerrado,
                    area_in_mata_atlantica,
                    area_in_pampa,
                    area_in_pantanal))
      
      }
  
  plan(multisession, workers = detectCores()-3)
  res = future_lapply(municipality, car_crossing)
  
  #Putting all the files together 
  car = bind_rows(res) 
  
  # Saving
  save(car,
       file = file.path(
         DIR.CPI.DATA,
         "projects",
         "car_a_car",
         "data",
         "builtData",
         "df_car_temp_aux.Rdata"
       )
  )
  
  print(
    Sys.time() - str.time
  )
  
# END OF CODE ---------------------------------