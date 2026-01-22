# ====================================================
# ANÁLISE DE DADOS DE COMÉRCIO EXTERIOR BRASILEIRO
# ====================================================
# OBJETIVO (visão geral do script):
# - Ler microdados anuais de exportações e importações (FOB) por NCM.
# - Deflacionar os valores para preços constantes usando um índice (CPI).
# - Mapear NCM -> CNAE respeitando as mudanças de classificação ao longo do tempo.
# - Tratar duplicidades/ambiguidade nas correspondências (CNAE 1.0 x CNAE 2.0).
# - Quando um NCM mapeia para múltiplos CNAEs, repartir o valor FOB de forma proporcional (aqui, divisão igual).
# - Agregar para o nível: Ano x CNAE (e depois por grandes categorias setoriais).
# - Entregar base final com exportação, importação e saldo comercial anuais por categoria.

# ==========================
# 1) CARREGAMENTO DE PACOTES
# ==========================
# Pacotes para leitura, manipulação eficiente (data.table), formatação de strings e gráficos.
library(readxl)        # Leitura de arquivos Excel (tabelas de correspondência e deflator)
library(data.table)    # Manipulação eficiente de dados (join, agregações, reshape)
library(stringr)       # Manipulação de strings (padronização de NCM)

# ==========================
# 2) CONFIGURAÇÃO INICIAL
# ==========================
# Leitura dos microdados de exportações/importações já com:
# - separador/decimal do padrão BR,
# - NA explícitos,
# - classes de colunas definidas para evitar inferência ambígua.
dt_exp <- fread(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/exportacoes_2000_2024.csv",
  sep = ";",
  dec = ",",
  na.strings = c("", "NA", "NaN", "null"),
  strip.white = TRUE,
  colClasses = list(
    integer = "CO_ANO",   # garante ano como inteiro (chave para merges e agregações)
    character = "CO_NCM", # NCM como string para preservar zeros à esquerda
    numeric  = "VL_FOB"   # valor FOB em moeda corrente (será deflacionado depois)
  )
)

dt_imp <- fread(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/importacoes_2000_2024.csv",
  sep = ";",
  dec = ",",
  na.strings = c("", "NA", "NaN", "null"),
  strip.white = TRUE,
  colClasses = list(
    integer = "CO_ANO",
    character = "CO_NCM",
    numeric  = "VL_FOB"
  )
)

# Padronização crítica: NCM sempre com 8 dígitos (mantém chaves coerentes para os merges por período).
dt_exp[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]
dt_imp[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]
# ===============================================
# 4) CARREGAMENTO E TRATAMENTO DO DEFLATOR
# ===============================================
# Carrega CPI (ou índice equivalente) para trazer valores a preços constantes.
# Supõe que o arquivo contenha coluna "Date" (ano) e colunas com fatores (p.ex., "Index").
deflator <- as.data.table(
  read_excel("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/CPI.xlsx")
)

# Normaliza nomes/tipos para permitir join por ano.
setnames(deflator, old = "Date", new = "CO_ANO")
deflator[, CO_ANO := as.integer(CO_ANO)]

# ===============================================
# 5) DEFLACIONAMENTO DOS VALORES FOB
# ===============================================
# Merge ano a ano para anexar o fator de correção de preços.
dt_exp_defl <- merge(dt_exp, deflator, by = "CO_ANO", all.x = TRUE)
dt_imp_defl <- merge(dt_imp, deflator, by = "CO_ANO", all.x = TRUE)

# Aplica deflator: cria VL_FOB_DEFL (valor real). Mantém VL_FOB nominal para referência/checagem.
dt_exp_defl[, VL_FOB_DEFL := VL_FOB * Index]
dt_imp_defl[, VL_FOB_DEFL := VL_FOB * Index]

# ===============================================
# 6) TRATAMENTO DA CLASSIFICAÇÃO CNAE
# ===============================================
# Lê correspondência CNAE 1.0 -> 2.0 e trata duplicidades, pois parte das tabelas históricas usa CNAE 1.0.
# Isso permite harmonizar tudo para CNAE 2.0 no final.
cnae <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/CNAE20_Correspondencia10x20.xls", 
                 skip = 8, sheet = 1)
setDT(cnae)
# Seleciona apenas as colunas relevantes (CNAE 1.0 e 2.0).
cnae <- cnae[, .(cnae_1 = .SD[[1]], cnae_2 = .SD[[3]])]

# Lê a aba de legenda com marcação explícita das linhas “válidas” para casos de duplicidade.
duplicadas_legenda <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/CNAE20_Correspondencia10x20.xls",
                               sheet = 2, skip = 2)
setDT(duplicadas_legenda)

# Preenche para baixo códigos CNAE vazios (técnica de carry-forward dentro da coluna),
# preservando o agrupamento indicado pela planilha de origem.
duplicadas_legenda[, `código...1` := {
  v <- as.character(`código...1`)
  v[v == ""] <- NA_character_
  idx <- which(!is.na(v))
  if (length(idx) == 0L) v else {
    pos <- findInterval(seq_along(v), idx)
    ifelse(pos == 0L, NA_character_, v[idx[pos]])
  }
}]

