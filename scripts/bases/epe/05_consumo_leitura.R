# ============================================================
# 05_consumo_leitura.R - Leitura dos dados de consumo
# ============================================================
# Carrega e processa dados de consumo de energia elétrica
# ============================================================

source("00_setup.R")

# ------------------------------------------------------------
# 1) LEITURA DOS DADOS DE CONSUMO POR SUBSISTEMA
# ------------------------------------------------------------

dt_consumo <- read_xlsx(file.path(INPUT_DIR, "consumo.xlsx"))
setDT(dt_consumo)

# Converte para GWh (divide por 1000) e ajusta escala
dt_consumo[, consumo := consumo / 1000]
dt_consumo[, consumo := consumo / 2]

# Filtra anos a partir de 2011
dt_consumo <- dt_consumo[ano > 2010]

# ------------------------------------------------------------
# 2) LEITURA DOS DADOS DE CONSUMO POR SETOR
# ------------------------------------------------------------

dt_consumo_setor <- read_xlsx(file.path(INPUT_DIR, "consumor_setor.xlsx"))
setDT(dt_consumo_setor)

# Converte para GWh
dt_consumo_setor[, consumo := consumo / 1000]

# ------------------------------------------------------------
# 3) SALVAR DADOS PROCESSADOS
# ------------------------------------------------------------

saveRDS(dt_consumo, file.path(INPUT_DIR, "dt_consumo_subsistema.rds"))
saveRDS(dt_consumo_setor, file.path(INPUT_DIR, "dt_consumo_setor.rds"))

message("Dados de consumo carregados e processados!")
message(paste("Anos (subsistema):", paste(range(dt_consumo$ano), collapse = "-")))
message(paste("Anos (setor):", paste(range(dt_consumo_setor$ano), collapse = "-")))
