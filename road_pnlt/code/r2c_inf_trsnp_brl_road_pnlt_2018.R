
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
source("config.R")  # sets local dirs and sources config for shared data repo



# SOURCES
source("_functions/convertLatinCharacterSp.R")
source("_functions/convertLatinCharsbyCharsSp.R")



# LIBRARIES
# sp, rgdal, rgeos for spatial manipulation
# Hmisc            for dataframe labelling
CallLibraries(c("sp", "rgdal", "rgeos", "Hmisc", "tidyverse"))





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------


# SHAPEFILE INPUT
raw.road <- readOGR(dsn   = "H:/CLARISSA/CDR/raw2clean/infrastructure/transportation/brazil/road_pnlt/input/2018",
                        layer = "rodovias")


# DATA EXPLORATION [disabled for speed]
# summary(raw.road)    # yields CRS WGS84 LongLat (not projected); contains NAs
# View(raw.road@data)
# plot(raw.road)       # shows segment outside of Brazil country boundaries





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# names
colnames(raw.road@data)

raw.road@data <- 
  raw.road@data %>% 
  rename(object_id = OBJECTID) %>% 
  rename(road_id = id_trecho_) %>% 
  rename(road_name_type = nm_tipo_tr) %>% 
  rename(road_number = vl_br) %>% 
  rename(state_uf = sg_uf) %>% 
  rename(road_code = vl_codigo) %>%
  rename(originalColName_ds_local_i = ds_local_i) %>% 
  rename(originalColName_ds_local_f = ds_local_f) %>% 
  rename(road_km_initial = vl_km_inic) %>% 
  rename(road_km_final = vl_km_fina) %>% 
  rename(road_extension = vl_extensa) %>% 
  rename(road_fed_surface_type = ds_sup_fed) %>% 
  rename(road_work = ds_obra) %>% 
  rename(originalColName_ul = ul) %>% 
  rename(road_fed_code = ds_coinc) %>% 
  rename(road_admin = ds_tipo_ad) %>% 
  rename(road_legal_act = ds_ato_leg) %>% 
  rename(road_sta_code = est_coinc) %>% 
  rename(road_sta_surface_type = sup_est_co) %>% 
  rename(road_fed_categ = ds_jurisdi) %>% 
  rename(road_categ = ds_superfi) %>% 
  rename(road_surface_type = ds_legenda) %>% 
  rename(road_surface_type_abbrev = sg_legenda) %>% 
  rename(originalColName_versao_snv = versao_snv) %>% 
  rename(originalColName_id_versao = id_versao) %>% 
  rename(originalColName_marcador = marcador) %>% 
  rename(road_length_shape = Shape_Leng) %>% 
  rename(originalColName_leg_multim = leg_multim)



# LATIN CHARACTER TREATMENT
raw.road <- ConvertLatinCharacterSp(raw.road, FROM_enc = "UTF8", TO_enc = "ASCII//TRANSLIT")



# TRANSLATION

# define words to be translated
port.vector <- c("Acesso", "Anel", "Contorno", "Eixo Principal", "Travessia Urbana", "Variante", "Duplicada", "Implantada", "Leito Natural",
                 "Pavimentada", "Planejada", "Travessia", "Em obra de Duplicacao", "Em obra de Implantacao", "Em obra de Pavimentacao", 
                 "Concessao Estadual", "Concessao Federal", "Convenio de Administracao", "Distrital", "Estadual", "Municipal", "Federal",
                 "N_PAV", "Concessao Estadual; Estadual", "Convenio de Administracao; Concessao Estadual",
                 "Estadual; Concessao Estadual", "Estadual; Convenio de Administracao", "Federal; Estadual", "PAV", "N_PAV", "PLA")

# define translation (vectors must match exactly by position)
eng.vector <- c("access", "ring", "contour", "main axis", "urban crossing", "variant", "double lane", "implanted", "unpaved", "paved", "planned", 
                "waterway crossing", "ongoing lane doubling", "ongoing implantation", "ongoing paving", "state concession","federal concession", 
                "management agreement", "district", "state", "municipal", "federal","unpaved",
                "state concession; state", "management agreement; state concession", "state; state concession", "state; management agreement", 
                "federal; state", "paved", "unpaved", "planned")

# translate
raw.road@data <- as.data.frame(lapply(raw.road@data, plyr::mapvalues, port.vector, eng.vector))


# adjust columns class 
raw.road@data <- 
  raw.road@data %>% 
  mutate_if(.predicate = is.factor, .funs = as.character)


raw.road$road_id <- as.numeric(raw.road$road_id)
raw.road$object_id <- as.numeric(raw.road$object_id)
raw.road$road_number <- as.numeric(raw.road$road_number)
raw.road@data$road_extension <- as.numeric(raw.road@data$road_extension)
raw.road@data$road_km_initial <- as.numeric(raw.road@data$road_km_initial)
raw.road@data$road_km_final <- as.numeric(raw.road@data$road_km_final)
raw.road@data$road_length_shape <- as.numeric(raw.road@data$road_length_shape)



# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.road@data$road_id)                  <- "segment identifier"
label(raw.road@data$state_uf)                 <- "state name (abbreviation)"
label(raw.road@data$road_number)              <- "segment number"
label(raw.road@data$road_name_type)           <- "segment name type"
label(raw.road@data$road_code)                <- "segment code"
label(raw.road@data$road_categ)               <- "segment pavement category"
label(raw.road@data$road_fed_categ)           <- "federal segment pavement category"
label(raw.road@data$road_km_initial)          <- "segment beginning (km)"
label(raw.road@data$road_km_final)            <- "segment end (km)"
label(raw.road@data$road_extension)           <- "segment extension (km)"
label(raw.road@data$road_fed_surface_type)    <- "federal segment surface type"
label(raw.road@data$road_sta_surface_type)    <- "state segment surface type"
label(raw.road@data$road_surface_type)        <- "segment surface type"
label(raw.road@data$road_surface_type_abbrev) <- "segment surface type (abbreviation)"
label(raw.road@data$road_work)                <- "segment ongoing works"
label(raw.road@data$road_fed_code)            <- "federal segment code"
label(raw.road@data$road_sta_code)            <- "state segment code"
label(raw.road@data$road_admin)               <- "segment administration"
label(raw.road@data$road_legal_act)           <- "segment legal act"
label(raw.road@data$road_length_shape)        <- "segment length (shape)"


# change object name for exportation
cln.inf.trnsp.brl.road.pnlt.2018.sp <- raw.road



# POST-TREATMENT OVERVIEW
# summary(cln.inf.trnsp.brl.road.pnlt)
# View(cln.inf.trnsp.brl.road.pnlt@data)
# plot(cln.inf.trnsp.brl.road.pnlt)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.inf.trnsp.brl.road.pnlt.2018.sp,
     file = file.path("H:/CLARISSA/CDR/raw2clean/infrastructure/transportation/brazil/road_pnlt/output/2018", 
                      "cln_inf_trnsp_brl_road_pnlt_2018_sp.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------