# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: IDENTIFY THE NUMBER OF UNIQUE VALUES WITHIN A VARIABLE
# AUTHOR: JOAO F. MOURAO
#
#
# > NOTES
# 1: USEFULL TO COMBINE WITH LAPPLAY OR APPLY, SUCH AS: "apply(DT,2,unique_values)" or ""lapply(DT,unique_values)"
#

unique_values <- function(x #numeric or character vector (or a collumn variable)
                          ) {
  length(unique(x))
}