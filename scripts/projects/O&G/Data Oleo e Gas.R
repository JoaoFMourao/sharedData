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
rais[, trab_oil_gas := substr(as.character(cnae_2_0), 1, 4) %in% c("0600","0910","1910","1921","1922")]
rais[, trab_oil_gas := as.integer(trab_oil_gas)]
setDT(rais)

resumo_mun <- rais[, .(
  # Total de trabalhadores no município
  n_tot_trabalhadores = .N,
  
  # Trabalhadores no setor de petróleo
  n_trab = sum(trab_oil_gas == 1),
  n_nao_trab_oil = sum(trab_oil_gas == 0),
  
  # Gênero - total e no setor petróleo
  n_homens        = sum(Gênero == "Masculino"),
  n_mulheres      = sum(Gênero == "Feminino"),
  n_homen_oil     = sum(Gênero == "Masculino" & trab_oil_gas == 1),
  n_mulheres_oil  = sum(Gênero == "Feminino" & trab_oil_gas == 1),
  
  # Qualificação - total e no setor petróleo
  n_low_skill         = sum(Skill_Class == "Low-skill"),
  n_high_skill        = sum(Skill_Class == "High-skill"),
  n_low_skill_oil     = sum(Skill_Class == "Low-skill" & trab_oil_gas == 1),
  n_high_skill_oil    = sum(Skill_Class == "High-skill" & trab_oil_gas == 1),
  
  # Gênero + Qualificação no setor de petróleo
  n_mulher_low_skill_oil    = sum(Gênero == "Feminino" & Skill_Class == "Low-skill" & trab_oil_gas == 1),
  n_mulher_high_skill_oil   = sum(Gênero == "Feminino" & Skill_Class == "High-skill" & trab_oil_gas == 1),
  
  n_homem_low_skill_oil     = sum(Gênero == "Masculino" & Skill_Class == "Low-skill" & trab_oil_gas == 1),
  n_homem_high_skill_oil    = sum(Gênero == "Masculino" & Skill_Class == "High-skill" & trab_oil_gas == 1),
  
  # Salários - média e faixas no setor petróleo
  salario_medio       = mean(Salário, na.rm = TRUE),
  salario_medio_oil   = mean(Salário[trab_oil_gas == 1], na.rm = TRUE),
  sal_br_0_2k         = sum(trab_oil_gas == 1 & Salário <= 2000, na.rm = TRUE),
  sal_br_2_4k         = sum(trab_oil_gas == 1 & Salário > 2000 & Salário <= 4000, na.rm = TRUE),
  sal_br_4_10k        = sum(trab_oil_gas == 1 & Salário > 4000 & Salário <= 10000, na.rm = TRUE),
  sal_br_10_30k       = sum(trab_oil_gas == 1 & Salário > 10000 & Salário <= 30000, na.rm = TRUE),
  sal_br_30k_up       = sum(trab_oil_gas == 1 & Salário > 30000, na.rm = TRUE)
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
############ Figura 9 #############
###################################
# Municípios com maior grau de dependência do setor de Óleo e Gás – Top 20 em 2023 #


Finbra <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\Finbra\\finbra.csv", encoding = "Latin-1")
Finbra[, Conta := as.character(Conta)]
Finbra[, Coluna := as.character(Coluna)]
Finbra[, Coluna := as.character(Coluna)]
Finbra_filtrada <- Finbra[Coluna %in% c("Receitas Brutas Realizadas")]
Finbra_filtrada <- Finbra[Conta %in% c("1.0.0.0.00.0.0 - Receitas Correntes", "1.7.1.2.52.0.0 - Cota-parte da Compensação Financeira pela Produção de Petróleo")]
Finbra_filtrada[, Valor := as.numeric(gsub(",", ".", Valor))]



# Criar coluna 'tipo' com base na Conta
Finbra_filtrada[, tipo := fifelse(grepl("^1\\.0\\.0\\.0\\.00\\.0\\.0", Conta), "receita_total",
                                  fifelse(grepl("^1\\.7\\.1\\.2\\.52\\.0\\.0", Conta), "cota_petroleo", NA_character_))]

# Somar por município (Cod.IBGE) e tipo de receita
soma_por_municipio <- Finbra_filtrada[!is.na(tipo),
                                      .(soma_valor = sum(Valor, na.rm = TRUE)),
                                      by = .(Cod.IBGE, tipo)]

# Transformar de long para wide (receita_total e cota_petroleo nas colunas)
soma_wide <- dcast(soma_por_municipio, Cod.IBGE ~ tipo, value.var = "soma_valor")

# Calcular o ratio
soma_wide[, ratio_petroleo := cota_petroleo / receita_total]

# Visualizar os resultados
soma_wide[order(-ratio_petroleo)]

# Criar uma tabela auxiliar com uma linha por município
info_municipio <- unique(Finbra_filtrada[, .(Cod.IBGE, Instituição, UF)])

# Fazer o merge com a tabela final
resultado_final <- merge(soma_wide, info_municipio, by = "Cod.IBGE", all.x = TRUE)

# Organizar colunas (opcional)
setcolorder(resultado_final, c("Cod.IBGE", "Instituição", "UF", "cota_petroleo", "receita_total", "ratio_petroleo"))

# Visualizar
resultado_final[order(-ratio_petroleo)][1:10]


# Seleciona os top 15 e simplifica o nome do município
top15 <- resultado_final[order(-ratio_petroleo)][1:20]
top15[, municipio := gsub("Prefeitura Municipal de ", "", Instituição)]
top15[, municipio := factor(municipio, levels = municipio[order(ratio_petroleo)])]

# Plot com melhorias visuais
ggplot(top15, aes(x = municipio, y = ratio_petroleo, fill = UF)) +
  geom_col(width = 0.7, color = "black") +
  geom_text(aes(label = percent(ratio_petroleo, accuracy = 1)),
            hjust = -0.05, size = 4.2) +
  coord_flip() +
  scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.15))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    #title = "Top 15 Municípios Mais Dependentes da Cota-parte do Petróleo",
    #subtitle = "Proporção da receita corrente vinda da compensação pela produção de petróleo (2023)",
    x = NULL,
    y = "Dependência (%)",
    fill = "UF"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
    axis.text.y = element_text(size = 12),
    legend.position = "right"
  )