# Mantém somente as linhas marcadas com "X" e reduz ao par (CNAE 1.0, CNAE 2.0) de interesse.
duplicadas_legenda <- duplicadas_legenda[`...4` == "X"]
duplicadas_legenda <- duplicadas_legenda[, .(cnae_1 = .SD[[1]], cnae_2 = .SD[[2]])]

# Constrói a tabela final “cnae_corrigido”:
# - remove do quadro base os CNAE 1.0 que foram substituídos,
# - insere a curadoria de duplicidades da aba 2,
# - descarta NAs,
# - padroniza os códigos removendo pontuação.
cnae_1_duplicados   <- duplicadas_legenda$cnae_1
cnae_sem_duplicatas <- cnae[!cnae_1 %in% cnae_1_duplicados]
cnae_corrigido      <- rbindlist(list(cnae_sem_duplicatas, duplicadas_legenda), fill = TRUE)
cnae_corrigido      <- na.omit(cnae_corrigido)
cnae_corrigido[, c("cnae_1", "cnae_2") := lapply(.SD, function(x) gsub("[.-]", "", x)),
               .SDcols = c("cnae_1", "cnae_2")]

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




# ---------- 2012–2024 ----------

dt_exp_defl_12_24 <- merge(dt_exp_defl[CO_ANO >= 2012, ], dt_12_24, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_defl_12_24 <- merge(dt_imp_defl[CO_ANO >= 2012, ], dt_12_24, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

# Explode CNAEs e normaliza
dt_exp_defl_12_24 <- dt_exp_defl_12_24[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_exp_defl_12_24[, cnae := trimws(cnae)]
dt_exp_defl_12_24[, cnae := gsub("[^0-9]", "", cnae)]

# Repartição e agregação[Passo importante. Como há ncm que se dividem em mais de um cnae diferente tem
# que se ter uma regra de como alocar o valor da exportação/importação. Eu adotei aqui dividir de maneira igual.]
dt_exp_defl_12_24[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_12_24[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_12_24[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_12_24 <- dt_exp_defl_12_24[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae,CO_NCM)]


dt_exp_defl_12_24[, cnae2 := substr(cnae, 1, 2)]

total <- dt_exp_defl_12_24[(grepl("(^|;)\\s*06",  cnae) | grepl("(^|;)\\s*192", cnae) ) & CO_ANO == 2024, .(VL_FOB = sum(VL_FOB)),
                           by = .(CO_ANO, CO_NCM)]

ncm <- fread("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/NCM.csv", 
             encoding = "Latin-1")


ncm <- ncm[,.(CO_NCM,NO_NCM_POR)]

ncm[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]


total <- merge(total,ncm,by = "CO_NCM",all.x = TRUE)


# Total do ano
total_ano <- total[, sum(VL_FOB), by = CO_ANO]
setnames(total_ano, "V1", "total_fob")

# Junta o total de volta
total <- merge(total, total_ano, by = "CO_ANO", all.x = TRUE)

# Calcula proporção por NCM
total[, prop_ncm := VL_FOB / total_fob]

# Em %
total[, prop_ncm_perc := 100 * prop_ncm]


###########################


# Explode CNAEs e normaliza
dt_imp_defl_12_24 <- dt_imp_defl_12_24[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_imp_defl_12_24[, cnae := trimws(cnae)]
dt_imp_defl_12_24[, cnae := gsub("[^0-9]", "", cnae)]

# Repartição e agregação[Passo importante. Como há ncm que se dividem em mais de um cnae diferente tem
# que se ter uma regra de como alocar o valor da exportação/importação. Eu adotei aqui dividir de maneira igual.]
dt_imp_defl_12_24[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_12_24[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_12_24[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_12_24 <- dt_imp_defl_12_24[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae,CO_NCM)]


dt_imp_defl_12_24[, cnae2 := substr(cnae, 1, 2)]

total <- dt_imp_defl_12_24[(grepl("(^|;)\\s*06",  cnae) | grepl("(^|;)\\s*192", cnae) ) & CO_ANO == 2024, .(VL_FOB = sum(VL_FOB)),
                           by = .(CO_ANO, CO_NCM)]

ncm <- fread("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/NCM.csv", 
             encoding = "Latin-1")


ncm <- ncm[,.(CO_NCM,NO_NCM_POR)]

ncm[, CO_NCM := sprintf("%08s", str_pad(trimws(as.character(CO_NCM)), 8, "left", "0"))]


total <- merge(total,ncm,by = "CO_NCM",all.x = TRUE)


# Total do ano
total_ano <- total[, sum(VL_FOB), by = CO_ANO]
setnames(total_ano, "V1", "total_fob")

# Junta o total de volta
total <- merge(total, total_ano, by = "CO_ANO", all.x = TRUE)

# Calcula proporção por NCM
total[, prop_ncm := VL_FOB / total_fob]

# Em %
total[, prop_ncm_perc := 100 * prop_ncm]


