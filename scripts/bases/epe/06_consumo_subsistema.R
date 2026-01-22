# ============================================================
# 06_consumo_subsistema.R - Consumo por subsistema
# ============================================================
# Gráficos de evolução do consumo de energia por subsistema
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt <- readRDS(file.path(INPUT_DIR, "dt_consumo_subsistema.rds"))

# ------------------------------------------------------------
# GRÁFICO 1: Consumo por subsistema (linhas)
# ------------------------------------------------------------

p_consumo_linha <- ggplot(dt, aes(x = ano,
                                   y = consumo,
                                   color = subsistema,
                                   group = subsistema)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text(aes(label = ifelse(ano == max(ano),
                               formato_br(consumo, 1),
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt$ano),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0.05, 0.1))) +
  scale_color_brewer(palette = "Set1") +
  labs(
    x = "Ano",
    y = "Consumo Energia Elétrica (GWh)",
    color = "Subsistema",
    title = "Evolução do Consumo de Energia Elétrica por Subsistema"
  ) +
  theme_epe() +
  guides(color = guide_legend(nrow = 1, byrow = TRUE))

ggsave(
  file.path(OUTPUT_DIR, "consumo_um_grafico.jpg"),
  plot = p_consumo_linha,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

# ------------------------------------------------------------
# GRÁFICO 2: Consumo por subsistema (facetado)
# ------------------------------------------------------------

p_consumo_facet <- ggplot(dt, aes(ano, consumo, colour = subsistema, group = subsistema)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3, alpha = 0.8) +
  scale_x_continuous(breaks = unique(dt$ano),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0.05, 0.10))) +
  scale_colour_brewer(palette = "Set1") +
  labs(
    x = "Ano",
    y = "Consumo de Energia Elétrica (GWh)",
    colour = "Subsistema",
    title = "Evolução do Consumo de Energia Elétrica por Subsistema"
  ) +
  facet_wrap(~ subsistema, scales = "free_y") +
  theme_epe() +
  theme(legend.position = "bottom")

ggsave(
  file.path(OUTPUT_DIR, "consumo.jpg"),
  plot = p_consumo_facet,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

# ------------------------------------------------------------
# GRÁFICO 3: Consumo total por subsistema (2023)
# ------------------------------------------------------------

dt_2023_sum <- dt[ano == 2023,
                  .(consumo_total = sum(consumo, na.rm = TRUE)),
                  by = subsistema][order(-consumo_total)]

p_consumo_2023 <- ggplot(dt_2023_sum,
                          aes(x = reorder(subsistema, -consumo_total),
                              y = consumo_total,
                              fill = subsistema)) +
  geom_col(width = 0.7, alpha = 0.8, colour = "white") +
  geom_text(aes(label = formato_br(consumo_total)),
            vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0, 0.05))) +
  scale_fill_brewer(palette = "Set1", guide = "none") +
  labs(
    title = "Consumo de Energia Elétrica por Subsistema — 2023",
    x = NULL,
    y = "Consumo Energia Elétrica (GWh)"
  ) +
  theme_epe() +
  theme(
    axis.text.x = element_text(angle = 20, hjust = 1, face = "bold"),
    panel.grid.major.x = element_blank()
  )

ggsave(
  file.path(OUTPUT_DIR, "consumo_2023.jpg"),
  plot = p_consumo_2023,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráficos de consumo por subsistema salvos!")