### Print dos dados para o Excel 
top15
write_excel_csv(top15, "Figure 9.csv") 

  
  
####################################
############ Figura 10 #############
####################################
  ### Municípios com maior grau de dependência do setor de Óleo e Gás – Top 20 em 2023 #
  
  ### Selecionar top 20 municípios com maior arrecadação absoluta de petróleo
  top20_valor <- resultado_final[!is.na(cota_petroleo)][order(-cota_petroleo)][1:20]
  
  ### Limpar nome do município
  top20_valor[, municipio := gsub("Prefeitura Municipal de ", "", Instituição)]
  top20_valor[, municipio := factor(municipio, levels = municipio[order(cota_petroleo)])]
  
  ### Plotting the figure
  ggplot(top20_valor, aes(x = municipio, y = cota_petroleo, fill = UF)) +
    geom_col(width = 0.7, color = "black") +
    geom_text(aes(label = paste0("R$ ", format(round(cota_petroleo / 1e6, 1), decimal.mark = ","), " mi")),
              hjust = -0.05, size = 4.2) +
    coord_flip() +
    scale_y_continuous(labels = label_number(scale = 1e-6, suffix = " mi", big.mark = ".", decimal.mark = ","), 
                       expand = expansion(mult = c(0, 0.15))) +
    scale_fill_brewer(palette = "Set2") +
    labs(
      #title = "Top 20 Municípios com Maior Arrecadação de Petróleo (Valor Absoluto)",
      #subtitle = "Cota-parte da Compensação Financeira pela Produção de Petróleo (2023)",
      x = NULL,
      y = "Receita (R$ milhões)",
      fill = "UF"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 12, margin = margin(b = 10)),
      axis.text.y = element_text(size = 12),
      legend.position = "right"
    )

  
### Print dos dados para o Excel
top20_valor
write_excel_csv(top20_valor, "Figure 10.csv")  

###################################
############ Figura 11 ############
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
salario_aggregado <- rais[, .(salario_total = mean(Salário)), by = Codigo_cne]
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
resultado_agrupado[, cor := ifelse(Setor == "Óleo e Gás", "Óleo e Gás", "Outros")]


### Atualizando os valores sem os NA
resultado_agrupado[Setor == "Outros", salario_total := 3525.629]
resultado_agrupado[Setor == "Mineração", salario_total := 5577.803]
resultado_agrupado[Setor == "Transporte", salario_total := 4252.285]
resultado_agrupado[Setor == "Resto da indústria", salario_total := 3848.599]
resultado_agrupado[Setor == "Metalurgia", salario_total := 5673.170]
resultado_agrupado[Setor == "Óleo e Gás", salario_total := 20310.934]
resultado_agrupado[Setor == "Cimento", salario_total := 6219.233]

# Gráfico ajustado com ponto como separador decimal
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
  scale_color_manual(values = c("Óleo e Gás" = "orange", "Outros" = "steelblue")) +
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
  theme(legend.position = "none") 


### Print dos dados para o Excel
resultado_agrupado
write_excel_csv(resultado_agrupado, "Figure 11.csv")  

###############################
########## Figura 12 ##########
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

### Criar coluna de cor: "Mineração" = laranja, demais = azul
collapsed_dt[, cor := ifelse(Setor == "Óleo e Gás", "Óleo e Gás", "Outros")]

### Criar o gráfico com rótulos no topo
ggplot(collapsed_dt, aes(x = reorder(Setor, -metric), y = metric, fill = cor)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(metric, 1)), vjust = -0.2, size = 4) +  # Adiciona os valores acima das barras
  scale_fill_manual(values = c("Óleo e Gás" = "orange", "Outros" = "steelblue")) +
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
write_excel_csv(collapsed_dt, "Figure 12.csv")








###############################
########## Figura 13 ##########
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
empregos_aggregado <- rais[, .(numero_empregos = .N), by = c('Codigo_cne','Skill_Class')]
salario_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
Valor_Adicionado_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(Valor_Adicionado_filtrado, empregos_aggregado, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(numero_empregos) & !is.na(Setor)]
resultado_final[,VA:=as.numeric(VA)]


