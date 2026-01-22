library(readxl)
library(data.table)
library(ggplot2)
library(scales)
library(data.table)
library(writexl) # opcional p/ salvar

base_path <- "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Preços"

# ----- Lista de arquivos -----
files <- c(
  file.path(base_path, sprintf("2018-%02d.xlsx", 2:12)),  # fev–dez/2018
  file.path(base_path, sprintf("2019-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2020-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2021-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2022-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2023-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2024-%02d.xlsx", 1:12)),
  file.path(base_path, sprintf("2025-%02d.xlsx", 1:7))
)

to_num <- function(x) as.numeric(gsub(",", ".", as.character(x)))

meses_pt <- c("Janeiro","Fevereiro","Março","Abril","Maio","Junho",
              "Julho","Agosto","Setembro","Outubro","Novembro","Dezembro")

# -------- Parser GERAL (2020-09..12 e 2021+)
encontra_col_val_brasil <- function(dt) {
  nms <- names(dt)
  get_chr <- function(i, j) as.character(dt[i, get(j)][[1]])
  # 1) linha 1 == "Brasil" e linha 2 contém "valor"
  mask_main <- vapply(nms, function(nm) {
    v1 <- tolower(trimws(get_chr(1, nm)))
    v2 <- tolower(trimws(get_chr(2, nm)))
    (v1 == "brasil") && grepl("valor", v2, fixed = TRUE)
  }, logical(1))
  idx <- which(mask_main)
  if (length(idx) > 0) return(nms[idx[1]])
  # 2) fallback: linha 1 == "Brasil" e linha 3 é numérico
  mask_fb <- vapply(nms, function(nm) {
    v1 <- tolower(trimws(get_chr(1, nm))) == "brasil"
    v3 <- suppressWarnings(!is.na(to_num(get_chr(3, nm))))
    v1 && v3
  }, logical(1))
  idx <- which(mask_fb)
  if (length(idx) > 0) return(nms[idx[1]])
  # 3) último recurso: segunda coluna
  if (ncol(dt) >= 2) return(nms[2])
  stop("Não foi possível identificar a coluna de Valor (Brasil).")
}

parse_geral <- function(dt, ano, mm) {
  col_val <- encontra_col_val_brasil(dt)
  # Detecta linhas por texto na 1ª coluna (com fallback 3/4)
  lab <- tolower(trimws(as.character(dt[[1]])))
  i_gas <- which(grepl("preço.*gasolina\\s*a", lab))[1]
  i_eta <- which(grepl("preço.*etanol\\s*anidro", lab))[1]
  if (is.na(i_gas) || is.na(i_eta)) { i_gas <- 3; i_eta <- 4 }
  
  vals <- c(dt[i_gas, get(col_val)], dt[i_eta, get(col_val)])
  data.table(
    Ano    = ano,
    Mes    = meses_pt[mm],
    Regiao = "Brasil",
    Item   = c("Preço Produtor Gasolina A", "Preço Etanol Anidro"),
    Valor  = to_num(vals)
  )
}

# -------- Parser ALTERNATIVO (layout 2018-fev..dez, 2019 e 2020-jan..ago)
# Linha 5 contém as regiões; pegamos a coluna em que r5 == "Brasil"
parse_alt <- function(dt, ano, mm) {
  r5 <- tolower(trimws(unlist(dt[5, , with = FALSE])))
  col_idx <- which(r5 == "brasil")[1]
  if (is.na(col_idx)) stop("Não encontrei a coluna de 'Brasil' na linha 5.")
  col_val <- names(dt)[col_idx]
  
  lab <- tolower(trimws(as.character(dt[[1]])))
  i_gas <- which(grepl("preço.*gasolina\\s*a", lab))[1]
  i_eta <- which(grepl("preço.*etanol\\s*anidro", lab))[1]
  if (is.na(i_gas) || is.na(i_eta)) { i_gas <- 7; i_eta <- 8 }  # padrão mais comum nesse layout
  
  vals <- c(dt[i_gas, get(col_val)], dt[i_eta, get(col_val)])
  data.table(
    Ano    = ano,
    Mes    = meses_pt[mm],
    Regiao = "Brasil",
    Item   = c("Preço Produtor Gasolina A", "Preço Etanol Anidro"),
    Valor  = to_num(vals)
  )
}

