# ============================================================
# 08_consumo_setor.R - Consumo setorial de energia
# ============================================================
# Análise do consumo por setor: Residencial, Comercial,
# Industrial e Outros
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt <- readRDS(file.path(INPUT_DIR, "dt_consumo_setor.rds"))

# Filtra consumo total por setor
dt_total <- dt[tipo == "total"]

# Ordena setores
dt_total[, setor := factor(setor, levels = c("Residencial", "Comercial", "Industrial", "Outros"))]

# Cores personalizadas
cores_setores <- c(
  "Residencial" = "#1f77b4",
  "Comercial" = "#ff7f0e",
  "Industrial" = "#2ca02c",
  "Outros" = "#9467bd"
)

# ------------------------------------------------------------
# GRÁFICO 1: Evolução do consumo por setor (linhas)
# ------------------------------------------------------------

p_setor_linha <- ggplot(dt_total, aes(x = ano, y = consumo, color = setor)) +
  geom_line(linewidth = 1.2, alpha = 0.9) +
  geom_point(size = 2.5) +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    limits = c(0, max(dt_total$consumo) * 1.05),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_color_manual(values = cores_setores) +
  labs(
    x = "Ano",
    y = "Consumo de Energia (GWh)",
    color = "Setor"
  ) +
  theme_epe() +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

ggsave(
  file.path(OUTPUT_DIR, "consumo_energia_setor.jpg"),
  plot = p_setor_linha,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

# Exporta dados
write_xlsx(dt_total, path = file.path(OUTPUT_DIR, "Figura 7 – Consumo setorial de energia elétrica.xlsx"))

# ------------------------------------------------------------
# GRÁFICO 2: Consumo por setor em 2023 (barras)
# ------------------------------------------------------------

dados_2023 <- dt_total[ano == 2023][order(-consumo)]
dados_2023[, setor := factor(setor, levels = setor)]

p_setor_barra <- ggplot(dados_2023, aes(x = setor, y = consumo, fill = setor)) +
  geom_col(width = 0.7, alpha = 0.9) +
  geom_text(
    aes(label = formato_br(consumo)),
    vjust = -0.5,
    size = 4.5,
    fontface = "bold",
    color = "black"
  ) +
  scale_fill_manual(values = cores_setores) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.1)),
    labels = function(x) formato_br(x)
  ) +
  labs(
    x = NULL,
    y = "Consumo (GWh)"
  ) +
  theme_epe() +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(face = "bold", size = 12, angle = 0, hjust = 0.5)
  )

ggsave(
  file.path(OUTPUT_DIR, "consumo_energia_setor_barra.jpg"),
  plot = p_setor_barra,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráficos de consumo setorial salvos!")
