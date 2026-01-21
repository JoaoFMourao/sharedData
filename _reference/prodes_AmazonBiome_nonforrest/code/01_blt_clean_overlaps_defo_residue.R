# > PROJECT INFO
# NAME: BOLSA VERDE
# LEAD: JOAO MOURAO 
#
# > THIS SCRIPT
# AIM: CLEAN OVERLAP 
# AUTHOR: Júlia Brandão Adapted from Rogério Reis
#
# > NOTES: 

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

str.time <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo
source(file.path("_functions", "associateCRS.R"))
source(file.path("_functions", "prevalent_values.R"))
source(file.path("_functions", "convertUnits.R"))

# loading packages
pkgs <- c("tidyverse","sf", "rlang","future.apply","furrr", "parallel", 
          "tictoc","labelled", "geobr", "dplyr", "readxl", "lwgeom")

groundhogLibraries(pkgs, date = "2025-01-26")

# Turns off scientific notation
options(scipen = 99) 

# INPUT  -------------------------------------------------------------------

# big resolution input 
aux.name <- load(
    file.path(
        "A:/land/prodes_AmazonBiome_nonforrest/cleanData/cln_prodes_amzbiome_nonforrest.Rdata"
    )
)


# Getting the code for the prodes munis 
prodes_increments <- get(aux.name)

# START FUNCTION  ----------------------------------------------------------------------------------------------------------------------------------------




deforestation <- prodes_increments %>% filter(prodes_main_class == "deforestation")
residue <- prodes_increments %>% filter(prodes_main_class == "residue")


# Now, we can verify the overlaps 
intersects = st_intersects(deforestation, residue) #considers every intersection (including only touches)
touches = st_touches(deforestation, residue)  #Getting only the touches 

#kicking off the intersections that only touche other polygons
overlaps <- lapply(seq_along(intersects), function(i) {
    setdiff(intersects[[i]], touches[[i]])
})

#saving memory 
rm(intersects) 
rm(touches) 

used = c() 

# Cleaning loop 

for (i in seq_len(nrow(deforestation))) {  
    if (length(overlaps[[i]]) != 0) {
        for (j in overlaps[[i]]) {  # Percorrer cada polígono que se sobrepõe ao resíduo
            
            # Garantir que a diferença espacial seja computada corretamente
            difference <- st_difference(residue$geometry[j], deforestation$geometry[i])
            
            # Se houver uma diferença válida (não está completamente contido)
            if (!st_is_empty(difference)) {
                residue$geometry[j] <- difference %>%
                    st_make_valid() %>%
                    st_buffer(0)  # Corrige possíveis geometrias inválidas
            } else {
                residue$geometry[j] <- NULL  # Remove a geometria caso esteja completamente contida
            }
        }
    }
}


# Atualizar o objeto muni com os resíduos processados
prodes_increments <- prodes_increments %>%
    filter(prodes_main_class != "residue") %>%  # Remove resíduos antigos
    bind_rows(residue) #%>% # Adiciona os resíduos corrigidos
# mutate(area_pol_prodes_ha = st_area(geometry)*convert.sqm.to.ha,
#        area_pol_prodes_ha = as.numeric(area_pol_prodes_ha))

save(prodes_increments,
     file = file.path(paste(
         DIR.CPI.DATA, 
         'land/prodes_AmazonBiome_nonforrest/builtData/cleanOverlap/new/',
         'blt_nonforest_without_overlaps',
         '.Rdata', sep=''))
)




print(
    Sys.time() - str.time
)        

# Time difference of 45.62528 secs
# END OF CODE -----------------------------------------------------------------------------------------------------------------------------
