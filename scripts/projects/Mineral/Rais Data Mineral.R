####### Rafael Parfitt 22/05/2025
####### Dados RAIS para o relatorio de Oleo e Gas

### Limpando ambiente do R
rm(list=ls())

setwd("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Relatorios\\Mineral\\")
### Escolhendo os Packages (e instalando se for necessÃÂ¡rio)
load.lib <- c("data.table","foreign","haven","dplyr","stargazer","ggplot2","viridis","ggrepel",
              "hrbrthemes","devtools", "jtools","haven","sf","geobr","stringr","scales","readr")

### Instalando e carregando os pacotes solicitados
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib, require, character=TRUE)


### Todos os dados utilizados para criação das bases e figuras estão salvos no share point do FGV CLIMA.
### Primeiro vamos abrir a rais e arrumar as variaveis e depois vamos salvar a base. Logo após, iremos criar as figuras usadas no relatorio.

### Abrindo a rais e transformando em datatable
rais <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais)
gc()
rais <- rais[Salário>0]

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
rais[, trab_mineral := substr(as.character(cnae_2_0), 1, 2) %in% c("05", "07", "08", "09")]
rais[, trab_mineral := as.integer(trab_mineral)]
setDT(rais)

resumo_mun <- rais[, .(
  # Total de trabalhadores no município
  n_tot_trabalhadores = .N,
  
  # Trabalhadores no setor de petróleo
  n_trab = sum(trab_mineral == 1),
  n_nao_trab_oil = sum(trab_mineral == 0),
  
  # Gênero - total e no setor petróleo
  n_homens        = sum(Gênero == "Masculino"),
  n_mulheres      = sum(Gênero == "Feminino"),
  n_homen_oil     = sum(Gênero == "Masculino" & trab_mineral == 1),
  n_mulheres_oil  = sum(Gênero == "Feminino" & trab_mineral == 1),
  
  # Qualificação - total e no setor petróleo
  n_low_skill         = sum(Skill_Class == "Low-skill"),
  n_high_skill        = sum(Skill_Class == "High-skill"),
  n_low_skill_oil     = sum(Skill_Class == "Low-skill" & trab_mineral == 1),
  n_high_skill_oil    = sum(Skill_Class == "High-skill" & trab_mineral == 1),
  
  # Gênero + Qualificação no setor de petróleo
  n_mulher_low_skill_oil    = sum(Gênero == "Feminino" & Skill_Class == "Low-skill" & trab_mineral == 1),
  n_mulher_high_skill_oil   = sum(Gênero == "Feminino" & Skill_Class == "High-skill" & trab_mineral == 1),
  
  n_homem_low_skill_oil     = sum(Gênero == "Masculino" & Skill_Class == "Low-skill" & trab_mineral == 1),
  n_homem_high_skill_oil    = sum(Gênero == "Masculino" & Skill_Class == "High-skill" & trab_mineral == 1),
  
  # Salários - média e faixas no setor petróleo
  salario_medio       = mean(Salário, na.rm = TRUE),
  salario_medio_oil   = mean(Salário[trab_mineral == 1], na.rm = TRUE),
  sal_br_0_2k         = sum(trab_mineral == 1 & Salário <= 2000, na.rm = TRUE),
  sal_br_2_4k         = sum(trab_mineral == 1 & Salário > 2000 & Salário <= 4000, na.rm = TRUE),
  sal_br_4_10k        = sum(trab_mineral == 1 & Salário > 4000 & Salário <= 10000, na.rm = TRUE),
  sal_br_10_30k       = sum(trab_mineral == 1 & Salário > 10000 & Salário <= 30000, na.rm = TRUE),
  sal_br_30k_up       = sum(trab_mineral == 1 & Salário > 30000, na.rm = TRUE)
), by = "Município"]


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
#### Salvando a base final
write_dta(Final_data, "C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Output\\Final_data.dta", version = 13)
Final_data



