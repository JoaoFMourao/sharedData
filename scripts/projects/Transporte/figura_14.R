# Pacotes
library(data.table)
library(ggplot2)
library(writexl) 

# helper: anos + meses -> anos decimais
ym <- function(anos, meses = 0) anos + meses/12

anos <- 2015:2024

# -----------------------------
# Base de dados (formato longo)
# -----------------------------
dt <- rbindlist(list(
  data.table(Segmento = "Automóveis", Ano = anos,
             Idade = ym(c(8,9,9,9,9,10,10,10,11,11),
                        c(10,2,5,7,9,1,5,9,1,2))),
  data.table(Segmento = "Comerciais Leves", Ano = anos,
             Idade = ym(c(7,7,7,7,8,8,8,8,8,8),
                        c(2,6,9,11,1,4,6,9,11,11))),
  data.table(Segmento = "Caminhões", Ano = anos,
             Idade = ym(c(10,10,11,11,11,11,11,11,12,12),
                        c(0,6,0,4,6,9,10,11,1,2))),
  data.table(Segmento = "Ônibus", Ano = anos,
             Idade = ym(c(9,9,10,10,10,10,11,11,11,11),
                        c(3,8,1,4,5,9,0,2,4,4))),
  data.table(Segmento = "Motocicletas", Ano = anos,
             Idade = ym(c(6,6,7,7,8,8,8,8,8,8),
                        c(5,10,4,8,0,3,5,5,4,0))),
  data.table(Segmento = "Média", Ano = anos,
             Idade = ym(c(8,9,9,9,10,10,10,10,10,10),
                        c(10,2,7,10,0,3,5,8,10,11)))
))

# (opcional) ordenar legenda
dt[, Segmento := factor(Segmento,
                        levels = c("Automóveis","Comerciais Leves",
                                   "Caminhões","Ônibus",
                                   "Motocicletas","Média"))]
# --- (re)cria o gráfico a partir de dt ---
library(ggplot2)

p <- ggplot(dt, aes(x = Ano, y = Idade, color = Segmento)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = 2015:2024) +
  labs(
    title   = "",
    x       = "Ano",
    y       = "Idade média (anos)",
    caption = ""
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"),
        legend.title = element_blank())

# --- salva na pasta pedida ---
out_dir <- "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

fname_base <- file.path(out_dir, "figura_14")

# PNG (300 dpi)
ggsave(filename = paste0(fname_base, ".png"),
       plot = p, width = 10, height = 6, units = "in", dpi = 300)

# PDF vetorial
ggsave(filename = paste0(fname_base, ".pdf"),
       plot = p, width = 10, height = 6, units = "in")


write_xlsx(dt,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_14.xlsx")
