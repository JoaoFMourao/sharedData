*** BASIC INFO -------------------------------------------------------
@data_name: Mapa de solos do Brasil - Embrapa
@data_type: shapefile
@format_and_extension: .shp
@last_update: 06/10/2023
@author: Mariana Stussi

*** DOWNLOAD INFO ----------------------------------------------------
Download links:
http://geoinfo.cnps.embrapa.br/layers/geonode%3Abrasil_solos_5m_20201104

The soil map from Embrapa was downloaded through the website above and later processed in R.

*** DESCRIPTION -------------------------------------------------------
The map (or information plan) represents the geographical distribution of soils in Brazil, according to the Brazilian Soil Classification System (SiBCS, 2006), classified up to the third categorical level. Scale 1:5,000,000.
Data is fixed in time and was uploaded in 2020. 

More metadata information can be found at:
http://geoinfo.cnps.embrapa.br/layers/geonode%3Abrasil_solos_5m_20201104/metadata_read

More information on soil classification can be found at:
https://www.embrapa.br/solos/sibcs/classificacao-de-solos

*** ADDITIONAL INFORMATION -------------------------------------------------------
 The map contains soil classifications at various levels. The most aggregated level of classification was used for data processing. 
Data treatment consists of intersecting soils shapefile with the AMC shapefile and calculating the area of each soil type for each municipality/AMC, in hectares. Treatment code is in the code folder.
Ps - at time of treatment, other embrapa shapefiles were considered and then abandoned, but the draft still remains in script treat_embrapa.R.