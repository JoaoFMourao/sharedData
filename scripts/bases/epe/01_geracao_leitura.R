# ============================================================
# 01_geracao_leitura.R - Leitura e limpeza dos dados de geração
# ============================================================
# Carrega dados de geração elétrica por estado do BEN/EPE
# e agrega por subsistema elétrico brasileiro
# ============================================================

source("00_setup.R")

# ------------------------------------------------------------
# 1) LEITURA DOS DADOS
# ------------------------------------------------------------

dt_geracao <- read_xlsx(
  file.path(INPUT_DIR, "Capítulo 8 (Dados Estaduais).xlsx"),
  sheet = 3
)
setDT(dt_geracao)

# ------------------------------------------------------------
# 2) LIMPEZA E ESTRUTURAÇÃO
# ------------------------------------------------------------

# Renomeia primeira coluna para "estado"
setnames(dt_geracao, names(dt_geracao)[1], "estado")

# Extrai o ano das linhas "ANO BASE ####"
dt_geracao[, year := fifelse(
  str_detect(estado, "^ANO BASE"),
  as.integer(str_extract(estado, "\\d{4}")),
  NA_integer_
)]

# Preenche os NA de year com o último valor conhecido (LOCF)
dt_geracao[, year := nafill(year, type = "locf")]

# Filtra linhas de cabeçalho repetido ou totalmente NA
dt_geracao <- dt_geracao[
  !is.na(estado) &
    !str_detect(estado, regex("^(TABLE|ANO BASE|Estado)", ignore_case = TRUE))
]

# Limpa caracteres especiais dos nomes de estado
dt_geracao[, estado := str_trim(str_replace_all(estado, "\\r|\\n", ""))]

# ------------------------------------------------------------
# 3) CONVERSÃO DE COLUNAS NUMÉRICAS
# ------------------------------------------------------------

num_cols <- setdiff(names(dt_geracao), c("estado", "year"))
dt_geracao[, (num_cols) := lapply(.SD, parse_number), .SDcols = num_cols]

# Remove coluna extra se existir
if ("...18" %in% names(dt_geracao)) {
  dt_geracao[, `...18` := NULL]
}

# ------------------------------------------------------------
# 4) RENOMEAR COLUNAS
# ------------------------------------------------------------

old_cols <- names(dt_geracao)[!names(dt_geracao) %in% c("estado", "year")]

new_cols <- c(
  "geracao_total",
  "hidro",
  "eolica",
  "solar",
  "nuclear",
  "termo",
  "bagaco_cana",
  "lenha",
  "lixivia",
  "outras_renovaveis",
  "carvao_vapor",
  "gas_natural",
  "gas_coqueria",
  "oleo_combustivel",
  "oleo_diesel",
  "outras_nao_renovaveis"
)

setnames(dt_geracao, old = old_cols, new = new_cols)

# ------------------------------------------------------------
# 5) CLASSIFICAÇÃO POR SUBSISTEMA
# ------------------------------------------------------------

# Remove agregados regionais
dt_geracao <- dt_geracao[
  !(estado %in% c("BRASIL", "NORTE", "NORDESTE", "SUDESTE", "SUL", "CENTRO OESTE"))
]

# Classifica estados por subsistema elétrico
dt_geracao[estado %in% c("Minas Gerais", "São Paulo", "Espírito Santo", "Rio de Janeiro",
                         "Rondônia", "Acre", "Goiás", "Mato Grosso", "Mato G. do Sul",
                         "Distrito Federal"),
           subsistema := "Sudeste/C.Oeste"]

dt_geracao[estado %in% c("Rio G. do Sul", "Santa Catarina", "Paraná"),
           subsistema := "Sul"]

dt_geracao[estado %in% c("Amapá", "Amazonas", "Maranhão", "Pará", "Tocantins"),
           subsistema := "Norte"]

dt_geracao[is.na(subsistema), subsistema := "Nordeste"]

# ------------------------------------------------------------
# 6) AGREGAÇÃO POR SUBSISTEMA
# ------------------------------------------------------------

num_cols <- setdiff(names(dt_geracao), c("estado", "subsistema", "year"))

dt_geracao_subsistema <- dt_geracao[
  ,
  lapply(.SD, sum, na.rm = TRUE),
  by = .(subsistema, year),
  .SDcols = num_cols
]

# ------------------------------------------------------------
# 7) SALVAR DADOS PROCESSADOS
# ------------------------------------------------------------

# Exporta para uso nos outros scripts
saveRDS(dt_geracao, file.path(INPUT_DIR, "dt_geracao_estados.rds"))
saveRDS(dt_geracao_subsistema, file.path(INPUT_DIR, "dt_geracao_subsistema.rds"))

message("Dados de geração carregados e processados!")
message(paste("Estados:", uniqueN(dt_geracao$estado)))
message(paste("Anos:", paste(range(dt_geracao$year), collapse = "-")))
message(paste("Subsistemas:", paste(unique(dt_geracao_subsistema$subsistema), collapse = ", ")))
