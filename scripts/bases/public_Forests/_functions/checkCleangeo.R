
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO VERIFY AND FIX GEOMETRY PROBLEMS 
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -




# CONDITIONAL CLEANGEO ------------------------------------------------------------------------------------------------------------------------------

CheckCleangeo <- function(layer, cleangeo_strategy="BUFFER") {

  # VERIFIES GEOMETRY PROBLEMS AND FIXES IT IF NEEDED. (saves time in case it is not needed)
  # Strategy Default: "BUFFER", alternative option: "POLYGONATION"
  #
  # ARGS
  #   layer: Spatial Object
  #
  # RETURNS
  #   SpatialPolygon without geometry irregularities (if successful, otherwise, negative feedback is given)

  # GEOMETRY CLEANUP [via 'cleangeo' package]
  require("cleangeo")                                     # makes sure package is loaded into workspace



  # ERROR CHECKING
  # checks if it is projected
  if ((is.projected(layer) == FALSE) | is.na(proj4string(layer))) {  # outputs are different for the same object in case it is or not projected
    stop("*** Object needs to be projected before CondCleangeo")     #  (recheck needed!)
  }


  # invalid geometry check
  layer.report        <- clgeo_CollectionReport(layer)    # collects info regarding geometry problems
  test.diff <- length(layer.report$valid) - sum(layer.report$valid)
  if (test.diff == 0){
    message("No geometry irregularities found")
  }
  if (test.diff > 0) {
    # runs cleangeo function if necessary
    layer <- clgeo_Clean(layer, strategy = cleangeo_strategy)

    # checks if cleangeo was successful
    layer.report        <- clgeo_CollectionReport(layer)    # collects info regarding geometry problems
    test.diff <- length(layer.report$valid) - sum(layer.report$valid)
    if (test.diff == 0){
      message("Cleangeo fix successful: No geometry irregularities found")
    }
    if (test.diff > 0) {
      message("Cleangeo was not able to fix geometry")
    }
  }

  return(layer)
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------