# > PROJECT INFO
# NAME: DATABASE CONSTRUCTION - BRAZILIAN PROTECTED AREAS
# LEAD: CLARISSA GANDOUR
#
# > THIS SCRIPT
# AIM: BUILT FROM CLEAN DATA - PROTECTED AREA BY GOVERNMENT
# AUTHOR: Joao Mourao
#
# 
#
#Notes:
# At the computer with  IP: 139.85.58.147:65000, this script tool 1.45 minutos at 2023-01-18
 




# SETUP ---------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()

time.strt <- Sys.time()

# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo


# SOURCES
source("_functions/associateCRS.R")
source("_functions/convertUnits.R")
source(file.path("_functions", "clean_overlaps_updated.R"))


# LIBRARIES
pkgs <- c("sf", "tidyverse","sp","future.apply","furrr","rlang", "geobr")

groundhogLibraries(pkgs, date = "2025-01-26")

# debug <- T
debug <- F

# Custom crs
new_crs <- st_crs(AssociateCRS("Proj_SIRGAS2000polyconic"))

# DATA INPUT ----------------------------------------------------------------------------------------------------------------------------------------


##  biomes ####
aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "territory/biome/cleanData", 
    "cln_adm_trtDv_brl_biome_ibge_2019_sf.Rdata")
)
biomes <- get(aux.name)
rm(list = aux.name, aux.name) 



## Protected Areas ####

aux.name <- load(file = file.path(
                      DIR.CPI.DATA,
                      "propertyRights/protec_Areas/cleanData",
                      "cln_pol_prtTe_brl_protectedAreas_mma.Rdata"
                    )
                 )


# get the object by its name
protectedAreas <- get(aux.name)


# remove the old object 
rm(list = aux.name, aux.name)

## 2007 municipal frontires ####
aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "territory/municipalities/cleanData/2022",
    "01_cln_trt_muni_no_overlap_ibge_2022_sf.Rdata"
  )
)

muni.2007 <- get(aux.name)

rm(list = aux.name, aux.name) 




# DATA MANIPULATION ----------------------------------------------------------------------------------------------------------------------------------

print(biomes$biome_name)
# biomes
biomes <- biomes %>%
  rename(
    biome = biome_name
  ) %>%
  mutate(
    biome = case_when(
      biome == "Amazon" ~ "Amazônia",
      biome == "AtlanticForest" ~ "Mata Atlântica",
      TRUE ~ biome
    )
  ) %>%
  filter(biome != "Sistema Costeiro") %>%
  st_transform(new_crs) %>%
  st_make_valid() %>%
  st_buffer(0) #%>%
  #rename(geometry = geom)

biome <- biomes %>%
 select(geometry, biome)



## crop municipality base ####

biome.muni.2007 <- muni.2007 %>% 
  
  st_as_sf() %>% #tranform in sf
  
  mutate(
    muni_code = as.double(muni_code)
  ) %>% #adjust var ca
  
  dplyr::select(muni_code, state_uf) %>% #select only relevant collumns 
  
  st_transform(new_crs) %>% 
  
  st_make_valid() %>%
  
  st_buffer(0) %>%

  st_intersection(biome) %>%
  
  st_make_valid() %>%
  
  st_buffer(0)


rm(biomes,muni.2007)
gc()



## Crop Potected Areas  ####
protectedAreas <- protectedAreas %>%
  
  st_as_sf() %>%
  
  st_transform(new_crs) %>%
  
  st_make_valid() %>%
  
  st_buffer(0) %>%
  
  st_intersection(biome) %>%
  
  st_make_valid() %>%

 st_buffer(0) %>%
  
  dplyr::rename(
    government = PA_jurisdiction,
    geom = geometry) %>%
  
  select(PA_type,government,geom)

#esquisse::esquisser(protectedAreas)
protectedAreas$PA_type
#check if there is any interception between sustainable use and full protection UCs (if u don't remove APAs, there will be)
fp <- protectedAreas %>% 
  filter(PA_type == "FP")

su <-  protectedAreas %>% 
  filter(PA_type == "SU")

aux <- st_intersection(fp, su)

aux <- aux %>%
  st_make_valid() %>%
  st_buffer(0)

#biome.muni.2007 <- st_make_valid(biome.muni.2007)
biome.muni.2007 <- biome.muni.2007 %>%
    st_transform(st_crs(aux))

mo <- st_intersection(biome.muni.2007, aux)


mo <- mo %>% mutate(area = st_area(geometry)) %>% arrange(-area)

#cleaning with clean_overlaps

pa <- protectedAreas %>% 
  mutate(un = paste0(government,"_",PA_type)) %>% 
  select(un)

print(unique(pa$un))

pa <- pa %>%
    mutate(un = case_when(
                  un == "federal_FP"     ~ "Federal_Proteção Integral",
                  un == "federal_SU"     ~ "Federal_Uso Sustentável",
                  un == "state_FP"       ~ "Estadual_Proteção Integral",
                  un == "state_SU"       ~ "Estadual_Uso Sustentável",
                  un == "municipal_SU"   ~ "Municipal_Uso Sustentável",
                  un == "municipal_FP"   ~ "Municipal_Proteção Integral")
    )

ordem <- c("Federal_Proteção Integral", "Estadual_Proteção Integral", "Municipal_Proteção Integral","Federal_Uso Sustentável", "Estadual_Uso Sustentável", "Municipal_Uso Sustentável")

clean.protectedAreas <- clean_overlaps(0,pa,"un",ordem)

