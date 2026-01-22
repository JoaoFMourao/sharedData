# ============================================================
# 01_coleta_comexBR_2000_2024
# ============================================================

# ------------------------------------------------------------
# Este script tem como objetivo coletar, agregar e salvar dados 
# de exportações e importações brasileiras no período 2000–2024.
# Os dados são organizados por ano e código NCM, com valores
# consolidados em dólares FOB.
#
# ETAPAS:
# 1) Carregar pacotes necessários
# 2) Ler arquivos anuais de exportação (2000–2024), agregando VL_FOB por NCM
# 3) Ler arquivos anuais de importação (2000–2024), agregando VL_FOB por NCM
# 4) Salvar bases finais em CSV para uso posterior
# ============================================================


# ==========================
# 1) CARREGAMENTO DE PACOTES
# ==========================

library(data.table)    # Manipulação eficiente de grandes volumes de dados
library(stringr)       # Manipulação de strings (ex: padronização de códigos)
library(ggplot2)
library(scales)   # percent_format
library(readxl)
library(gridExtra)

# ==========================
# 2) EXPORTAÇÕES
# ==========================

# Diretório dos arquivos de exportação
caminho <- "~/secex/exp/"

# Período de análise
anos <- 2024:2024

# Leitura e agregação das exportações
dt_exp <- rbindlist(
  lapply(anos, function(ano) {
    arq <- paste0(caminho, "EXP_", ano, ".csv")
    dt <- fread(arq)
    dt[, .(VL_FOB = sum(VL_FOB, na.rm = TRUE)), by = .(CO_ANO, CO_NCM,CO_PAIS)]
  })
)


# ==========================
# 3) IMPORTAÇÕES
# ==========================

# Diretório dos arquivos de importação
caminho <- "~/secex/imp/"

# Período de análise
anos <- 2024:2024

# Leitura e agregação das importações
dt_imp <- rbindlist(
  lapply(anos, function(ano) {
    arq <- paste0(caminho, "IMP_", ano, ".csv")
    dt <- fread(arq)
    dt[, .(VL_FOB = sum(VL_FOB, na.rm = TRUE)), by = .(CO_ANO, CO_NCM,CO_PAIS)]
  })
)




# Padronização crítica: NCM sempre com 8 dígitos (mantém chaves coerentes para os merges por período).
dt_exp[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]
dt_imp[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]



# Padronização crítica: PAIS sempre com 3 dígitos (mantém chaves coerentes para os merges por período).
dt_exp[, CO_PAIS := sprintf("%03s", str_pad(trimws(as.character(CO_PAIS)), 3, "left", "0"))]
dt_imp[, CO_PAIS := sprintf("%03s", str_pad(trimws(as.character(CO_PAIS)), 3, "left", "0"))]



# ===============================================
# 7) CORRESPONDÊNCIA NCM-CNAE POR PERÍODO
# ===============================================
# O mapeamento NCM -> CNAE muda no tempo (novas versões, reclassificações).
# Por isso, o script usa TABELAS DE PERÍODO para 2012–, 2007–2011, 2004–2006, 2002–2003, 2000–2001.
# Cada bloco abaixo:
# - lê a planilha com a correspondência vigente,
# - seleciona as colunas de NCM e CNAE relevantes,
# - padroniza NCM (8 dígitos) e limpa CNAE.

# --- PERÍODO 2012-2024 ---
dt_12_24 <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/NCM2012XCNAE20.xls", skip = 1)
setDT(dt_12_24)
dt_12_24 <- dt_12_24[, .(ncm = `NCM 2012 (AGOSTO)`, cnae = `CNAE 2.0`)]
dt_12_24[, ncm := sprintf("%08s", str_pad(trimws(as.character(ncm)), 8, "left", "0"))]





# ===============================================
# 8) JUNÇÃO DOS DADOS COM CORRESPONDÊNCIAS NCM-CNAE
# ===============================================
# Para cada janela de anos:
# - une os dados deflacionados (exp/imp) à tabela NCM->CNAE pertinente,
# - “explode” linhas quando um NCM tem múltiplos CNAEs (split por ";"),
# - limpa espaços e mantém apenas dígitos do CNAE,
# - reparte o valor FOB entre os CNAEs da mesma linha (divisão igual),
# - re-agrega por (Ano, CNAE).


# ---------- 2024 ----------