#### Fazendo a agregação dos valores para os setores (collapsing)
collapsed_dt <- resultado_final[, .(
  VA_total = sum(VA, na.rm = TRUE),
  numero_empregos_total = sum(numero_empregos, na.rm = TRUE)), by = c('Setor','Skill_Class')]

### Calcular a métrica (numero_empregos / VTBI) * 1000000
collapsed_dt$metric <- (collapsed_dt$numero_empregos / (collapsed_dt$VA)) * 1000000


# Order Skill_Class manually
collapsed_dt[, Skill_Class := factor(Skill_Class,
                                     levels = c("High-skill", "Low-skill"))]

# Sort Setor by total metric (sum across Skill_Class)
collapsed_dt[, total_metric := sum(metric), by = Setor]
collapsed_dt <- collapsed_dt[order(-total_metric)]


ggplot(collapsed_dt, aes(
  x = reorder(Setor, -metric),  # ordena setores dentro de cada facet
  y = metric,
  fill = Skill_Class
)) +
  geom_col(width = 0.8) +
  geom_text(aes(label = round(metric, 1)),
            vjust = -0.3, size = 2.5) +
  scale_fill_manual(
    values = c("High-skill" = "darkgreen",
               "Low-skill" = "steelblue")
  ) +
  facet_wrap(~ Skill_Class, ncol = 1, scales = "free_y") +
  labs(
    title = "Empregos por Valor Adicionado por Setor e Nível de Habilidade",
    x = "Setor",
    y = "Número de Empregos / VA * 1.000.000",
    fill = "Classe de Habilidade"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none", # já está no facet
    strip.text = element_text(face = "bold"),
    axis.text.x = element_text(angle = 90, hjust = 1)
  )
collapsed_dt
write_excel_csv(collapsed_dt, "Figure Apendice.csv") 





###############################
########## Figura 13 ##########
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
collapsed_dt[, cor := ifelse(Setor == "Industrial", "Industrial", "Outros")]

# criar variável "Setor_group" para destacar Industrial
collapsed_dt[, Setor_group := ifelse(Setor == "Industrial", "Industrial", "Outros")]

# Figura 1: % de empregos (barras verticais)
ggplot(collapsed_dt, aes(x = reorder(Setor, perc_empregos), 
                         y = perc_empregos, fill = Setor_group)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("Industrial" = "orange", "Outros" = "steelblue")) +
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
  scale_fill_manual(values = c("Industrial" = "orange", "Outros" = "steelblue")) +
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


write_excel_csv(empregos_long, "Figura 13 A.csv") 
empregos_long


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



###############################
########## Figura 14 ##########
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
top15_massa <- Final_data[order(-prop_massa_oil)][1:15]
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
    subtitle = "Proporção da Massa Salarial do Setor de Mineração sobre o Total Municipal",
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
write_excel_csv(top15_massa, "Figure 14.csv")






############################################
########### Tabela principal ###############
############################################


rais <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais)
rais <- rais[Salário>0]
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
rais[, trab_transporte := substr(as.character(cnae_2_0), 1, 2) %in% c("29","30","49","50","51","52")]
rais[, trab_transporte := as.integer(trab_transporte)]
rais[, trab_mineracao := substr(as.character(cnae_2_0), 1, 2) %in% c("05", "07", "08", "09")]
rais[, trab_mineracao := as.integer(trab_mineracao)]
cnaes_industriais <- sprintf("%02d", 10:33)
rais[, trab_industrial := substr(as.character(cnae_2_0), 1, 2) %in% cnaes_industriais]
excluir <- c("1921", "1922", "232", "24", "29", "30")
rais[substr(as.character(cnae_2_0), 1, 4) %in% excluir, trab_industrial := FALSE]
rais[substr(as.character(cnae_2_0), 1, 3) %in% excluir, trab_industrial := FALSE]
rais[substr(as.character(cnae_2_0), 1, 2) %in% excluir, trab_industrial := FALSE]
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








###################################
########## MAPA ESTADUAL ##########
###################################


# Supondo que sua base está no objeto chamado 'df'
setDT(Final_data)  # transforma em data.table, se ainda não for

# n_trab_oil já é o total do SETOR por unidade de observação
Final_data[, n_trab_oil := n_tot_trabalhadores - n_nao_trab_oil]

# 1) Total do SETOR por UF
uf_sector <- Final_data[, .(
  trab_oil = sum(n_trab_oil, na.rm = TRUE)
), by = UF_sigla]

# 2) Participação do estado no TOTAL NACIONAL do SETOR (soma = 100%)
uf_sector[, prop_oil := trab_oil / sum(trab_oil, na.rm = TRUE)]
# Baixa o shapefile dos estados brasileiros
estados_br <- read_state(year = 2020)

# Faz o merge com base na sigla
mapa_dados <- left_join(estados_br, uf_sector, by = c("abbrev_state" = "UF_sigla")) %>%
  mutate(prop_oil = if_else(is.na(prop_oil), 0.001, prop_oil))