#esquisse::esquisser(clean.protectedAreas)
# ## generate a functions that takes for each ####
# 
# clean.intersections <- function(x) {
#   
#   #this will be the function input
#   city <- x
#   
#   #get the shape of the municipality
#   muni.shape <- amazon.muni.2007 %>%
#     
#     filter(muni_code == city) %>%
#     
#     dplyr::select(geometry) %>%
#     
#     st_make_valid() %>%
#     
#     st_buffer(0)
#   
#   st_agr(muni.shape) <- "constant"  
#   
#   #crop the protected areas to the municipality ###
#   
#   ucs.muni <- protectedAreas %>%
#     
#     st_intersection(muni.shape) %>%
#     
#     st_make_valid() %>%
#     
#     st_buffer(0) 
#   
#   # separate each type of conservation unit ####
#   
#   ucs.fp <- ucs.muni %>%
#     filter(PA_type == "FP") 
#   
#   ucs.su <- ucs.muni %>%
#     filter(PA_type == "SU")
#   
#   # first remove from sustainable use, what is full protection
#   
#   fp.su <- st_intersection(ucs.fp,ucs.su) %>%
#     st_make_valid() %>%
#     st_buffer(0)
#   
#   
#   #if there is no intersection between ucs sustainable use and ucs full protection at this municipality
#   if (length(fp.su$geometry) == 0){
#     
#     clean.ucs.su <- ucs.su
#     
#   }else{
#     
#     #calculate the union of this inserction
#     union <- st_union(fp.su)  %>%
#       
#       st_make_valid() %>%
#       
#       st_buffer(0) 
#     
#     #what remais of the sustainable use when removind the difference
#     clean.ucs.su <- st_difference(ucs.su, union) %>%
#       
#       st_make_valid() %>%
#       
#       st_buffer(0) 
#     
#     #if all the sustainable use area of the municipality is in the intersection, than the muni has no conservation units 
#     #of sustainable use an that is the result of st_difference. 
#     
#   }
#   
#   ucs.muni <- bind_rows(
#     ucs.fp,
#     clean.ucs.su
#   )
#   #this takes care of the intersections between sustainable use and full protection, however, we still want to clean the ones between
#   #governments
#   
#   ucs.federal <- ucs.muni %>%
#     filter(government == "federal")
#   
#   ucs.non.federal <- ucs.muni %>%
#     filter(government != "federal")
#   
#   
#   intersection <- st_intersection(
#     ucs.federal,
#     ucs.non.federal
#   ) %>%
#     st_make_valid() %>%
#     st_buffer(0)
#   
#   if (length(intersection$geometry) == 0){
#     
#     clean.ucs.non.federal <- ucs.non.federal
#     
#   }else{
#     
#     #calculate the union of this inserction
#     union <- st_union(intersection)  %>%
#       
#       st_make_valid() %>%
#       
#       st_buffer(0) 
#     
#     #what remais of the non federal use when removing the difference
#     clean.ucs.non.federal <- st_difference(ucs.non.federal, union) %>%
#       
#       st_make_valid() %>%
#       
#       st_buffer(0) 
#     
#   }
#   
#   
#   
#   #we got clean the intersection between municipal and statual ucs
#   if (sum(clean.ucs.non.federal$government == "municipal") > 0){
#     
#     ucs.state <- clean.ucs.non.federal %>%
#       filter(government == "state")
#     
#     municipal.ucs <- clean.ucs.non.federal %>%
#       filter(government == "municipal")
#     
#     intersection <- st_intersection(ucs.state,municipal.ucs) %>%
#       st_make_valid() %>%
#       st_buffer(0)
#     
#     if(length(intersection$geometry) == 0) {
#       
#       clean.ucs.non.federal <- clean.ucs.non.federal
#       
#     } else{
#       
#       union <- st_union(intersection) %>%
#         st_make_valid() %>%
#         st_buffer(0)
#       
#       clean.municipal.ucs <- st_difference(municipal.ucs,union) %>%
#         st_make_valid() %>%
#         st_buffer(0)
#       
#       clean.ucs.non.federal <- bind_rows(
#         ucs.state,
#         clean.municipal.ucs
#       )
#       
#       
#     }
#   }
#   
#   ucs.muni <- bind_rows(
#     ucs.federal,
#     clean.ucs.non.federal
#   ) %>%
#     group_by(government) %>%
#     
#     summarize(geometry = st_union(geometry)) 
#   
#   
#   
#   ucs.muni
# }
# 
# if (debug == T) {
# 
# x <- 2103703
# clean.intersections(x)
# x <- 1200302
# clean.intersections(x)
# x <- 2105005
# clean.intersections(x)
# x <- 1300409 #cross between state x federal and FP x 
# clean.intersections(x)
# x <- 1600154 #cross between muni x state
# clean.intersections(x)
# }
# 
# 
# detectCores()
# 
# plan(multisession, workers = detectCores() - 2)
# 
# aux <- future_lapply(
#   amazon.muni.2007$muni_code,
#   clean.intersections
# )
# 
# clean.protectedAreas <- bind_rows(aux)


# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

clean.protectedAreas <- clean.protectedAreas %>% 
  select(-muni_code) %>% 
  mutate(government = ifelse(str_detect(un, "Estadual"), "state",
                             ifelse(str_detect(un, "Municipal"), "municipal",
                                    "federal")),
         subclass = str_sub(un, start = -2L, end = -1L))

  

  
blt.pol.prtTe.amz.protectedAreas.stateFederal.sf <- clean.protectedAreas


# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

save(blt.pol.prtTe.amz.protectedAreas.stateFederal.sf,
     file = file.path(DIR.CPI.DATA,
                      "propertyRights/protec_Areas/cleanData",
                      "blt_pol_prtTe_amz_protectedAreas_stateFederal_sf.RData"))



Sys.time() - time.strt

# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------