###################################
############ Figura XX ############
###################################
### Relação entre Salário Médio e Valor Adicionado, setores industriais selecionados no Brasil (2024) 

### Abrindo o data com o Valor Adicionado por empresa, e limpando os dados
VA <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\VTBI\\Valor Adicionado Empresas.csv")
setDT(VA)

### Cotando o que não interessa
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

### Arruma erros no dado e formatos
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
  "13" = "Resto da indústria",
  "14" = "Resto da indústria",
  "15" = "Resto da indústria",
  "16" = "Resto da indústria",
  "17" = "Celulose e papel",
  "18" = "Celulose e papel",
  "19" = "Óleo e Gás",
  "20" = "Químicos",
  "21" = "Químicos",
  "22" = "Resto da indústria",
  "23.2" = "Cimento",
  "23.4" = "Cerâmica",
  "24" = "Metalurgia",
  "25" = "Resto da indústria",
  "26" = "Resto da indústria",
  "27" = "Resto da indústria",
  "28" = "Resto da indústria",
  "29" = "Transporte",
  "30" = "Transporte",
  "31" = "Resto da indústria",
  "32" = "Resto da indústria",
  "33" = "Resto da indústria"
)

nomes_resumidos_dt <- data.table(
  Codigo_cne = names(nomes_agrupados),
  Setor = nomes_agrupados
)

###  Junta VA com os nomes de setor
VA_filtrado <- merge(VA_filtrado, nomes_resumidos_dt, by = "Codigo_cne", all.x = TRUE, sort = FALSE)

### Juntando os dados de VA com salários da RAIS por setor
rais[, Codigo_cne := substr(as.character(cnae_2_0), 1, 2)]
salario_aggregado <- rais[, .(salario_total = mean(Salário, na.rm = TRUE)), by = Codigo_cne]
salario_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
VA_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(VA_filtrado, salario_aggregado, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(salario_total) & !is.na(Setor)]
resultado_final[,VA:=as.numeric(VA)]

####  Agregação por setor (collapse)
resultado_agrupado <- resultado_final[, .(
  salario_total = mean(salario_total, na.rm = TRUE),
  VA = sum(VA, na.rm = TRUE)
), by = Setor]

#### Calcular as medianas gerais para plotar no grafico
mediana_salarial <- median(resultado_agrupado$salario_total, na.rm = TRUE)
mediana_va <- median(resultado_agrupado$VA, na.rm = TRUE)


# Adiciona uma variável para destacar Mineração
resultado_agrupado[, cor := ifelse(Setor == "Mineração", "Mineração", "Outros")]

resultado_agrupado[Setor == "Mineração",          salario_total := 5179.930]
resultado_agrupado[Setor == "Óleo e Gás",         salario_total := 19683.580]
resultado_agrupado[Setor == "Transporte",         salario_total := 5480.242]
resultado_agrupado[Setor == "Cimento",            salario_total := 5695.893]

