# ============================================================
# 04_geracao_solar_eolica.R - Análise Solar e Eólica
# ============================================================
# Evolução da geração solar e eólica com foco no Nordeste
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt_agg <- readRDS(file.path(INPUT_DIR, "dt_geracao_subsistema.rds"))

# ------------------------------------------------------------
# GRÁFICO 1: Solar e Eólica por subsistema
# ------------------------------------------------------------

dt_sw <- melt(
  dt_agg,
  id.vars = c("subsistema", "year"),
  measure.vars = c("eolica", "solar"),
  variable.name = "Fonte",
  value.name = "GWh"
)

# Ajusta labels
dt_sw[Fonte == "eolica", Fonte := "Eólica"]
dt_sw[Fonte == "solar", Fonte := "Solar"]

p_sw_all <- ggplot(dt_sw, aes(x = year, y = GWh, color = Fonte, group = Fonte)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~ subsistema) +
  scale_x_continuous(breaks = unique(dt_sw$year)) +
  labs(
    x = "Ano",
    y = "Geração (GWh)",
    color = "Fonte",
    title = "Evolução da Geração Solar e Eólica por Subsistema"
  ) +
  theme_epe() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )

# ------------------------------------------------------------
# GRÁFICO 2: Solar e Eólica no Nordeste (destaque)
# ------------------------------------------------------------

dt_sw_ne <- dt_sw[subsistema == "Nordeste"]

p_nordeste <- ggplot(dt_sw_ne, aes(x = year, y = GWh, color = Fonte, group = Fonte)) +
  geom_line(size = 1.5, alpha = 0.9, lineend = "round") +
  geom_point(size = 4, alpha = 0.9) +
  geom_text(aes(label = ifelse(year == max(year),
                               formato_br(GWh), "")),
            vjust = -1, size = 4.5, fontface = "bold", show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt_sw_ne$year),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0.1, 0.2))) +
  scale_color_manual(values = c("Eólica" = "#3498db",
                                "Solar" = "#f39c12")) +
  labs(
    title = "Evolução da Geração Eólica e Solar no Nordeste",
    x = "Ano",
    y = "Geração (GWh)",
    color = "Fonte de Energia:"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    legend.position = "bottom",
    panel.grid.major.y = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  ) +
  guides(color = guide_legend(override.aes = list(size = 5)))

# Salvar gráficos
ggsave(
  file.path(OUTPUT_DIR, "geracao_eletrica_nordeste.jpg"),
  plot = p_nordeste,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráficos de solar e eólica salvos!")
