
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE (IMAFLORA)
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA
# AUTHOR: RAFAEL PUCCI
#
# > NOTES
# 0: Edited by Sergio Pimentel to save as parquet aswell
# 1: it takes 5.77 minutes with computer 147
# 2: it takes 5.30 minutes with computer 151



# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source("_functions/convert_sf_geom_to_raw.R")
source(file.path("_functions", "associateCRS.R"))


# SOURCES
# -


# LIBRARIES
# sf for spatial input
# tidyverse for data.frame manipulations
# Hmisc     for dataframe labelling
# textclean for multiple gsub


pkgs <- c("sf", "tidyverse", "haven", 
          "Hmisc", "textclean",
          "foreach","doParallel", "arrow", "sfarrow", "stringr"
)


# Use the correct function and parameter names
groundhogLibraries(pkgs, date = "2024-04-23")





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

main.path <- file.path(
  DIR.CPI.DATA,
  "propertyRights/lndTenure_imaflora/rawData/")
print(main.path)

aux.layers <- list()
# paths to layers
for (i in c("centro_oeste", "nordeste", "norte", "sudeste", "sul")){
  
  aux <- data.frame("layer" = gsub(pattern = "\\.shp$", replacement = "", 
                                   list.files(path = file.path(main.path, i), pattern = "shp")))
  
  
  aux$dsn <- file.path(main.path, i)
  
  
  aux.layers[[paste0(i)]] <- aux
  
  rm(aux)
  
  
}



aux.layers <- do.call(rbind, aux.layers)


# SHAPEFILE INPUT ---------------->  we load data inside loop

# CLEAN ENVIRONMENT
rm(main.path)


# LOOP BY STATE ----------------------------------------------------------------------------------------------------------------

nCores <- detectCores() # number of cores
cl <- makeCluster(nCores - 14) 

#registerDoSNOW(cl) # activate cores

#n.cores <- 3
#cl <- makeCluster(n.cores)
registerDoParallel(cl)