# Gráfico com ponto da Mineração em laranja
ggplot(resultado_agrupado, aes(x = salario_total, y = VA, label = Setor, color = cor)) +
  geom_point(size = 6) +
  geom_text_repel(
    size = 5,
    max.overlaps = 100,
    box.padding = 0.6,
    point.padding = 0.4,
    force = 1.2,
    force_pull = 0.5,
    segment.size = 0.3
  ) +
  scale_color_manual(values = c("Mineração" = "orange", "Outros" = "steelblue")) +
  geom_vline(xintercept = mediana_salarial, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = mediana_salarial, y = max(resultado_agrupado$VA), 
           label = paste0("Mediana salarial: R$ ", format(round(mediana_salarial, 0), big.mark = ".")),
           angle = 90, vjust = -0.5, hjust = 1, color = "red", size = 4.5) +
  geom_hline(yintercept = mediana_va, linetype = "dashed", color = "blue", size = 1) +
  annotate("text", x = max(resultado_agrupado$salario_total), y = mediana_va, 
           label = paste0("Mediana Valor Adicionado: R$ ", format(round(mediana_va, 0), big.mark = ".", decimal.mark = ",")),
           hjust = 1.1, vjust = -0.5, color = "blue", size = 4.5) +
  scale_x_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = ".")) +
  scale_y_continuous(labels = scales::label_number(decimal.mark = ",", big.mark = ".")) +
  labs(
    x = "Salário médio por setor agregado",
    y = "Valor Agregado (R$)",
    title = "Relação entre Salário Médio e Valor Adicionado por Setor"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")  # Esconde legenda, se quiser


### Print dos dados para o Excel 
resultado_agrupado
write_excel_csv(resultado_agrupado, "Figure 9.csv") 



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
  "13" = "Resto da indústria",
  "14" = "Resto da indústria",
  "15" = "Resto da indústria",
  "16" = "Resto da indústria",
  "17" = "Celulose e papel",
  "18" = "Celulose e papel",
  "19" = "Óleo e Gás",
  "20" = "Químicos",
  "21" = "Químicos",
  "22" = "Resto da indústria",
  "23.2" = "Cimento",
  "23.4" = "Cerâmica",
  "24" = "Metalurgia",
  "25" = "Resto da indústria",
  "26" = "Resto da indústria",
  "27" = "Resto da indústria",
  "28" = "Resto da indústria",
  "29" = "Transporte",
  "30" = "Transporte",
  "31" = "Resto da indústria",
  "32" = "Resto da indústria",
  "33" = "Resto da indústria"
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
salario_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
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

# Criar coluna de cor: "Mineração" = laranja, demais = azul
collapsed_dt[, cor := ifelse(Setor == "Mineração", "Mineração", "Outros")]

# Criar o gráfico com rótulos no topo
ggplot(collapsed_dt, aes(x = reorder(Setor, -metric), y = metric, fill = cor)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(metric, 1)), vjust = -0.2, size = 4) +  # Adiciona os valores acima das barras
  scale_fill_manual(values = c("Mineração" = "orange", "Outros" = "steelblue")) +
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
########## Figura 11 ##########
###############################

### Total massa salarial

### Convertendo corretamente o nome dos municípios para portugues
Final_data[, Mun_name_utf8 := iconv(Mun_name, from = "latin1", to = "UTF-8")]
Final_data[, nome_mun := str_remove(Mun_name_utf8, "Prefeitura Municipal de ")]
Final_data[, nome_mun := str_remove(nome_mun, " - [A-Z]{2}$")]
Final_data[, UF_sigla := UF]
Final_data[, mun_uf := paste0(nome_mun, " - ", UF_sigla)]
Final_data[, n_trab_oil := n_tot_trabalhadores - n_nao_trab_oil]

### Garantir que número de trabalhadores e salários sejam finitos
Final_data <- Final_data[
  is.finite(salario_medio) & is.finite(salario_medio_oil) &
    n_tot_trabalhadores > 0 & n_trab_oil > 0
]

###  Calcular massas salariais totais dos municipios
Final_data[, massa_total := salario_medio * n_tot_trabalhadores]
Final_data[, massa_oil := salario_medio_oil * n_trab_oil]
Final_data[, prop_massa_oil := massa_oil / massa_total]

#### Selecionar os top 15 municipios
top15_massa <- Final_data[order(-prop_massa_oil)][1:20]
top15_massa <- top15_massa[, .(mun_uf, prop_massa_oil)]

