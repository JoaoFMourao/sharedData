
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - LAND TENURE
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: TREATS QUILOMBOLAS TERRITORIES RAW DATA
# AUTHOR: DIEGO MENEZES 
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sources config for shared data repo




# SOURCES




# sp, rgdal, rgeos for spatial manipulation
# Hmisc            for dataframe labelling
# data.table       for dataframe manipulation
CallLibraries(c("sp", "rgdal", "rgeos", "Hmisc", "data.table"))





# FUNCTIONS ------------------------------------------------------------------------------------------------------------------------------------------

ConvertLatinCharsbyCharsSp <- function(x) {  # for unknown reason, not working from repo
  
  # SUBSTITUTES LATIN CHARACTERS IN SPDF
  #
  # ARGS
  #   x: spatial data.frame containing latin characters
  #
  # RETURNS
  #   spatial data.frame without special characters
  # OBS: checks only character columns
  
  if (all(class(x@data) == "data.frame")) {
    
    # treating column names
    names(x@data) <- gsub("À", "A", names(x@data))
    names(x@data) <- gsub("Á", "A", names(x@data))
    names(x@data) <- gsub("Ã", "A", names(x@data))
    names(x@data) <- gsub("Â", "A", names(x@data))
    names(x@data) <- gsub("È", "E", names(x@data))
    names(x@data) <- gsub("É", "E", names(x@data))
    names(x@data) <- gsub("Ê", "E", names(x@data))
    names(x@data) <- gsub("Ì", "I", names(x@data))
    names(x@data) <- gsub("Í", "I", names(x@data))
    names(x@data) <- gsub("Î", "I", names(x@data))
    names(x@data) <- gsub("Ò", "O", names(x@data))
    names(x@data) <- gsub("Ó", "O", names(x@data))
    names(x@data) <- gsub("Õ", "O", names(x@data))
    names(x@data) <- gsub("Ô", "O", names(x@data))
    names(x@data) <- gsub("Ù", "U", names(x@data))
    names(x@data) <- gsub("Ú", "U", names(x@data))
    names(x@data) <- gsub("Û", "U", names(x@data))
    names(x@data) <- gsub("Ç", "C", names(x@data)) 
    names(x@data) <- gsub("à", "a", names(x@data))
    names(x@data) <- gsub("á", "a", names(x@data))
    names(x@data) <- gsub("ã", "a", names(x@data))
    names(x@data) <- gsub("â", "a", names(x@data))
    names(x@data) <- gsub("è", "e", names(x@data))
    names(x@data) <- gsub("é", "e", names(x@data))
    names(x@data) <- gsub("ê", "e", names(x@data))
    names(x@data) <- gsub("ì", "i", names(x@data))
    names(x@data) <- gsub("í", "i", names(x@data))
    names(x@data) <- gsub("î", "i", names(x@data))
    names(x@data) <- gsub("ò", "o", names(x@data))
    names(x@data) <- gsub("ó", "o", names(x@data))
    names(x@data) <- gsub("õ", "o", names(x@data))
    names(x@data) <- gsub("ô", "o", names(x@data))
    names(x@data) <- gsub("ù", "u", names(x@data))
    names(x@data) <- gsub("ú", "u", names(x@data))
    names(x@data) <- gsub("û", "u", names(x@data))
    names(x@data) <- gsub("ç", "c", names(x@data))
    
    # treating observations column by column 
    for (i in 1:ncol(x@data)) {
      if (class(x@data[, i]) == "character"){
        
        x@data[, i] <- gsub("À", "A", x@data[, i])
        x@data[, i] <- gsub("Á", "A", x@data[, i])
        x@data[, i] <- gsub("Ã", "A", x@data[, i])
        x@data[, i] <- gsub("Â", "A", x@data[, i])
        x@data[, i] <- gsub("È", "E", x@data[, i])
        x@data[, i] <- gsub("É", "E", x@data[, i])
        x@data[, i] <- gsub("Ê", "E", x@data[, i])
        x@data[, i] <- gsub("Ì", "I", x@data[, i])
        x@data[, i] <- gsub("Í", "I", x@data[, i])
        x@data[, i] <- gsub("Î", "I", x@data[, i])
        x@data[, i] <- gsub("Ò", "O", x@data[, i])
        x@data[, i] <- gsub("Ó", "O", x@data[, i])
        x@data[, i] <- gsub("Õ", "O", x@data[, i])
        x@data[, i] <- gsub("Ô", "O", x@data[, i])
        x@data[, i] <- gsub("Ù", "U", x@data[, i])
        x@data[, i] <- gsub("Ú", "U", x@data[, i])
        x@data[, i] <- gsub("Û", "U", x@data[, i])
        x@data[, i] <- gsub("Ç", "C", x@data[, i]) 
        x@data[, i] <- gsub("à", "a", x@data[, i])
        x@data[, i] <- gsub("á", "a", x@data[, i])
        x@data[, i] <- gsub("ã", "a", x@data[, i])
        x@data[, i] <- gsub("â", "a", x@data[, i])
        x@data[, i] <- gsub("è", "e", x@data[, i])
        x@data[, i] <- gsub("é", "e", x@data[, i])
        x@data[, i] <- gsub("ê", "e", x@data[, i])
        x@data[, i] <- gsub("ì", "i", x@data[, i])
        x@data[, i] <- gsub("í", "i", x@data[, i])
        x@data[, i] <- gsub("î", "i", x@data[, i])
        x@data[, i] <- gsub("ò", "o", x@data[, i])
        x@data[, i] <- gsub("ó", "o", x@data[, i])
        x@data[, i] <- gsub("õ", "o", x@data[, i])
        x@data[, i] <- gsub("ô", "o", x@data[, i])
        x@data[, i] <- gsub("ù", "u", x@data[, i])
        x@data[, i] <- gsub("ú", "u", x@data[, i])
        x@data[, i] <- gsub("û", "u", x@data[, i])
        x@data[, i] <- gsub("ç", "c", x@data[, i])
      } else {
        
        print(paste0("ATTENTION: function did not aplly to column ", colnames(x@data)[i], " because its class was not 'character'!"))
      }
    }
    
  } else {
    
    stop("Function must be applied before coversion to data.table")
  }
  
  return(x)
  
}





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# SHAPEFILE INPUT
quilombolas.BR <- readOGR(dsn   = file.path(DIR.CDR.DATA, "raw2clean/propertyRights/landTenure/brazil/quilombolas_incra/input"),
                          layer = "Áreas de Quilombolas", 
                          stringsAsFactors = F,
                          encoding = "UTF8", use_iconv = T) 