foreach(
  i = seq(1:nrow(aux.layers)),
  
  .packages = c( "sf", "foreach", "tidyverse","doParallel", "textclean",
                 "haven", "Hmisc", "arrow", "stringr")
  
) %dopar% {
  
  # i <- 17 #para
  #i <- 20 #tocantins
  #i <- 4
  
  print(aux.layers[i, "dsn"])
  print(aux.layers[i, "layer"])
  
  # LOAD LAYER ------------------------------------------------------------------------------------------------------------------------------------------
  
  raw.tenure <- st_read(dsn = aux.layers[i, "dsn"], 
                        layer = aux.layers[i, "layer"])
  
  #pa
  
  
  # DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------- 
  
  # COLUMN CLEANUP
  # names
  colnames(raw.tenure)
  raw.tenure <- 
    raw.tenure %>% 
    rename(id = gid,
           muni_code = cd_mun,
           muni_code_contain = cd_mun_con,
           name_polygon = name,
           class = ownership_,
           subclass = sub_class,
           area_orig = area_origi,
           original_id = original_g,
           source = table_sour,
           
           # Areas lost/re-allocated to each category
           ag_area_loss = ag_area_lo,
           aru_area_loss = aru_area_l,
           carpo_area_loss = carpo_area,
           carpr_area_loss = carpr_area, 
           com_area_loss = com_area_l, 
           ml_area_loss = ml_area_lo,
           nd_b_area_loss = nd_b_area_,
           nd_i_area_loss = nd_i_area_,
           ql_area_loss = ql_area_lo,
           sigef_area_loss = sigef_area,
           ti_h_area_loss = ti_h_area_,
           ti_n_area_loss = ti_n_area_,
           tlpc_area_loss = tlpc_area_,
           tlpl_area_loss = tlpl_area_,
           trans_area_loss = trans_area,
           ucpi_area_loss = ucpi_area_,
           ucus_area_loss = ucus_area_,
           urb_area_loss = urb_area_l
           
    )
  
  # class
  raw.tenure <- 
    raw.tenure %>% 
    mutate_if(.predicate = is.factor, .funs = as.character)
  
  
  
  # TRANSLATION
  aux.subclass <- c("water" = "AG",
                    "militarArea" = "ML",
                    "ruralSettlement" ="ARU",
                    "CARpoor" = "CARpo",
                    "CARpremium" = "CARpr",
                    "nonDesignated" = "ND_B",
                    "SIGEF_public" = "ND_I",
                    "SIGEF_private" = "SIGEF",
                    "indigenousLandHomologated" = "TI_H",
                    "indigenousLandNotHomologated" = "TI_N",
                    "TerraLegalTitled" = "TLPL",
                    "TerraLegalNotTitled" = "TLPC",
                    "quilombola" = "QL",
                    "communityTerritory" = "COM",
                    "Transport" = "TRANS",
                    "protectedTerritoryFullProtection" = "UCPI",
                    "protectedTerritorySustainableUse" = "UCUS",
                    "urban" = "URB")
  new_crs <- st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))
  raw.tenure <- 
    raw.tenure %>% 
    mutate(class = mgsub(class,
                         pattern = c("PL", "PC", "NP"), 
                         replacement = c("private",
                                         "public",
                                         "not_processed")),
           subclass = mgsub(x = subclass, 
                            pattern = aux.subclass, 
                            replacement = names(aux.subclass))) %>%
    st_transform(new_crs)

  
  # ADD state_uf COLUMN --------------------------------------------------------------------------------------------------------------------------------
  
  # Extract the state abbreviation using regex
  state_uf <- str_extract(aux.layers[i, "layer"], "(?<=es_)[a-z]{2}(?=_landternure)")
  
  # Check if the extraction succeeded
  if (is.na(state_uf) || state_uf == "") {
    stop(paste("Failed to extract state_uf from layer name:", aux.layers[i, "layer"]))
  }
  
  # Ensure the extracted state_uf is in lowercase (if desired)
  state_uf <- tolower(state_uf)
  
  # Add the state_uf column to raw.tenure
  raw.tenure <- raw.tenure %>%
    mutate(state_uf = state_uf)
  
  
  
  # EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------
  
  # LABELS
  label(raw.tenure$id) <- "polygon identifier (rural property)"
  label(raw.tenure$original_id) <- "original polygon identifier (rural property) before cleaning process"
  label(raw.tenure$source) <- "data source"
  label(raw.tenure$class) <- "property ownership (private or public)"
  label(raw.tenure$subclass) <- "land tenure class"
  label(raw.tenure$area_orig) <- "original property size (sq meters)"
  label(raw.tenure$area) <- "final property size, after cleaning overlapping areas (sq meters)"
  label(raw.tenure$muni_code) <- "municipality code (IBGE, 7-digits)"
  label(raw.tenure$muni_code_contain) <- "municipality has IBGE code?"
  label(raw.tenure$name_polygon) <- "name of polygon (rural property)"
  label(raw.tenure$rast) <- "not described in metadata"
  
  for(j in aux.subclass){
    
    label(raw.tenure[[paste0(tolower(j), "_area_loss")]]) <- paste0("Area re-allocated to '", 
                                                                    names(aux.subclass[aux.subclass==j]), 
                                                                    "' after cleaning process")
    
  }
  
  
  
  
  # EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------
  
  # create final object
  return.object <- paste0("cln.prp.lndTe.brl.landTenure.imaflora.", 
                          substr(aux.layers[i, "layer"], start = 4, stop = 5),
                          ".sf")
  
  assign(x = return.object, 
         value = raw.tenure)
  
  
  # create filename
  return.file <- gsub(return.object, pattern = "\\.", replacement = "_")
  
  # SAVE!
  save(list = return.object,
       file = file.path(DIR.CPI.DATA, "propertyRights/lndTenure_imaflora/cleanData/2021/rdata", 
                        paste0(return.file, ".Rdata")))
  
  parquet_file_path <- file.path(DIR.CPI.DATA, "propertyRights/lndTenure_imaflora/cleanData/2021/parquet", 
                                 paste0(return.file, ".parquet"))
  assign(x = return.object, value = raw.tenure)
  temp_data <- get(return.object)
  temp_data <- convert_sf_geom_to_raw(temp_data)
  write_parquet(temp_data, parquet_file_path)
  #para shoudl have 234491 observations
  
  # CLEAN ENVIRONMENT
  rm(list = return.object)
  gc()
  
  
}

stopCluster(cl)


print(Sys.time() - str.time)


# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
