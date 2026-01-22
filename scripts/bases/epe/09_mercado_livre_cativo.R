# ============================================================
# 09_mercado_livre_cativo.R - Mercado Livre vs Cativo
# ============================================================
# Análise da evolução do mercado livre e cativo de energia
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt <- readRDS(file.path(INPUT_DIR, "dt_consumo_setor.rds"))

# ------------------------------------------------------------
# GRÁFICO 1: Mercado livre vs cativo (total)
# ------------------------------------------------------------

dt_total <- dt[tipo %in% c("livre", "cativo"),
               .(consumo = sum(consumo)),
               by = .(ano, tipo)]

p_mercado <- ggplot(dt_total, aes(x = ano, y = consumo, color = tipo)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = seq(min(dt_total$ano), max(dt_total$ano), by = 3)) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_color_manual(
    values = c("livre" = "#0066CC", "cativo" = "#FF6600"),
    labels = c("livre" = "Mercado Livre", "cativo" = "Mercado Cativo")
  ) +
  labs(
    x = NULL,
    y = "Consumo (GWh)",
    color = "Tipo de Mercado"
  ) +
  theme_epe() +
  geom_text(
    data = dt_total[ano == max(ano)],
    aes(label = formato_br(consumo)),
    vjust = -1,
    size = 4,
    show.legend = FALSE
  )

ggsave(
  file.path(OUTPUT_DIR, "consumo_energia_livre_cativo.jpg"),
  plot = p_mercado,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

# ------------------------------------------------------------
# GRÁFICO 2: Mercado livre vs cativo por setor (facetado)
# ------------------------------------------------------------

dados_setor <- dt[tipo %in% c("livre", "cativo")]

p_mercado_setor <- ggplot(dados_setor, aes(x = ano, y = consumo, color = tipo)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  facet_wrap(~setor, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = seq(min(dados_setor$ano), max(dados_setor$ano), by = 4)) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    expand = expansion(mult = c(0, 0.15))
  ) +
  scale_color_manual(
    values = c("livre" = "#0066CC", "cativo" = "#FF6600"),
    labels = c("livre" = "Mercado Livre", "cativo" = "Mercado Cativo")
  ) +
  labs(
    x = NULL,
    y = "Consumo (GWh)",
    color = "Tipo de Mercado"
  ) +
  theme_epe() +
  theme(
    panel.spacing = unit(1.5, "lines"),
    strip.text = element_text(face = "bold", size = 12),
    strip.background = element_rect(fill = "gray95", color = NA)
  ) +
  geom_text(
    data = dados_setor[ano == max(ano)],
    aes(label = formato_br(consumo)),
    vjust = -0.8,
    size = 3.5,
    show.legend = FALSE
  )

ggsave(
  file.path(OUTPUT_DIR, "consumo_energia_livre_cativo_setor.jpg"),
  plot = p_mercado_setor,
  device = "jpg",
  width = 13,
  height = 7,
  units = "in"
)

# ------------------------------------------------------------
# GRÁFICO 3: Mercado livre vs cativo por setor em 2023 (barras)
# ------------------------------------------------------------

dados_2023 <- dt[ano == 2023 & tipo %in% c("livre", "cativo")]
ordem_setores <- dados_2023[, .(total = sum(consumo)), by = setor][order(-total), setor]
dados_2023[, setor := factor(setor, levels = ordem_setores)]

p_mercado_2023 <- ggplot(dados_2023, aes(x = setor, y = consumo, fill = tipo)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_text(
    aes(label = formato_br(consumo)),
    position = position_dodge(width = 0.7),
    vjust = -0.5,
    size = 3.5,
    fontface = "bold"
  ) +
  scale_fill_manual(
    values = c("livre" = "#0066CC", "cativo" = "#FF6600"),
    labels = c("livre" = "Mercado Livre", "cativo" = "Mercado Cativo")
  ) +
  scale_y_continuous(
    labels = function(x) formato_br(x),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
    x = NULL,
    y = "Consumo (GWh)",
    fill = "Tipo de Mercado"
  ) +
  theme_epe() +
  theme(
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave(
  file.path(OUTPUT_DIR, "consumo_energia_livre_cativo_setor_2023.jpg"),
  plot = p_mercado_2023,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráficos de mercado livre vs cativo salvos!")