ggplot(mapa_dados) +
  geom_sf(aes(fill = prop_oil), color = "gray90", size = 0.3) +
  scale_fill_gradientn(
    name = "% trabalhadores em Óleo e Gás",
    labels = percent_format(accuracy = 0.1),
    colours = c("#fff5eb", "#fee0d2", "#fc9272", "#de2d26"), # degrade mais forte
    values = scales::rescale(c(0, 0.01, 0.05, 0.10, max(mapa_dados$prop_oil, na.rm = TRUE)))
  ) +
  labs(
    title = "Proporção de Trabalhadores no Setor Óleo e Gás por Estado",
    subtitle = "Quebras manuais para destacar variações",
    caption = "",
    fill = "% no setor Óleo e Gás"
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
  prop_oil = round(mapa_dados$prop_oil, 4)
)
mapa_export

# Save to CSV
write_excel_csv(mapa_export, "Mapa 15.csv") 










##### Resto não utilizado 
######
{





#####################################################
##### Mapa municipios por setores do oil e gas ######
#####################################################

##### Figura do Joao ####

### Total empregabilidade

# Garantir que os nomes estejam em UTF-8 (corrige "S\xe3o" para "São")
#Final_data[, Mun_name_utf8 := stri_trans_general(Mun_name, "latin-ascii")]
Final_data[, Mun_name_utf8 := iconv(Mun_name, from = "latin1", to = "UTF-8")]

# Calcular proporção de trabalhadores no setor
Final_data[, n_trab_oil := n_tot_trabalhadores - n_nao_trab_oil]
Final_data[, prop_oil := n_trab_oil / n_tot_trabalhadores]
Final_data <- Final_data[is.finite(prop_oil) & n_tot_trabalhadores > 0]

# Extrair nome limpo do município e UF
Final_data[, nome_mun := str_remove(Mun_name_utf8, "Prefeitura Municipal de ")]
Final_data[, nome_mun := str_remove(nome_mun, " - [A-Z]{2}$")]
Final_data[, UF_sigla := UF]
Final_data[, mun_uf := paste0(nome_mun, " - ", UF_sigla)]

# Selecionar top 15
top15 <- Final_data[order(-prop_oil)][1:15]

# Gráfico
ggplot(top15, aes(x = reorder(mun_uf, prop_oil), y = prop_oil)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Top 15 Municípios Mais Dependentes do Setor de Óleo e Gás",
    x = NULL,
    y = "Proporção de Trabalhadores no Setor"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(hjust = 0.5, face = "bold")
  )







#####################################################
##### Mapa municipios por setores do oil e gas ######
#####################################################

##### Figura do Joao ####

### Total massa salarial por setor

rais2 <- fread("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Raw\\RAIS\\base_limpa.csv", encoding = "UTF-8")
as.data.table(rais2)
gc()
rais2 <- rais2[Salário>0]

rais2[, Skill_Class := fifelse(cbo_grp %in% 1:2, "High-skill",
                                      fifelse(cbo_grp %in% 4:9, "Low-skill", NA_character_))]
table(rais2$Skill_Class)

Final_data[, n_trab_oil := n_tot_trabalhadores - n_nao_trab_oil]

### Trab oleo e gas
rais2[, trab_oil_gas := substr(as.character(cnae_2_0), 1, 4) %in% c("0600","0910","1910","1921","1922")]
rais2[, trab_oil_gas := as.integer(trab_oil_gas)]
rais2[, Extração_oil := substr(as.character(cnae_2_0), 1, 4) %in% c("0600","0910")]
rais2[, Extração_oil := as.integer(Extração_oil)]
rais2[, Derivado_petroleo := substr(as.character(cnae_2_0), 1, 4) %in% c("1910","1921","1922")]
rais2[, Derivado_petroleo := as.integer(Derivado_petroleo)]
rais2[, Distribuicao_oil := substr(as.character(cnae_2_0), 1, 3) %in% c("352")]
rais2[, Distribuicao_oil := as.integer(Distribuicao_oil)]

setDT(rais2)

resumo_mun2 <- rais2[, .(
  # Total de trabalhadores no município
  n_tot_trabalhadores = .N,
  
  # Trabalhadores no setor de petróleo
  n_trab = sum(trab_oil_gas == 1),
  n_nao_trab_oil = sum(trab_oil_gas == 0),
  
  # Salários - média e faixas no setor petróleo
  salario_medio       = mean(Salário, na.rm = TRUE)), 
  by = c("Município","Extração_oil","Derivado_petroleo","Distribuicao_oil")]


resumo_mun2[is.na(resumo_mun2)] <- 0

setnames(resumo_mun2, old = "Município", new = "Cod_IBGE")

Data_aux <- read.dta("C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Output\\final_wide.dta")
setDT(Data_aux)
Data_aux[, Cod_IBGE := substr(as.character(Cod_IBGE), 1, 6)]
Data_aux[, Cod_IBGE := as.numeric(Cod_IBGE)]

Final_data2 <- merge(Data_aux,resumo_mun2, by = "Cod_IBGE")
setnames(Final_data2, old = "Instituição", new = "Mun_name")
setnames(Final_data2, old = "População", new = "Pop_tot")


Final_data2





base <- Final_data2
# Corrigir nome de município
base[, Mun_name_utf8 := iconv(Mun_name, from = "latin1", to = "UTF-8")]
base[, nome_mun := str_remove(Mun_name_utf8, "Prefeitura Municipal de ")]
base[, nome_mun := str_remove(nome_mun, " - [A-Z]{2}$")]
base[, UF_sigla := UF]
base[, mun_uf := paste0(nome_mun, " - ", UF_sigla)]

# Calcular massa salarial por setor
base[, massa_extracao := Extração_oil * salario_medio]
base[, massa_derivado := Derivado_petroleo * salario_medio]
base[, massa_distribuicao := Distribuicao_oil * salario_medio]

# Derreter em formato longo
long_base <- melt(
  base,
  id.vars = "mun_uf",
  measure.vars = list(
    c("massa_extracao", "massa_derivado", "massa_distribuicao")
  ),
  variable.name = "setor",
  value.name = "massa_salarial"
)

# Ajustar rótulos dos setores
long_base[, setor := factor(
  setor,
  levels = c("massa_extracao", "massa_derivado", "massa_distribuicao"),
  labels = c("Extração de Petróleo", "Derivados de Petróleo", "Distribuição de Gás")
)]

# Selecionar os 15 municípios com maior massa total (soma dos 3 setores)
top_mun <- long_base[, .(massa_total = sum(massa_salarial)), by = mun_uf][
  order(-massa_total)][1:15, mun_uf]

# Filtrar base para top 15
plot_base <- long_base[mun_uf %in% top_mun]
plot_base[, mun_uf := factor(mun_uf, levels = top_mun)]

# Gráfico
ggplot(plot_base, aes(x = mun_uf, y = massa_salarial, fill = setor)) +
  geom_col(position = "dodge") +
  scale_y_continuous(
    labels = label_number(scale = 1e-6, suffix = "M", accuracy = 0.1)
  ) +
  labs(
    title = "Massa Salarial por Setor de Petróleo e Gás",
    subtitle = "Top 15 Municípios com Maior Massa Salarial Total no Setor",
    x = NULL,
    y = "Massa Salarial (R$ milhões)",
    fill = "Setor"
  ) +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


















##### Mapa 1 municipal proporcoes #####

library(sf)
library(dplyr)
library(geobr)
library(ggplot2)
library(data.table)
library(scales)

# Preparar dados
Final_data[, n_trab_oil := n_tot_trabalhadores - n_nao_trab_oil]
base_oil_gas <- Final_data[, .(
  code_muni = Cod_IBGE,
  prop_trabalhadores_oil_gas = n_trab_oil / n_tot_trabalhadores
)]

base_oil_gas <- base_oil_gas[is.finite(prop_trabalhadores_oil_gas)]

# Criar categorias manuais com labels mais intuitivos
base_oil_gas[, quintil := cut(
  prop_trabalhadores_oil_gas,
  breaks = c(-0.001, 0, 0.0001, 0.001, 0.01, Inf),
  labels = c("0%", "<0,01%", "0,01–0,1%", "0,1–1%", ">1%"),
  include.lowest = TRUE
)]

# Carregar o shapefile dos municípios
muni <- read_municipality(year = 2023)
muni$code_muni <- as.numeric(substr(muni$code_muni, 1, 6))

# Juntar
muni_joined <- left_join(muni, base_oil_gas, by = "code_muni")

# Mapa com categorias fixas
ggplot(muni_joined) +
  geom_sf(aes(fill = quintil), color = NA, size = 0.1) +
  scale_fill_brewer(palette = "YlOrRd", na.value = "gray90", name = "Proporção") +
  labs(
    title = "Proporção de Trabalhadores no Setor de Óleo e Gás por Município",
    subtitle =
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10)
  )






