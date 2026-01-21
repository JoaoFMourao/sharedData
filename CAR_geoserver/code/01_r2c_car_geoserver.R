# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - CAR
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: DOWNLOAD AND CLEAN CAR GEOMETRIES
# AUTHOR: MARCELO SESSIM
#
# > NOTES

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()


# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo

# SOURCES
source(file.path("_functions", "associateCRS.R"))

# LIBRARIES
pkgs <- c("tidyverse","sf", "rlang","future.apply", "furrr", "parallel", "tictoc","labelled")

groundhogLibraries(pkgs, date = "2023-09-30")

# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------
#states vector
states <- c(
  
  "am", "pa", "ac", "ro", "rr", "ap","to", #norte
  
  "ma", "ba","pb", "rn", "pi",  "pe", "al", "ce", "se", #nordeste
  
  "DF", "go", "ms","mt", #centroest
  
  "rj", "sp","mg","es", #sudeste
  
  "pr","rs","sc" # sul
  
  
)

#loop within all elements of state variable
date <- Sys.Date()
for (uf in states) {
  
  ##DOWNOAD LOOP FOR SHAPEFILES ####
  #(need to download csv files as well because date variable comes corrupted)
  
  # Define folder path
  folder_path_shape <- file.path("A:\\propertyRights\\CAR_Geoserver\\rawData\\shape",date, uf)
  
  # Create the directory if it doesn't exist
  if (!dir.exists(folder_path_shape)) {
    dir.create(folder_path_shape, recursive = TRUE)
  }
  
  # Function to generate the URL for each chunk
  generate_url <- function(base, start, max_feats) {
    sprintf("%s&maxFeatures=%d&startIndex=%d", base, max_feats, start)
  }
  
  # Base URL and parameters
  base_url <- paste0(
      "https://geoserver.car.gov.br/geoserver/sicar/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=sicar%3Asicar_imoveis_", 
      uf,
      "&outputFormat=SHAPE-ZIP")
  
  # Set the number of features to download per request
  max_features <- 5000
  start_index <- 0
  last_file_size <- 0
  consecutive_small_files <- 0
  
  # Download loop
  repeat {
    current_url <- generate_url(base_url, start_index, max_features)
    file_name <- file.path(folder_path_shape, paste0("data_chunk_", start_index, ".zip"))
    
    # Download with retry logic
    download_attempts <- 0
    max_attempts <- 3
    success <- FALSE
    
    while (!success && download_attempts < max_attempts) {
      tryCatch({
        download.file(current_url, destfile = file_name, mode = "wb")
        success <- TRUE  # If download is successful, set success to TRUE
      }, error = function(e) {
        download_attempts <- download_attempts + 1
        Sys.sleep(5)  # Wait for 5 seconds before retrying
      })
    }
    
    if (!success) {
      message("Failed to download after ", max_attempts, " attempts: ", current_url)
      break  # Exit the loop if download fails
    }
    
    current_file_size <- file.size(file_name)
    
    if (current_file_size < 5120 || current_file_size == last_file_size) {
      consecutive_small_files <- consecutive_small_files + 1
    } else {
      consecutive_small_files <- 0
    }
    
    if (consecutive_small_files >= 2) {
      break
    }
    
    last_file_size <- current_file_size
    start_index <- start_index + max_features
  }
  
  ##DOWNOAD LOOP FOR CSV FILES ####
  #(need to download csv files as well because date variable comes corrupted)
  
  # Define folder path
  folder_path_csv <- file.path("A:\\propertyRights\\CAR_Geoserver\\rawData\\csv",date, uf)
  
  # Create the directory if it doesn't exist
  if (!dir.exists(folder_path_csv)) {
    dir.create(folder_path_csv, recursive = TRUE)
  }
  
  # Function to generate the URL for each chunk
  generate_url <- function(base, start, max_feats) {
    sprintf("%s&maxFeatures=%d&startIndex=%d", base, max_feats, start)
  }
  
  # Base URL and parameters
  base_url <- paste0("https://geoserver.car.gov.br/geoserver/sicar/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=sicar%3Asicar_imoveis_", 
                     uf,
                     "&outputFormat=text/csv")  # Changed SHAPE-ZIP to text/csv
  
  # Set the number of features to download per request
  max_features <- 50000  # Adjust this number as needed for the new format
  start_index <- 0
  last_file_size <- 0
  consecutive_small_files <- 0
  
  # Download loop
  repeat {
    current_url <- generate_url(base_url, start_index, max_features)
    file_name <- file.path(folder_path_csv, paste0("data_chunk_", start_index, ".csv"))  # Changed file extension to .csv
    
    # Download with retry logic
    download_attempts <- 0
    max_attempts <- 3
    success <- FALSE
    
    while (!success && download_attempts < max_attempts) {
      tryCatch({
        download.file(current_url, destfile = file_name, mode = "wb")
        success <- TRUE  # If download is successful, set success to TRUE
      }, error = function(e) {
        download_attempts <- download_attempts + 1
        Sys.sleep(5)  # Wait for 5 seconds before retrying
      })
    }
    
    if (!success) {
      message("Failed to download after ", max_attempts, " attempts: ", current_url)
      break  # Exit the loop if download fails
    }
    
    current_file_size <- file.size(file_name)
    
    if (current_file_size < 5120 || current_file_size == last_file_size) {
      consecutive_small_files <- consecutive_small_files + 1
    } else {
      consecutive_small_files <- 0
    }
    
    if (consecutive_small_files >= 2) {
      break
    }
    
    last_file_size <- current_file_size
    start_index <- start_index + max_features
  }
  
}    
  # UNZIP AND LOAD FILES --------------------------------------------------------------------------