# -------- Loop principal
lst <- lapply(files, function(f){
  if (!file.exists(f)) {
    message(sprintf("Aviso: arquivo não encontrado e será ignorado -> %s", f))
    return(NULL)
  }
  
  stem <- sub("\\.xlsx$", "", basename(f))   # "YYYY-MM"
  ano  <- as.integer(sub("^(\\d{4})-\\d{2}$", "\\1", stem))
  mm   <- as.integer(sub("^\\d{4}-(\\d{2})$", "\\1", stem))
  
  dt <- read_xlsx(f)
  setDT(dt)
  
  # Regras de escolha do parser:
  # - 2018 fev..dez => ALT
  # - 2019 jan..dez => ALT
  # - 2020 jan..ago => ALT
  # - 2020 set..dez e 2021+ => GERAL
  use_alt <- (ano == 2018 && mm >= 2) || (ano == 2019) || (ano == 2020 && mm <= 8)
  
  if (use_alt) {
    out <- tryCatch(parse_alt(dt, ano, mm),
                    error = function(e) {
                      message(sprintf("ALT falhou em %s: %s — tentando parser geral.", f, e$message))
                      tryCatch(parse_geral(dt, ano, mm),
                               error = function(e2) {
                                 message(sprintf("Geral também falhou em %s: %s", f, e2$message))
                                 NULL
                               })
                    })
  } else {
    out <- tryCatch(parse_geral(dt, ano, mm),
                    error = function(e) {
                      message(sprintf("Geral falhou em %s: %s — tentando ALT.", f, e$message))
                      tryCatch(parse_alt(dt, ano, mm),
                               error = function(e2) {
                                 message(sprintf("ALT também falhou em %s: %s", f, e2$message))
                                 NULL
                               })
                    })
  }
  out
})

dados_brasil <- rbindlist(Filter(Negate(is.null), lst), use.names = TRUE, fill = TRUE)

# Ordenação e colunas auxiliares
dados_brasil[, Mes := factor(Mes, levels = meses_pt)]
dados_brasil[, Mes_num := as.integer(Mes)]
dados_brasil[, Data := as.IDate(sprintf("%d-%02d-01", Ano, Mes_num))]
setorder(dados_brasil, Ano, Mes_num, Item)

# Long
dados_brasil[]

# Wide
dados_brasil_wide <- dcast(dados_brasil, Ano + Mes + Mes_num + Data + Regiao ~ Item, value.var = "Valor")
setorder(dados_brasil_wide, Ano, Mes_num)
dados_brasil_wide[]

# (OPCIONAL) salvar
# write_xlsx(list(
#   long = dados_brasil,
#   wide = dados_brasil_wide
# ), file.path(base_path, "brasil_gasolinaA_etanol_2018fev_2025_jan_jul.xlsx"))

# --- 0) Parâmetros da base de preços desejada ---
ref_ano <- 2025L
ref_mes <- 7L   # Jul = 7

ipca<- fread("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Preços/ipca.csv")

# --- 1) Limpeza do IPCA ---
ipca_dt <- as.data.table(ipca)
col_ipca <- setdiff(names(ipca_dt), "Data")

ipca_dt <- ipca_dt[grepl("^\\d{2}/\\d{4}$", Data)]
ipca_dt[, Var_mensal := as.numeric(gsub(",", ".", ipca_dt[[col_ipca]]))]
ipca_dt[, Mes_num := as.integer(sub("^(\\d{2})/\\d{4}$", "\\1", Data))]
ipca_dt[, Ano     := as.integer(sub("^\\d{2}/(\\d{4})$", "\\1", Data))]
setorder(ipca_dt, Ano, Mes_num)