dt_exp_24 <- merge(dt_exp, dt_12_24, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_24 <- merge(dt_imp, dt_12_24, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

# Explode CNAEs e normaliza
dt_exp_24 <- dt_exp_24[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CO_PAIS)]
dt_exp_24[, cnae := trimws(cnae)]
dt_exp_24[, cnae := gsub("[^0-9]", "", cnae)]

# Repartição e agregação[Passo importante. Como há ncm que se dividem em mais de um cnae diferente tem
dt_exp_24[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB,CO_PAIS)]
dt_exp_24[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_24 <- dt_exp_24[, .(VL_FOB = sum(VL_FOB)),
                                       by = .(CO_ANO, cnae,CO_PAIS)]

# Mesma lógica para importações
dt_imp_24 <- dt_imp_24[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB,CO_PAIS)]
dt_imp_24[, cnae := trimws(cnae)]
dt_imp_24[, cnae := gsub("[^0-9]", "", cnae)]
dt_imp_24[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB,CO_PAIS)]
dt_imp_24[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_24 <- dt_imp_24[, .(VL_FOB = sum(VL_FOB)),
                                       by = .(CO_ANO, cnae,CO_PAIS)]




# ===============================================
# 9) CONSOLIDAÇÃO DOS DADOS
# ===============================================
# Une todos os períodos já no nível (Ano, CNAE), com valores deflacionados.
dt_exp_defl <- rbind(dt_exp_24, fill = TRUE)
dt_imp_defl <- rbind(dt_imp_24, fill = TRUE)

# Cria rótulo de operação para pivotar depois.
dt_exp_defl[, variavel := "exportacao"]
dt_imp_defl[, variavel := "importacao"]

# Empilha e passa para formato wide: colunas “exportacao” e “importacao”.
dt <- rbind(dt_exp_defl, dt_imp_defl)
dt <- dcast(
  dt, CO_ANO + cnae+CO_PAIS ~ variavel,
  value.var = "VL_FOB",
  fun.aggregate = sum,
  fill = 0
)

# Saldo = exp - imp (já em valores reais deflacionados).
dt[, saldo_comercial := exportacao - importacao]

# ===============================================
# 10) CLASSIFICAÇÃO SETORIAL
# ===============================================
# Mapeia blocos CNAE em grandes categorias analíticas do projeto:
# - Cimento, Metalurgia, Elétrico, Óleo e Gás, Mineração, Transporte,
# - Indústria de Transformação (10–33),
# - Indústria de Base (subset de seções selecionadas).
# Observação: o mapeamento usa prefixos (regex) e espera CNAE padronizado somente com dígitos.

# Criar subsets com categorias
cimento <- dt[grepl("^232", cnae)][, categoria := "Cimento"]
metalurgia <- dt[grepl("^24", cnae)][, categoria := "Metalurgia"]
eletrico <- dt[grepl("^351", cnae)][, categoria := "Elétrico"]
oleo_gas <- dt[grepl("(^|;)\\s*06",  cnae) | grepl("(^|;)\\s*192", cnae) | grepl("(^|;)\\s*1931", cnae)][, categoria := "Óleo e Gás"]
mineracao <- dt[grepl("(^|;)\\s*05",  cnae) | grepl("(^|;)\\s*07",  cnae) | grepl("(^|;)\\s*099", cnae) | grepl("(^|;)\\s*08991", cnae)][, categoria := "Mineração"]
transporte <- dt[grepl("(^|;)\\s*(49|50|51|52|29|30|53)", cnae)][, categoria := "Transporte"]
dt_transf <- dt[grepl("(^|;)\\s*(1[0-9]|2[0-9]|3[0-3])", cnae)][, categoria := "Transformação"]
dt_base <- dt[grepl("(^|;)\\s*((0[5-9])|17|19|20|22|23|27|28|29|30|33)", cnae)][, categoria := "Base"]
dt_total <- dt[, categoria := "Total"]

# Aplicar a função de agregação para cada categoria
cimento <- cimento[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

metalurgia <- metalurgia[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

eletrico <- eletrico[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

oleo_gas <- oleo_gas[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

mineracao <- mineracao[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

transporte <- transporte[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

dt_transf <- dt_transf[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

dt_base <- dt_base[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

dt_total <- dt_total[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria,CO_PAIS)]

# Juntar todos os datasets
dt_final <- rbindlist(list(
  cimento, metalurgia, eletrico, oleo_gas, 
  mineracao, transporte, dt_transf, dt_base, dt_total
), use.names = TRUE)




pais <- fread("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/PAIS.csv", 
              encoding = "Latin-1")

pais[, CO_PAIS := sprintf("%03s", str_pad(trimws(as.character(CO_PAIS)), 3, "left", "0"))]


dt_final <- merge(dt_final,pais,by = "CO_PAIS")

# Lista de países da UE em inglês
eu <- c("Austria", "Belgium", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark",
        "Estonia", "Finland", "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland",
        "Italy", "Latvia", "Lithuania", "Luxembourg", "Malta", "Netherlands", "Poland",
        "Portugal", "Romania", "Slovakia", "Slovenia", "Spain", "Sweden")

# Criar a nova coluna 'classificacao_pais' 
dt_final[, classificacao_pais := ifelse(NO_PAIS_ING %in% eu, "UE", NO_PAIS)]


dt_agregado <- dt_final[, .(
  exportacao_total = sum(exportacao, na.rm = TRUE),
  importacao_total = sum(importacao, na.rm = TRUE),
  saldo_comercial_total = sum(saldo_comercial, na.rm = TRUE)
), by = .(classificacao_pais,categoria)]


dt_agregado <- dt_agregado[categoria == "Óleo e Gás"]

# Supondo que você quer manter apenas dt_agregado e dt_metal
rm(list = setdiff(ls(), c("dt_agregado", "dt_final")))

# Carregar bibliotecas necessárias
library(ggplot2)
library(dplyr)
library(scales)

# Calcular totais globais
total_exportacao <- sum(dt_agregado$exportacao_total, na.rm = TRUE)
total_importacao <- sum(dt_agregado$importacao_total, na.rm = TRUE)

# Preparar dados - top 15 países por exportação com porcentagem
top_export <- dt_agregado %>%
  mutate(porcentagem = (exportacao_total / total_exportacao) * 100,
         valor_milhoes = exportacao_total / 1000000) %>%
  arrange(desc(exportacao_total)) %>%
  head(15)

# Preparar dados - top 15 países por importação com porcentagem
top_import <- dt_agregado %>%
  mutate(porcentagem = (importacao_total / total_importacao) * 100,
         valor_milhoes = importacao_total / 1000000) %>%
  arrange(desc(importacao_total)) %>%
  head(15)

# Função para formatar números com ponto como separador de milhares (sem decimais)
formatar_numero <- function(x) {
  format(round(x), big.mark = ".", scientific = FALSE)
}

# Gráfico 1: Top 15 Países por Exportação com Porcentagem
ggplot(top_export, aes(x = reorder(classificacao_pais, valor_milhoes), 
                       y = valor_milhoes)) +
  geom_bar(stat = "identity", fill = "#2E8B57", alpha = 0.8, width = 0.7) +
  geom_text(aes(label = paste0(round(porcentagem, 1), "%")),
            hjust = -0.1, size = 3.5, color = "black", fontface = "bold") +
  scale_y_continuous(labels = formatar_numero,
                     expand = expansion(mult = c(0, 0.2)),
                     name = "Valor de Exportação (em milhões)") +
  labs(title = "Top 15 Países por Volume de Exportação - Metalurgia",
       subtitle = paste("Total global:", formatar_numero(total_exportacao/1000000)),
       x = "Países/Regiões",
       y = "Exportação Total") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_flip()

# Gráfico 2: Top 15 Países por Importação com Porcentagem
ggplot(top_import, aes(x = reorder(classificacao_pais, valor_milhoes), 
                       y = valor_milhoes)) +
  geom_bar(stat = "identity", fill = "#CD5C5C", alpha = 0.8, width = 0.7) +
  geom_text(aes(label = paste0(round(porcentagem, 1), "%")),
            hjust = -0.1, size = 3.5, color = "black", fontface = "bold") +
  scale_y_continuous(labels = formatar_numero,
                     expand = expansion(mult = c(0, 0.2)),
                     name = "Valor de Importação (em milhões)") +
  labs(title = "Top 15 Países por Volume de Importação - Metalurgia",
       subtitle = paste("Total global:", formatar_numero(total_importacao/1000000)),
       x = "Países/Regiões",
       y = "Importação Total") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_flip()


plot_export <- ggplot(top_export, aes(x = reorder(classificacao_pais, valor_milhoes), 
                                      y = valor_milhoes)) +
  geom_bar(stat = "identity", fill = "#2E8B57", alpha = 0.8) +
  geom_text(aes(label = paste0(round(porcentagem, 1), "%")),
            hjust = -0.1, size = 3.2, color = "black", fontface = "bold") +
  scale_y_continuous(labels = formatar_numero,
                     expand = expansion(mult = c(0, 0.2)),
                     name = "Exportação(em milhões)") +
  labs(title = "Top 15 - Exportação",
       x = NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold")) +
  coord_flip()

plot_import <- ggplot(top_import, aes(x = reorder(classificacao_pais, valor_milhoes), 
                                      y = valor_milhoes)) +
  geom_bar(stat = "identity", fill = "#CD5C5C", alpha = 0.8) +
  geom_text(aes(label = paste0(round(porcentagem, 1), "%")),
            hjust = -0.1, size = 3.2, color = "black", fontface = "bold") +
  scale_y_continuous(labels = formatar_numero,
                     expand = expansion(mult = c(0, 0.2)),
                     name = "Importação(em milhões)") +
  labs(title = "Top 15 - Importação",
       x = NULL) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(hjust = 0.5, face = "bold")) +
  coord_flip()

# Exibir gráficos lado a lado
p <- grid.arrange(plot_export, plot_import, ncol = 2,
             top = "",
             bottom = "")


ggsave(
  filename = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/graph/metalurgia_2024_pais.png",
  plot = p, width = 11, height = 7
)
