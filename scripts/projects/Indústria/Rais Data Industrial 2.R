####### Rafael Parfitt 22/05/2025
####### Dados RAIS para o relatorio de Oleo e Gas

### Limpando ambiente do R
rm(list=ls())


setwd("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Relatorios\\Oleo e Gas\\")
### Escolhendo os Packages (e instalando se for necessÃÂ¡rio)
load.lib <- c("data.table","foreign","haven","dplyr","stargazer","ggplot2","viridis","ggrepel",
              "hrbrthemes","devtools", "jtools","haven","sf","geobr","stringr","scales","readr")

### Instalando e carregando os pacotes solicitados
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib, require, character=TRUE)



### Todos os dados utilizados para criação das bases e figuras estão salvos no share point do FGV CLIMA.
### Primeiro vamos abrir a rais e arrumar as variaveis e depois vamos salvar a base. Logo após, iremos criar as figuras usadas no relatorio.

############################################
########### Tabela principal ###############
############################################


rais <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais)
gc()



rais[, Skill_Class := fifelse(cbo_grp %in% 1:3, "High-skill",
                              fifelse(cbo_grp %in% 4:9, "Low-skill", NA_character_))]
table(rais$Skill_Class)
# Reclassifica para High-skill se escolaridade for alta
rais[Escolaridade %in% c("SUP. COMP", "MESTRADO", "DOUTORADO"), Skill_Class := "High-skill"]
# Reclassifica para Low-skill se escolaridade for muito baixa
rais[Escolaridade %in% c("ANALFABETO", "5.A CO FUND", "ATE 5.A INC", "A 9. FUND"), Skill_Class := "Low-skill"]
rais[, cnae_2_0 := as.character(cnae_2_0)]
rais[, cnae_2_0 := str_trim(cnae_2_0)]
rais[, cnae_2_0 := gsub(" ", "", cnae_2_0)]
rais[, cnae_2_0 := str_pad(cnae_2_0, width = 5, side = "left", pad = "0")]

### Trab oleo e gas
rais[, trab_oil_gas := substr(as.character(cnae_2_0), 1, 4) %in% c("0600","0910","1921","1922")]
rais[, trab_oil_gas := as.integer(trab_oil_gas)]
rais[, trab_eletrico := substr(as.character(cnae_2_0), 1, 3) %in% c("351")]
rais[, trab_eletrico := as.integer(trab_eletrico)]
rais[, trab_cimento := substr(as.character(cnae_2_0), 1, 3) %in% c("232")]
rais[, trab_cimento := as.integer(trab_cimento)]
rais[, trab_metalurgia := substr(as.character(cnae_2_0), 1, 2) %in% c("24")]
rais[, trab_metalurgia := as.integer(trab_metalurgia)]
rais[, trab_transporte := substr(as.character(cnae_2_0), 1, 2) %in% c("29","30")]
rais[, trab_transporte := as.integer(trab_transporte)]
rais[, trab_mineracao := substr(as.character(cnae_2_0), 1, 2) %in% c("05", "07", "08", "09")]
rais[, trab_mineracao := as.integer(trab_mineracao)]
cnaes_industriais <- sprintf("%02d", 10:33)  
rais[, trab_industrial := substr(as.character(cnae_2_0), 1, 2) %in% cnaes_industriais]
rais[, trab_industrial := as.integer(trab_industrial)]


# Define hierarquia e variável categórica única
rais[, setor := "Outros"]
rais[trab_oil_gas == 1, setor := "Oléo e Gás"]
rais[trab_eletrico == 1 & setor == "Outros", setor := "Elétrico"]
rais[trab_cimento == 1 & setor == "Outros", setor := "Cimento"]
rais[trab_metalurgia == 1 & setor == "Outros", setor := "Metalurgia"]
rais[trab_transporte == 1 & setor == "Outros", setor := "Transporte"]
rais[trab_mineracao == 1 & setor == "Outros", setor := "Mineração"]
rais[trab_industrial == 1 & setor == "Outros", setor := "Indústria"]

