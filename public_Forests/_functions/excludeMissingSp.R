
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
# 
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO EXCLUDE ROWS AND/OR COLUMNS WITH MISSING DATA ENTRIES IN SPATIAL 
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -





ExcludeMissingSp <- function(x, margin = 1) {

  # REMOVES NAs IN sp DataFrame OBJECT
  #
  # ARGS
  #   x:      sp spatial DataFrame object
  #   margin: remove rows (1) or columns (2) 
  # 
  # RETURNS
  #   spatial object with excluded rows/columns

  if (!inherits(x, "SpatialPointsDataFrame") & !inherits(x, "SpatialPolygonsDataFrame")) {
    stop("MUST BE sp SpatialPointsDataFrame OR SpatialPolygonsDataFrame CLASS OBJECT")  # returns error if object not spatial
  }

  na.index <- unique(as.data.frame(which(is.na(x@data), arr.ind = TRUE))[, margin])  # records margin index of NA occurrence

  if(margin == 1) {
    cat("DELETING ROWS: ", na.index, "\n")
	return(x[-na.index, ])  # excludes rows indexed by margin index
  }

  if(margin == 2) {
    cat("DELETING COLUMNS: ", na.index, "\n")
	return(x[, -na.index])  # excludes columns indexed by margin index
  }
}







# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------