
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO SUBSTITUTE LATIN CHARACTERS IN DF
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





# LATIN CHARACTER CONVERSION -------------------------------------------------------------------------------------------------------------------------

ConvertLatinCharsbyChars <- function(x) {
  
  # SUBSTITUTES LATIN CHARACTERS
  #
  # ARGS
  #   x: data.frame containing latin characters
  #
  # RETURNS
  #   data.frame or data.table without special characters
  # OBS: checks only character columns
  
  if (sum(all(class(x) == "data.frame"))) {
    
    # treating column names
    names(x) <- gsub("À", "A", names(x))
    names(x) <- gsub("Á", "A", names(x))
    names(x) <- gsub("Ã", "A", names(x))
    names(x) <- gsub("Â", "A", names(x))
    names(x) <- gsub("È", "E", names(x))
    names(x) <- gsub("É", "E", names(x))
    names(x) <- gsub("Ê", "E", names(x))
    names(x) <- gsub("Ì", "I", names(x))
    names(x) <- gsub("Í", "I", names(x))
    names(x) <- gsub("Î", "I", names(x))
    names(x) <- gsub("Ò", "O", names(x))
    names(x) <- gsub("Ó", "O", names(x))
    names(x) <- gsub("Õ", "O", names(x))
    names(x) <- gsub("Ô", "O", names(x))
    names(x) <- gsub("Ù", "U", names(x))
    names(x) <- gsub("Ú", "U", names(x))
    names(x) <- gsub("Û", "U", names(x))
    names(x) <- gsub("Ç", "C", names(x)) 
    names(x) <- gsub("à", "a", names(x))
    names(x) <- gsub("á", "a", names(x))
    names(x) <- gsub("ã", "a", names(x))
    names(x) <- gsub("â", "a", names(x))
    names(x) <- gsub("è", "e", names(x))
    names(x) <- gsub("é", "e", names(x))
    names(x) <- gsub("ê", "e", names(x))
    names(x) <- gsub("ì", "i", names(x))
    names(x) <- gsub("í", "i", names(x))
    names(x) <- gsub("î", "i", names(x))
    names(x) <- gsub("ò", "o", names(x))
    names(x) <- gsub("ó", "o", names(x))
    names(x) <- gsub("õ", "o", names(x))
    names(x) <- gsub("ô", "o", names(x))
    names(x) <- gsub("ù", "u", names(x))
    names(x) <- gsub("ú", "u", names(x))
    names(x) <- gsub("û", "u", names(x))
    names(x) <- gsub("ç", "c", names(x))
    
    # treating observations column by column 
    for (i in 1:ncol(x)) {
      if (class(x[, i]) == "character"){
        
        x[, i] <- gsub("À", "A", x[, i])
        x[, i] <- gsub("Á", "A", x[, i])
        x[, i] <- gsub("Ã", "A", x[, i])
        x[, i] <- gsub("Â", "A", x[, i])
        x[, i] <- gsub("È", "E", x[, i])
        x[, i] <- gsub("É", "E", x[, i])
        x[, i] <- gsub("Ê", "E", x[, i])
        x[, i] <- gsub("Ì", "I", x[, i])
        x[, i] <- gsub("Í", "I", x[, i])
        x[, i] <- gsub("Î", "I", x[, i])
        x[, i] <- gsub("Ò", "O", x[, i])
        x[, i] <- gsub("Ó", "O", x[, i])
        x[, i] <- gsub("Õ", "O", x[, i])
        x[, i] <- gsub("Ô", "O", x[, i])
        x[, i] <- gsub("Ù", "U", x[, i])
        x[, i] <- gsub("Ú", "U", x[, i])
        x[, i] <- gsub("Û", "U", x[, i])
        x[, i] <- gsub("Ç", "C", x[, i]) 
        x[, i] <- gsub("à", "a", x[, i])
        x[, i] <- gsub("á", "a", x[, i])
        x[, i] <- gsub("ã", "a", x[, i])
        x[, i] <- gsub("â", "a", x[, i])
        x[, i] <- gsub("è", "e", x[, i])
        x[, i] <- gsub("é", "e", x[, i])
        x[, i] <- gsub("ê", "e", x[, i])
        x[, i] <- gsub("ì", "i", x[, i])
        x[, i] <- gsub("í", "i", x[, i])
        x[, i] <- gsub("î", "i", x[, i])
        x[, i] <- gsub("ò", "o", x[, i])
        x[, i] <- gsub("ó", "o", x[, i])
        x[, i] <- gsub("õ", "o", x[, i])
        x[, i] <- gsub("ô", "o", x[, i])
        x[, i] <- gsub("ù", "u", x[, i])
        x[, i] <- gsub("ú", "u", x[, i])
        x[, i] <- gsub("û", "u", x[, i])
        x[, i] <- gsub("ç", "c", x[, i])
      } else {
        
        print(paste0("ATTENTION: function did not aplly to column ", colnames(x)[i], " because its class was not 'character'!"))
      }
    }
    
  } else {
    
    stop("Function must be applied before coversion to data.table")
  }
  
  return(x)
  
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------