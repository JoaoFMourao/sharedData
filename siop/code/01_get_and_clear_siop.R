##################

# Author : Renan Morais
# Date: 18-08-2023
# Email: renanflorias@hotmail.com
# Goal: clear operações indiretas automaticas BNDES
# resource:

########################### Libraries ######################################

pacman::p_load(tidyverse, stringi, janitor, writexl, openxlsx, httr, magrittr, readr, data.table, dplyr, plyr)

##### directory #########

dir_siop_raw <- ("A:/finance/siop/rawData")

dir_siop_clear <- ("A:/finance/siop/CleanData")


##### import datasets #########
setwd(dir_siop_raw)

base_siop_raw <- readr::read_csv2("siop_2012-2022_02fev2023.csv")

base_siop_raw <- base_siop_raw[-1,]

######################## cleand and transform #####################

"standizing columns and clear and obtain code and description of each column"

siop_clean <- base_siop_raw %>%
  janitor::clean_names(.) %>% #padronizando os nomes das variáveis
  filter(ano >2012) %>% #eliminando o ano de 2023 pois não faz parte do escopo
  mutate(localizador=str_to_lower(localizador))%>%     ## making all observations in lowercase, keeping accents 
  mutate(localizador=stri_trans_general(str = localizador, id = "Latin-ASCII"))%>% ## removing accents
  mutate(localizador=str_trim(localizador))%>%
  mutate(acao_cod=str_sub(acao,1,4))%>%     ## separating codigo from description
  mutate(acao_desc=str_replace(acao,acao_cod,""))%>%
  mutate(acao_desc=str_replace(acao_desc," - ",""))%>%
  mutate(programa=str_to_lower(programa))%>% ## making all observations in lowercase, keeping accents 
  mutate(programa=stri_trans_general(str = programa, id = "Latin-ASCII"))%>%   ## removing accents
  mutate(programa=str_trim(programa))%>%
  mutate(prog_cod=str_sub(programa,1,4))%>%     
  mutate(prog_desc=str_replace(programa,prog_cod,""))%>%
  mutate(prog_desc=str_replace(prog_desc," - ",""))%>%
  mutate(loc_cod=str_sub(localizador,1,4))%>%     
  mutate(loc_desc=str_replace(localizador,loc_cod,""))%>%
  mutate(loc_desc=str_replace(loc_desc," - ","")) %>% 
  mutate(unidade_orcamentaria=str_to_lower(unidade_orcamentaria))%>%     ## making all observations in lowercase, keeping accents 
  mutate(unidade_orcamentaria=stri_trans_general(str = unidade_orcamentaria, id = "Latin-ASCII"))%>% ## removing accents
  mutate(unidade_orcamentaria=str_trim(unidade_orcamentaria))%>%
  mutate(un_orc_cod=str_sub(unidade_orcamentaria,1,5))%>%     
  mutate(un_orc_desc=str_replace(unidade_orcamentaria,un_orc_cod,""))%>%
  mutate(un_orc_desc=str_replace(un_orc_desc," - ","")) %>% 
  mutate(orgao_orcamentario=str_to_lower(orgao_orcamentario)) %>% 
  mutate(orgao_orcamentario=stri_trans_general(str = orgao_orcamentario, id = "Latin-ASCII"))%>%   ## removing accents
  mutate(orgao_orcamentario=str_trim(orgao_orcamentario)) %>%
  mutate(orgao_orc_cod=str_sub(orgao_orcamentario,1,5))%>% 
  mutate(orgao_orc_desc=str_replace(orgao_orcamentario,orgao_orc_cod,""))%>%
  mutate(orgao_orc_desc=str_replace(orgao_orc_desc," - ","")) %>% 
  mutate(funcao=str_to_lower(funcao))%>%     ## making all observations in lowercase, keeping accents 
  mutate(funcao=stri_trans_general(str = funcao, id = "Latin-ASCII"))%>% ## removing accents
  mutate(funcao=str_trim(funcao))%>%
  mutate(funcao_cod=str_sub(funcao,1,2))%>%     
  mutate(funcao_desc=str_replace(funcao,funcao_cod,""))%>%
  mutate(funcao_desc=str_replace(funcao_desc," - ","")) %>% 
  mutate(grupo_de_despesa=str_to_lower(grupo_de_despesa))%>%     ## making all observations in lowercase, keeping accents 
  mutate(grupo_de_despesa=stri_trans_general(str = grupo_de_despesa, id = "Latin-ASCII"))%>% ## removing accents
  mutate(grupo_de_despesa=str_trim(grupo_de_despesa))%>%
  mutate(grupo_desp_cod=str_sub(grupo_de_despesa,1,1))%>%     
  mutate(grupo_desp_desc=str_replace(grupo_de_despesa,grupo_desp_cod,""))%>%
  mutate(grupo_desp_desc=str_replace(grupo_desp_desc," - ","")) %>%
  mutate(modalidade_de_aplicacao=str_to_lower(modalidade_de_aplicacao))%>%     ## making all observations in lowercase, keeping accents 
  mutate(modalidade_de_aplicacao=stri_trans_general(str = modalidade_de_aplicacao, id = "Latin-ASCII"))%>% ## removing accents
  mutate(modalidade_de_aplicacao=str_trim(modalidade_de_aplicacao))%>%
  mutate(modalidade_aplic_cod=str_sub(modalidade_de_aplicacao,1,2))%>%     
  mutate(modalidade_aplic_desc=str_replace(modalidade_de_aplicacao,modalidade_aplic_cod,""))%>%
  mutate(modalidade_aplic_desc=str_replace(modalidade_aplic_desc," - ",""))%>% 
  mutate(subfuncao=str_to_lower(subfuncao))%>%     ## making all observations in lowercase, keeping accents 
  mutate(subfuncao=stri_trans_general(str = subfuncao, id = "Latin-ASCII"))%>% ## removing accents
  mutate(subfuncao=str_trim(subfuncao))%>%
  mutate(subfuncao_cod=str_sub(subfuncao,1,3))%>%     
  mutate(subfuncao_desc=str_replace(subfuncao,subfuncao_cod,""))%>%
  mutate(subfuncao_desc=str_replace(subfuncao_desc," - ",""))



################## save data ##################3
setwd(dir_siop_clear)

saveRDS(siop_clean, "siop_2012_2023_clean.RDS")
