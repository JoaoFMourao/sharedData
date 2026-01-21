
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD INPUT/OUTPUT FUNCTIONS FOR SPATIAL OBJECTS
# AUTHOR: BERNARD LUPIAC
#
# > EDIT DETAILS
# BY: CLARISSA GANDOUR
# ON: APR/04/17
#
# > NOTES
# 1: -





# INPUT ----------------------------------------------------------------------------------------------------------------------------------------------

ReadShape <- function(path = file.choose(), shp.encoding = NULL, convert.strings = F) {

  # READS SHAPEFILE FROM SPECIFIED FOLDER AND ASSIGNS ITS INFORMATION TO A SPATIAL OBJECT
  #
  # ARGS
  #   path:         string; shapefile path [if left empty, opens the file chooser by default]
  #   shp.encoding: string; shapefile encoding
  #   use_iconv:    logical; should be set to T if shp.encoding is different form default NULL
  #
  # RETURNS
  #   spatial object


  # required packages
  require("rgdal")


  # function objects
  fctn.shp.path <- path                                                            # assigns path containing shapefile


  # shapefile input
  if (length(layers <- ogrListLayers(fctn.shp.path)) == 1) {                       # if file directory contains only one layer:
    readOGR(dsn       = fctn.shp.path,                                             # reads it automatically
            layer     = layers[[1]],
            encoding  = shp.encoding,
            use_iconv = convert.strings)
  } else {                                                                         # if file directory contains multiple layers:
    print(layers)                                                                  # prompts user for layer selection
    fctn.layer <- readline("Select input layer from above. Copy without quotes.")

    readOGR(dsn       = fctn.shp.path,
            layer     = fctn.layer,
            encoding  = shp.encoding,
            use_iconv = convert.strings)
  }
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------