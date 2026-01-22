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


# ==========================
# 2) EXPORTAÇÕES
# ==========================

# Diretório dos arquivos de exportação
caminho <- "~/secex/exp/"

# Período de análise
anos <- 2000:2024

# Leitura e agregação das exportações
dt_exp <- rbindlist(
  lapply(anos, function(ano) {
    arq <- paste0(caminho, "EXP_", ano, ".csv")
    dt <- fread(arq)
    dt[, .(VL_FOB = sum(VL_FOB, na.rm = TRUE)), by = .(CO_ANO, CO_NCM)]
  })
)


# ==========================
# 3) IMPORTAÇÕES
# ==========================

# Diretório dos arquivos de importação
caminho <- "~/secex/imp/"

# Período de análise
anos <- 2000:2024

# Leitura e agregação das importações
dt_imp <- rbindlist(
  lapply(anos, function(ano) {
    arq <- paste0(caminho, "IMP_", ano, ".csv")
    dt <- fread(arq)
    dt[, .(VL_FOB = sum(VL_FOB, na.rm = TRUE)), by = .(CO_ANO, CO_NCM)]
  })
)


# ==========================
# 4) SALVAR RESULTADOS
# ==========================

# Caminho de saída
caminho <- "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/input/"

# Exportações consolidadas
fwrite(dt_exp,
       file = paste0(caminho, "exportacoes_2000_2024.csv"),
       sep = ";", dec = ",", bom = TRUE)

# Importações consolidadas
fwrite(dt_imp,
       file = paste0(caminho, "importacoes_2000_2024.csv"),
       sep = ";", dec = ",", bom = TRUE)
