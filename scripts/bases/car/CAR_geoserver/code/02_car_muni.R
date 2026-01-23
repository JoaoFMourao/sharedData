# > PROJECT INFO
# NAME: CENTRAL DATA REPOSITORY CONSTRUCTION - CAR
# LEAD: JOAO MOURAO E MARIANA STUSSI
#
# > THIS SCRIPT
# AIM: INTERSECT CAR WITH MUNI GEOM
# AUTHOR: MARCELO SESSIM
#
# > NOTES

# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------
rm(list = ls())
gc()


# GLOBAL SETTINGS
source("config.R")  # sets local dirs and sources config for shared data repo

# SOURCES
source(file.path("_functions", "associateCRS.R"))

# LIBRARIES
pkgs <- c("tidyverse","sf", "rlang","future.apply", "furrr", "parallel", "tictoc","labelled")

groundhogLibraries(pkgs, date = "2023-09-30")


# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

tic()
## load muni 2022 ####

aux.name <- load(
  file.path(
    DIR.CPI.DATA,
    "territory", 
    "municipalities",
    "cleanData",
    "2022", 
    "01_cln_trt_muni_no_overlap_ibge_2022_sf.Rdata"
  )
)

#get the object by its names
muni <- get(aux.name)

#remove the old object
rm(list = aux.name, aux.name)

# TIDYING DATA -----------------------------------------------------------------------------------------------------------------------------------------

##change muni crs ####
muni <- muni %>%
  
  st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
  
  #and make geometry clean-up
  st_make_valid()

muni = muni %>% 
  select(muni_code)

#date of the last download
date = "2023-11-08"

states <- c(
  
  "am", "pa", "ac", "ro", "rr", "ap","to", #norte
  
  "ma", "ba","pb", "rn", "pi",  "pe", "al", "ce", "se", #nordeste
  
  "DF", "go", "ms","mt", #centroest
  
  "rj", "sp","mg","es", #sudeste
  
  "pr","rs","sc" # sul
  
  
)


for (uf in states) {
  
  ## creating an sf object that has the intersection between car and amazon municipalities####
  inters_muni <- function(i){
    
    file <- aux.files[i]
    
    # load car file
    
    aux.name <- load(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\cleanData",date,
        uf,
        file
      )
    )
    
    #get the object by its names
    car <- get(aux.name)
    
    
    #remove the old object
    rm(list = aux.name, aux.name)
    
    #change car crs
    
    car <- car %>%
      
      st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
      
      #and make geometry clean-up
      st_make_valid()
    
    car <- car %>% 
      mutate(area_car = st_area(car))
    
    result <- car %>% 
      ungroup() %>% 
      st_intersects(muni, sparse = F)
    
    # Usando apply() com MARGIN = 2 para aplicar a função em colunas
    # any() verifica se há algum TRUE em cada coluna
    colunas_com_true <- apply(result, MARGIN = 2, any)
    
    # Obtendo os índices das colunas onde alguma entrada é TRUE
    indices_colunas_com_true <- which(colunas_com_true)
    
    # Filtrando o dataframe para ter apenas as linhas correspondentes aos índices
    muni_filtrado <- muni[indices_colunas_com_true, ] %>% 
      st_drop_geometry()
    
    
    for (j in 1:nrow(muni_filtrado)) {
      
      city = muni_filtrado[j,]
      
      city = muni %>% 
        filter(muni_code == city)
      
      resulta <- car %>% 
        ungroup() %>% 
        st_intersects(city, sparse = F)
      
      result = car
      
      result$resulta = resulta
      
      result = result %>% 
        filter(resulta == T) %>% 
        select(-resulta)
      
      if(nrow(result) != 0) {
        
        result <- result %>% 
          st_intersection(city) %>% 
          st_make_valid() %>% 
          st_buffer(0)
        
        
        
        # Define folder path
        folder_path_shape <- file.path("A:\\propertyRights\\CAR_Geoserver\\built_muni",date,
                                       uf)

        # Create the directory if it doesn't exist
        if (!dir.exists(folder_path_shape)) {
          dir.create(folder_path_shape, recursive = TRUE)
        }

        
        save(result,
             file = file.path(
               "A:\\propertyRights\\CAR_Geoserver\\built_muni",date,
               uf,
               paste0("car_geoserver_",
                      uf,
                      "_",
                      city$muni_code,
                      "_",
                      i,
                      "_sf.Rdata"))
        )
        
      }
      
    }
    
    
    
  }
  
  aux.files = list.files(file.path(
    "A:\\propertyRights\\CAR_Geoserver\\cleanData",
    date,
    uf),
    full.names = F
  )
  
  detectCores()
  
  plan(multisession, workers = 12)
  
  result = future_lapply(1:length(aux.files), inters_muni)
  
  
  
}
toc()



# CROSS CHECK - CHECKING HOW MANY HA PER STATE ####

#pos mrg muni
result = list()
for (uf  in states) {
  
  area_f =function(i) {
    
    file <- aux.files[i]
    
    # load car file
    
    aux.name <- load(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\built_muni",date,
        uf,
        file
      )
    )
    
    #get the object by its names
    car <- get(aux.name)
    
    
    #remove the old object
    rm(list = aux.name, aux.name)
    
    
    # car <- car %>% 
    #   mutate(area = st_area(car)) %>% 
    #   st_drop_geometry()
    
    car = car %>% 
      st_drop_geometry()
    car
  }
  
  aux.files = list.files(file.path(
    "A:\\propertyRights\\CAR_Geoserver\\built_muni",
    date,
    uf),
    full.names = F
  )
  
  detectCores()
  
  plan(multisession, workers = 12)
  
  result = c(result, future_lapply(1:length(aux.files), area_f))
  
  print(uf)
  
}