# Tabela resumo com shares
resumo_setor <- rais[, .(
  n_total_trabalhadores = (.N)/1000,
  share_mulheres        = sum(Gênero == "Feminino", na.rm = TRUE) / .N,
  share_high_skill      = sum(Skill_Class == "High-skill", na.rm = TRUE) / .N,
  salario_medio         = mean(Salário, na.rm = TRUE),
  salario_mediana       = median(Salário, na.rm = TRUE)
), by = setor]

# Opcional: transformar shares em porcentagem
resumo_setor[, `:=`(
  share_mulheres = round(100 * share_mulheres, 1),
  share_high_skill = round(100 * share_high_skill, 1)
)]

resumo_setor
write_excel_csv(resumo_setor, "Table X.csv") 


##########################################
###### Base da rais para as figuras ######
##########################################

### Abrindo a rais e transformando em datatable
rais <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais)
gc()


### Definindo High and Low skill using o CBO da RAIS
rais[, Skill_Class := fifelse(cbo_grp %in% 1:3, "High-skill",
                              fifelse(cbo_grp %in% 4:9, "Low-skill", NA_character_))]
table(rais$Skill_Class)

# Reclassifica para High-skill se escolaridade for alta
rais[Escolaridade %in% c("SUP. COMP", "MESTRADO", "DOUTORADO"), Skill_Class := "High-skill"]

# Reclassifica para Low-skill se escolaridade for muito baixa
rais[Escolaridade %in% c("ANALFABETO", "5.A CO FUND", "ATE 5.A INC", "A 9. FUND"), Skill_Class := "Low-skill"]

### Arrumando a variavel que identifica o cnae dos trabalhadores, pois essa não tinha zeros do lado esquerdo.
rais[, cnae_2_0 := as.character(cnae_2_0)]
rais[, cnae_2_0 := str_trim(cnae_2_0)]
rais[, cnae_2_0 := gsub(" ", "", cnae_2_0)]
rais[, cnae_2_0 := str_pad(cnae_2_0, width = 5, side = "left", pad = "0")]

### Trab oleo e gas
rais[, trab_cimento := substr(as.character(cnae_2_0), 1, 3) %in% c("232")]
rais[, trab_cimento := as.integer(trab_cimento)]
rais[, trab_metalurgia := substr(as.character(cnae_2_0), 1, 2) %in% c("24")]
rais[, trab_metalurgia := as.integer(trab_metalurgia)]

setDT(rais)

resumo_mun <- rais[, .(
  # Total de trabalhadores no município
  n_tot_trabalhadores = .N,
  
  # Trabalhadores no setor de petróleo
  trab_cimento = sum(trab_cimento == 1),
  trab_not_cimento = sum(trab_cimento == 0),
  trab_metalurgia = sum(trab_metalurgia == 1),
  trab_not_metalurgia = sum(trab_metalurgia == 0),
  
  # Gênero - total e no setor petróleo
  n_homens        = sum(Gênero == "Masculino"),
  n_mulheres      = sum(Gênero == "Feminino"),
  n_homen_cimento    = sum(Gênero == "Masculino" & trab_cimento == 1),
  n_mulheres_cimento  = sum(Gênero == "Feminino" & trab_cimento == 1),
  n_homen_metalurgia    = sum(Gênero == "Masculino" & trab_metalurgia == 1),
  n_mulheres_metalurgia  = sum(Gênero == "Feminino" & trab_metalurgia == 1),
  
  # Qualificação - total e no setor petróleo
  n_low_skill         = sum(Skill_Class == "Low-skill"),
  n_high_skill        = sum(Skill_Class == "High-skill"),
  n_low_skill_metalurgia    = sum(Skill_Class == "Low-skill" & trab_metalurgia == 1),
  n_high_skill_metalurgia   = sum(Skill_Class == "High-skill" & trab_metalurgia == 1),
  n_low_skill_cimento    = sum(Skill_Class == "Low-skill" & trab_cimento == 1),
  n_high_skill_cimento    = sum(Skill_Class == "High-skill" & trab_cimento == 1),
  
  # Gênero + Qualificação no setor de petróleo
  n_mulher_low_skill_metalurgia    = sum(Gênero == "Feminino" & Skill_Class == "Low-skill" & trab_metalurgia == 1),
  n_mulher_high_skill_metalurgia   = sum(Gênero == "Feminino" & Skill_Class == "High-skill" & trab_metalurgia == 1),
  n_mulher_low_skill_cimento    = sum(Gênero == "Feminino" & Skill_Class == "Low-skill" & trab_cimento == 1),
  n_mulher_high_skill_cimento   = sum(Gênero == "Feminino" & Skill_Class == "High-skill" & trab_cimento == 1),
  
  n_homem_low_skill_metalurgia     = sum(Gênero == "Masculino" & Skill_Class == "Low-skill" & trab_metalurgia == 1),
  n_homem_high_skill_metalurgia    = sum(Gênero == "Masculino" & Skill_Class == "High-skill" & trab_metalurgia == 1),
  n_homem_low_skill_cimento     = sum(Gênero == "Masculino" & Skill_Class == "Low-skill" & trab_cimento == 1),
  n_homem_high_skill_cimento    = sum(Gênero == "Masculino" & Skill_Class == "High-skill" & trab_cimento == 1),
  
  # Salários - média e faixas no setor petróleo
  salario_medio       = mean(Salário, na.rm = TRUE),
  salario_medio_metalurgia   = mean(Salário[trab_metalurgia == 1], na.rm = TRUE),
  salario_medio_cimento   = mean(Salário[trab_cimento == 1], na.rm = TRUE)), by = "Município"]