for (uf in states) {
  
  # list csv in folder
  aux.files <- as.list(
    list.files(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\rawData\\csv",
        date,
        uf
      ), 
      full.names = T)
  )
  
  
  # Loop over all zipped files
  car.aux <- list()
  
  # Use lapply to read each CSV file and store it in the list
  car.aux <- lapply(aux.files, function(f) {
    read.csv(f[[1]], stringsAsFactors = FALSE)
  })
  
  # Filter out the empty data frames (with 0 rows)
  car.aux <- Filter(nrow, car.aux)
  
  # Assuming car.sf is your list of sf data frames
  car.aux <- do.call(bind_rows, car.aux)
  
  car.aux <- car.aux %>% 
    select(-geo_area_imovel)
  
  # list shapefiles in folder
  aux.files <- as.list(
    list.files(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\rawData\\shape",
        date,
        uf
      ), 
      full.names = T)
  )
  
  # list shapefiles in folder
  aux.files2 <- list.files(
    file.path(
      "A:\\propertyRights\\CAR_Geoserver\\rawData\\shape",
      date,
      uf
    ), 
    full.names = F)
  
  
  # Loop over all zipped files
  car.sf <- list()
  
  for (i in 1:length(aux.files)){
    
    # Open connection with zip file
    temp <- tempfile()
    unzip(zipfile = aux.files[[i]], exdir = temp)  
    temp <- list.files(temp, pattern = ".shp$", full.names=TRUE)  
    
    # Read shapefile
    car.sf <- st_read(temp, options = "ENCODING=WINDOWS-1252") %>% 
      st_make_valid()
    
    
    if(nrow(car.sf)!=0){
      
      car.sf <- car.sf %>% 
        select(cod_imovel)
      
      car.sf <- left_join(car.sf,car.aux)
      
      
      # Define folder path
      folder_path_shape <- file.path("A:\\propertyRights\\CAR_Geoserver\\cleanData",date,
                                     uf)
      
      # Create the directory if it doesn't exist
      if (!dir.exists(folder_path_shape)) {
        dir.create(folder_path_shape, recursive = TRUE)
      }
      
      
      save(car.sf,
           file = file.path(
             "A:\\propertyRights\\CAR_Geoserver\\cleanData",date,
             uf,
             paste0("car_geoserver_",
                    uf,
                    "_",
                    aux.files2[i],
                    "_sf.Rdata"))
      )
      
    }
    
  }
  
}  
  
  
  