# DATASET CLEANUP ------------------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# changes column names
colnames(quilombolas.BR@data)
setnames(quilombolas.BR@data, "cd_quilomb", "code")
setnames(quilombolas.BR@data, "cd_sr"     , "jur_code")
setnames(quilombolas.BR@data, "nr_process", "process_num")
setnames(quilombolas.BR@data, "nm_comunid", "community_name")
setnames(quilombolas.BR@data, "nm_municip", "muni_name")
setnames(quilombolas.BR@data, "cd_uf"     , "state_uf")
setnames(quilombolas.BR@data, "dt_publica", "publication_date_1")
setnames(quilombolas.BR@data, "dt_public1", "publication_date_2")
setnames(quilombolas.BR@data, "nr_familia", "family_num")
setnames(quilombolas.BR@data, "dt_titulac", "title_date")
setnames(quilombolas.BR@data, "nr_area_ha", "shape_area_1")
setnames(quilombolas.BR@data, "nr_perimet", "shape_length_1")
setnames(quilombolas.BR@data, "cd_sipra"  , "sipra_code")
setnames(quilombolas.BR@data, "ob_descric", "polyg_description")
setnames(quilombolas.BR@data, "st_titulad", "d_title")
setnames(quilombolas.BR@data, "dt_decreto", "decree_date")
setnames(quilombolas.BR@data, "tp_levanta", "obtention_method")
setnames(quilombolas.BR@data, "nr_escalao", "scale_num")
setnames(quilombolas.BR@data, "area_calc_", "shape_area_2")
setnames(quilombolas.BR@data, "perimetro_", "shape_length_2")
setnames(quilombolas.BR@data, "esfera"    , "government")
setnames(quilombolas.BR@data, "fase"      , "stage")
setnames(quilombolas.BR@data, "responsave", "organization")