### Arrumando os zeros e algumas variaveis do dado
resumo_mun[is.na(resumo_mun)] <- 0

setnames(resumo_mun, old = "Município", new = "Cod_IBGE")
#### Colocando o nome dos municipios para dentro
Data_aux <- read.dta("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Output\\final_wide.dta")
setDT(Data_aux)
Data_aux[, Cod_IBGE := substr(as.character(Cod_IBGE), 1, 6)]
Data_aux[, Cod_IBGE := as.numeric(Cod_IBGE)]
Final_data <- merge(Data_aux,resumo_mun, by = "Cod_IBGE")
setnames(Final_data, old = "Instituição", new = "Mun_name")
setnames(Final_data, old = "População", new = "Pop_tot")
Final_data[, c("Receita_cota_especial_petroleo",
               "Receita_cota_petroleo",
               "Receita_total") := NULL]

Final_data


##############################
########## Figura 1 ##########
##############################

### Total massa salarial

### Convertendo corretamente o nome dos municípios para portugues
Final_data[, Mun_name_utf8 := iconv(Mun_name, from = "latin1", to = "UTF-8")]
Final_data[, nome_mun := str_remove(Mun_name_utf8, "Prefeitura Municipal de ")]
Final_data[, nome_mun := str_remove(nome_mun, " - [A-Z]{2}$")]
Final_data[, UF_sigla := UF]
Final_data[, mun_uf := paste0(nome_mun, " - ", UF_sigla)]

### Garantir que número de trabalhadores e salários sejam finitos
Final_data <- Final_data[
  is.finite(salario_medio) & is.finite(salario_medio_metalurgia) &
    n_tot_trabalhadores > 0 & trab_metalurgia > 0
]

###  Calcular massas salariais totais dos municipios
Final_data[, massa_total := salario_medio * n_tot_trabalhadores]
Final_data[, massa_metalurgia := salario_medio_metalurgia * trab_metalurgia]
Final_data[, massa_cimento := salario_medio_cimento * trab_cimento]
Final_data[, prop_massa_metalurgia := massa_metalurgia / massa_total]
Final_data[, prop_massa_cimento := massa_cimento / massa_total]

#### Selecionar os top 15 municipios
top15_massa_metargia <- Final_data[order(-prop_massa_metalurgia)][1:15]
top15_massa_metargia <- top15_massa_metargia[, .(mun_uf, prop_massa_metalurgia)]

#### Selecionar os top 15 municipios
top15_massa_cimento <- Final_data[order(-prop_massa_cimento)][1:15]
top15_massa_cimento <- top15_massa_cimento[, .(mun_uf, prop_massa_cimento)]


