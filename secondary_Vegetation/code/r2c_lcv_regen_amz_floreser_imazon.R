
# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - FLORESER [AMAZON REGENERATION]
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: UNIFY RAW DATA BY YEAR
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo



# SOURCES
# -



# LIBRARIES
CallLibraries(c("raster"))



# RASTER OPTIONS
rasterOptions(tmpdir = file.path(DIR.TEMP, "raster"),
              timer  = T)

tmpDir(create = T)





# DATA INPUT ----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
# input is done inside the loop





# DATASET PREP AND CLEANUP ---------------------------------------------------------------------------------------------------------------------------


# create vector of year
aux.years <- 1986:2019

for (y in seq_along(aux.years)) {

  # read all parts (12) of the year and merge them together
  raster <- do.call(raster::merge, lapply(list.files(file.path(DIR.CDR.DATA, "raw2clean/landCover/regeneration/amazonBiome/floreser_imazon/input"),
                                                    full.names = T,
                                                    pattern = paste0("Floreser_Biome_", aux.years[y])),
                                         raster))

  # save unified tif by year
  writeRaster(raster, paste0(DIR.CDR.DATA, "/raw2clean/landCover/regeneration/amazonBiome/floreser_imazon/output/cln_lcv_regen_amz_floreser_imazon_", aux.years[y], ".tif"))



  # CLEAN TEMP DIR
  # showTmpFiles()
  removeTmpFiles(h = 2)
  gc()

}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------