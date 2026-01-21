
# > PROJECT INFO
# TITLE: CENTRAL DATA REPOSITORY CONSTRUCTION - DETER (REAL-TIME DETECTION OF LEGAL AMAZON DEFORESTATION & DEGRADATION)
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: CLEAN RAW DATA - ALERTS
# AUTHOR: JOAO VEIRA
#
# > EDIT DETAILS
# BY: CLARISSA GANDOUR
# ON: SEP/18/2017
#
# > NOTES
# 1: SCRIPT WILL RETURN WARNING, DESPITE SUCCESSFUL RUN - REFERS TO 2011/OCT ALERTS SHAPEFILE, WHICH APPEARS TO CONTAIN NULL GEOMETRIES





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# GLOBAL SETTINGS
source("config.R")  # local dirs and sources config for shared data repo



# SOURCES
source(file.path("_functions", "associateCRS.R"))



# LIBRARIES
CallLibraries(c("sp", "rgdal", "rgeos"))





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# RAW DATA
# input automated in dataset cleanup and prep section





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# AUXILIARY OBJECTS
aux.deter.years <- c("2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017")
aux.months      <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")



# CLEANUP AND PREP BY CALENDAR YEAR
for (y in seq_along(aux.deter.years)) {

  # DIR SELECTION
  select.deter.year <- aux.deter.years[y]
  dir.input.folders <- list.files(path        = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/input", select.deter.year),  # lists monthly folders for given year
                                  pattern     = "Deter",
                                  ignore.case = T)



  # PROCESSING
  dir.input.folder.index <- 1                                                    # starts folder index iterator

  for (m in seq_along(aux.months)) {

    # calendar month identification
    cal.month   <- aux.months[m]


    # folder date extraction
    folder.name <- dir.input.folders[dir.input.folder.index]                     # excludes non-standard part of folder name
    folder.date <- gsub(pattern     = "Deter_",
                         replacement = "",
                         x           = folder.name,
                         ignore.case = T)


    # error check
    if (dir.input.folder.index > length(dir.input.folders)) {                    # if directory index greater than number of folders...
      folder.date <- "string to force mismatch with cal.month"                   # assign string that forces mismatch with cal.month in next step
    }


    # folder type: data DOES NOT exist for given month [== full cloud coverage]
    if (substr(folder.date, start = 5, stop = 6) != cal.month) {                 # if calendar month does not match folder date...
      assign(x     = paste("deter.alerts", cal.month, sep = "."),                # ... assigns NULL to indicate no alerts issued (typically due to   >
             value = NULL)                                                       # full cloud coverage that month)

      next                                                                       # cycles through months while holding dir.input.folder.index fixed


    # folder type: data DOES exist for given month [== partial cloud coverage]
    } else {

      # shapefile access
      file.names <- list.files(file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/input", select.deter.year, folder.name))

      layer.names <- vector()
      for (l in seq_along(file.names)) {
        select.layer <- strsplit(x     = file.names,
                                 split = ".",                                    # splits layer names into pre/post file extension
                                 fixed = T)[[l]][1]                              # selects first (pre-split) component of l-th element
        layer.names  <- rbind(layer.names, select.layer)
      }
      layer.names <- as.vector(unique(layer.names))                              # excludes repeated names from extensions, preserves multiple layers


      # observation type: TWO layers for given month [rare occurrences]
      if (length(layer.names) > 1) {

        # layer input
        deter.alerts.month.half1 <- readOGR(dsn   = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/input", select.deter.year, folder.name),
                                            layer = layer.names[1])
        deter.alerts.month.half2 <- readOGR(dsn   = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/input", select.deter.year, folder.name),
                                            layer = layer.names[2])


        # CRS attribution [for shapefiles missing proj4string only; see documentation for details on CRS selection]
        if (select.deter.year <= 2010) {
          if (is.na(proj4string(deter.alerts.month.half1))) {
            proj4string(deter.alerts.month.half1) <- AssociateCRS("Unproj_SAD69longlat")
          }
          if (is.na(proj4string(deter.alerts.month.half2))) {
            proj4string(deter.alerts.month.half2) <- AssociateCRS("Unproj_SAD69longlat")
          }
        } 
        
        if ((select.deter.year > 2010 & select.deter.year < 2015) | (select.deter.year == 2015 & cal.month <= 7) ) {
          if (is.na(proj4string(deter.alerts.month.half1))) {
            proj4string(deter.alerts.month.half1) <- AssociateCRS("Unproj_SAD69longlat_pre96BR")
          }
          if (is.na(proj4string(deter.alerts.month.half2))) {
            proj4string(deter.alerts.month.half2) <- AssociateCRS("Unproj_SAD69longlat_pre96BR")
          }
        }
        
        if ((select.deter.year > 2015) | (select.deter.year == 2015 & cal.month > 7) ) {
          if (is.na(proj4string(deter.alerts.month.half1))) {
            proj4string(deter.alerts.month.half1) <- AssociateCRS("Unproj_SIRGAS2000longlat")
          }
          if (is.na(proj4string(deter.alerts.month.half2))) {
            proj4string(deter.alerts.month.half2) <- AssociateCRS("Unproj_SIRGAS2000longlat")
          }
        }

        # merge alerts halfs
        deter.alerts.month <- list(deter.alerts.month.half1, deter.alerts.month.half2)
        
        # environment cleanup
        rm(deter.alerts.month.half1, deter.alerts.month.half2)


      # observation type: ONE layer for given month
      } else {

        # layer input
        deter.alerts.month <- readOGR(dsn   = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/input", select.deter.year, folder.name),
                                      layer = layer.names)

        
        # CRS attribution [for shapefiles missing proj4string only; see documentation for details on CRS selection]
        if (select.deter.year <= 2010) {
          if (is.na(proj4string(deter.alerts.month))) {
            proj4string(deter.alerts.month) <- AssociateCRS("Unproj_SAD69longlat")
          }
        } 
        
        if ((select.deter.year > 2010 & select.deter.year < 2015) | (select.deter.year == 2015 & cal.month <= 7) ) {
          if (is.na(proj4string(deter.alerts.month))) {
            proj4string(deter.alerts.month) <- AssociateCRS("Unproj_SAD69longlat_pre96BR")
          }
        }
        
        if ((select.deter.year > 2015) | (select.deter.year == 2015 & cal.month > 7) ) {
          if (is.na(proj4string(deter.alerts.month))) {
            proj4string(deter.alerts.month) <- AssociateCRS("Unproj_SIRGAS2000longlat")
          }
        }
        
        # polygon extraction
        deter.alerts.month <- as.SpatialPolygons.PolygonsList(Srl         = deter.alerts.month@polygons,
                                                              proj4string = deter.alerts.month@proj4string)


      }                                                                          # closes if/else condition referring to number of layers
    }                                                                            # closes if/else condition referring to existence of data


    # object identification
    assign(x     = paste("deter.alerts", cal.month, sep = "."),
           value = deter.alerts.month)


    # environment cleanup
    rm(deter.alerts.month)


    # iteration
    dir.input.folder.index = dir.input.folder.index + 1                          # loops folder index iterator
  }                                                                              # closes month loop


  # annual compilation
  deter.alerts.year <- list("JAN" = deter.alerts.01,
                            "FEB" = deter.alerts.02,
                            "MAR" = deter.alerts.03,
                            "APR" = deter.alerts.04,
                            "MAY" = deter.alerts.05,
                            "JUN" = deter.alerts.06,
                            "JUL" = deter.alerts.07,
                            "AUG" = deter.alerts.08,
                            "SEP" = deter.alerts.09,
                            "OCT" = deter.alerts.10,
                            "NOV" = deter.alerts.11,
                            "DEC" = deter.alerts.12)



  # EXPORT PREP
  aux.name <- paste("cln.lcv.alert.laz.deterAAlert.inpe.sp", select.deter.year, sep = ".")      # needed for export
  assign(x     = aux.name,
         value = deter.alerts.year)



  # INTERMEDIARY EXPORT
  # save(list = aux.name,                                                          # list argument needed to export by ref to object name
  #      file = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/output", paste0("cln_lcv_alert_laz_deterAAlert_inpe_", select.deter.year, ".Rdata")))



  # ENVIRONMENT CLEANUP
  rm(deter.alerts.year, aux.name)
}                                                                                # closes year loop

save(cln.lcv.alert.laz.deterAAlert.inpe.sp.2004,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2005,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2006,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2007,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2008,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2009,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2010,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2011,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2012,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2013,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2014,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2015,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2016,
     cln.lcv.alert.laz.deterAAlert.inpe.sp.2017,
     file = file.path(DIR.CDR.DATA, "raw2clean/landCover/alert/legalAmazon/deterA_inpe/output", "cln_lcv_alert_laz_deterAAlert_inpe_sp.Rdata"))




# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------