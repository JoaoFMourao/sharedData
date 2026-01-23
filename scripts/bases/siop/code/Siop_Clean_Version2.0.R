##########################################################################
# Codigo para tratar a base de dados SIOP                                #
#  O tratamento será a limpeza das colunas para retirada de caracteres   #
# Como também a padronização dos dados                                   #
##########################################################################

#Importanto pacotes:
library(tidyverse)
library(stringi)
library(readxl)


siop = read_csv2('A:\\finance\\siop\\rawData\\siop_2015_2023_05_04_2024.csv')
#siop = siop %>% filter(Ano>=2015)#Apenas observações a partir de 2015
siop = siop %>% filter(Pago!=0) #Apenas observações que pagaram
siop$ID_SIOP = seq_len(nrow(siop))#Criando um ID numerico
#checando os anos:
siop%>% select(Ano)%>%unique()
#Retirando a primeira linha(Ela toda é NA)
siop <- siop %>% slice(-1)
siop_tratado <- siop %>%
  
  select(-c( `Projeto de Lei`, `Dotação Inicial`,
             `Dotação Atual`)) %>% 
  mutate(Ano = as.numeric(Ano),
         funcao = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(Função,"Latin-ASCII")),"^[[:alnum:]]{2}",""),"-","")),
         funcao_cod = substr(Função,start = 1,stop = 2),
         und_orc = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(`Unidade Orçamentária`,"Latin-ASCII")), "^[[:alnum:]]{5}", ""),"-","")),
         und_orc_cod = substr(`Unidade Orçamentária`,start = 1,stop = 5),
         programa = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(Programa,"Latin-ASCII")),"^[[:alnum:]]{4}",""),"-","")),
         programa_cod = substr(Programa,start = 1,stop = 4),
         acao =str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(
           Ação, "Latin-ASCII")), "^[[:alnum:]]{4}", ""), "-", "")),
         acao_cod = substr(Ação,start = 1 , stop = 4),
         localizador = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(
           Localizador, "Latin-ASCII")), "^[[:alnum:]]{4}", ""), "-", "")),
         localizador_cod = substr(Localizador,start = 1, stop = 4),
         regiao = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(
           Região, "LAtin-ASCII")), "^[[:alnum:]]{2}", ""), "-", "")),
         regiao_cod = substr(Região,start = 1, stop = 2),
         uf = str_trim(str_replace(str_replace(str_to_lower(stri_trans_general(
           UF, "Latin-ASCII")), "^[[:alnum:]]{2}", ""), "-","")),
         uf_cod = substr(UF,start = 1, stop = 2),
         municipio = str_trim(str_replace(str_replace((str_to_lower(stri_trans_general(
           Município, "Latin-ASCII"))),"^[[:alnum:]]{7}", ""), "-", "")),
         municipio_cod = substr(Município,start = 1 , stop = 7),
         plano_orc = str_trim(str_remove(str_remove(str_remove(str_replace(str_to_lower(stri_trans_general(`Plano Orçamentário`,"Latin-ASCII")),"^[[:alnum:]]{4}", ""),"-"),"  000m - "),"  00se - ")),
         plano_orc_cod = substr(`Plano Orçamentário`,start = 1 , stop = 4),
         grupo_de_despesa = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Grupo de Despesa`, "Latin-ASCII")),"^[[:alnum:]]{1}"),"-")),
         grupo_despesa_cod = substr(`Grupo de Despesa`,start=1,stop = 1),
         modalidade = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Modalidade de Aplicação`, "Latin-ASCII")), "^[[:alnum:]]{2}"),"-")),
         modalidade_cod = substr(`Modalidade de Aplicação`,1,2),
         fonte_recursos = str_trim(str_remove(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Fonte`,"Latin-ASCII")),"^[[:alnum:]]{3}"),"^[[:alnum:]]{1}"),"-")),
         fonte_recursos_cod = substr(`Fonte`,1,3),
         subfuncao = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Subfunção`, "Latin-ASCII")),"^[[:alnum:]]{3}"),"-")),
         subfuncao_cod =substr(`Subfunção`,1,3),
         origem_do_credito = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Origem do Crédito`, "Latin-ASCII")), "^[[:alnum:]]{1}"), "-")),
         origem_do_credito_cod = substr(`Origem do Crédito`,1,1),
         objetivo = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           Objetivo, "Latin-ASCII")),"^[[:alnum:]]{4}"),"-")),
         objetivo_cod = substr(Objetivo,1,4),
         empenhado = as.numeric(Empenhado),
         liquidado = as.numeric(Liquidado),
         programa = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Programa`, "Latin-ASCII")),"^[[:alnum:]]{4}"),"-")),
         programa_cod = substr(Programa,start = 1,stop=4),
         resultado_primario = str_trim(str_remove(str_remove(str_to_lower(stri_trans_general(
           `Resultado Primário`, "Latin-ASCII")),"^[[:alnum:]]{1}"),"-")),
         resultado_primario_cod = substr( `Resultado Primário`,1,1))
         

lista <- NULL
vetor = siop_tratado$Ano %>% unique

for(i in 1:length(vetor)){
  a = siop_tratado %>% filter(Ano == vetor[[i]])
  lista[[i]] <- a%>% mutate(row_num = seq(1,nrow(a)))  %>% mutate(ID_SIOP = str_c(row_num,Ano,sep = "_"))
  
}

siop_tratado2 <- do.call(rbind,lista) 



siop_tratado2 %>% write_rds('A:\\finance\\siop\\cleanData/siop_tratado_Versao_20_08_2024.rds')
siop_tratado2 %>% names
