library(readxl)
library(data.table)
library(ggplot2)
library(writexl) 

# ---------- THEME BASE ----------
theme_base <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_line(linewidth = 0.3),
    strip.text = element_text(face = "bold"),
    strip.background = element_rect(fill = "#F5F5F7", color = NA)
  )

# ================== CARGA ==================
dt_carga <- read_xlsx(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Atlas_2024_Planilha_Dados.xlsx",
  sheet = 53, skip = 19
)
setDT(dt_carga)
dt_carga <- dt_carga[1:24,]
setnames(dt_carga, "tep/(106 pt.km)", "Ano")
dt_carga[, Ano := as.integer(Ano)]

dt_carga_long <- melt(
  dt_carga,
  id.vars      = "Ano",
  measure.vars = c("Rodoviário", "Ferroviário", "Aquaviário", "Aéreo", "Total"),
  variable.name = "Modo",
  value.name    = "Intensidade"
)[Modo != "Total"]

# Remover AÉREO de CARGA
dt_carga_long <- dt_carga_long[Modo != "Aéreo"]
dt_carga_long[, Tipo := "Carga — Tep/(10^6 t·km)"]

# ================== PASSAGEIROS ==================
dt_pass <- read_xlsx(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Atlas_2024_Planilha_Dados.xlsx",
  sheet = 48, skip = 19
)
setDT(dt_pass)
dt_pass <- dt_pass[, 1:7]
setnames(dt_pass, "tep/(106 pass.km)", "Ano")
dt_pass[, Ano := as.integer(Ano)]
setnames(dt_pass,
         old = c("Aqua", "Rodo Leves", "Rodo Coletivo", "Ferro"),
         new = c("Hidroviário", "Rodoviário Leves", "Rodoviário Coletivo", "Ferroviário"))

dt_pass_long <- melt(
  dt_pass,
  id.vars      = "Ano",
  measure.vars = c("Hidroviário","Rodoviário Leves","Total","Aéreo","Rodoviário Coletivo","Ferroviário"),
  variable.name = "Modo",
  value.name    = "Intensidade"
)[Modo != "Total"]

dt_pass_long[, Tipo := "Passageiros — Tep/(10^6 p·km)"]

# ================== COMBINAR E ORDENAR ==================
dt_all <- rbindlist(list(dt_carga_long, dt_pass_long), use.names = TRUE, fill = TRUE)

dt_all[, Modo := factor(
  as.character(Modo),
  levels = c("Rodoviário", "Rodoviário Leves", "Rodoviário Coletivo",
             "Ferroviário", "Aquaviário", "Hidroviário", "Aéreo")
)]

paleta <- c(
  "Rodoviário"          = "#D73027",  # vermelho
  "Rodoviário Leves"    = "#D73027",  # vermelho (consistência)
  "Rodoviário Coletivo" = "#FD8D3C",  # laranja
  "Ferroviário"         = "#377EB8",  # azul
  "Aquaviário"          = "#4DAF4A",  # verde (carga)
  "Hidroviário"         = "#4DAF4A",  # verde (passageiros)
  "Aéreo"               = "#984EA3"   # roxo (só passageiros)
)

# ================== GRÁFICO: 2 PAINÉIS, MODAIS JUNTOS EM CADA ==================
g <- ggplot(dt_all, aes(Ano, Intensidade, color = Modo)) +
  geom_line(linewidth = 1.0) +
  geom_point(size = 1.6) +
  scale_color_manual(values = paleta, name = NULL) +
  scale_x_continuous(breaks = seq(2000, 2025, 5)) +
  facet_wrap(~ Tipo, ncol = 2, scales = "free_y") +  # lado a lado; troque ncol=1 para empilhado
  labs(
    x = "Ano", y = NULL
  ) +
  theme_base +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11)
  )

print(g)

ggsave(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_13.jpg",
  g, width = 14, height = 8, units = "in", dpi = 300
)

write_xlsx(dt_all,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_13.xlsx")

