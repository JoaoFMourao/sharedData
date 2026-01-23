
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREAT PUBLIC FORESTS (SFB) RAW DATA
# AUTHOR: (ADAPTED FROM) DIEGO MENEZES 
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sources config for shared data repo




# SOURCES
source("_functions/convertLatinCharsbyCharsSf.R", encoding = "UTF-8")
source("_functions/groundhogLibraries.R")


# LIBRARIES
# libraries
pkgs <- c("sf", "data.table", "Hmisc")
groundhogLibraries(pkgs, date = "2023-06-05")




# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
# data input inside processing because it's constructed in a loop format





# DATASET CLEANUP ------------------------------------------------------------------------------------------------------------------------------------

# AUXILIARY OBJECTS
# list of brazilian states
aux.states <- c("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT", 
                "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO")




# READ RAW DATA
for (i in seq_along(aux.states)) {

# read
 aux.sp <- st_read(dsn   = file.path(DIR.CDR.DATA, "raw2clean/propertyRights/landTenure/brazil/publicForests_sfb/input/2020"), 
                   layer = paste0("CNFP_2020_",aux.states[i])) 



# assign shapefile to an object
  assign(x     = paste0("publicForest.", tolower(aux.states[i])),
         value = aux.sp)



#clean environment
 rm(aux.sp)

}




# MERGE
# merge all auxiliary shapefiles
# we can use rbind here because all public forest spdf have the same number of columns 
publicForest.BR <- do.call(rbind, lapply(ls(pattern = "^publicForest.[a-z][a-z]$"), get))

rm(list = ls(pattern = "^publicForest.[a-z][a-z]$"))




# COLUMN CLEANUP
# changes column names
colnames(publicForest.BR)
setnames(publicForest.BR, "OBJECTID"   , "id")
setnames(publicForest.BR, "nome"       , "name")
setnames(publicForest.BR, "orgao"      , "organization")
setnames(publicForest.BR, "classe"     , "class")
setnames(publicForest.BR, "estagio"    , "stage")
setnames(publicForest.BR, "governo"    , "government")
setnames(publicForest.BR, "codigo"     , "code")
setnames(publicForest.BR, "ano"        , "year")
setnames(publicForest.BR, "uf"         , "state_uf")
setnames(publicForest.BR, "protecao"   , "protection")
setnames(publicForest.BR, "tipo"       , "type")
setnames(publicForest.BR, "comunitari" , "communitarian")
setnames(publicForest.BR, "atolegal"   , "legal_act")
setnames(publicForest.BR, "anocriacao" , "creation_year")
setnames(publicForest.BR, "categoria"  , "category")
setnames(publicForest.BR, "observacao" , "note")
setnames(publicForest.BR, "sobreposic" , "overlap")
setnames(publicForest.BR, "bioma"      , "biome")
setnames(publicForest.BR, "Shape_Leng" , "shape_length")
setnames(publicForest.BR, "Shape_Area" , "shape_area")
setnames(publicForest.BR, "area_ha"    , "area")




# checks column classes
lapply(publicForest.BR, class) # every column already has its ideal class; no need to change


# ROW CLEANUP
# latin characters treatment
publicForest.BR <- ConvertLatinCharsbyCharsSf(publicForest.BR)



# translation
# stage
summary(as.factor(publicForest.BR$stage))

publicForest.BR$stage <- gsub(pattern = "DELIMITACAO",   replacement = "delimitation",   x = publicForest.BR$stage)   
publicForest.BR$stage <- gsub(pattern = "DEMARCACAO",    replacement = "demarcation",    x = publicForest.BR$stage)   
publicForest.BR$stage <- gsub(pattern = "IDENTIFICACAO", replacement = "identification", x = publicForest.BR$stage)   


# protection 
summary(as.factor(publicForest.BR$protection))

publicForest.BR$protection <- gsub(pattern = "OUTROS USOS",       replacement = "other uses",      x = publicForest.BR$protection)
publicForest.BR$protection <- gsub(pattern = "PROTECAO INTEGRAL", replacement = "full protection", x = publicForest.BR$protection)
publicForest.BR$protection <- gsub(pattern = "SEM DESTINACAO",    replacement = "undesignated",    x = publicForest.BR$protection)
publicForest.BR$protection <- gsub(pattern = "USO MILITAR",       replacement = "military use",    x = publicForest.BR$protection)
publicForest.BR$protection <- gsub(pattern = "USO SUSTENTAVEL",   replacement = "sustainable use", x = publicForest.BR$protection)