# --- 2) Índice acumulado e rebase para (ref_ano/ref_mes) ---
ipca_dt[, fator  := 1 + Var_mensal/100]
ipca_dt[, indice := cumprod(fator)]

ref_val <- ipca_dt[Ano == ref_ano & Mes_num == ref_mes, indice][1]
if (is.na(ref_val)) stop(sprintf("Não encontrei IPCA para %02d/%d na sua série.", ref_mes, ref_ano))

# Fator para trazer valores NOMINAIS do mês t para R$ de (ref_ano/ref_mes):
ipca_dt[, fator_ref := ref_val / indice]

# --- 3) Aplicar aos seus dados LONG (dados_brasil) ---
if (exists("dados_brasil")) {
  dados_brasil_adj <- merge(
    dados_brasil,
    ipca_dt[, .(Ano, Mes_num, fator_ref)],
    by = c("Ano", "Mes_num"),
    all.x = TRUE
  )[
    , Valor_ref := Valor * fator_ref
  ][
    , .(Ano, Mes, Mes_num, Data, Regiao, Item, Valor, Valor_ref)
  ]
  
  # Seus equivalentes a 100% (73/27) agora com base Jul/2025:
  dados_brasil_adj[Item == "Preço Produtor Gasolina A", valor_real := (Valor_ref * 100) / 73]
  dados_brasil_adj[Item == "Preço Etanol Anidro",       valor_real := (Valor_ref * 100) / 27]
}

# --- 4) Aplicar aos seus dados WIDE (opcional) ---
if (exists("dados_brasil_wide")) {
  rot_gas <- sprintf("Preço Produtor Gasolina A (Jul/%d R$)", ref_ano)
  rot_eta <- sprintf("Preço Etanol Anidro (Jul/%d R$)",       ref_ano)
  
  dados_brasil_wide_adj <- merge(
    dados_brasil_wide,
    ipca_dt[, .(Ano, Mes_num, fator_ref)],
    by = c("Ano", "Mes_num"),
    all.x = TRUE
  )[
    , (rot_gas) := `Preço Produtor Gasolina A` * fator_ref
  ][
    , (rot_eta) := `Preço Etanol Anidro` * fator_ref
  ]
}

# Visualização rápida (se existirem)
if (exists("dados_brasil_adj"))      print(dados_brasil_adj[])
if (exists("dados_brasil_wide_adj")) print(dados_brasil_wide_adj[])



###################################





# garantir que temos as duas séries calculadas em valor_real (já fez nas duas linhas acima)
# Filtrar Brasil e montar dados do gráfico
plot_dt <- dados_brasil_adj[
  Regiao == "Brasil" & Item %in% c("Preço Produtor Gasolina A", "Preço Etanol Anidro"),
  .(data = as.Date(Data), 
    preco = valor_real,
    serie = ifelse(Item == "Preço Produtor Gasolina A",
                   "Preço Gasolina A",
                   "Preço Etanol Anidro"))
][order(data)]

# remover possíveis NAs
plot_dt <- plot_dt[!is.na(preco) & !is.na(data)]

p <- ggplot(plot_dt, aes(x = data, y = preco, color = serie)) +
  geom_line(linewidth = 1.2, na.rm = TRUE) +
  geom_point(size = 2.2, na.rm = TRUE) +
  scale_y_continuous(
    labels = label_number(
      accuracy = 0.01, big.mark = ".", decimal.mark = ",", prefix = "R$ "
    ),
    expand = expansion(mult = c(0.03, 0.08))
  ) +
  # apenas o ano no eixo X
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  scale_color_manual(
    values = c("Preço Gasolina A" = "#1f77b4",
               "Preço Etanol Anidro"       = "#d62728"),
    name = NULL
  ) +
  labs(y = "Preço", x = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    legend.justification = "left",
    panel.grid.minor = element_blank()
  )

p


ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_9.png", p, width = 9.5, height = 5.2, dpi = 300)
write_xlsx(plot_dt,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_9.xlsx")
