# ============================================================
# 02_geracao_subsistema.R - Geração elétrica por subsistema
# ============================================================
# Gráfico de evolução da geração elétrica total por subsistema
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt_agg <- readRDS(file.path(INPUT_DIR, "dt_geracao_subsistema.rds"))

# ------------------------------------------------------------
# GRÁFICO: Evolução da geração por subsistema
# ------------------------------------------------------------

p_geracao <- ggplot(dt_agg, aes(x = year,
                                 y = geracao_total,
                                 color = subsistema,
                                 group = subsistema)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text(aes(label = ifelse(year == max(year),
                               formato_br(geracao_total, 1),
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt_agg$year),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0.05, 0.1))) +
  scale_color_brewer(palette = "Set1") +
  labs(
    x = "Ano",
    y = "Geração Elétrica (GWh)",
    color = "Subsistema",
    title = "Evolução da Geração Elétrica por Subsistema"
  ) +
  theme_epe() +
  guides(color = guide_legend(nrow = 1, byrow = TRUE))

# Salvar gráfico
ggsave(
  file.path(OUTPUT_DIR, "geracao_eletrica.jpg"),
  plot = p_geracao,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráfico de geração por subsistema salvo!")
