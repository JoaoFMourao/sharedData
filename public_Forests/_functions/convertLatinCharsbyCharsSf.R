
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO SUBSTITUTE LATIN CHARACTERS IN SF OBJECT
# AUTHOR: RAFAEL PUCCI
#
# > NOTES
# 1: -





# LATIN CHARACTER CONVERSION -------------------------------------------------------------------------------------------------------------------------

ConvertLatinCharsbyCharsSf <- function(x) {
  
  # SUBSTITUTES LATIN CHARACTERS
  #
  # ARGS
  #   x: data.frame containing latin characters
  #
  # RETURNS
  #   data.frame or data.table without special characters
  # OBS: checks only character columns
  
  if (length(class(x))>1 &
      class(x)[1] == "sf") {
    
    # treating column names
    colnames(x) <- gsub("À", "A", colnames(x))
    colnames(x) <- gsub("Á", "A", colnames(x))
    colnames(x) <- gsub("Ã", "A", colnames(x))
    colnames(x) <- gsub("Â", "A", colnames(x))
    colnames(x) <- gsub("È", "E", colnames(x))
    colnames(x) <- gsub("É", "E", colnames(x))
    colnames(x) <- gsub("Ê", "E", colnames(x))
    colnames(x) <- gsub("Ì", "I", colnames(x))
    colnames(x) <- gsub("Í", "I", colnames(x))
    colnames(x) <- gsub("Î", "I", colnames(x))
    colnames(x) <- gsub("Ò", "O", colnames(x))
    colnames(x) <- gsub("Ó", "O", colnames(x))
    colnames(x) <- gsub("Õ", "O", colnames(x))
    colnames(x) <- gsub("Ô", "O", colnames(x))
    colnames(x) <- gsub("Ù", "U", colnames(x))
    colnames(x) <- gsub("Ú", "U", colnames(x))
    colnames(x) <- gsub("Û", "U", colnames(x))
    colnames(x) <- gsub("Ç", "C", colnames(x)) 
    colnames(x) <- gsub("à", "a", colnames(x))
    colnames(x) <- gsub("á", "a", colnames(x))
    colnames(x) <- gsub("ã", "a", colnames(x))
    colnames(x) <- gsub("â", "a", colnames(x))
    colnames(x) <- gsub("è", "e", colnames(x))
    colnames(x) <- gsub("é", "e", colnames(x))
    colnames(x) <- gsub("ê", "e", colnames(x))
    colnames(x) <- gsub("ì", "i", colnames(x))
    colnames(x) <- gsub("í", "i", colnames(x))
    colnames(x) <- gsub("î", "i", colnames(x))
    colnames(x) <- gsub("ò", "o", colnames(x))
    colnames(x) <- gsub("ó", "o", colnames(x))
    colnames(x) <- gsub("õ", "o", colnames(x))
    colnames(x) <- gsub("ô", "o", colnames(x))
    colnames(x) <- gsub("ù", "u", colnames(x))
    colnames(x) <- gsub("ú", "u", colnames(x))
    colnames(x) <- gsub("û", "u", colnames(x))
    colnames(x) <- gsub("ç", "c", colnames(x))
    
    # treating observations column by column 
    for (i in colnames(x)[colnames(x)!="geometry"]) {
      print(i)
      
      if (unique(class(x[[i]]))[1] == "character"){
        
        x[[i]] <- gsub("À", "A", x[[i]])
        x[[i]] <- gsub("Á", "A", x[[i]])
        x[[i]] <- gsub("Ã", "A", x[[i]])
        x[[i]] <- gsub("Â", "A", x[[i]])
        x[[i]] <- gsub("È", "E", x[[i]])
        x[[i]] <- gsub("É", "E", x[[i]])
        x[[i]] <- gsub("Ê", "E", x[[i]])
        x[[i]] <- gsub("Ì", "I", x[[i]])
        x[[i]] <- gsub("Í", "I", x[[i]])
        x[[i]] <- gsub("Î", "I", x[[i]])
        x[[i]] <- gsub("Ò", "O", x[[i]])
        x[[i]] <- gsub("Ó", "O", x[[i]])
        x[[i]] <- gsub("Õ", "O", x[[i]])
        x[[i]] <- gsub("Ô", "O", x[[i]])
        x[[i]] <- gsub("Ù", "U", x[[i]])
        x[[i]] <- gsub("Ú", "U", x[[i]])
        x[[i]] <- gsub("Û", "U", x[[i]])
        x[[i]] <- gsub("Ç", "C", x[[i]]) 
        x[[i]] <- gsub("à", "a", x[[i]])
        x[[i]] <- gsub("á", "a", x[[i]])
        x[[i]] <- gsub("ã", "a", x[[i]])
        x[[i]] <- gsub("â", "a", x[[i]])
        x[[i]] <- gsub("è", "e", x[[i]])
        x[[i]] <- gsub("é", "e", x[[i]])
        x[[i]] <- gsub("ê", "e", x[[i]])
        x[[i]] <- gsub("ì", "i", x[[i]])
        x[[i]] <- gsub("í", "i", x[[i]])
        x[[i]] <- gsub("î", "i", x[[i]])
        x[[i]] <- gsub("ò", "o", x[[i]])
        x[[i]] <- gsub("ó", "o", x[[i]])
        x[[i]] <- gsub("õ", "o", x[[i]])
        x[[i]] <- gsub("ô", "o", x[[i]])
        x[[i]] <- gsub("ù", "u", x[[i]])
        x[[i]] <- gsub("ú", "u", x[[i]])
        x[[i]] <- gsub("û", "u", x[[i]])
        x[[i]] <- gsub("ç", "c", x[[i]])
      } else {
        
        print(paste0("ATTENTION: function did not aplly to column ", i, " because its class was not 'character'!"))
      }
    }
    
  } else {
    
    stop("Function must be applied sf object with a collum called geometry")
  }
  
  return(x)
  
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------