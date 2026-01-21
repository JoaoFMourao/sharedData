
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO TREAT SLIVERS THAT RESULT FROM TOPOLOGY OPERATIONS 
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -




# TREAT SLIVERS ------------------------------------------------------------------------------------------------------------------------------

TreatSlivers <- function(drop, threshold, scale=getScale(), warn = T) {
  
  # TREAT SLIVERS THAT RESULT FROM TOPOLOGY OPERATIONS
  # A sliver is a polygon that results from any topology operation (dissolve, intersect) which area is equal or greater than precision (= 1/scale)
  # and smaller than the determined polyThreshold.
  #
  #
  # ARGS
  #   drop:      Logical
  #   threshold: Numerical (> 1/scale)
  #   scale:     Numerical (> 0)
  #   warn:      Logical
  #
  # RETURNS
  #   Rgeos settings for handling slivers
  
  setScale(scale)                     # default: scale = 1e+09 ; smallest scale available in R-3.4: 1e+15
  set_RGEOS_polyThreshold(threshold)  # default: threshold = 0.0
  set_RGEOS_dropSlivers(drop)         # drops slivers if drop = TRUE
  set_RGEOS_warnSlivers(warn)         # prints a warning for every sliver encountered during topology operations if warn = TRUE
  # objects reported in warnings are dropped if drop = TRUE
  
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------