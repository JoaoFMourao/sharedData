# Pacotes
library(data.table)
library(ggplot2)
library(scales)
library(ggrepel)
library(readxl)
library(writexl) 

dt <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/tabela_veiculos_fuel.xlsx")
setDT(dt)

# =======================
# 1) Reestruturar p/ formato longo (tidy)
# =======================
# dt: data.table com colunas como AUTO_GASOLINA, COM_LEVE_DIESEL, etc.
dt_long <- melt(
  dt,
  id.vars = "ANO",
  variable.name = "VAR",
  value.name = "VALOR"
)

# Extrair CATEGORIA (antes do último "_") e COMBUSTIVEL (depois do último "_")
dt_long[, CATEGORIA   := sub("_(?!.*_).*", "", VAR, perl = TRUE)]
dt_long[, COMBUSTIVEL := sub("^.*_",        "", VAR)]

# Mapear categorias
cat_map <- c(
  "AUTO"      = "Automóvel",
  "COM_LEVE"  = "Comercial Leve",
  "CAMINHÕES" = "Caminhão",
  "ÔNIBUS"    = "Ônibus",
  "TOTAL"     = "Total"
)
dt_long[, CATEGORIA := fcase(
  CATEGORIA %in% names(cat_map), cat_map[CATEGORIA],
  default = CATEGORIA
)]

# Padronizar combustíveis
norm <- function(x){
  x <- trimws(tolower(x))
  x <- chartr("áéíóúãõç", "aeiouaoc", x)   # normaliza acentos
  fcase(
    x == "gasolina",          "Gasolina",
    x == "etanol",            "Etanol",
    x == "flex",              "Flex",
    x == "eletrificado",      "Elétrico",
    x == "diesel",            "Diesel",
    x == "gas",               "Gás",
    default = tools::toTitleCase(x)
  )
}
dt_long[, COMBUSTIVEL := norm(COMBUSTIVEL)]

# Tidy final básico
dt_long <- dt_long[!is.na(VALOR), .(ANO, CATEGORIA, COMBUSTIVEL, VALOR)]

# =======================
# 2) Filtrar 2019–2024
# =======================
dt_2019_2024 <- dt_long[ANO %between% c(2019, 2024)]

# =======================
# 3) Consolidações pedidas:
#    - Etanol + Flex  -> "Etanol+Flex"
#    - Gasolina + Diesel -> "Gasolina+Diesel"
# =======================
dt_sum2 <- copy(dt_2019_2024)
dt_sum2[, COMBUSTIVEL := fcase(
  COMBUSTIVEL %in% c("Etanol","Flex"),   "Etanol+Flex",
  COMBUSTIVEL %in% c("Gasolina","Diesel"), "Gasolina+Diesel",
  COMBUSTIVEL == "Elétrico",             "Elétrico",
  COMBUSTIVEL == "Gás",                  "Gás",
  default = COMBUSTIVEL
)]
dt_sum2 <- dt_sum2[, .(VALOR = sum(VALOR, na.rm = TRUE)),
                   by = .(ANO, CATEGORIA, COMBUSTIVEL)]

# =======================
# 4) Preparar dados para o gráfico de ELÉTRICOS
#    - Excluir "Total"
#    - Calcular % dos elétricos no último ano por categoria
# =======================
elec   <- dt_sum2[COMBUSTIVEL == "Elétrico" & CATEGORIA != "Total"]
totais <- dt_sum2[CATEGORIA != "Total",
                  .(TOTAL = sum(VALOR, na.rm = TRUE)),
                  by = .(ANO, CATEGORIA)]

ultimo_ano <- elec[, max(ANO, na.rm = TRUE)]

elec_last <- merge(
  elec[ANO == ultimo_ano],
  totais[ANO == ultimo_ano],
  by = c("ANO","CATEGORIA"),
  all.x = TRUE
)
elec_last[, PCT := fifelse(TOTAL > 0, VALOR / TOTAL, NA_real_)]
elec_last[, LABEL := percent(PCT, accuracy = 0.1)]

# =======================
# 5) Gráfico — Elétricos por categoria, com % no último ano
# =======================
p <- ggplot(elec, aes(x = ANO, y = VALOR)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.4) +
  facet_wrap(~ CATEGORIA, scales = "free_y") +
  # Destaque do último ano
  geom_vline(xintercept = ultimo_ano, linetype = "dotted") +
  # Rótulo da % no último ano, por categoria
  geom_label_repel(
    data = elec_last,
    aes(label = LABEL),
    nudge_x = 0.25,
    min.segment.length = 0,
    segment.alpha = 0.6,
    seed = 123,
    box.padding = 0.35,
    point.padding = 0.3,
    label.size = 0.2,
    size = 4,
    show.legend = FALSE
  ) +
  scale_x_continuous(breaks = sort(unique(elec$ANO))) +
  scale_y_continuous(labels = comma) +
  labs(
   # title    = "Emplacamento de autoveículos novos elétricos",
    #subtitle = paste0("Percentual de elétricos no total em ", ultimo_ano),
    x = "Ano",
    y = "Número de Emplacamentos"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title      = element_text(face = "bold"),
    legend.position = "none",
    panel.grid.minor = element_blank(),
    strip.text      = element_text(face = "bold")
  )

print(p)


# --- salvar gráfico ---
ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_10.png", p, width = 9, height = 6, dpi = 300)
write_xlsx(elec,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_10.xlsx")


# Se preferir destacar tendência sem achatar séries, use eixo log:
# p + scale_y_log10(labels = comma)