### Fazendo a Figura A
ggplot(top15_massa_metargia, aes(x = reorder(mun_uf, prop_massa_metalurgia), y = prop_massa_metalurgia)) +
  geom_col(fill = "darkorange") +
  geom_text(
    aes(label = scales::percent(prop_massa_metalurgia, accuracy = 0.1)),
    hjust = -0.1,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 0.1),
    expand = expansion(mult = c(0, 0.15))  # garante espaço à direita para os textos
  ) +
  labs(
    title = "",
    subtitle = "Proporção da Massa Salarial do Setor de Metalurgia sobre o Total Municipal",
    x = NULL,
    y = "Proporção da Massa Salarial (%)"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

### Print dos dados para o Excel
top15_massa_metargia
write_excel_csv(top15_massa_metargia, "Figure 1A.csv")


### Fazendo a Figura B
ggplot(top15_massa_cimento, aes(x = reorder(mun_uf, prop_massa_cimento), y = prop_massa_cimento)) +
  geom_col(fill = "darkorange") +
  geom_text(
    aes(label = scales::percent(prop_massa_cimento, accuracy = 0.1)),
    hjust = -0.1,
    size = 4
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 0.1),
    expand = expansion(mult = c(0, 0.15))  # garante espaço à direita para os textos
  ) +
  labs(
    title = "",
    subtitle = "Proporção da Massa Salarial do Setor de Cimento sobre o Total Municipal",
    x = NULL,
    y = "Proporção da Massa Salarial (%)"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

### Print dos dados para o Excel
top15_massa_cimento
write_excel_csv(top15_massa, "Figure 1B.csv")




###########################################
########## MAPA ESTADUAL Emprego ##########
###########################################


# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# 1) Total do SETOR por UF
uf_sector <- Final_data[, .(
  trab_metalurgia = sum(trab_metalurgia, na.rm = TRUE)
), by = UF_sigla]

# 2) Participação do estado no TOTAL NACIONAL do SETOR (soma = 100%)
uf_sector[, prop_metalurgia := trab_metalurgia / sum(trab_metalurgia, na.rm = TRUE)]
# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_sector, by = c("abbrev_state" = "UF_sigla"))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_metalurgia), color = "gray90", size = 0.3) +
  scale_fill_gradientn(
    name = "% trabalhadores em Industrias",
    labels = percent_format(accuracy = 0.1),
    colours = c("#fff5eb", "#fee0d2", "#fc9272", "#de2d26"), # degrade mais forte
    values = scales::rescale(c(0, 0.01, 0.05, 0.10, max(mapa_dados$prop_indust, na.rm = TRUE)))
  ) +
  labs(
    title = "Proporção de Trabalhadores no Setor de Metalurgia por Estado",
    subtitle = "",
    caption = "",
    fill = "% trabalhadores no Setor Industrial"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(size = 9, hjust = 1, color = "gray40"),
    legend.position = "right",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )
mapa_dados
mapa_export <- data.frame(
  estado = mapa_dados$name_state,
  prop_indust = round(mapa_dados$prop_oil, 4)
)
mapa_export
# Save to CSV
write_excel_csv(mapa_export, "Mapa.csv") 



###########################################
########## MAPA ESTADUAL Emprego ##########
###########################################


# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# 1) Total do SETOR por UF
uf_sector <- Final_data[, .(
  trab_cimento = sum(trab_cimento, na.rm = TRUE)
), by = UF_sigla]

# 2) Participação do estado no TOTAL NACIONAL do SETOR (soma = 100%)
uf_sector[, prop_cimento := trab_cimento / sum(trab_cimento, na.rm = TRUE)]
# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_sector, by = c("abbrev_state" = "UF_sigla"))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_cimento), color = "gray90", size = 0.3) +
  scale_fill_gradientn(
    name = "% trabalhadores em Industrias",
    labels = percent_format(accuracy = 0.1),
    colours = c("#fff5eb", "#fee0d2", "#fc9272", "#de2d26"), # degrade mais forte
    values = scales::rescale(c(0, 0.01, 0.05, 0.10, max(mapa_dados$prop_indust, na.rm = TRUE)))
  ) +
  labs(
    title = "Proporção de Trabalhadores no Setor de Cimento por Estado",
    subtitle = "",
    caption = "",
    fill = "% trabalhadores no Setor Industrial"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(size = 9, hjust = 1, color = "gray40"),
    legend.position = "right",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )
mapa_dados
mapa_export <- data.frame(
  estado = mapa_dados$name_state,
  prop_indust = round(mapa_dados$prop_oil, 4)
)
mapa_export
# Save to CSV
write_excel_csv(mapa_export, "Mapa.csv") 




###########################################
########## MAPA ESTADUAL Salario ##########
###########################################


# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# 1) Total do SETOR por UF
uf_sector <- Final_data[, .(
  salario_medio_metalurgia = sum(salario_medio_metalurgia, na.rm = TRUE)
), by = UF_sigla]

# 2) Participação do estado no TOTAL NACIONAL do SETOR (soma = 100%)
uf_sector[, prop_metalurgia := salario_medio_metalurgia / sum(salario_medio_metalurgia, na.rm = TRUE)]
# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_sector, by = c("abbrev_state" = "UF_sigla"))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_metalurgia), color = "gray90", size = 0.3) +
  scale_fill_gradientn(
    name = "% Massa Salarial Total das em Industrias",
    labels = percent_format(accuracy = 0.1),
    colours = c("#fff5eb", "#fee0d2", "#fc9272", "#de2d26"), # degrade mais forte
    values = scales::rescale(c(0, 0.01, 0.05, 0.10, max(mapa_dados$prop_indust, na.rm = TRUE)))
  ) +
  labs(
    title = "Proporção de Massa Salarial no Setor de Metalurgia por Estados",
    subtitle = "",
    caption = "",
    fill = "% de Massa Salarial Setor Industrial"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(size = 9, hjust = 1, color = "gray40"),
    legend.position = "right",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )
mapa_dados
mapa_export <- data.frame(
  estado = mapa_dados$name_state,
  prop_indust = round(mapa_dados$prop_oil, 4)
)
mapa_export




###########################################
########## MAPA ESTADUAL Salario ##########
###########################################


# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# 1) Total do SETOR por UF
uf_sector <- Final_data[, .(
  salario_medio_cimento = sum(salario_medio_cimento, na.rm = TRUE)
), by = UF_sigla]

# 2) Participação do estado no TOTAL NACIONAL do SETOR (soma = 100%)
uf_sector[, prop_cimento := salario_medio_cimento / sum(salario_medio_cimento, na.rm = TRUE)]
# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_sector, by = c("abbrev_state" = "UF_sigla"))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_cimento), color = "gray90", size = 0.3) +
  scale_fill_gradientn(
    name = "% Massa Salarial Total das em Industrias",
    labels = percent_format(accuracy = 0.1),
    colours = c("#fff5eb", "#fee0d2", "#fc9272", "#de2d26"), # degrade mais forte
    values = scales::rescale(c(0, 0.01, 0.05, 0.10, max(mapa_dados$prop_indust, na.rm = TRUE)))
  ) +
  labs(
    title = "Proporção de Massa Salarial no Setor de Cimento por Estados",
    subtitle = "",
    caption = "",
    fill = "% de Massa Salarial Setor Industrial"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    plot.caption = element_text(size = 9, hjust = 1, color = "gray40"),
    legend.position = "right",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )
mapa_dados
mapa_export <- data.frame(
  estado = mapa_dados$name_state,
  prop_indust = round(mapa_dados$prop_oil, 4)
)
mapa_export




###############################
########## Figura XX ##########
###############################

#### Intensidade de emprego por setor industrial em relação ao Valor Adicionado (por 1.000.000 unidades de VA)

#### Primeiro abrindo os dados e limpando o que não vamos usar
VA <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\VTBI\\Valor Adicionado Empresas.csv")
setDT(VA)
VA <- VA[13:.N]
VA <- VA[, c(1, 6), with = FALSE]
setnames(VA, c("Codigo_cne", "VA"))
VA_filtrado <- VA[nchar(as.character(Codigo_cne)) == 2]

### Arumando valores errados
substituicoes <- data.table(
  Codigo_cne = c("15", "17", "19", "21", "22", "25", "26", "27", "29", "30", "33"),
  VA = c(
    "23 185 001",
    "70 948 630",
    "525 914 629",
    "46 796 998",
    "63 727 226",
    "53 519 232",
    "42 553 465",
    "48 001 516",
    "128 128 340",
    "23 291 879",
    "21 677 594"
  )
)
setDT(VA_filtrado)  # garante que é um data.table
VA_filtrado[substituicoes, on = "Codigo_cne", VA := i.VA]
VA_filtrado[, VA := gsub(" ", "", VA)]
VA_filtrado[,VA:=as.numeric(VA)]
VA_filtrado <- rbind(
  VA_filtrado,
  data.table(Codigo_cne = c("09.1","23.4","23.2"), VA = c("6483390","11010821","9859505")))

### Substitui os nomes resumidos por categorias agregadas
nomes_agrupados <- c(
  "05" = "Mineração",
  "06" = "Óleo e Gás",
  "07" = "Mineração",
  "08" = "Mineração",
  "09" = "Mineração",
  "09.1" = "Óleo e Gás",
  "10" = "Alimentos, bebidas e fumo",
  "11" = "Alimentos, bebidas e fumo",
  "12" = "Alimentos, bebidas e fumo",
  "13" = "Industrial",
  "14" = "Industrial",
  "15" = "Industrial",
  "16" = "Industrial",
  "17" = "Celulose e papel",
  "18" = "Celulose e papel",
  "19" = "Óleo e Gás",
  "20" = "Químicos",
  "21" = "Químicos",
  "22" = "Industrial",
  "23.2" = "Cimento",
  "23.4" = "Cerâmica",
  "24" = "Metalurgia",
  "25" = "Industrial",
  "26" = "Industrial",
  "27" = "Industrial",
  "28" = "Industrial",
  "29" = "Transporte",
  "30" = "Transporte",
  "31" = "Industrial",
  "32" = "Industrial",
  "33" = "Industrial"
)

nomes_resumidos_dt <- data.table(
  Codigo_cne = names(nomes_agrupados),
  Setor = nomes_agrupados
)

### Juntando o VA com os nomes de setor
Valor_Adicionado_filtrado <- merge(VA_filtrado, nomes_resumidos_dt, by = "Codigo_cne", all.x = TRUE, sort = FALSE)

### Juntando com o valor dos salarios com a RAIS e arrumando o codigo
rais[, Codigo_cne := substr(as.character(cnae_2_0), 1, 2)]
empregos_aggregado <- rais[, .(numero_empregos = .N), by = Codigo_cne]
empregos_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
Valor_Adicionado_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(Valor_Adicionado_filtrado, empregos_aggregado, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(numero_empregos) & !is.na(Setor)]
resultado_final[,VA:=as.numeric(VA)]


#### Fazendo a agregação dos valores para os setores (collapsing)
collapsed_dt <- resultado_final[, .(
  VA_total = sum(VA, na.rm = TRUE),
  numero_empregos_total = sum(numero_empregos, na.rm = TRUE)), by = Setor]

### Calcular a métrica (numero_empregos / VTBI) * 1000000
collapsed_dt$metric <- (collapsed_dt$numero_empregos / collapsed_dt$VA) * 1000000


### Ordenar por métrica, se quiser um gráfico mais legível
collapsed_dt <- collapsed_dt[order(-metric)]

# Criar coluna de cor: Cimento e Metalurgia em laranja, demais em azul
collapsed_dt[, cor := ifelse(Setor %in% c("Cimento", "Metalurgia"), "Destaque", "Outros")]

# Criar o gráfico com rótulos no topo
ggplot(collapsed_dt, aes(x = reorder(Setor, -metric), y = metric, fill = cor)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(metric, 1)), vjust = -0.2, size = 4) +  # Adiciona os valores acima das barras
  scale_fill_manual(values = c("Destaque" = "orange", "Outros" = "steelblue")) +
  labs(
    title = "Empregos por Valor Adicionado por Setor",
    x = "Setor",
    y = "Número de Empregos / VA * 1.000.000"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 12),
    legend.position = "none"
  )

