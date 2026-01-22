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

# --- PERÍODO 2007-2011 ---
dt_07_11 <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/NCM2007XCNAE10XCNAE20ABRIL2010.xls", skip = 1)
setDT(dt_07_11)
dt_07_11 <- dt_07_11[, .(ncm = `NCM 2007`, cnae = `CNAE 2.0`)]
dt_07_11[, ncm := sprintf("%08s", str_pad(trimws(as.character(ncm)), 8, "left", "0"))]

# --- PERÍODO 2004-2006 ---
# Esta planilha tem cabeçalho “irregular”: redefine nomes a partir da 2a linha útil e remove linhas de topo.
dt_04_06 <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/NCM2004XCNAE10.xls")
setDT(dt_04_06)
novos_nomes <- as.character(unlist(dt_04_06[2, ]))
setnames(dt_04_06, novos_nomes)
dt_04_06 <- dt_04_06[-c(1:8)]
dt_04_06 <- dt_04_06[, .(ncm = `NCM 2003/04`, cnae_1 = `CNAE 1.0`)]
dt_04_06[, cnae_1 := gsub("[.-]", "", cnae_1)]
# Harmoniza CNAE 1.0 -> 2.0 usando “cnae_corrigido”.
dt_04_06 <- merge(dt_04_06, cnae_corrigido, by = "cnae_1", all.x = TRUE)
dt_04_06 <- dt_04_06[, .(ncm, cnae = cnae_2)]

# --- PERÍODO 2002-2003 ---
# Aqui a planilha já traz a relação NCM x CNAE 1.0; limpa e guarda em “cnae”.
dt_02_03 <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/NCM2002XCNAE.xls", skip = 3)
setDT(dt_02_03)
dt_02_03 <- dt_02_03[-1, .(ncm = .SD[[1]], cnae_1 = .SD[[2]])]
dt_02_03[, cnae := gsub("[.-]", "", cnae_1)]
dt_02_03 <- dt_02_03[, .(ncm, cnae)]
# (Observação: a harmonização para 2.0 ocorrerá mais abaixo, após o merge com os dados.)

# --- PERÍODO 2000-2001 ---
dt_00_01 <- read_xls("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/NCM96XCNAE.xls", skip = 11)
setDT(dt_00_01)
dt_00_01 <- dt_00_01[, .(ncm = .SD[[1]], cnae_1 = .SD[[2]])]
dt_00_01[, cnae := gsub("[.-]", "", cnae_1)]
dt_00_01[, ncm := sprintf("%08s", str_pad(trimws(as.character(ncm)), 8, "left", "0"))]
dt_00_01 <- dt_00_01[, .(ncm, cnae)]
# (Observação: idem ao bloco acima quanto à harmonização posterior.)

# ===============================================
# 8) JUNÇÃO DOS DADOS COM CORRESPONDÊNCIAS NCM-CNAE
# ===============================================
# Para cada janela de anos:
# - une os dados deflacionados (exp/imp) à tabela NCM->CNAE pertinente,
# - “explode” linhas quando um NCM tem múltiplos CNAEs (split por ";"),
# - limpa espaços e mantém apenas dígitos do CNAE,
# - reparte o valor FOB entre os CNAEs da mesma linha (divisão igual),
# - re-agrega por (Ano, CNAE).


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
                                       by = .(CO_ANO, cnae)]

