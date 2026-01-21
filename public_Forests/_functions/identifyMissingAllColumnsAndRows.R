
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO IDENTIFY FULL NA/NaN COLUMNS AND ROWS IN DATA FRAME
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -




# MISSING IDENTIFICATION -----------------------------------------------------------------------------------------------------------------------------

MissingAllColumnsAndRows <- function(dataframe) {
  
  # IDENTIFIES FULL NA/NaN COLUMNS AND ROWS IN DATA FRAME
  #
  # ARGS
  #   dataframe: non-spatial DataFrame object
  # 
  # RETURNS
  #   row names for rows having NA or NaN in all the columns
  #   column names for columns having NA or NaN in all the rows
  
  na.index     <- rowSums(is.na(dataframe)) == ncol(dataframe)
  missing.rows <- as.vector(row.names(dataframe)[na.index])
  cat("FULL NA/NaN ROWS: ", missing.rows, "\n")
  
  
  na.index     <- colSums(is.na(dataframe)) == nrow(dataframe)
  missing.cols <- as.vector(names(dataframe)[na.index])
  cat("FULL NA/NaN COLUMNS: ", missing.cols, "\n")
  
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------