##### Mapa 2 municipal salario medio #####

##### Mapa do Salário Médio Relativo – Setor de Óleo e Gás #####

library(sf)
library(dplyr)
library(geobr)
library(ggplot2)
library(data.table)
library(scales)

# Preparar dados
setnames(Final_data, "code_muni", "Cod_IBGE")

# Calcular razão entre salário médio do setor e salário médio municipal
base_oil_gas <- Final_data[, .(
  code_muni = Cod_IBGE,
  salario_relativo = salario_medio_oil / salario_medio
)]

# Remover valores inválidos e extremos absurdos (por segurança, cortar razão > 20)
base_oil_gas <- base_oil_gas[
  is.finite(salario_relativo) & salario_relativo <= 20
]

# Criar categorias manuais (proporções salariais)
base_oil_gas[, categoria_salario := cut(
  salario_relativo,
  breaks = c(-0.001, 0.5, 1, 2, 5, Inf),
  labels = c("< 50% da média", "≈ média", "2x a média", "2–5x a média", ">5x a média"),
  include.lowest = TRUE
)]

# Carregar o shapefile dos municípios
muni <- read_municipality(year = 2023)
muni$code_muni <- as.numeric(substr(muni$code_muni, 1, 6))

# Juntar dados ao shapefile
muni_joined <- left_join(muni, base_oil_gas, by = "code_muni")

# Plotar o mapa
ggplot(muni_joined) +
  geom_sf(aes(fill = categoria_salario), color = NA, size = 0.1) +
  scale_fill_brewer(
    palette = "YlGnBu", na.value = "gray90",
    name = "Salário médio\ndo setor vs geral"
  ) +
  labs(
    title = "Relação entre Salário Médio do Setor de Óleo e Gás e Salário Médio Municipal",
    subtitle = 
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10)
  )




















