#' @title treat_embrapa.R
#' @description Treat shapefiles from Embrapa
#' @author Mariana Stussi
#' @date 06-10-2022



## 0. Setting up the environment -------------------------------------------------------------------


rm(list = ls())

# loading packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, data.table, janitor, lubridate, stringr, geobr, sf, viridis)


# set user
user = "mstussi.CPIRIO"

# set directories

raw_data <- paste0("C:/Users/", user, "/Dropbox (CPI)/Rural_credit/Dados/Embrapa/Brutos/")
data_out <- paste0("C:/Users/", user, "/Dropbox (CPI)/Rural_credit/Dados/Embrapa/Tratados/")


# Turns off scientific notation
options(scipen = 99)


## 1. Read Files -------------------------------------------------------------------

erosion = st_read(paste0(raw_data, "Erodibilidade_solos_erosao_hidrica_Brasil/Brasil_erodibilidade_solo.shp"))

amc = geobr::read_comparable_areas(start_year = 2000, end_year = 2010) # Decided to use AMC instead of municipalities due to possible change in municipality limits throughout the period.


## 2. Treat Data -------------------------------------------------------------------

  # 2.1 Soil Type
  soil = st_read(paste0(raw_data, "brasil_solos_5m_20201104/brasil_solos_5m_20201104.shp"))

  # Fill NAs from ORDEM1 Collumn with info from COMP1
  soil = soil %>% mutate(soil_type = ifelse(!is.na(ORDEM1), ORDEM1, COMP1))

  # Change CRS 4674
  st_crs(se)
  soil = soil %>% st_transform(crs = 4674)
  
  # Plot to check map
  p_soil = ggplot() +
    geom_sf(data = soil, mapping = aes(fill = soil_type, alpha = 0.5), color = NA) + 
    # coord_sf(datum = st_crs(4674)) +  
    scale_fill_viridis(discrete = TRUE, option = "turbo") +
    geom_sf(data = amc, fill = NA, color = "gray50", size = 0) + 
    labs(fill  = "") + 
    ggtitle("SOIL TYPE") +  
    theme_void() +
    theme(legend.position = "none")
  
  p_soil 

  # Calculate intersections between soil and amc polygons 
  amc_int = st_intersection(st_make_valid(soil), st_make_valid(amc)) # output is a subset of all intersections combinations
  
  # Create column with polygon area in m2
  amc_int$area = st_area(amc_int)
  
  # Dataframe with area by soil-municipality combination
  amc_int_df = amc_int %>% st_drop_geometry() %>% group_by(code_amc, soil_type) %>% summarize(area_km2 = as.numeric(sum(area)/10000)) # area em hectares que cada tipo de solo ocupa em cada municipio
  
  # Transform soil area by municipality to cols // rows = municipalities
  wide = amc_int_df %>% spread(soil_type, area_km2, fill = 0) 
  
  # Clean col names
  wide = wide %>% rename_with(~paste0('area_', make_clean_names(.x)), AGUA:VERTISSOLOS)
  
  
  saveRDS(wide, file = paste0(data_out, "fixed_effects_amc_soil_type.Rds"))
  
  
  
  
  # 2.2 Water (Água Disponível)
  
  rm(list=setdiff(ls(), "amc")) # remove all objects from environment except amc shapefile
  gc() # clean memory
  water = st_read(paste0(raw_data, "Brasil_AD_solos/Brasil_AD_solos_v5.shp"))
  
  # Fill NAs from ORDEM1 Collumn with info from COMP1
  water =  water %>% mutate(water_type = ifelse(!is.na(nom_unid), nom_unid, legenda))
  
  teste = st_make_valid(water) %>% group_by(water_type) %>% summarize(agua_disp = sum(Total_AD, na.rm = T))
  teste2 = teste %>% sf::st_drop_geometry()

  # Change CRS 4674
  st_crs(amc)
  water = teste %>% st_transform(crs = 4674)
  
  # Calculate intersections between soil and amc polygons 
  amc_int = st_intersection(st_make_valid(water), st_make_valid(amc)) # output is a subset of all intersections combinations
  
  # Create column with polygon area in m2
  amc_int$area = st_area(amc_int)
  
  # Dataframe with area by soil-municipality combination
  amc_int_df = amc_int %>% st_drop_geometry() %>% group_by(code_amc, soil_type) %>% summarize(area_km2 = as.numeric(sum(area)/10000)) # area em hectares que cada tipo de solo ocupa em cada municipio
  
  # Transform soil area by municipality to cols // rows = municipalities
  wide = amc_int_df %>% spread(soil_type, area_km2, fill = 0) 
  
  # Clean col names
  wide = wide %>% rename_with(~paste0('area_', make_clean_names(.x)), AGUA:VERTISSOLOS)
  
  # Plot to check map
  p_water = ggplot() +
    geom_sf(data = water, mapping = aes(fill = agua_disp, alpha = 0.5), color = NA) + 
    # coord_sf(datum = st_crs(4674)) +  
    scale_fill_viridis(discrete = F, option = "turbo") +
    #   geom_sf(data = amc, fill = NA, color = "gray50", size = 0) + 
    labs(fill  = "") + 
    ggtitle("SOIL TYPE") +  
    theme_void() +
    theme(legend.position = "none")
  
  p_water 
  
  



# Plot 
p_soil = ggplot() +
  geom_sf(data = soil, mapping = aes(fill = soil_type, alpha = 0.5), color = NA) + 
  # coord_sf(datum = st_crs(4674)) +  
  scale_fill_viridis(discrete = TRUE, option = "turbo") +
#  geom_sf(data = amc, fill = NA, color = "gray50", size = 0) + 
  labs(fill  = "") + 
  ggtitle("SOIL TYPE") +  
  theme_void() +
  theme(legend.position = "none")

p_soil 

