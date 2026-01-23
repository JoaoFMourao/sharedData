# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: IDENTIFY THE SHARE OF NA VALUES WITHIN A VARIABLE
# AUTHOR: JOAO F. MOURAO
#
#
# > NOTES
# 1: USEFULL TO COMBINE WITH LAPPLAY OR APPLY, SUCH AS: "apply(DT,2,share_na)" or ""lapply(DT,share_na)"
#

share_na <- function(x #numeric or character vector (or a collumn variable
                     ) {
  round(sum(is.na(x))/length(x),2)
}
