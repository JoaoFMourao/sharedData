
# > PROJECT INFO
# NAME: FUNCTION REPOSITORY
# LEAD: TEAM EFFORT
#
# > THIS SCRIPT
# AIM: BUILD FUNCTION TO EXCLUDE LATIN CHARACTERS IN NON-SPATIAL OBJECTS
# AUTHOR: MARCELO SESSIM
#
# > NOTES
# 1: -





# LATIN CHARACTER EXTRACTION -------------------------------------------------------------------------------------------------------------------------


exclude_accent <- function(x){
  library(stringr)
  x <- str_to_lower(x)
  x <- str_remove_all(x, "á")
  x <- str_remove_all(x, "é")
  x <- str_remove_all(x, "í")
  x <- str_remove_all(x, "ó")
  x <- str_remove_all(x, "ú")
  x <- str_remove_all(x, "ã")
  x <- str_remove_all(x, "õ")
  x <- str_remove_all(x, "â")
  x <- str_remove_all(x, "ê")
  x <- str_remove_all(x, "î")
  x <- str_remove_all(x, "ô")
  x <- str_remove_all(x, "û")
  x <- str_remove_all(x, "à")
  x <- str_remove_all(x, "ò")
  x <- str_remove_all(x, "ì")
  x <- str_remove_all(x, "è")
  x <- str_remove_all(x, "ù")
  x <- str_remove_all(x, "ñ")
  x <- str_remove_all(x, "ç")
  x <- str_remove_all(x, "ü")
}
