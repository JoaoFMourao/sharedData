# ============================================================
# 07_consumo_geracao.R - Comparação Geração vs Consumo
# ============================================================
# Compara a evolução da geração e consumo por subsistema
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt_agg <- readRDS(file.path(INPUT_DIR, "dt_geracao_subsistema.rds"))
dt_consumo <- readRDS(file.path(INPUT_DIR, "dt_consumo_subsistema.rds"))

# ------------------------------------------------------------
# PREPARAÇÃO DOS DADOS
# ------------------------------------------------------------

# Prepara dados de geração
dt_ger <- dt_agg[
  subsistema != "Sistemas isolados",
  .(subsistema, year, Geracao = geracao_total)
]

# Prepara dados de consumo
dt_cons <- dt_consumo[
  subsistema != "Sistemas isolados",
  .(subsistema, year = ano, Consumo = consumo)
]

# Padroniza nomes de subsistema
dt_ger[subsistema == "Sudeste/C.Oeste", subsistema := "Sudeste"]
dt_cons[subsistema == "Sudeste/C. Oeste", subsistema := "Sudeste"]

# Junta geração + consumo
dt_gc <- merge(dt_ger, dt_cons, by = c("subsistema", "year"))

# Restaura nome original
dt_gc[subsistema == "Sudeste", subsistema := "Sudeste/C.Oeste"]

# Derrete para formato longo
dt_gc_long <- melt(
  dt_gc,
  id.vars = c("subsistema", "year"),
  measure.vars = c("Geracao", "Consumo"),
  variable.name = "Tipo",
  value.name = "GWh"
)

# Ajusta labels
dt_gc_long[Tipo == "Geracao", Tipo := "Geração"]

# Pontos do último ano para anotações
last_points <- dt_gc_long[, .SD[year == max(year)], by = .(subsistema, Tipo)]

# ------------------------------------------------------------
# GRÁFICO: Geração vs Consumo por subsistema
# ------------------------------------------------------------

p_gc <- ggplot(dt_gc_long, aes(x = year, y = GWh, colour = Tipo, group = Tipo)) +
  geom_line(size = 1.3, alpha = 0.9) +
  geom_point(size = 3, alpha = 0.9) +
  geom_text(
    data = last_points,
    aes(label = formato_br(GWh)),
    hjust = -0.1,
    vjust = 0.5,
    size = 3,
    show.legend = FALSE
  ) +
  facet_wrap(~ subsistema, scales = "free_y", ncol = 2) +
  scale_x_continuous(
    breaks = unique(dt_gc_long$year),
    expand = expansion(mult = c(0.05, 0.2))
  ) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_colour_manual(
    values = c("Geração" = "#27ae60", "Consumo" = "#e74c3c")
  ) +
  labs(
    x = "Ano",
    y = "Energia Elétrica (GWh)",
    title = "Geração e Consumo de Energia Elétrica por Subsistema"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    legend.text = element_text(size = 12, face = "bold"),
    legend.position = "top",
    panel.spacing = unit(1.8, "lines"),
    strip.text = element_text(face = "bold", size = 12),
    strip.background = element_rect(fill = "gray96", color = NA),
    panel.grid.major = element_line(color = "gray92", size = 0.3),
    panel.grid.minor = element_blank(),
    plot.margin = unit(c(1.5, 1.5, 1.5, 1.5), "cm")
  ) +
  guides(colour = guide_legend(override.aes = list(size = 4, alpha = 1)))

ggsave(
  file.path(OUTPUT_DIR, "consumo_geracao.jpg"),
  plot = p_gc,
  device = "jpg",
  width = 12,
  height = 9,
  units = "in"
)

message("Gráfico de comparação geração vs consumo salvo!")
