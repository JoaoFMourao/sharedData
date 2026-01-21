
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO CONVERT LATIN CHARACTERS IN SPATIAL OBJECTS
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





ConvertLatinCharacterSp <- function(x, FROM_enc = "UTF-8", TO_enc = "ASCII//TRANSLIT") {

  # CONVERTS LATIN CHARACTERS IN SPATIAL OBJECTS
  #
  # ARGS
  #   x:        spatial object containing string characters
  #   FROM_enc: object's current encoding
  #   TO_enc:   object's target encoding
  #
  # RETURNS
  #   object in which strings with special characters have been replaced by strings with non-special characters
  #
  # OBS
  #   use (utils::head(iconvlist(), n = 500)) for list of available encodings

  for (i in 1:ncol(x@data)) {
    if (is.factor(x@data[, i])) {
	    if (is.character(levels(x@data[, i]))) {  # if string is factor, recovers special characters from character levels
	      x@data[, i] <- iconv(x@data[, i], from = FROM_enc, to = TO_enc)
	    }
      x@data[, i] <- as.factor(x@data[, i])  # restores factor class
    }
	  else if (is.character(x@data[, i])) {
	    x@data[, i] <- iconv(x@data[, i], from = FROM_enc, to = TO_enc)
	  }
  }
  return(x)
}



# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------