########## MAPA Municipal ##########


# Carregar bibliotecas
library(sf)
library(dplyr)
library(ggplot2)
library(geobr)
library(data.table)

########## DADOS MUNICIPAIS ##########

# Supondo que Final_data seja um data.table com colunas:
# Cod_IBGE, n_trab_oil (ou (n_homen_oil + n_mulheres_oil)), n_tot_trabalhadores

# Criar coluna de proporção de trabalhadores do setor de óleo e gás por município
base_oil_gas <- Final_data[, .(
  code_muni = Cod_IBGE,
  prop_trabalhadores_oil_gas = n_trab_oil / n_tot_trabalhadores
)]

# Carregar o shapefile de municípios (ano 2023)
muni <- read_municipality(year = 2023)

# Ajustar o código do município para 6 dígitos (removendo dígito verificador se necessário)
muni$code_muni <- as.numeric(substr(muni$code_muni, 1, 6))

# Juntar shapefile com os dados de proporção
muni_joined <- muni %>%
  left_join(base_oil_gas, by = "code_muni")

# Plotar o mapa com ggplot2
ggplot(muni_joined) +
  geom_sf(aes(fill = prop_trabalhadores_oil_gas), color = NA, size = 0.1) +
  scale_fill_viridis_c(option = "plasma", na.value = "gray90", labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Proporção de Trabalhadores do Setor de Óleo e Gás por Município",
    fill = "Proporção"
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    legend.position = "right",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10)
  )






















#### OLD #####









nomes_resumidos <- c(
  "05" = "Carvão mineral",
  "06" = "Petróleo e gás",
  "07" = "Minerais metálicos",
  "08" = "Minerais não-metálicos",
  "09" = "Minerais não-metálicos",
  "10" = "Alimentos",
  "11" = "Bebidas",
  "12" = "Fumo",
  "13" = "Têxteis",
  "14" = "Vestuário",
  "15" = "Couro e artefatos",
  "16" = "Madeira",
  "17" = "Celulose e papel",
  "18" = "Impressão",
  "19" = "Óleo e Gás",
  "20" = "Químicos",
  "21" = "Farmoquímicos",
  "22" = "Borracha e plástico",
  "23" = "Minerais não-metálicos",
  "24" = "Metalurgia",
  "25" = "Produtos de metal",
  "26" = "Informática e eletrônicos",
  "27" = "Máquinas e materiais",
  "28" = "Máquinas e equipamentos",
  "29" = "Veículos automotores",
  "30" = "Outros transportes",
  "31" = "Móveis",
  "32" = "Diversos",
  "33" = "Manutenção e reparação"
)
nomes_resumidos_dt <- data.table(
  Codigo_cne = names(nomes_resumidos),
  Setor = nomes_resumidos
)

#VA_filtrado[,Setor.y:=NULL]
Valor_Adicionado <- VTBI_filtrado

VA_filtrado <- merge(Valor_Adicionado, nomes_resumidos_dt, by = "Codigo_cne", all.x = TRUE, sort = FALSE)

rais[, Codigo_cne := substr(as.character(cnae_2_0), 1, 2)]
salario_aggregado <- rais[, .(salario_total = mean(Salário)), by = Codigo_cne]
VA_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
salario_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(VA_filtrado, salario_aggregado, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(salario_total)]
resultado_final_filtrado <- resultado_final

# Calcular as médias
media_salarial <- median(resultado_final_filtrado$salario_total, na.rm = TRUE)
media_va <- median(resultado_final_filtrado$VA, na.rm = TRUE)

ggplot(resultado_final_filtrado, aes(x = salario_total, y = VA, label = Setor, color = VA)) +
  geom_point(size = 4) +
  geom_text_repel(size = 3, max.overlaps = 20) +
  
  # Linha vertical da média salarial
  geom_vline(xintercept = media_salarial, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = media_salarial, y = max(resultado_final_filtrado$VA), 
           label = paste0("Mediana salarial: R$ ", round(media_salarial, 0)),
           angle = 90, vjust = -0.5, hjust = 1, color = "red", size = 3.5) +
  
  # Linha horizontal da média VTBI
  geom_hline(yintercept = media_va, linetype = "dashed", color = "blue", size = 1) +
  annotate("text", x = max(resultado_final$salario_total), y = media_va, 
           label = paste0("Mediana Valor Adicinado: R$ ", format(round(media_va, 0), big.mark = ".", decimal.mark = ",")),
           hjust = 1.1, vjust = -0.5, color = "blue", size = 3.5) +
  
  # Escalas e tema
  scale_color_viridis(option = "D", direction = -1, trans = "log", labels = scales::comma) +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    x = "Salário médio por setor",
    y = "Valor Adicionado (R$)",
    title = "Relação entre Salário Médio e Valor Adicinado por Setor",
    color = "Valor Adicionado"
  ) +
  theme_minimal(base_size = 12)













########### Tabela principal ###################


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
rais[, trab_oil_gas := substr(as.character(cnae_2_0), 1, 4) %in% c("0600","0910","1910","1921","1922")]
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





















































###########################################################
################# RESTO NÃO UTILIZADO #####################
###########################################################






#################### 
##### Figura 1 #####
####################

