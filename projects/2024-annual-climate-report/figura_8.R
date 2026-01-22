  # ================== Pacotes ==================
  library(readxl)
  library(data.table)
  library(ggplot2)
  library(scales)
  library(writexl)
  
  # ================== 1) Importar ==================
  dt <- read_xlsx(
    "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/biodiesel x diesel.xlsx",
    sheet = 38
  )
  setDT(dt)
  
  # Garantir colunas necessárias (ajuste os nomes se diferirem)
  cols_needed <- c("Ano","Mês",
                   "Preço do diesel na refinaria (sem ICMS)",
                   "Preço do biodiesel no leilão",
                   "Preço do biodiesel - negociação livre")
  dt <- dt[, ..cols_needed]
  
  # ================== 2) Preparar dt_final ==================
  setDT(dt)
  dt[, Ano := nafill(Ano, type = "locf")]
  
  # mês -> número e data
  map_mes <- c(jan=1L, fev=2L, mar=3L, abr=4L, mai=5L, jun=6L,
               jul=7L, ago=8L, set=9L, out=10L, nov=11L, dez=12L)
  dt[, Mes_num := unname(map_mes[tolower(trimws(`Mês`))])]
  dt[, data := as.IDate(sprintf("%04d-%02d-01", Ano, Mes_num))]
  
  # converter preços para numérico (caso venham como texto com vírgula)
  to_num <- function(x) as.numeric(gsub(",", ".", as.character(x)))
  dt[, `Preço do diesel na refinaria (sem ICMS)` := to_num(`Preço do diesel na refinaria (sem ICMS)`)]
  dt[, `Preço do biodiesel no leilão`            := to_num(`Preço do biodiesel no leilão`)]
  dt[, `Preço do biodiesel - negociação livre`   := to_num(`Preço do biodiesel - negociação livre`)]
  
  # unificar biodiesel (prioriza leilão; se NA, usa negociação livre)
  dt[, preco_biodiesel := fcoalesce(`Preço do biodiesel no leilão`,
                                    `Preço do biodiesel - negociação livre`)]
  dt[, preco_diesel_refinaria_sem_icms := `Preço do diesel na refinaria (sem ICMS)`]
  
  # manter apenas o que o código posterior espera
  dt_final <- dt[, .(data, preco_diesel_refinaria_sem_icms, preco_biodiesel)]
  setorder(dt_final, data)
  
  # ================== 3) (Opcional) detectar início de negociação livre ==================
  switch_date <- NA
  if ("Preço do biodiesel - negociação livre" %in% names(dt)) {
    tmp <- copy(dt)
    tmp[, ano := nafill(Ano, type = "locf")]
    tmp[, mes := tolower(trimws(`Mês`))]
    tmp[, mes_num := unname(map_mes[mes])]
    tmp[, data := as.IDate(sprintf("%04d-%02d-01", ano, mes_num))]
    if (any(!is.na(tmp$`Preço do biodiesel - negociação livre`))) {
      switch_date <- tmp[!is.na(`Preço do biodiesel - negociação livre`), min(data)]
    }
  }
  
  # ================== 4) Preparar dados para gráfico ==================
  plot_dt <- melt(
    dt_final,
    id.vars = "data",
    measure.vars = c("preco_diesel_refinaria_sem_icms", "preco_biodiesel"),
    variable.name = "serie",
    value.name   = "preco"
  )
  
  labs_series <- c(
    preco_diesel_refinaria_sem_icms = "Preço do Diesel na refinaria (sem ICMS)",
    preco_biodiesel                 = "Preço do Biodiesel"
  )
  plot_dt[, serie := factor(serie, levels = names(labs_series), labels = labs_series)]
  
  last_points <- plot_dt[!is.na(preco), .SD[.N], by = serie]
  
  # ================== 5) Gráfico e exportações ==================
  p <- ggplot(plot_dt, aes(x = data, y = preco, color = serie)) +
    geom_line(linewidth = 1.2, na.rm = TRUE) +
    geom_point(size = 2.2, na.rm = TRUE) +
    scale_y_continuous(
      labels = label_number(accuracy = 0.01, big.mark = ".", decimal.mark = ",", prefix = "R$ "),
      expand = expansion(mult = c(0.03, 0.08))
    ) +
    scale_color_manual(
      values = c("Preço do Diesel na refinaria (sem ICMS)" = "#1f77b4",
                 "Preço do Biodiesel"                      = "#d62728"),
      name = NULL
    ) +
    labs(y = "Preço", x = NULL) +
    theme_minimal(base_size = 12) +
    theme(
      legend.position = "top",
      legend.justification = "left",
      panel.grid.minor = element_blank()
    )
  
  print(p)

ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_8.png",
       p, width = 9.5, height = 5.2, dpi = 300)

write_xlsx(plot_dt,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_8.xlsx")
