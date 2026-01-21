
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO SUBSTITUTE BRAZILIAN STATES FULL NAMES BY ITS ABBREVIATION
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -





# ABBREVIATION ---------------------------------------------------------------------------------------------------------------------------------------

AbbreviateStateNames <- function(state.column) {
  
  # SUBSTITUTES BRAZILIAN STATES FULL NAMES BY ITS ABBREVIATION
  #
  # ARGS
  #   state.column: column containing states full names  
  #
  # RETURNS
  #   column composed by states abbreviations
  
  if (class(state.column) != "character") {
    state.column <- as.character(state.column)
    print("ATTENTION: transformed column class to character!")
  }
  
  state.column <- toupper(state.column)
  
  state.column <- gsub(x           = state.column,
                       pattern     = "^ACRE$",
                       replacement = "AC")
  state.column <- gsub(x           = state.column,
                       pattern     = "^ALAGOAS$",
                       replacement = "AL")
  state.column <- gsub(x           = state.column,
                       pattern     = "^AMAPA$",
                       replacement = "AP")
  state.column <- gsub(x           = state.column,
                       pattern     = "^AMAZONAS$",
                       replacement = "AM")
  state.column <- gsub(x           = state.column,
                       pattern     = "^BAHIA$",
                       replacement = "BA")
  state.column <- gsub(x           = state.column,
                       pattern     = "^CEARA$",    
                       replacement = "CE")
  state.column <- gsub(x           = state.column,
                       pattern     = "^DISTRITO FEDERAL$",
                       replacement = "DF")
  state.column <- gsub(x           = state.column,
                       pattern     = "^ESPIRITO SANTO$",
                       replacement = "ES")
  state.column <- gsub(x           = state.column,
                       pattern     = "^GOIAS$",
                       replacement = "GO")
  state.column <- gsub(x           = state.column,
                       pattern     = "^MARANHAO$",
                       replacement = "MA")
  state.column <- gsub(x           = state.column,
                       pattern     = "^MATO GROSSO$",
                       replacement = "MT")
  state.column <- gsub(x           = state.column,
                       pattern     = "^MATO GROSSO DO SUL$",
                       replacement = "MS")
  state.column <- gsub(x           = state.column,
                       pattern     = "^MINAS GERAIS$",
                       replacement = "MG")
  state.column <- gsub(x           = state.column,
                       pattern     = "^PARA$",
                       replacement = "PA")
  state.column <- gsub(x           = state.column,
                       pattern     = "^PARAIBA$",
                       replacement = "PB")
  state.column <- gsub(x           = state.column,
                       pattern     = "^PARANA$",
                       replacement = "PR")
  state.column <- gsub(x           = state.column,
                       pattern     = "^PERNAMBUCO$",
                       replacement = "PE")
  state.column <- gsub(x           = state.column,
                       pattern     = "^PIAUI$",
                       replacement = "PI")
  state.column <- gsub(x           = state.column,
                       pattern     = "^RIO DE JANEIRO$",
                       replacement = "RJ")
  state.column <- gsub(x           = state.column,
                       pattern     = "^RIO GRANDE DO NORTE$",
                       replacement = "RN")
  state.column <- gsub(x           = state.column,
                       pattern     = "^RIO GRANDE DO SUL$",
                       replacement = "RS")
  state.column <- gsub(x           = state.column,
                       pattern     = "^RONDONIA$",
                       replacement = "RO")
  state.column <- gsub(x           = state.column,
                       pattern     = "^RORAIMA$",
                       replacement = "RR")
  state.column <- gsub(x           = state.column,
                       pattern     = "^SANTA CATARINA$",
                       replacement = "SC")
  state.column <- gsub(x           = state.column,
                       pattern     = "^SAO PAULO$",
                       replacement = "SP")
  state.column <- gsub(x           = state.column,
                       pattern     = "^SERGIPE$",
                       replacement = "SE")
  state.column <- gsub(x           = state.column,
                       pattern     = "^TOCANTINS$",
                       replacement = "TO")
  
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------