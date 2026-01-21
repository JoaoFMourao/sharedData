
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO SUBSTITUTE LATIN CHARACTERS IN SPDF
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





# LATIN CHARACTER CONVERSION -------------------------------------------------------------------------------------------------------------------------

ConvertLatinCharsbyCharsSp <- function(x) {
 
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





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------