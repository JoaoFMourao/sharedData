# ============================================================
# 03_geracao_renovavel.R - Análise renovável vs não-renovável
# ============================================================
# Compara geração de fontes renováveis e não-renováveis
# por subsistema elétrico
# ============================================================

source("00_setup.R")

# Carrega dados processados
dt_agg <- readRDS(file.path(INPUT_DIR, "dt_geracao_subsistema.rds"))

# ------------------------------------------------------------
# CLASSIFICAÇÃO DAS FONTES
# ------------------------------------------------------------

renew_cols <- c("hidro", "eolica", "solar", "bagaco_cana",
                "lenha", "lixivia", "outras_renovaveis")

nonrenew_cols <- c("nuclear", "termo", "carvao_vapor", "gas_natural",
                   "gas_coqueria", "oleo_combustivel", "oleo_diesel",
                   "outras_nao_renovaveis")

# Agrega por tipo de fonte
dt_energy <- dt_agg[
  ,
  .(
    Renovavel = rowSums(.SD[, ..renew_cols], na.rm = TRUE),
    Nao_Renovavel = rowSums(.SD[, ..nonrenew_cols], na.rm = TRUE)
  ),
  by = .(subsistema, year),
  .SDcols = c(renew_cols, nonrenew_cols)
]

# Derrete para formato longo
dt_long <- melt(
  dt_energy,
  id.vars = c("subsistema", "year"),
  measure.vars = c("Renovavel", "Nao_Renovavel"),
  variable.name = "Tipo",
  value.name = "GWh"
)

# Ajusta labels
dt_long[Tipo == "Renovavel", Tipo := "Renovável"]
dt_long[Tipo == "Nao_Renovavel", Tipo := "Não Renovável"]

# ------------------------------------------------------------
# GRÁFICO: Renovável vs Não-Renovável por subsistema
# ------------------------------------------------------------

p_renovavel <- ggplot(dt_long, aes(x = year, y = GWh, color = Tipo, group = Tipo)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_text(aes(label = ifelse(year == max(year),
                               formato_br(GWh, 1),
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  facet_wrap(~ subsistema, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = unique(dt_long$year),
                     expand = expansion(mult = c(0.05, 0.2))) +
  scale_y_continuous(labels = function(x) formato_br(x),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_color_manual(values = c("Renovável" = "#2ecc71",
                                "Não Renovável" = "#e74c3c")) +
  labs(
    x = "Ano",
    y = "Geração Elétrica (GWh)",
    color = "Tipo de Energia",
    title = "Geração Elétrica Renovável vs Não-Renovável por Subsistema"
  ) +
  theme_epe() +
  theme(
    legend.position = "top",
    panel.spacing = unit(1.5, "lines"),
    strip.text = element_text(face = "bold", size = 11, color = "gray20"),
    strip.background = element_rect(fill = "gray97", color = NA)
  ) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1)))

# Salvar gráfico
ggsave(
  file.path(OUTPUT_DIR, "geracao_eletrica_renovavel.jpg"),
  plot = p_renovavel,
  device = "jpg",
  width = 11,
  height = 7,
  units = "in"
)

message("Gráfico renovável vs não-renovável salvo!")
