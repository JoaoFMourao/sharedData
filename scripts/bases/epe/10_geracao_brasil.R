# ============================================================
# 10_geracao_brasil.R - Geração nacional por fonte
# ============================================================
# Análise da geração elétrica total do Brasil por fonte
# ============================================================

source("00_setup.R")

# ------------------------------------------------------------
# LEITURA E PROCESSAMENTO DOS DADOS NACIONAIS
# ------------------------------------------------------------

dt <- read_xlsx(
  file.path(INPUT_DIR, "Capítulo 8 (Dados Estaduais).xlsx"),
  sheet = 3
)
setDT(dt)

# Renomeia primeira coluna
setnames(dt, names(dt)[1], "estado")

# Extrai ano
dt[, year := fifelse(
  str_detect(estado, "^ANO BASE"),
  as.integer(str_extract(estado, "\\d{4}")),
  NA_integer_
)]
dt[, year := nafill(year, type = "locf")]

# Filtra cabeçalhos
dt <- dt[
  !is.na(estado) &
    !str_detect(estado, regex("^(TABLE|ANO BASE|Estado)", ignore_case = TRUE))
]

# Limpa nomes
dt[, estado := str_trim(str_replace_all(estado, "\\r|\\n", ""))]

# Converte para numérico
num_cols <- setdiff(names(dt), c("estado", "year"))
dt[, (num_cols) := lapply(.SD, parse_number), .SDcols = num_cols]

if ("...18" %in% names(dt)) dt[, `...18` := NULL]

# Renomeia colunas
old_cols <- names(dt)[!names(dt) %in% c("estado", "year")]
new_cols <- c(
  "Total", "Hydro", "Wind", "Solar", "Nuclear", "Thermal",
  "Bagasse", "Firewood", "BlackLiquor", "OtherRenew",
  "SteamCoal", "NatGas", "CokeGas", "FuelOil", "DieselOil", "OtherNonRenew"
)
setnames(dt, old = old_cols, new = new_cols)

# Filtra apenas Brasil
dt <- dt[estado == "BRASIL"]

# ------------------------------------------------------------
# PREPARAÇÃO PARA GRÁFICOS
# ------------------------------------------------------------

dt2 <- dt %>%
  mutate(
    Oil = FuelOil + DieselOil,
    Others = Total - (Hydro + Wind + Solar + SteamCoal + NatGas + Oil),
    year = as.integer(year)
  ) %>%
  select(year, Total, Hydro, Wind, Solar, NatGas, SteamCoal, Oil, Others) %>%
  pivot_longer(-c(year, Total),
               names_to = "Source",
               values_to = "Generation") %>%
  group_by(year) %>%
  mutate(perc = Generation / Total) %>%
  ungroup() %>%
  mutate(
    Source = factor(Source,
                    levels = c("Hydro", "Wind", "Solar", "NatGas", "SteamCoal", "Oil", "Others"),
                    labels = c("Hidráulica", "Eólica", "Solar", "Gás natural", "Carvão", "Óleo", "Outros"))
  )

# ------------------------------------------------------------
# GRÁFICO 1: Participação por fonte (facetado)
# ------------------------------------------------------------

p_fonte_parti <- ggplot(dt2, aes(x = year, y = perc, fill = Source)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = percent(perc, accuracy = 0.01)),
            position = position_dodge(width = 0.8),
            vjust = -0.3, size = 2.5) +
  facet_wrap(~ Source, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = seq(min(dt2$year), max(dt2$year), by = 2)) +
  scale_y_continuous(
    labels = percent_format(accuracy = 0.01),
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    x = "Ano",
    y = "Participação (%)"
  ) +
  theme_epe() +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "none",
    panel.spacing = unit(1, "lines")
  )

ggsave(
  file.path(OUTPUT_DIR, "geracao_fonte_parti.jpg"),
  plot = p_fonte_parti,
  device = "jpg",
  width = 12,
  height = 7,
  units = "in"
)

# ------------------------------------------------------------
# GRÁFICO 2: Geração total do Brasil
# ------------------------------------------------------------

total_df <- dt %>%
  mutate(year = as.integer(year)) %>%
  select(year, Total)

p_total <- ggplot(total_df, aes(x = year, y = Total)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  geom_text(
    data = total_df %>% filter(year == max(year)),
    aes(label = paste0(formato_br(Total), " GWh")),
    vjust = -1, size = 3.5, color = "steelblue"
  ) +
  scale_x_continuous(breaks = total_df$year) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Geração Elétrica Total por Ano",
    x = "Ano",
    y = "Geração (GWh)"
  ) +
  theme_epe()

ggsave(
  file.path(OUTPUT_DIR, "geracao_total.jpg"),
  plot = p_total,
  device = "jpg",
  width = 12,
  height = 7,
  units = "in"
)

# Exporta dados
write_xlsx(as.data.frame(dt2), path = file.path(OUTPUT_DIR, "dados_figura_5.xlsx"))

message("Gráficos de geração nacional salvos!")
