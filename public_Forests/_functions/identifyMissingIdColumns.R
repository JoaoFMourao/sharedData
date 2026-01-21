
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO IDENTIFY COLUMNS CONTAINING MISSING DATA IN DATA FRAME
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -




# MISSING IDENTIFICATION -----------------------------------------------------------------------------------------------------------------------------

MissingIdColumns <- function(dataframe) {
  
  # IDENTIFIES COLUMNS CONTAINING MISSING DATA IN DATA FRAME
  #
  # ARGS
  #   dataframe: non-spatial DataFrame object
  # 
  # RETURNS
  #   column name for columns with at least one NA
  
  colnames(dataframe)[unlist(lapply(dataframe, function(x) any(is.na(x))))]
  
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------