### Print dos dados para o Excel 
collapsed_dt
write_excel_csv(collapsed_dt, "Figure 10.csv") 




###############################
########## Figura YY ##########
###############################

#### Massa salarial e emprego por setores

#### Primeiro abrindo os dados e limpando o que não vamos usar
VA <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\VTBI\\Valor Adicionado Empresas.csv")
setDT(VA)
VA <- VA[13:.N]
VA <- VA[, c(1, 6), with = FALSE]
setnames(VA, c("Codigo_cne", "VA"))
VA_filtrado <- VA[nchar(as.character(Codigo_cne)) == 2]

### Arumando valores errados
substituicoes <- data.table(
  Codigo_cne = c("15", "17", "19", "21", "22", "25", "26", "27", "29", "30", "33"),
  VA = c(
    "23 185 001",
    "70 948 630",
    "525 914 629",
    "46 796 998",
    "63 727 226",
    "53 519 232",
    "42 553 465",
    "48 001 516",
    "128 128 340",
    "23 291 879",
    "21 677 594"
  )
)
setDT(VA_filtrado)  # garante que é um data.table
VA_filtrado[substituicoes, on = "Codigo_cne", VA := i.VA]
VA_filtrado[, VA := gsub(" ", "", VA)]
VA_filtrado[,VA:=as.numeric(VA)]
VA_filtrado <- rbind(
  VA_filtrado,
  data.table(Codigo_cne = c("09.1","23.4","23.2"), VA = c("6483390","11010821","9859505")))

