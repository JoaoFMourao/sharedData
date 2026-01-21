  
  # > PROJECT INFO
  # NAME: FUNCTION REPOSITORY
  # LEAD: CLARISSA GANDOUR
  #
  # > THIS SCRIPT
  # AIM: BUILD FUNCTION TO INSTALL AND LOAD MULTIPLE PACKAGES
  # AUTHOR: TEAM EFFORT
  #
  # > NOTES
  # 1: -
  
  
  
  
  
  # PACKAGES -------------------------------------------------------------------------------------------------------------------------------------------
  
  CallLibraries <- function(packages) {
    
    # INSTALLS AND LOADS MULTIPLE PACKAGES
    #
    # ARGS
    #   packages: character vector containg names of libraries to be called
    #
    # RETURNS
    #   installed and loaded library packages
    
    mapply(x = packages, MoreArgs = list(y = row.names(installed.packages())), function(x,y) {
      if (any(x %in% y)) {
        library(x, character.only = T)
      } else {
        install.packages(x)
        library(x, character.only = T)
        v <- paste("version", packageVersion(x))
        paste(paste("installed:", x),v)
      }
      v <- paste("version", packageVersion(x))
      paste(paste("called:", x),v)
    })
  }
  
  
  
  
  
  # END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------