
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO CONVERT LATIN CHARACTERS IN NON-SPATIAL OBJECTS
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





# LATIN CHARACTER CONVERSION -------------------------------------------------------------------------------------------------------------------------

ConvertLatinCharacter <- function(x, FROM_enc = "UTF-8", TO_enc = "ASCII//TRANSLIT") {

  # CONVERTS LATIN CHARACTERS IN NON-SPATIAL OBJECTS
  #
  # ARGS
  #   x:        non-spatial object containing string characters
  #   FROM_enc: object's current encoding
  #   TO_enc:   object's target encoding
  #
  # RETURNS
  #   object in which strings with special characters have been replaced by strings with non-special characters
  #
  # OBS
  #   use (utils::head(iconvlist(), n = 500)) for list of available encodings

  for (i in 1:ncol(x)) {
    if (is.factor(x[, i])) {
      if (is.character(levels(x[, i]))) {  # if string is factor, recovers special characters from character levels
	      x[, i] <- iconv(x[, i], from = FROM_enc, to = TO_enc)
	    }
      x[, i] <- as.factor(x[, i])  # restores factor class
	  }
	  else if (is.character(x[, i])) {
	    x[, i] <- iconv(x[, i], from = FROM_enc, to = TO_enc)
	  }
  }
  return(x)
}







# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------