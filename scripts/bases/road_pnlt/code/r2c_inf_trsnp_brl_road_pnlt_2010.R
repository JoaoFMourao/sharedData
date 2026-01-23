
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - BRAZILIAN ROAD NETWORK
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT RAW DATA
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source(file.path(Sys.getenv("HOMEPATH"), "__code_config_local", "config_data_repo_user.R"))  # sets local dirs and sources config for shared data repo



# SOURCES
source("_functions/convertLatinCharacterSp.R")



# LIBRARIES
# sp, rgdal, rgeos for spatial manipulation
# Hmisc            for dataframe labelling
CallLibraries(c("sp", "rgdal", "rgeos", "Hmisc"))





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
raw.road <- readOGR(dsn = "H:/CLARISSA/CDR/raw2clean/infrastructure/transportation/brazil/road_pnlt/input/2010", 
                          layer = "Rodovias_Segmentos_Homogeneos")



# DATA EXPLORATION [disabled for speed]
# summary(raw.road)    # yields CRS WGS84 LongLat (not projected); contains NAs
# View(raw.road@data)
# plot(raw.road)       # shows segment outside of Brazil country boundaries





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# names
colnames(raw.road@data)

names(raw.road)[which(names(raw.road) == "FID")]     <- "road_id"
names(raw.road)[which(names(raw.road) == "KMI")]     <- "road_km_initial"
names(raw.road)[which(names(raw.road) == "KMF")]     <- "road_km_final"
names(raw.road)[which(names(raw.road) == "TipoPNV")] <- "road_surface_type"
names(raw.road)[which(names(raw.road) == "CODIGO")]  <- "road_code"


# class
lapply(raw.road@data, class)

raw.road$road_surface_type <- as.character(raw.road$road_surface_type)
raw.road$road_code <- as.character(raw.road$road_code)



# LATIN CHARACTER TREATMENT
raw.road <- ConvertLatinCharacterSp(raw.road, FROM_enc = "UTF8", TO_enc = "ASCII//TRANSLIT")



# TRANSLATION
unique(raw.road@data$road_surface_type)  # cross-check for encoding errors

# types that contain no latin characters
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Duplicada")]     <- "double lane"
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Implantada")]    <- "implanted"
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Leito Natural")] <- "unpaved"
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Pavimentada")]   <- "paved"
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Planejada")]     <- "planned"
raw.road@data$road_surface_type[which(raw.road@data$road_surface_type == "Travessia")]     <- "waterway crossing"

# types that contain latin characters
raw.road@data$road_surface_type[which(grepl(pattern = "Em obras de duplica", x = raw.road@data$road_surface_type))]   <- "ongoing lane doubling"
raw.road@data$road_surface_type[which(grepl(pattern = "Em obras de implanta", x = raw.road@data$road_surface_type))]  <- "ongoing implantation"
raw.road@data$road_surface_type[which(grepl(pattern = "Em obras de pavimenta", x = raw.road@data$road_surface_type))] <- "ongoing paving"





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.road@data$road_id)           <- "segment identifier"
label(raw.road@data$road_km_initial)   <- "segment beginning (km)"
label(raw.road@data$road_km_final)     <- "segment end (km)"
label(raw.road@data$road_surface_type) <- "segment type"
label(raw.road@data$road_code)         <- "segment code"


# change object name for exportation
cln.inf.trnsp.brl.road.pnlt.2010.sp <- raw.road



# POST-TREATMENT OVERVIEW
# summary(raw.road)
# View(raw.road@data)
# plot(raw.road)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.inf.trnsp.brl.road.pnlt.2010.sp,
     file = file.path("H:/CLARISSA/CDR/raw2clean/infrastructure/transportation/brazil/road_pnlt/output/2010", 
                      "cln_inf_trnsp_brl_road_pnlt_2010_sp.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------