
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO ELIMINATE BLANK SPACE
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





# BLANK SPACES ---------------------------------------------------------------------------------------------------------------------------------------

TrimString <- function(string) {
  # REMOVES LEADING/TRAILING AND DUPLICATE BLANK SPACES IN CHARACTER STRING
  #
  # ARGS
  #   string: character string
  #
  # RETURNS
  #   edited character string
  
  output <- gsub(pattern = "^\\s+|\\s+$", replacement = "",  x = string)  # removes leading/trailing blank spaces
  output <- gsub(pattern = "\\s+",        replacement = " ", x = output)  # removes duplicate blank spaces
  
  return(output)
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------