### Substitui os nomes resumidos por categorias agregadas
nomes_agrupados <- c(
  "05" = "Mineração",
  "06" = "Óleo e Gás",
  "07" = "Mineração",
  "08" = "Mineração",
  "09" = "Mineração",
  "09.1" = "Óleo e Gás",
  "10" = "Alimentos, bebidas e fumo",
  "11" = "Alimentos, bebidas e fumo",
  "12" = "Alimentos, bebidas e fumo",
  "13" = "Industrial",
  "14" = "Industrial",
  "15" = "Industrial",
  "16" = "Industrial",
  "17" = "Celulose e papel",
  "18" = "Celulose e papel",
  "19" = "Óleo e Gás",
  "20" = "Químicos",
  "21" = "Químicos",
  "22" = "Industrial",
  "23.2" = "Cimento",
  "23.4" = "Cerâmica",
  "24" = "Metalurgia",
  "25" = "Industrial",
  "26" = "Industrial",
  "27" = "Industrial",
  "28" = "Industrial",
  "29" = "Transporte",
  "30" = "Transporte",
  "31" = "Industrial",
  "32" = "Industrial",
  "33" = "Industrial"
)

nomes_resumidos_dt <- data.table(
  Codigo_cne = names(nomes_agrupados),
  Setor = nomes_agrupados
)