# Mesma lógica para importações
dt_imp_defl_12_24 <- dt_imp_defl_12_24[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_imp_defl_12_24[, cnae := trimws(cnae)]
dt_imp_defl_12_24[, cnae := gsub("[^0-9]", "", cnae)]
dt_imp_defl_12_24[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_12_24[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_12_24[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_12_24 <- dt_imp_defl_12_24[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# ---------- 2007–2011 ----------
# (Mesmíssima lógica: merge -> explode -> limpar -> repartir -> agregar)




dt_exp_defl_07_11 <- merge(dt_exp_defl[CO_ANO >= 2007 & CO_ANO < 2012, ], dt_07_11, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_defl_07_11 <- merge(dt_imp_defl[CO_ANO >= 2007 & CO_ANO < 2012, ], dt_07_11, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

dt_exp_defl_07_11 <- dt_exp_defl_07_11[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_exp_defl_07_11[, cnae := trimws(cnae)]
dt_exp_defl_07_11[, cnae := gsub("[^0-9]", "", cnae)]
dt_exp_defl_07_11[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_07_11[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_07_11[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_07_11 <- dt_exp_defl_07_11[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

dt_imp_defl_07_11 <- dt_imp_defl_07_11[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_imp_defl_07_11[, cnae := trimws(cnae)]
dt_imp_defl_07_11[, cnae := gsub("[^0-9]", "", cnae)]
dt_imp_defl_07_11[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_07_11[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_07_11[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_07_11 <- dt_imp_defl_07_11[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# ---------- 2004–2006 ----------
dt_exp_defl_04_06 <- merge(dt_exp_defl[CO_ANO >= 2004 & CO_ANO < 2007, ], dt_04_06, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_defl_04_06 <- merge(dt_imp_defl[CO_ANO >= 2004 & CO_ANO < 2007, ], dt_04_06, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

dt_exp_defl_04_06 <- dt_exp_defl_04_06[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_exp_defl_04_06[, cnae := trimws(cnae)]
dt_exp_defl_04_06[, cnae := gsub("[^0-9]", "", cnae)]
dt_exp_defl_04_06[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_04_06[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_04_06[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_04_06 <- dt_exp_defl_04_06[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

dt_imp_defl_04_06 <- dt_imp_defl_04_06[, .(cnae = unlist(strsplit(cnae, ";"))),
                                       by = .(CO_NCM, CO_ANO, VL_FOB, CPI, CPI_new, Index, VL_FOB_DEFL)]
dt_imp_defl_04_06[, cnae := trimws(cnae)]
dt_imp_defl_04_06[, cnae := gsub("[^0-9]", "", cnae)]
dt_imp_defl_04_06[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_04_06[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_04_06[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_04_06 <- dt_imp_defl_04_06[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# ---------- 2002–2003 ----------
# Nota: aqui a correspondência veio como CNAE e foi inicialmente apenas limpa.
# A harmonização para 2.0 ocorre logo após a agregação usando tabela de mapeamento “cnae0_cnae1” + “cnae_corrigido”.
dt_exp_defl_02_03 <- merge(dt_exp_defl[CO_ANO >= 2002 & CO_ANO < 2004, ], dt_02_03, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_defl_02_03 <- merge(dt_imp_defl[CO_ANO >= 2002 & CO_ANO < 2004, ], dt_02_03, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

# Repartição e agregação (já que cnae aqui é único por linha após a limpeza)
dt_exp_defl_02_03[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_02_03[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_02_03[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_02_03 <- dt_exp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

dt_imp_defl_02_03[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_02_03[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_02_03[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_02_03 <- dt_imp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# Harmonização 1.0 -> 2.0 para 2002–2003:
# 1) tabela “cnae0_cnae1” traz o elo (CNAE 2.0 "cnae" -> CNAE 1.0 "cnae_1")
# 2) em NA, mantém-se o próprio código como fallback
# 3) mapeia para 2.0 definitivo via “cnae_corrigido”
cnae0_cnae1 <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/correspondencia_CNAE_vs_CNAE1_0.xlsx")
setDT(cnae0_cnae1)
cnae0_cnae1 <- cnae0_cnae1[, .(cnae = CNAE, cnae_1 = `CNAE 1.0`)]
cnae0_cnae1[, cnae   := gsub("[^0-9]", "", trimws(cnae))]
cnae0_cnae1[, cnae_1 := gsub("[^0-9]", "", trimws(cnae_1))]

# EXP 2002–2003: junta elo 2.0->1.0, preenche faltas, re-agrega com chave CNAE 1.0,
# depois converte para 2.0 com “cnae_corrigido” e re-agrega por CNAE 2.0.
dt_exp_defl_02_03 <- merge(dt_exp_defl_02_03, cnae0_cnae1, by = "cnae", all.x = TRUE)
dt_exp_defl_02_03[is.na(cnae_1), cnae_1 := cnae]
dt_exp_defl_02_03[, n_cnaes := .N, by = .(cnae, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_02_03[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_02_03[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_02_03 <- dt_exp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae_1)]
dt_exp_defl_02_03 <- merge(dt_exp_defl_02_03, cnae_corrigido, by = "cnae_1", all.x = TRUE)
setnames(dt_exp_defl_02_03, "cnae_2", "cnae")
dt_exp_defl_02_03 <- dt_exp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# IMP 2002–2003: fluxo idêntico ao de exportações.
dt_imp_defl_02_03 <- merge(dt_imp_defl_02_03, cnae0_cnae1, by = "cnae", all.x = TRUE)
dt_imp_defl_02_03[is.na(cnae_1), cnae_1 := cnae]
dt_imp_defl_02_03[, n_cnaes := .N, by = .(cnae, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_02_03[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_02_03[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_02_03 <- dt_imp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae_1)]
dt_imp_defl_02_03 <- merge(dt_imp_defl_02_03, cnae_corrigido, by = "cnae_1", all.x = TRUE)
setnames(dt_imp_defl_02_03, "cnae_2", "cnae")
dt_imp_defl_02_03 <- dt_imp_defl_02_03[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# ---------- 2000–2001 ----------
# Fluxo similar ao de 2002–2003, com harmonização via cnae0_cnae1 + cnae_corrigido.
dt_exp_defl_00_01 <- merge(dt_exp_defl[CO_ANO >= 2000 & CO_ANO < 2002, ], dt_00_01, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)
dt_imp_defl_00_01 <- merge(dt_imp_defl[CO_ANO >= 2000 & CO_ANO < 2002, ], dt_00_01, by.x = "CO_NCM", by.y = "ncm", all.x = TRUE)

dt_exp_defl_00_01 <- unique(dt_exp_defl_00_01)[!is.na(cnae)]
dt_exp_defl_00_01[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_00_01[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_00_01[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_00_01 <- dt_exp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

dt_imp_defl_00_01 <- unique(dt_imp_defl_00_01)[!is.na(cnae)]
dt_imp_defl_00_01[, n_cnaes := .N, by = .(CO_NCM, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_00_01[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_00_01[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_00_01 <- dt_imp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# Elo 2.0 -> 1.0 e harmonização final para 2.0 (mesma lógica já descrita):
cnae0_cnae1 <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/correspondencia_CNAE_vs_CNAE1_0.xlsx")
setDT(cnae0_cnae1)
cnae0_cnae1 <- cnae0_cnae1[, .(cnae = CNAE, cnae_1 = `CNAE 1.0`)]
cnae0_cnae1[, cnae   := gsub("[^0-9]", "", trimws(cnae))]
cnae0_cnae1[, cnae_1 := gsub("[^0-9]", "", trimws(cnae_1))]

# EXP 2000–2001
dt_exp_defl_00_01 <- merge(dt_exp_defl_00_01, cnae0_cnae1, by = "cnae", all.x = TRUE)
dt_exp_defl_00_01[is.na(cnae_1), cnae_1 := cnae]
dt_exp_defl_00_01[, n_cnaes := .N, by = .(cnae, CO_ANO, VL_FOB_DEFL)]
dt_exp_defl_00_01[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_exp_defl_00_01[, VL_FOB      := VL_FOB      / n_cnaes]
dt_exp_defl_00_01 <- dt_exp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae_1)]
dt_exp_defl_00_01 <- merge(dt_exp_defl_00_01, cnae_corrigido, by = "cnae_1", all.x = TRUE)
setnames(dt_exp_defl_00_01, "cnae_2", "cnae")
dt_exp_defl_00_01 <- dt_exp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# IMP 2000–2001
dt_imp_defl_00_01 <- merge(dt_imp_defl_00_01, cnae0_cnae1, by = "cnae", all.x = TRUE)
dt_imp_defl_00_01[is.na(cnae_1), cnae_1 := cnae]
dt_imp_defl_00_01[, n_cnaes := .N, by = .(cnae, CO_ANO, VL_FOB_DEFL)]
dt_imp_defl_00_01[, VL_FOB_DEFL := VL_FOB_DEFL / n_cnaes]
dt_imp_defl_00_01[, VL_FOB      := VL_FOB      / n_cnaes]
dt_imp_defl_00_01 <- dt_imp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae_1)]
dt_imp_defl_00_01 <- merge(dt_imp_defl_00_01, cnae_corrigido, by = "cnae_1", all.x = TRUE)
setnames(dt_imp_defl_00_01, "cnae_2", "cnae")
dt_imp_defl_00_01 <- dt_imp_defl_00_01[, .(VL_FOB = sum(VL_FOB), VL_FOB_DEFL = sum(VL_FOB_DEFL)),
                                       by = .(CO_ANO, cnae)]

# ===============================================
# 9) CONSOLIDAÇÃO DOS DADOS
# ===============================================
# Une todos os períodos já no nível (Ano, CNAE), com valores deflacionados.
dt_exp_defl <- rbind(dt_exp_defl_00_01, dt_exp_defl_02_03, dt_exp_defl_04_06, 
                     dt_exp_defl_07_11, dt_exp_defl_12_24, fill = TRUE)
dt_imp_defl <- rbind(dt_imp_defl_00_01, dt_imp_defl_02_03, dt_imp_defl_04_06,
                     dt_imp_defl_07_11, dt_imp_defl_12_24, fill = TRUE)

# Cria rótulo de operação para pivotar depois.
dt_exp_defl[, variavel := "exportacao"]
dt_imp_defl[, variavel := "importacao"]

# Empilha e passa para formato wide: colunas “exportacao” e “importacao”.
dt <- rbind(dt_exp_defl, dt_imp_defl)
dt <- dcast(
  dt, CO_ANO + cnae ~ variavel,
  value.var = "VL_FOB_DEFL",
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
oleo_gas <- dt[grepl("(^|;)\\s*06",  cnae) | grepl("(^|;)\\s*192", cnae) ][, categoria := "Óleo e Gás"]
oleo_gas_bruto <- dt[grepl("(^|;)\\s*06",  cnae) ][, categoria := "Petróleo cru e Gás natural"]
mineracao <- dt[grepl("(^|;)\\s*05",  cnae) | grepl("(^|;)\\s*07",  cnae) | grepl("(^|;)\\s*099", cnae) | grepl("(^|;)\\s*08991", cnae)][, categoria := "Mineração"]
transporte <- dt[grepl("(^|;)\\s*(49|50|51|52|29|30|53)", cnae)][, categoria := "Transporte"]
dt_transf <- dt[grepl("(^|;)\\s*(1[0-9]|2[0-9]|3[0-3])", cnae)][, categoria := "Transformação"]
dt_base <- dt[grepl("(^|;)\\s*((0[2])|0[5-9])|16|17|20|232|24|27|28)", cnae)][, categoria := "Base"]
dt_agri <- dt[grepl("(^|;)\\s*((0[1-3]))", cnae)][, categoria := "Agricultura"]
dt_total <- dt[, categoria := "Total"]

# Aplicar a função de agregação para cada categoria
cimento <- cimento[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

metalurgia <- metalurgia[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

eletrico <- eletrico[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

oleo_gas <- oleo_gas[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

oleo_gas_bruto <- oleo_gas_bruto[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]


mineracao <- mineracao[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

transporte <- transporte[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

dt_transf <- dt_transf[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

dt_base <- dt_base[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]


dt_agri <- dt_agri[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

dt_total <- dt_total[, .(
  exportacao      = sum(exportacao,      na.rm = TRUE),
  importacao      = sum(importacao,      na.rm = TRUE),
  saldo_comercial = sum(saldo_comercial, na.rm = TRUE)
), by = .(CO_ANO, categoria)]

# Juntar todos os datasets
dt_final <- rbindlist(list(
  cimento, metalurgia, eletrico, oleo_gas, 
  mineracao, transporte, dt_transf, dt_base,dt_agri, dt_total,oleo_gas_bruto
), use.names = TRUE)


# ===============================================
# 4) SALVAR DADOS EM CSV
# ===============================================
# Exporta a base final (preços constantes) para consumo em análises e gráficos.
caminho <- "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/output/"
fwrite(
  dt_final,
  file = paste0(caminho, "balança_comercial_2000_2024.csv")
)
