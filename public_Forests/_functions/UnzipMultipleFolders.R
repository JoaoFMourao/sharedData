
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD DATA SCRAPPING FUNCTIONS
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -





# DIRECTORY MANIPULATION -----------------------------------------------------------------------------------------------------------------------------

UnzipMultipleFolders <- function(fctn.zip.dir,
                                 fctn.zip.pattern  = ".zip",
                                 fctn.unzip.subdir = T) {

  # UNZIPS FOLDERS IN GIVEN DIRECTORY & SUBDIRECTORIES AND DELETES COMPRESSED FOLDERS
  #
  # ARGS
  #   fctn.zip.dir:      parent directory containing zip files
  #   fctn.zip.pattern:  zipped file extension
  #   fctn.unzip.subdir: if TRUE, looks for 'fctn.zip.pattern' subdirs in 'fctn.zip.dir' (but does not find nested compressed dirs - 'while' loop in >
  #                      function addresses this)
  #
  # RETURN
  #   unzipped folders in equivalent directory structure
  #
  # OBS
  #   earlier version of function contained logical argument for choosing whether to delete original zip dirs - removed when 'while' loop introduced >
  #   to address recursive unzip, as option to NOT delete original zip dirs would imply in never-ending while loop


  # libraries
  require(utils)  # for 'unzip' function


  # zipped folder identification [will NOT identify nested compressed folders, regardless of recursive argument]
  zip.list <- list.files(path       = fctn.zip.dir,
                         pattern    = fctn.zip.pattern,
                         recursive  = T,
                         full.names = T)


  # unzip procedure
  while (length(zip.list) > 0) {                          # 'while' to enable recursive unzip
    for (zip.folder in zip.list) {
      unzip.dir <- gsub(pattern     = fctn.zip.pattern,   # sets unzipped dir structure to mirror original zipped dir structure
                        replacement = "",
                        x           = zip.folder,
                        ignore.case = TRUE)

      unzip(zipfile   = zip.folder,                       # unzips folders
            overwrite = T,
            exdir     = unzip.dir)
    }

  lapply(X   = zip.list,                                  # deletes zip files
         FUN = unlink)

  zip.list <- list.files(path       = fctn.zip.dir,       # 'zip.list' updated to check existence of remaining zip dirs in recently unzipped dirs
                         pattern    = fctn.zip.pattern,
                         recursive  = fctn.unzip.subdir,
                         full.names = T)
  }
}





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------