### Juntando o VA com os nomes de setor
Valor_Adicionado_filtrado <- merge(VA_filtrado, nomes_resumidos_dt, by = "Codigo_cne", all.x = TRUE, sort = FALSE)

### Juntando com o valor dos salarios com a RAIS e arrumando o codigo
rais[, Codigo_cne := substr(as.character(cnae_2_0), 1, 2)]
empregos_aggregado <- rais[, .( numero_empregos = .N, salario_total = sum(Salário, na.rm = TRUE),
                                numero_empregos_low  = sum(Skill_Class == "Low-skill", na.rm = TRUE),
                                numero_empregos_high = sum(Skill_Class == "High-skill", na.rm = TRUE),
                                salario_low  = sum(Salário * (Skill_Class == "Low-skill"), na.rm = TRUE),
                                salario_high = sum(Salário * (Skill_Class == "High-skill"), na.rm = TRUE),
                                numero_empregos_mulher = sum(Gênero == "Feminino", na.rm = TRUE),
                                numero_empregos_homem  = sum(Gênero == "Masculino", na.rm = TRUE),
                                salario_mulher = sum(Salário * (Gênero == "Feminino"), na.rm = TRUE),
                                salario_homem  = sum(Salário * (Gênero == "Masculino"), na.rm = TRUE)), 
                           by = Codigo_cne]

empregos_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
Valor_Adicionado_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(Valor_Adicionado_filtrado, empregos_aggregado, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(numero_empregos) & !is.na(Setor)]
resultado_final[,VA:=NULL]
resultado_final

