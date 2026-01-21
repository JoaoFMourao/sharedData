# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO INSTALL AND LOAD MULTIPLE PACKAGES worried with replication
# AUTHOR: TEAM EFFORT
#
# > NOTES
# 1: -


# PACKAGES -------------------------------------------------------------------------------------------------------------------------------------------
groundhogLibraries <- function(packages, date = Sys.Date() - 2, 
                          tolerate.R.version =  ""){
  
    # INSTALLS AND LOADS MULTIPLE PACKAGES
  #
  # ARGS
  #   packages: character vector containg names of libraries to be called
  
  #   date:  The date of reference of the packages to be downloads. This function will download the 
  #          version of the package that was available at that date. The default is the two days before 
  #          the current day. The functions doesn't work well for the same day, thus, this is the closest possible to the 
  #          current package version. A data should have the following format : "yyyy-mm-dd" 
  
  #   tolerate.R.version: Ideally the R version used should be the last released before the "date". If it isn't the function
  #                       generate an error and do not load or download any package. If you want this function to ran at your
  #                       current version, regardless of anything, just set it to
  #                       "paste(version$major, version$minor, sep = "."))".
  # RETURNS
  #   installed and loaded library packages
  
  #load and, if not installed, install the "groundhog" package
  if ("groundhog" %in% installed.packages()){
    library(groundhog)}else{
      install.packages("groundhog")
      library(groundhog)
    }
  
  #adjust to use the groudhog package of avaliable at the date
 # meta.groundhog(date)
# if your code is not working, comment this line and see if it does.
  # The tolerate.R.version option was only included latter, for instance
  
  
  mapply(x = packages,
  function(x,y) {
    groundhog.library(x, date = date, tolerate.R.version = tolerate.R.version)
    v <- paste("version", packageVersion(x))
    paste(paste("called:", x),v)})
  

}


# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------