result = bind_rows(result)

result1 = result %>% 
  group_by(uf) %>% 
  summarise(area = sum(as.numeric(area))*10^(-4)) %>% 
  ungroup() %>% 
  mutate(total = sum(area))


#pre muni mrg

res = list()
for (uf  in states) {
  
  area_f =function(i) {
    
    file <- aux.files[i]
    
    # load car file
    
    aux.name <- load(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\cleanData",
        date,
        uf,
        file
      )
    )
    
    #get the object by its names
    car <- get(aux.name)
    
    
    #remove the old object
    rm(list = aux.name, aux.name)
    
    car <- car %>%
      
      st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
      
      #and make geometry clean-up
      st_make_valid()
    
    if(nrow(car) != 0){
      car <- car %>% 
        mutate(area = st_area(car)) %>% 
        st_drop_geometry()
      
      car
    }
    
    
  }
  
  aux.files = list.files(file.path(
    "A:\\propertyRights\\CAR_Geoserver\\cleanData",
    date,
    uf),
    full.names = F
  )
  
  detectCores()
  
  plan(multisession, workers = 12)
  
  res = c(res, future_lapply(1:length(aux.files), area_f))
  
  
}

res = bind_rows(res)

res1 = res %>% 
  group_by(uf) %>% 
  summarise(area = sum(as.numeric(area))*10^(-4)) %>% 
  ungroup() %>% 
  mutate(total = sum(area))

result1$area_pre = res1$area

result1 = result1 %>% 
  mutate(dif = area_pre - area)

tes = car %>%
  filter(FID == "sicar_imoveis_ma.6168")

a = res %>%
  ungroup() %>%
  distinct(cod_imovel) %>%
  nrow()

b = res %>%
  ungroup() %>%
  distinct(FID) %>%
  nrow()

c = result %>%
  ungroup() %>%
  distinct(cod_imovel) %>%
  nrow()

d = result %>%
  ungroup() %>%
  distinct(FID) %>%
  nrow()

a
b
c
d

temp1 = res %>%
  mutate(c = 1) %>%
  group_by(FID) %>%
  mutate(c_FID = sum(c)) %>%
  ungroup() %>%
  distinct(FID, .keep_all = T) %>%
  filter(c_FID>1)

temp = res %>%
  mutate(c = 1) %>%
  group_by(cod_imovel) %>%
  mutate(c_cod = sum(c)) %>%
  ungroup() %>%
  distinct(cod_imovel, .keep_all = T) %>%
  filter(c_cod>1)

t = res %>%
  mutate(c = 1) %>%
  group_by(cod_imovel) %>%
  mutate(c_cod = sum(c)) %>%
  ungroup() %>%
  filter(c_cod>1)

states.rep = t$uf %>% unique()
states.rep = tolower(states.rep)
cod_imov.rep = t$cod_imovel %>%  unique()

rm(res,t,temp)

res = list()
for (uf  in states.rep) {
  
  area_f =function(i) {
    
    file <- aux.files[i]
    
    # load car file
    
    aux.name <- load(
      file.path(
        "A:\\propertyRights\\CAR_Geoserver\\cleanData",
        date,
        uf,
        file
      )
    )
    
    #get the object by its names
    car <- get(aux.name)
    
    
    #remove the old object
    rm(list = aux.name, aux.name)
    
    car <- car %>%
      
      filter(cod_imovel %in% cod_imov.rep) %>% 
      
      st_transform(crs = st_crs(AssociateCRS(CRS_id = "Proj_SIRGAS2000polyconic"))) %>% #adjust crs
      
      #and make geometry clean-up
      st_make_valid()
    
    if(nrow(car) != 0){
      car <- car %>% 
        mutate(area = st_area(car))
      
      
      car
    }
    
    
  }
  
  aux.files = list.files(file.path(
    "A:\\propertyRights\\CAR_Geoserver\\cleanData",
    date,
    uf),
    full.names = F
  )
  
  detectCores()
  
  plan(multisession, workers = 12)
  
  res = c(res, future_lapply(1:length(aux.files), area_f))
  
  
}

res = bind_rows(res)


final = list()
for (uf  in states.rep) {
  
  f =function(i) {
    
    cod = cod_imov.rep[i]
    
    car <- res %>%
      
      filter(cod_imovel ==  cod)
    
    car$num = 1:nrow(car)
    
    for (j in 1:nrow(car)) {
      
      now = car %>% 
        filter(num == j)
      
      all = car %>% 
        filter(num != j) %>% 
        select(num,geometry) 
      
      now = now %>% 
        st_difference(all)
      
      now
      
    }
    
    
  }
  
  
  
  detectCores()
  
  plan(multisession, workers = 12)
  
  final = c(final, future_lapply(1:length(cod_imov.rep), f))
  
  
}

final = bind_rows(final)

nrow(final)
# since nrow(final) has output == 0, cod_imovel is the unique identifier
# and the other rows are duplicates