collapsed_final <- resultado_final[, .(numero_empregos_total = sum(numero_empregos, na.rm = TRUE), 
                                       salario_total         = sum(salario_total, na.rm = TRUE),
                                       numero_empregos_low   = sum(numero_empregos_low, na.rm = TRUE),
                                       numero_empregos_high  = sum(numero_empregos_high, na.rm = TRUE),
                                       salario_low           = sum(salario_low, na.rm = TRUE),
                                       salario_high          = sum(salario_high, na.rm = TRUE),
                                       numero_empregos_mulher = sum(numero_empregos_mulher, na.rm = TRUE),
                                       numero_empregos_homem  = sum(numero_empregos_homem, na.rm = TRUE),
                                       salario_mulher         = sum(salario_mulher, na.rm = TRUE),
                                       salario_homem          = sum(salario_homem, na.rm = TRUE)), 
                                       by = Setor]

collapsed_dt <- collapsed_final
collapsed_dt[, perc_empregos := numero_empregos_total / sum(numero_empregos_total)]
collapsed_dt[, perc_salario := salario_total / sum(salario_total)]

# Criar coluna de cor: "Mineração" = laranja, demais = azul
collapsed_dt[, cor := ifelse(Setor %in% c("Cimento", "Metalurgia"), "Destaque", "Outros")]

# criar variável "Setor_group" para destacar Industrial
collapsed_dt[, Setor_group := ifelse(Setor %in% c("Cimento", "Metalurgia"), "Destaque", "Outros")]

# Figura 1: % de empregos (barras verticais)
ggplot(collapsed_dt, aes(x = reorder(Setor, perc_empregos), 
                         y = perc_empregos, fill = Setor_group)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("Destaque" = "orange", "Outros" = "steelblue")) +
  labs(x = "Setor", y = "% do total de empregos",
       title = "Distribuição percentual do número de trabalhadores por setor") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

# Figura 2: % da massa salarial (barras verticais)
ggplot(collapsed_dt, aes(x = reorder(Setor, perc_salario), 
                         y = perc_salario, fill = Setor_group)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("Destaque" = "orange", "Outros" = "steelblue")) +
  labs(x = "Setor", y = "% da massa salarial",
       title = "Distribuição percentual da massa salarial por setor") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")



### Criar percentuais por setor (low vs high)
collapsed_dt[, perc_empregos_low  := numero_empregos_low / sum(numero_empregos_low)]
collapsed_dt[, perc_empregos_high := numero_empregos_high / sum(numero_empregos_high)]
collapsed_dt[, perc_salario_low   := salario_low / sum(salario_low)]
collapsed_dt[, perc_salario_high  := salario_high / sum(salario_high)]

# --------- FIGURA 1: Empregos Low vs High ---------
empregos_long <- melt(
  collapsed_dt,
  id.vars = "Setor",
  measure.vars = c("perc_empregos_low", "perc_empregos_high"),
  variable.name = "Skill",
  value.name = "Percentual"
)

# Renomear rótulos
empregos_long[, Skill := fifelse(Skill == "perc_empregos_low", "Low-skill", "High-skill")]

ggplot(empregos_long, aes(x = reorder(Setor, Percentual), 
                          y = Percentual, fill = Skill)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("Low-skill" = "steelblue", "High-skill" = "orange")) +
  labs(x = "Setor", y = "% do total de empregos",
       title = "Distribuição percentual de trabalhadores por setor (Low vs High skill)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


write_excel_csv(salario_long, "Figura 13 A.csv") 
salario_long


# --------- FIGURA 2: Salários Low vs High ---------
salario_long <- melt(
  collapsed_dt,
  id.vars = "Setor",
  measure.vars = c("perc_salario_low", "perc_salario_high"),
  variable.name = "Skill",
  value.name = "Percentual"
)

salario_long[, Skill := fifelse(Skill == "perc_salario_low", "Low-skill", "High-skill")]

ggplot(salario_long, aes(x = reorder(Setor, Percentual), 
                         y = Percentual, fill = Skill)) +
  geom_col(position = "dodge") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("Low-skill" = "steelblue", "High-skill" = "orange")) +
  labs(x = "Setor", y = "% da massa salarial",
       title = "Distribuição percentual da massa salarial por setor (Low vs High skill)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


write_excel_csv(salario_long, "Figura 13 B.csv") 
salario_long






