# checks column classes
lapply(quilombolas.BR@data, class) # every column already has its ideal class; no need to change




# ROW CLEANUP
# latin characters treatment
quilombolas.BR <- ConvertLatinCharsbyCharsSp(quilombolas.BR)



# typo fixes
# state_uf
quilombolas.BR@data$state_uf <- gsub(pattern = "^sp$", replacement = "SP", x = quilombolas.BR@data$state_uf)   


# government
quilombolas.BR@data$government <- gsub(pattern = "^Federal$" , replacement = "FEDERAL", x = quilombolas.BR@data$government)   
quilombolas.BR@data$government <- gsub(pattern = "^FEDERRAL$", replacement = "FEDERAL", x = quilombolas.BR@data$government)   
quilombolas.BR@data$government <- gsub(pattern = "^FEDEERAL$", replacement = "FEDERAL", x = quilombolas.BR@data$government)   


# organization
quilombolas.BR@data$organization <- gsub(pattern = "^Incra$" , replacement = "INCRA", x = quilombolas.BR@data$organization)   
quilombolas.BR@data$organization <- gsub(pattern = "^INCRTA$", replacement = "INCRA", x = quilombolas.BR@data$organization)   



# translation
# government
quilombolas.BR@data$government <- gsub(pattern = "^ESTADUAL$", replacement = "state"  , x = quilombolas.BR@data$government) 
quilombolas.BR@data$government <- gsub(pattern = "^FEDERAL$" , replacement = "federal", x = quilombolas.BR@data$government) 





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
label(quilombolas.BR@data$code)               <- "unknown"
label(quilombolas.BR@data$jur_code)           <- "regional superintendence code"
label(quilombolas.BR@data$process_num)        <- "process number"
label(quilombolas.BR@data$community_name)     <- "community name"
label(quilombolas.BR@data$muni_name)          <- "municipality name"
label(quilombolas.BR@data$state_uf)           <- "state name abbreviation"
label(quilombolas.BR@data$publication_date_1) <- "publication date of a certain stage of the process"
label(quilombolas.BR@data$publication_date_2) <- "publication date of a certain stage of the process"
label(quilombolas.BR@data$family_num)         <- "number of families installed"
label(quilombolas.BR@data$title_date)         <- "date of title concession (when the registry is done or the decree is published)"
label(quilombolas.BR@data$shape_area_1)       <- "shape area (ha; INCRA)"
label(quilombolas.BR@data$shape_length_1)     <- "shape length (unknown measure; INCRA)"
label(quilombolas.BR@data$sipra_code)         <- "sipra code (Sistema de Informações de Projetos de Reforma Agrária)"
label(quilombolas.BR@data$polyg_description)  <- "polygon description"
label(quilombolas.BR@data$d_title)            <- "whether the land has or has not received the title of quilombola land"
label(quilombolas.BR@data$decree_date)        <- "decree date"
label(quilombolas.BR@data$obtention_method)   <- "which technology was used to obtain the quilombola land georeference"
label(quilombolas.BR@data$scale_num)          <- "unknown"
label(quilombolas.BR@data$shape_area_2)       <- "shape area (unknown measure; INCRA)"
label(quilombolas.BR@data$shape_length_2)     <- "shape length (unknown measure; INCRA)"
label(quilombolas.BR@data$government)         <- "gorvernment level responsible"
label(quilombolas.BR@data$stage)              <- "registry stage"
label(quilombolas.BR@data$organization)       <- "organization responsible"




# CHANGE FINAL OBJECT NAME
cln.prp.lndTe.brl.quilombolas.incra <- quilombolas.BR
rm(quilombolas.BR)




# POST-TREATMENT OVERVIEW
# summary(cln.prp.lndTe.brl.quilombolas.incra@data)
# View(cln.prp.lndTe.brl.quilombolas.incra@data)





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(cln.prp.lndTe.brl.quilombolas.incra,
     file = file.path(DIR.CDR.DATA, "raw2clean/propertyRights/landTenure/brazil/quilombolas_incra/output", 
                      "cln_prp_lndTe_brl_quilombolas_incra.Rdata"))





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
