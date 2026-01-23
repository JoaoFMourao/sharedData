
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO SPLIT LARGE RASTER INTO 8 PARTS (OCTANTS)
# AUTHOR: CLARISSA GANDOUR
#
# > NOTES
# 1: -




# RASTER SPLIT INTO OCTANTS ------------------------------------------------------------------------------------------------------------------------------

splitRasterOctants <- function(raster) {

  # SPLIT LARGE RASTER INTO 8 SMALLER PARTS (OCTANTS) - USEFUL TO AVOID MEMORY ISSUES
  #
  # ARGS
  #   raster: raster Object
  #
  # RETURNS
  #   list of containing 8 raster objects (octants of the original raster)

  # GEOMETRY CLEANUP [via 'cleangeo' package]
  require("raster")                                     # makes sure package is loaded into workspace


  # create empty list
  raster.octants <- list()


  # extract xmin, xmax, ymin, ymax from the raster extent
  xmin <- xmin(raster)
  xmax <- xmax(raster)
  ymin <- ymin(raster)
  ymax <- ymax(raster)


  # PART 1
  raster.octants[[1]] <- crop(raster,
                              extent(c(xmin + 0*(xmax - xmin)/4,
                                       xmin + 1*(xmax - xmin)/4,
                                       (ymax + ymin)/2,
                                       ymax)))
  # PART 2
  raster.octants[[2]] <- crop(raster,
                              extent(c(xmin + 1*(xmax - xmin)/4,
                                       xmin + 2*(xmax - xmin)/4,
                                       (ymax + ymin)/2,
                                       ymax)))

  # PART 3
  raster.octants[[3]] <- crop(raster,
                              extent(c(xmin + 2*(xmax - xmin)/4,
                                       xmin + 3*(xmax - xmin)/4,
                                       (ymax + ymin)/2,
                                       ymax)))

  # PART 4
  raster.octants[[4]] <- crop(raster,
                              extent(c(xmin + 3*(xmax - xmin)/4,
                                       xmin + 4*(xmax - xmin)/4,
                                       (ymax + ymin)/2,
                                       ymax)))

  # PART 5
  raster.octants[[5]] <- crop(raster,
                              extent(c(xmin + 0*(xmax - xmin)/4,
                                       xmin + 1*(xmax - xmin)/4,
                                       ymin,
                                       (ymax + ymin)/2)))


  # PART 6
  raster.octants[[6]] <- crop(raster,
                              extent(c(xmin + 1*(xmax - xmin)/4,
                                       xmin + 2*(xmax - xmin)/4,
                                       ymin,
                                       (ymax + ymin)/2)))

  # PART 7
  raster.octants[[7]] <- crop(raster,
                              extent(c(xmin + 2*(xmax - xmin)/4,
                                       xmin + 3*(xmax - xmin)/4,
                                       ymin,
                                       (ymax + ymin)/2)))

  # PART 8
  raster.octants[[8]] <- crop(raster,
                              extent(c(xmin + 3*(xmax - xmin)/4,
                                       xmin + 4*(xmax - xmin)/4,
                                       ymin,
                                       (ymax + ymin)/2)))


  return(raster.octants)
}





# END OF SCRIPT -------------------------------------------------------------------------------------------------------------------------------------