# Criação das faixas salariais individuais
Final_data[, faixa_salarial := fifelse(
  salario_medio_oil <= 2000, "Até R$2 mil",
  fifelse(salario_medio_oil <= 4000, "R$2–4 mil",
          fifelse(salario_medio_oil <= 10000, "R$4–10 mil",
                  fifelse(salario_medio_oil <= 30000, "R$10–30 mil",
                          "Acima de R$30 mil"))))]

# Filtrar apenas estados selecionados
selected_states <- c("RJ", "SP", "MG", "BA", "ES")
Final_data_filtrado <- Final_data[UF %in% selected_states & !is.na(faixa_salarial)]

# Calcular total de municípios com trabalhadores de petróleo por estado
Total_por_estado <- Final_data_filtrado[, .N, by = UF]
setnames(Total_por_estado, "N", "total_estado")

# Calcular número de municípios por faixa salarial e estado
Distribuicao <- Final_data_filtrado[, .N, by = .(UF, faixa_salarial)]
Distribuicao <- merge(Distribuicao, Total_por_estado, by = "UF")
Distribuicao[, percentual := 100 * N / total_estado]

# Ordenar faixas salariais
Distribuicao[, faixa_salarial := factor(faixa_salarial,
                                        levels = c("Até R$2 mil", "R$2–4 mil", "R$4–10 mil", "R$10–30 mil", "Acima de R$30 mil"))]

