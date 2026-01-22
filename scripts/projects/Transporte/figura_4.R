# Pacotes
library(readxl)
library(data.table)
library(ggplot2)
library(scales)
library(patchwork)
library(writexl)



# ---------- helper ----------
to_long_share <- function(dt, ano_col = "ano") {
  setDT(dt)
  setnames(dt, names(dt)[1], ano_col)
  dt <- dt[!is.na(get(ano_col))]
  num_cols <- names(dt)[vapply(dt, function(x) is.numeric(x) || is.integer(x), logical(1))]
  num_cols <- setdiff(num_cols, ano_col)
  long <- melt(dt, id.vars = ano_col, measure.vars = num_cols,
               variable.name = "modal", value.name = "valor")
  long[, total := sum(valor, na.rm = TRUE), by = get(ano_col)]
  long[, share := ifelse(total > 0, valor/total, NA_real_)]
  long[, label := ifelse(is.na(share), NA, paste0(round(share*100, 1), "%"))]
  setnames(long, ano_col, "ano")
  long[]
}

# ========= CARGA =========
carga_raw <- read_xlsx(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Atlas_2024_Planilha_Dados.xlsx",
  sheet = 54, skip = 20
)
carga <- to_long_share(carga_raw)

carga[, modal := trimws(modal)]
carga[grepl("(?i)rodovi", modal), modal := "Rodoviário"]
carga[grepl("(?i)ferrovi", modal), modal := "Ferroviário"]
carga[grepl("(?i)aquavi", modal), modal := "Aquaviário"]
carga[grepl("(?i)a[eé]reo", modal), modal := "Aéreo"]

carga_dado <- carga
carga_dado <- carga_dado[,categoria := "carga"]

# --- remove Aéreo da Carga ---
carga <- carga[modal != "Aéreo"]

stack_carga  <- c("Rodoviário", "Ferroviário", "Aquaviário")
legend_carga <- c("Aquaviário", "Ferroviário", "Rodoviário")

carga[, modal := factor(modal, levels = stack_carga)]
carga[, ano := factor(ano, levels = c(2000, 2010, 2020, 2023))]

cols_carga <- c(
  "Rodoviário"  = "#244F73",
  "Ferroviário" = "#BFBFBF",
  "Aquaviário"  = "#E7C21A"
)

p_carga <- ggplot(carga, aes(ano, share, fill = modal)) +
  geom_col(width = 0.92, position = "fill") +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5),
            size = 4, fontface = "bold", color = "black") +
  scale_y_continuous(labels = percent_format(accuracy = 1), breaks = seq(0,1,.25), expand = c(0,0)) +
  scale_fill_manual(values = cols_carga, breaks = legend_carga) +
  labs(title = "Carga [t·km]", x = NULL, y = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.title = element_blank()
  )

# ========= PASSAGEIROS =========
pass_raw <- read_xlsx(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Atlas_2024_Planilha_Dados.xlsx",
  sheet = 49, skip = 17
)
pass <- to_long_share(pass_raw)

pass[, modal := trimws(modal)]
pass[grepl("(?i)rodovi[áa]rio.*(leve|individual|auto)", modal), modal := "Rodoviário Leves"]
pass[grepl("(?i)rodovi[áa]rio.*(coletivo|[ôo]nibus)", modal), modal := "Rodoviário Coletivo"]
pass[grepl("(?i)ferrovi", modal), modal := "Ferroviário"]
pass[grepl("(?i)aquavi", modal), modal := "Aquaviário"]
pass[grepl("(?i)a[eé]reo", modal), modal := "Aéreo"]

pass_dado <- pass

pass_dado <- pass_dado[,categoria := "passageiro"]

# --- remove Aquaviário de Passageiros ---
pass <- pass[modal != "Aquaviário"]

stack_pass  <- c("Rodoviário Leves", "Rodoviário Coletivo", "Ferroviário", "Aéreo")
legend_pass <- c("Aéreo", "Ferroviário", "Rodoviário Coletivo", "Rodoviário Leves")

pass[, modal := factor(modal, levels = stack_pass)]
pass[, ano := factor(ano, levels = c(2000, 2010, 2020, 2023))]

cols_pass <- c(
  "Rodoviário Leves"    = "#6FA9DC",
  "Rodoviário Coletivo" = "#F08C2A",
  "Ferroviário"         = "#BFBFBF",
  "Aéreo"               = "#8D4053"
)

p_pass <- ggplot(pass, aes(ano, share, fill = modal)) +
  geom_col(width = 0.92, position = "fill") +
  geom_text(
    aes(label = ifelse(modal == "Ferroviário", "", label)), # oculta apenas ferroviário
    position = position_stack(vjust = 0.5),
    size = 4, fontface = "bold", color = "black"
  ) +
  scale_y_continuous(labels = percent_format(accuracy = 1), breaks = seq(0,1,.25), expand = c(0,0)) +
  scale_fill_manual(values = cols_pass, breaks = legend_pass) +
  labs(title = "Passageiros [p·km]", x = NULL, y = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.title = element_blank()
  )

# ========= Combinar =========
fig <- p_pass + p_carga + plot_layout(widths = c(1,1))
fig

dado <- rbind(carga_dado,pass_dado)

dado <- dado[,.(ano,modal,categoria,label)]

write_xlsx(dado, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_4.xlsx")


# salvar
ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_4.jpg",
       fig, width = 14, height = 8, units = "in", dpi = 300)
