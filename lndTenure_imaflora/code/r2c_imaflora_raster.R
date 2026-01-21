# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE (IMAFLORA)
# LEAD: JOÃO MOURÃO
#
# > THIS SCRIPT
# AIM: transform 2025's imaflora landTenure from raster to polygon and save per muni
# AUTHOR: SERGIO PIMENTEL

# > NOTES
# 1: - 2055.75 sec elapsed


# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

rm(list = ls())
gc()

str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo

# SOURCES
source("_functions/convert_sf_geom_to_raw.R")
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "convertUnits.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "themeCPIforGraphics.R"))
source(file.path("_functions","prevalent_values.R"))

# LIBRARIES
pkgs <- c(
  "tidyverse", "sf", "rlang", "future.apply", "furrr", "foreach", "doParallel",
  "sp", "parallel", "tictoc", "labelled", "geobr", "DBI", "duckdb", "duckplyr", 
  "arrow", "glue", "logger", "readxl", "raster", "terra", "stars", "tibble"
)
groundhogLibraries(pkgs, date = "2025-01-26")

logfile_path_output <- file.path(
  DIR.CPI.DATA,
  "propertyRights", 
  "lndTenure_imaflora", 
  "cleanData",
  "2025", 
  "_log.txt"
)

dir.create(dirname(logfile_path_output), recursive = TRUE, showWarnings = FALSE)
# Reading the Raster ----------------------------------------------------------------------
aux.name <- load("A:\\territory\\municipalities\\cleanData\\2022\\01_cln_trt_muni_no_overlap_ibge_2022_sf.Rdata")
muni_ibge <- get(aux.name)

# Tible raster id dict
df <- tribble(
  ~classe,                                                      ~id_sem_car, ~id_com_car, ~cor_hexacode,
  "Terras sob regime do SNUC (Domínio público, privado ou privado-coletivo)", NA,          NA,          "03401A",
  "Unidade de Conservação de Proteção Integral (UCPI)",          "21",        "2110",      "034732",
  "Unidade de Conservação de Uso Sustentável (UCUS)",             "22",        "2210",      "008148",
  "Unidade de Conservação APA (UCUS-APA)",                        "23",        "2310",      "B2DF8A",
  "Sobreposição entre terras sob regime do SNUC",                "29",        "2910",      "D3DF8A",
  "Terras Públicas",                                              NA,          NA,          "602D21",
  "Terra Indígena Declarada",                                      "10",        "1010",      "DBBD09",
  "Terra Indígena Não Declarada",                                  "11",        "1110",      "FEEB72",
  "Gleba Pública",                                                 "12",        "1210",      "7F3822",
  "Área Militar",                                                  "13",        "1310",      "F27070",
  "Sobreposição entre terras públicas",                           "19",        "1910",      "F1B585",
  "Terras Privadas (Domínio Individual ou Coletivo)",              NA,          NA,          "A40000",
  "Imóvel Rural Privado",                                          "61",        "6110",      "6A3D9A",
  "Território quilombola",                                         "62",        "6210",      "FF7F11",
  "Assentamento",                                                  "63",        "6310",      "EF2917",
  "Sobreposição entre terras privadas",                           "69",        "6910",      "EE9ACF",
  "Zonas de sobreposição entre domínios",                           NA,          NA,          "A7A5AA",
  "Terras Públicas/ Terras sob regime do SNUC",                     NA,          NA,          "37401A",
  "Terra Indígena Declarada/UCPI",                                  "31",        "3110",      "9FBC09",
  "Terra Indígena Declarada/UCUS",                                  "32",        "3210",      "B4BC09",
  "Terra Indígena Não Declarada/UCPI",                              "33",        "3310",      "D6C618",
  "Terra Indígena Não Declarada/UCUS",                              "34",        "3410",      "D6D80E",
  "Terra Indígena Declarada /UCUSAPA",                              "35",        "3510",      "F5EC22",
  "Terra Indígena Não Declarada /UCUSAPA",                          "36",        "3610",      "F5F66B",
  "Outras sobreposições entre terras públicas e terras sob regime do SNUC", "39",  "3910",      "64713B",
  "Terras Públicas/Terras Privadas",                              NA,          NA,          "540000",
  "Terra Indígena Declarada/Imóvel Rural Privado",                  "71",        "7110",      "813D9A",
  "Terra Indígena Não Declarada/Imóvel Rural Privado",              "72",        "7210",      "A63D9A",
  "Terra Indígena Declarada/Assentamento",                          "73",        "7310",      "EE5235",
  "Terra Indígena Não Declarada/Assentamento",                      "74",        "7410",      "EE7E42",
  "Outras sobreposições entre terras públicas e terras privadas",    "79",        "7910",      "A22432",
  "Terras sob regime do SNUC/Terras Privadas",                      NA,          NA,          "032F38",
  "UCPI/Imóvel Rural Privado",                                      "81",        "8110",      "034732",
  "UCUS/Imóvel Rural Privado",                                      "82",        "8210",      "03405D",
  "UCPI/Assentamento",                                              "83",        "8310",      "5B4100",
  "UCUS/Assentamento",                                              "84",        "8410",      "5B5D0F",
  "UCPI/Território Quilombola",                                     "85",        "8510",      "D27F11",
  "UCUS/Território Quilombola",                                     "86",        "8610",      "BE7F11",
  "UCUSAPA/Assentamento",                                             "87",        "8710",      "5B8931",
  "UCUSAPA/Imóvel Rural Privado",                                     "88",        "8810",      "6A5179",
  "Outras sobreposições entre terras sob regime do SNUC e terras privadas", "89",  "8910",      "025B6C",
  "Terras sob regime do SNUC/Terras Privadas/Terras Públicas",       NA,          NA,          "002800",
  "Outras sobreposições entre terras sob regime do SNUC, privadas e públicas", "99", "9910",    "9D9D9C",
  "Áreas urbanas",                                                  "41",        "4110",      "494949",
  "Massas d'água",                                                  "51",        "5110",      "41BBD9",
  "Áreas Sem Registro Fundiário Georreferenciado",                  "101",       "10110",     "E5E5E5"
)
# Reshape df so that id_sem_car and id_com_car become one column:
df_long <- df %>%
  pivot_longer(
    cols = c(id_sem_car, id_com_car),
    names_to = "car_type",
    values_to = "raster_id"
  ) %>%
  filter(!is.na(raster_id))  # remove rows where the id is NA