### Fazendo a Figura
ggplot(top15_massa, aes(x = reorder(mun_uf, prop_massa_oil), y = prop_massa_oil)) +
  geom_col(fill = "darkorange") +
  geom_text(
    aes(label = scales::percent(prop_massa_oil, accuracy = 0.1)),
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
    subtitle = "",
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
top15_massa
write_excel_csv(top15_massa, "Figure 11.csv") 






##### Mapa geografico 
library(data.table)
library(ggplot2)
library(sf)
library(dplyr)

# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# Agrupa por UF e calcula a % de trabalhadores do setor de óleo
uf_prop <- Final_data[, .(
  total_trab = sum(n_tot_trabalhadores, na.rm = TRUE),
  trab_oil = sum(n_trab_oil, na.rm = TRUE)
), by = UF_sigla]

uf_prop[, prop_oil := trab_oil / total_trab]
library(geobr)

# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_prop, by = c("abbrev_state" = "UF_sigla"))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_oil), color = "gray90", size = 0.3) +  # contorno mais leve
  scale_fill_gradient(
    name = "% trabalhadores em mineral",
    labels = percent_format(accuracy = 0.1),
    low = "#fff5eb", high = "darkorange"  # degrade suave de branco para laranja escuro
  ) +
  labs(
    title = "",
    subtitle = "",
    caption = "",
    fill = "% no setor mineral"
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
  prop_oil = mapa_dados$prop_oil
)

# Save to CSV
write_excel_csv(mapa_export, "Mapa.csv") 





##### Figura adicional particular da mineração

cfem <- data.table(
  Substancia = c(
    "Ferro", "Cobre", "Ouro", "Alumínio", "Níquel", "Lítio", "Nióbio", "Estanho",
    "Zinco", "Manganês", "Cromo", "Columbita-Tantalita", "Grafita", "Vanádio", "Chumbo"
  ),
  CFEM = c(
    5133500286, 324244836, 316558779, 164269712, 59134355, 55074227, 35911539, 33688588,
    18268958, 8775549, 8355706, 7476284, 7355661, 5282451, 4072320
  ),
  Participacao = c(
    83.0, 5.2, 5.1, 2.7, 1.0, 0.9, 0.6, 0.5,
    0.3, 0.14, 0.14, 0.12, 0.12, 0.09, 0.07
  )
)


#### Ordena pela participação
cfem[, Substancia := factor(Substancia, levels = cfem[order(Participacao)]$Substancia)]

cores_personalizadas <- c("#7CD6C2", "#FFA480", "#B0C4FF")  # verde água, laranja claro, azul claro

ggplot(df_figura, aes(x = Categoria, y = Salario_Medio, fill = Categoria)) +
  geom_col(width = 0.7, color = "black") +
  geom_text(aes(label = paste0("R$ ", format(round(Salario_Medio, 2), big.mark = ".", decimal.mark = ","))),
            vjust = -0.4, fontface = "bold", size = 4.2) +
  scale_fill_manual(values = cores_personalizadas) +
  labs(title = "Remuneração Média — Setores Selecionados",
       subtitle = "Brasil — RAIS (elaboração própria)",
       x = NULL, y = "Salário médio (R$)") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.text = element_text(size = 11),
    axis.title.y = element_text(size = 12),
    legend.position = "none"
  )





###########################################
########### Tabela principal ##############
###########################################

####### Rafael Parfitt 22/05/2025
####### Dados RAIS 

#install.packages("remotes")
#remotes::install_github("rfsaldanha/microdatasus", force = TRUE)

### Limpando ambiente do R
rm(list=ls())


### Escolhendo os Packages (e instalando se for necessÃÂ¡rio)
load.lib <- c("data.table","foreign","haven","microdatasus","remotes","dplyr","stargazer","ggplot2","viridis", "ggrepel",
              "hrbrthemes","lmtest","devtools","fixest","modelsummary", "jtools","remotes","rio","haven","sf","geobr")

### Instalando e carregando os pacotes solicitados
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib, require, character=TRUE)

rais <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais)
gc()
rais <- rais[Salário>0]


rais[, Skill_Class := fifelse(cbo_grp %in% 1:2, "High-skill",
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

# Tabela resumo com shares
resumo_setor_brasil <- rais[, .(
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











