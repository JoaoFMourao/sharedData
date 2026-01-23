
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO IDENTIFY FULL NA/NaN COLUMNS AND ROWS IN sp DataFrame OBJECT
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -




# MISSING IDENTIFICATION -----------------------------------------------------------------------------------------------------------------------------

MissingAllColumnsAndRowsSp <- function(x) {
  
  # IDENTIFIES FULL NA/NaN COLUMNS AND ROWS IN sp DataFrame OBJECT
  #
  # ARGS
  #   x:      sp spatial DataFrame object
  # 
  # RETURNS
  #   row names for rows having NA or NaN in all the columns
  #   column names for columns having NA or NaN in all the rows
  
  na.index     <- rowSums(is.na(x@data)) == ncol(x@data)
  missing.rows <- as.vector(row.names(x@data)[na.index])
  cat("FULL NA/NaN ROWS: ", missing.rows, "\n")
  
  
  na.index     <- colSums(is.na(x@data)) == nrow(x@data)
  missing.cols <- as.vector(names(x@data)[na.index])
  cat("FULL NA/NaN COLUMNS: ", missing.cols, "\n")
  
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------