# Gráfico
ggplot(Distribuicao, aes(x = faixa_salarial, y = percentual, fill = UF)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_viridis(discrete = TRUE, option = "D") +
  labs(
    #title = "Distribuição de Trabalhadores do Setor de Petróleo por Faixa Salarial",
    x = "Faixa Salarial",
    y = "Percentual Total",
    fill = "Estado"
  ) +
  theme_minimal(base_size = 14)









#################### 
##### Figura 2 #####
####################

selected_states <- c("RJ", "SP", "MG", "BA", "ES")
dados_filtrados <- Final_data[UF %in% selected_states]

# Soma total de trabalhadores de petróleo por estado
totais_estado <- dados_filtrados[, .(total_oil = sum(n_trab, na.rm = TRUE)), by = UF]

# Reshape para long format das colunas de skill
dados_long <- melt(
  dados_filtrados[, .(UF, n_low_skill_oil, n_middle_skill_oil, n_high_skill_oil)],
  id.vars = "UF",
  variable.name = "Skill",
  value.name = "N"
)

# Converte nome das variáveis para rótulos legíveis
dados_long[, Skill := factor(Skill,
                             levels = c("n_low_skill_oil", "n_middle_skill_oil", "n_high_skill_oil"),
                             labels = c("Baixa", "Média", "Alta"))]

# Agrega número total por estado e categoria
agg_data <- dados_long[, .(N = sum(N, na.rm = TRUE)), by = .(UF, Skill)]

# Junta com totais e calcula percentual
agg_data <- merge(agg_data, totais_estado, by = "UF")
agg_data[, percentual := 100 * N / total_oil]

# Ordena os níveis do eixo X (UF) na ordem original
agg_data[, UF := factor(UF, levels = selected_states)]

# Gráfico
ggplot(agg_data, aes(x = UF, y = percentual, fill = Skill)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_viridis(discrete = TRUE, option = "D") +
  labs(
    #title = "Distribuição de Trabalhadores do Petróleo por Nível de Qualificação",
    x = "Estado",
    y = "Percentual (%)",
    fill = "Nível de Qualificação"
  ) +
  theme_minimal(base_size = 14)











#################### 
##### Figura 3 #####
####################

# Seleciona apenas os estados desejados
selected_states <- c("RJ", "SP", "MG", "BA", "ES")
dados_filtrados <- Final_data[UF %in% selected_states]

# Soma total de trabalhadores de petróleo por estado
totais_estado <- dados_filtrados[, .(total_oil = sum(n_trab, na.rm = TRUE)), by = UF]

# Reshape para long format das colunas de sexo
dados_long <- melt(
  dados_filtrados[, .(UF, n_homen_oil, n_mulheres_oil)],
  id.vars = "UF",
  variable.name = "Sexo",
  value.name = "N"
)

# Converte nome das variáveis para rótulos legíveis
dados_long[, Sexo := factor(Sexo,
                            levels = c("n_homen_oil", "n_mulheres_oil"),
                            labels = c("Homens", "Mulheres"))]

# Agrega número total por estado e sexo
agg_data <- dados_long[, .(N = sum(N, na.rm = TRUE)), by = .(UF, Sexo)]

# Junta com totais e calcula percentual
agg_data <- merge(agg_data, totais_estado, by = "UF")
agg_data[, percentual := 100 * N / total_oil]

# Ordena os níveis do eixo X (UF) na ordem original
agg_data[, UF := factor(UF, levels = selected_states)]

# Gráfico
ggplot(agg_data, aes(x = UF, y = percentual, fill = Sexo)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_viridis(discrete = TRUE, option = "D") +
  labs(
    #title = "Distribuição de Gênero no Setor de Petróleo por Estado",
    x = "Estado",
    y = "Percentual (%)",
    fill = "Sexo"
  ) +
  theme_minimal(base_size = 14)













#################### 
##### Figura 4 #####
####################

# 1. Seleciona apenas os estados desejados
selected_states <- c("RJ", "SP", "MG", "BA", "ES")
dados_filtrados <- Final_data[UF %in% selected_states]

# 2. Soma total de trabalhadores do setor petróleo por estado
totais_estado <- dados_filtrados[, .(total_oil = sum(n_trab, na.rm = TRUE)), by = UF]

# 3. Seleciona e transforma para long format os 6 grupos
dados_long <- melt(
  dados_filtrados[, .(
    UF,
    n_mulher_low_skill_oil,
    n_mulher_middle_skill_oil,
    n_mulher_high_skill_oil,
    n_homem_low_skill_oil,
    n_homem_middle_skill_oil,
    n_homem_high_skill_oil
  )],
  id.vars = "UF",
  variable.name = "Grupo",
  value.name = "N"
)

# 4. Converte nomes para rótulos legíveis
dados_long[, Grupo := factor(Grupo,
                             levels = c("n_mulher_low_skill_oil", "n_mulher_middle_skill_oil", "n_mulher_high_skill_oil",
                                        "n_homem_low_skill_oil", "n_homem_middle_skill_oil", "n_homem_high_skill_oil"),
                             labels = c("Mulher - Baixa", "Mulher - Média", "Mulher - Alta",
                                        "Homem - Baixa", "Homem - Média", "Homem - Alta")
)]

# 5. Agrega e calcula percentual
agg_data <- dados_long[, .(N = sum(N, na.rm = TRUE)), by = .(UF, Grupo)]
agg_data <- merge(agg_data, totais_estado, by = "UF")
agg_data[, percentual := 100 * N / total_oil]
agg_data[, UF := factor(UF, levels = selected_states)]

# 6. Gera o gráfico
ggplot(agg_data, aes(x = UF, y = percentual, fill = Grupo)) +
  geom_col(position = "dodge", width = 0.75) +
  scale_fill_viridis(discrete = TRUE, option = "D") +
  labs(
    #title = "Distribuição de Gênero e Qualificação no Setor de Petróleo por Estado",
    x = "Estado",
    y = "Percentual (%)",
    fill = "Grupo"
  ) +
  theme_minimal(base_size = 14)











##### Table salareis

# Define the classification labels
rais[, grupo := fifelse(
  trab_oil_gas == 1 & Gênero == "Feminino" & Skill_Class == "Low-skill", "Mulher - Baixa",
  fifelse(trab_oil_gas == 1 & Gênero == "Feminino" & Skill_Class == "Middle-skill", "Mulher - Média",
          fifelse(trab_oil_gas == 1 & Gênero == "Feminino" & Skill_Class == "High-skill", "Mulher - Alta",
                  fifelse(trab_oil_gas == 1 & Gênero == "Masculino" & Skill_Class == "Low-skill", "Homem - Baixa",
                          fifelse(trab_oil_gas == 1 & Gênero == "Masculino" & Skill_Class == "Middle-skill", "Homem - Média",
                                  fifelse(trab_oil_gas == 1 & Gênero == "Masculino" & Skill_Class == "High-skill", "Homem - Alta", NA_character_))))))]

# Remove NA (i.e., those not in oil or without classification)
rais_valido <- rais[!is.na(grupo) & !is.na(Salário)]

# Compute descriptive statistics
tabela_salarios <- rais_valido[, .(
  Média = mean(Salário, na.rm = TRUE),
  DP = sd(Salário, na.rm = TRUE),
  Q1 = quantile(Salário, 0.25, na.rm = TRUE),
  Mediana = quantile(Salário, 0.5, na.rm = TRUE),
  Q3 = quantile(Salário, 0.75, na.rm = TRUE)
), by = grupo]

# Optional: order by gender then skill level
tabela_salarios[, grupo := factor(grupo, levels = c(
  "Mulher - Baixa", "Mulher - Média", "Mulher - Alta",
  "Homem - Baixa", "Homem - Média", "Homem - Alta"
))]

# Print table
tabela_salarios[order(grupo)]












##### ##### ##### ##### 
##### Figura Teste #####
##### ##### ##### ##### 

# Junta com salários
rais[, Codigo_cne := substr(as.character(cnae_2_0), 1, 2)]
empregos_aggregado_15 <- rais[Salário > 20000, .(numero_empregos = .N), by = Codigo_cne]
salario_aggregado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
Valor_Adicionado_filtrado[, Codigo_cne := sprintf("%02d", as.integer(Codigo_cne))]
resultado_final <- merge(Valor_Adicionado_filtrado, empregos_aggregado_15, by = "Codigo_cne", all.x = TRUE, sort = FALSE)
resultado_final <- resultado_final[!is.na(numero_empregos)]


# Calcular a métrica (numero_empregos / VA) * 1000000
resultado_final$metric <- (resultado_final$numero_empregos / resultado_final$VA) * 1000000

# Criar o gráfico com ggplot2
ggplot(resultado_final, aes(x = Setor, y = metric, fill = Setor)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Número de Empregos por Setor (em relação ao Valor Adicionado)",
    x = "Setor",
    y = "Número de Empregos / Valor Adicionado * 100000"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, size = 12) # Aumenta o tamanho da fonte da legenda inferior
  )
}