# type
summary(as.factor(publicForest.BR$type))

publicForest.BR$type <- gsub(pattern = "TIPO A", replacement = "A", x = publicForest.BR$type)   
publicForest.BR$type <- gsub(pattern = "TIPO B", replacement = "B", x = publicForest.BR$type) 


# biome
summary(as.factor(publicForest.BR$biome))

publicForest.BR$biome <- gsub(pattern = "AMAZONIA",       replacement = "amazon",          x = publicForest.BR$biome)   
publicForest.BR$biome <- gsub(pattern = "CAATINGA",       replacement = "caatinga",        x = publicForest.BR$biome)   
publicForest.BR$biome <- gsub(pattern = "CERRADO",        replacement = "cerrado",         x = publicForest.BR$biome)   
publicForest.BR$biome <- gsub(pattern = "MATA ATLANTICA", replacement = "atlantic forest", x = publicForest.BR$biome)   
publicForest.BR$biome <- gsub(pattern = "PAMPA",          replacement = "pampa",           x = publicForest.BR$biome)   
publicForest.BR$biome <- gsub(pattern = "PANTANAL",       replacement = "pantanal",        x = publicForest.BR$biome)   


# government
summary(as.factor(publicForest.BR$government))

publicForest.BR$government <- gsub(pattern = "ESTADUAL",             replacement = "state",         x = publicForest.BR$government)
publicForest.BR$government <- gsub(pattern = "FEDERAL",              replacement = "federal",       x = publicForest.BR$government) 
publicForest.BR$government <- gsub(pattern = "MUNICIPAL",            replacement = "local",         x = publicForest.BR$government) 




# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(publicForest.BR$id)            <- "polygon identifier"
label(publicForest.BR$name)          <- "public forest full name"
label(publicForest.BR$organization)  <- "organization responsible"
label(publicForest.BR$class)         <- "class (SFB classification)"
label(publicForest.BR$stage)         <- "registry stage"
label(publicForest.BR$government)    <- "gorvernment level responsible"
label(publicForest.BR$code)          <- "identification code"
label(publicForest.BR$year)          <- "waiting for answers to complete label"  # /!\
label(publicForest.BR$state_uf)      <- "state name abbreviation"
label(publicForest.BR$protection)    <- "protection type"
label(publicForest.BR$type)          <- "public forest type"
label(publicForest.BR$communitarian) <- "whether it is communitarian or not"
label(publicForest.BR$legal_act)     <- "waiting for answers to complete label"  # /!\
label(publicForest.BR$creation_year) <- "year of creation"
label(publicForest.BR$category)      <- "public forest category (see 'siglas_categ' in documentation)"
label(publicForest.BR$note)          <- "notes"
label(publicForest.BR$overlap)       <- "whether it overlaps with another public forest or not"
label(publicForest.BR$biome)         <- "biome name"
label(publicForest.BR$shape_length)  <- "shape length (unknown measure; SFB)"
label(publicForest.BR$shape_area)    <- "shape area (unknown measure; SFB)"
label(publicForest.BR$area)          <- "shape area (ha; SFB)"



# CHANGE FINAL OBJECT NAME
cln.prp.lndTe.brl.publicForests.sfb.2020 <- publicForest.BR
rm(publicForest.BR)


cln.prp.lndTe.brl.publicForests.sfb.2020 <- cln.prp.lndTe.brl.publicForests.sfb.2020 %>% 
  rename(uf = state_uf)



# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.prp.lndTe.brl.publicForests.sfb.2020,
     file = file.path("A:/propertyRights/public_Forests/cleanData", 
                      "cln_prp_lndTe_brl_publicForests_sfb_2020_sf.Rdata"))

# 
# st_write(
#   cln.prp.lndTe.brl.publicForests.sfb.2020, file.path(DIR.CDR.DATA, "raw2clean/propertyRights/landTenure/brazil/publicForests_sfb/output/2020", 
#                                                             "cln_prp_lndTe_brl_publicForests_sfb_2020_sf_B.shp")
# )
# 

# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------



