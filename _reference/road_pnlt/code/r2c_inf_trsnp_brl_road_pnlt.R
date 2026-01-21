
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
source("_functions/convertLatinCharacter.R")
source("_functions/convertLatinCharsbyChars.R")
source("_functions/prevalent_values.R")



# LIBRARIES
pkgs <- c("sf","tidyverse","plyr","Hmisc")

groundhogLibraries(pkgs, "2023-05-01")

last.date <- c("202304")


# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------



# SHAPEFILE INPUT
raw.road <- st_read(
  file.path(
  DIR.CDR.DATA,
  "raw2clean/infrastructure/transportation/brazil/road_pnlt/input",
  last.date
  ),
layer = "SNV_202304A" #adjust
  
)


# DATA EXPLORATION [disabled for speed]
# summary(raw.road)    # yields CRS WGS84 LongLat (not projected); contains NAs
# View(raw.road)
# plot(raw.road)       # shows segment outside of Brazil country boundaries





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# names
colnames(raw.road)

raw.road <- raw.road %>%
  dplyr::rename(
    road_id = id_trecho_,
    road_number = vl_br,
    state_uf = sg_uf,
    road_name_type = nm_tipo_tr,
    road_sg_type = sg_tipo_tr,
    desc_coinc = desc_coinc,
    road_code = vl_codigo,
    originalColName_ds_local_i = ds_local_i,
    originalColName_ds_local_f = ds_local_f,
    road_km_initial = vl_km_inic,
    road_km_final = vl_km_fina,
    road_extension = vl_extensa,
    road_fed_surface_type = ds_sup_fed,
    road_work = ds_obra,
    originalColName_ul = ul,
    road_fed_code = ds_coinc,
    road_admin = ds_tipo_ad,
    road_legal_act = ds_ato_leg,
    road_sta_code = est_coinc,
    road_sta_surface_type = sup_est_co,
    road_fed_categ = ds_jurisdi,
    road_categ = ds_superfi,
    road_surface_type = ds_legenda,
    road_surface_type_abbrev = sg_legenda,
    originalColName_versao_snv = versao_snv,
    originalColName_id_versao = id_versao,
    originalColName_marcador = marcador,
    originalColName_leg_multim = leg_multim
  )



# LATIN CHARACTER TREATMENT
raw.road <- ConvertLatinCharsbyCharsSf(raw.road)



# TRANSLATION

# # define words to be translated
# port.vector <- c("Acesso", "Anel", "Contorno", "Eixo Principal", "Travessia Urbana", "Variante", "Duplicada", "Implantada", "Leito Natural",
#                  "Pavimentada", "Planejada", "Travessia", "Em obra de Duplicacao", "Em obra de Implantacao", "Em obra de Pavimentacao", 
#                  "Concessao Estadual", "Concessao Federal", "Convenio de Administracao", "Distrital", "Estadual", "Municipal", "Federal",
#                  "N_PAV", "Concessao Estadual; Estadual", "Convenio de Administracao; Concessao Estadual",
#                  "Estadual; Concessao Estadual", "Estadual; Convenio de Administracao", "Federal; Estadual", "PAV", "N_PAV", "PLA")
# 
# # define translation (vectors must match exactly by position)
# eng.vector <- c("access", "ring", "contour", "main axis", "urban crossing", "variant", "double lane", "implanted", "unpaved", "paved", "planned", 
#                 "waterway crossing", "ongoing lane doubling", "ongoing implantation", "ongoing paving", "state concession","federal concession", 
#                 "management agreement", "district", "state", "municipal", "federal","unpaved",
#                 "state concession; state", "management agreement; state concession", "state; state concession", "state; management agreement", 
#                 "federal; state", "paved", "unpaved", "planned")
# 
# # translate

# adjust columns class 
raw.road <- 
  raw.road %>% 
  mutate_if(.predicate = is.factor, .funs = as.character)


raw.road$road_id <- as.numeric(raw.road$road_id)
raw.road$road_number <- as.numeric(raw.road$road_number)
raw.road$road_extension <- as.numeric(raw.road$road_extension)
raw.road$road_km_initial <- as.numeric(raw.road$road_km_initial)
raw.road$road_km_final <- as.numeric(raw.road$road_km_final)
raw.road$road_length_shape <- as.numeric(raw.road$road_length_shape)



# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(raw.road$road_id)                  <- "segment identifier"
label(raw.road$state_uf)                 <- "state name (abbreviation)"
label(raw.road$road_number)              <- "segment number"
label(raw.road$road_name_type)           <- "segment name type"
label(raw.road$road_code)                <- "segment code"
label(raw.road$road_categ)               <- "segment pavement category"
label(raw.road$road_fed_categ)           <- "federal segment pavement category"
label(raw.road$road_km_initial)          <- "segment beginning (km)"
label(raw.road$road_km_final)            <- "segment end (km)"
label(raw.road$road_extension)           <- "segment extension (km)"
label(raw.road$road_fed_surface_type)    <- "federal segment surface type"
label(raw.road$road_sta_surface_type)    <- "state segment surface type"
label(raw.road$road_surface_type)        <- "segment surface type"
label(raw.road$road_surface_type_abbrev) <- "segment surface type (abbreviation)"
label(raw.road$road_work)                <- "segment ongoing works"
label(raw.road$road_fed_code)            <- "federal segment code"
label(raw.road$road_sta_code)            <- "state segment code"
label(raw.road$road_admin)               <- "segment administration"
label(raw.road$road_legal_act)           <- "segment legal act"
label(raw.road$road_length_shape)        <- "segment length (shape)"


# change object name for exportation
cln.inf.trnsp.brl.road.pnlt.2018.sp <- raw.road



# POST-TREATMENT OVERVIEW
# summary(cln.inf.trnsp.brl.road.pnlt)
# View(cln.inf.trnsp.brl.road.pnlt)
# plot(cln.inf.trnsp.brl.road.pnlt)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.inf.trnsp.brl.road.pnlt.2018.sp,
     file = file.path("H:/CLARISSA/CDR/raw2clean/infrastructure/transportation/brazil/road_pnlt/output/202304", 
                      "cln_inf_trnsp_brl_road_pnlt_202304.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