municipalities <- unique(muni_ibge$muni_code)
cl <- makeCluster(detectCores() - 15)
registerDoParallel(cl)
tic()
foreach(
  muni = municipalities, 
  .packages = c( "sf", 
                 "terra",
                 "foreach", 
                 "tidyverse",
                 "doParallel",
                 "rlang",
                 "glue",
                 "logger",
                 "arrow")
) %dopar% {
  
  logger::log_appender(logger::appender_file(logfile_path_output))
  logger::log_layout(logger::layout_glue)
  logger::log_threshold("ERROR")  # Set to capture only error
  
  tryCatch({
    # Loading the raster
    imaflora_raster_path <- "A:\\propertyRights\\lndTenure_imaflora\\rawData\\pa_br_malhafundiaria_raster_final.tif"
    
    r <- rast(imaflora_raster_path)
    
    # Subset the municipality polygon
    muni_sub <- muni_ibge %>% 
      filter(muni_code == muni) %>%
      st_transform(crs(r))
    
    muni_vect <- vect(muni_sub)
    # Crop the original raster to the municipality's extent and vectorize it
    r_cropped <- crop(r, muni_vect)
    gc()
    r_masked <- mask(r_cropped, muni_vect)

    p_local <- as.polygons(r_masked, na.rm = TRUE, dissolve = TRUE)
    gc()
    # Convert to an SF object and then convert the geometry to WKB Raw format
    new_crs <- sf::st_crs(AssociateCRS("Proj_SIRGAS2000polyconic"))
    # reproject the muni_sub 
    muni_sub <- muni_sub %>%
      st_transform(new_crs)
    
    # Convert p_local to sf object, reproject and intersection with muni_sub to clip to boundary
    # then transform the geometry to WKB Raw format to save as parquet
    p_sf_parquet <- convert_sf_geom_to_raw(st_as_sf(p_local) %>%
                                             st_transform(new_crs) %>%
                                             st_intersection(muni_sub))

    
    
    p_sf_parquet <- p_sf_parquet %>%
      rename(raster_id = pa_br_malhafundiaria_raster_final) %>%
      mutate(raster_id = as.character(raster_id)) %>%
      left_join(df_long, by = "raster_id") %>%
      mutate(muni_code = muni)
    
    # Define output file path
    output_file <- glue("A:\\propertyRights\\lndTenure_imaflora\\cleanData\\2025\\landTenure_2025_{muni}.parquet")
    # Save the data as a parquet file
    write_parquet(p_sf_parquet, output_file)
    
    # Clean up to free memory
    rm(r_cropped, r_masked, p_local, p_sf_parquet)
    gc()
    
  }, error = function(e) {
    # Log the error with relevant context
    logger::log_error("Error processing {muni}: {e$message}")
  })
}
toc()
stopCluster(cl)

