library(readxl)
library(data.table)
library(stringr)
library(readr)
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(scales)


setwd("C:/Users/User/OneDrive - FGV/Fgv Clima")

dt <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Energia Elétrica/Capítulo 8 (Dados Estaduais).xlsx",sheet = 3)
setDT(dt)


# 1) renomeia a primeira coluna para "estado" (mantendo todas as outras intactas)
setnames(dt, names(dt)[1], "estado")

# 2) extrai o ano das linhas “ANO BASE ####” para nova coluna year
dt[, year := fifelse(
  str_detect(estado, "^ANO BASE"),
  as.integer(str_extract(estado, "\\d{4}")),
  NA_integer_
)]

# 3) preenche os NA de year com o último valor conhecido (locf)
dt[, year := nafill(year, type = "locf")]

# 4) filtra fora linhas de cabeçalho repetido ou totalmente NA
dt <- dt[
  !is.na(estado) &
    !str_detect(estado, regex("^(TABLE|ANO BASE|Estado)", ignore_case = TRUE))
]

# 5) limpa eventuais “\r\n” dos nomes em estado
dt[, estado := str_trim(str_replace_all(estado, "\\r|\\n", ""))]

# 6) identifica todas as colunas que devem virar numéricas (todas exceto estado e year)
num_cols <- setdiff(names(dt), c("estado", "year"))

# 7) aplica parse_number() a cada uma delas, preservando exatamente os nomes originais (...2, ...3, etc.)
dt[, (num_cols) := lapply(.SD, parse_number), .SDcols = num_cols]

# Resultado: dt com 'estado', as colunas originais numéricas (...2, ...3, …), e 'year'
print(dt)

dt <- dt[,`...18`:= NULL]



# 5) definir vetor com os nomes originais das colunas numéricas
old_cols <- names(dt)[!names(dt) %in% c("estado", "year")]

# 6) vetor com os novos nomes, na mesma ordem:
new_cols <- c(
  "Geração total\nTotal Generation",
  "Hidro\nHydro",
  "Eólica\nWind",
  "Solar\nSolar",
  "Nuclear\nNuclear",
  "Termo\nThermal",
  "Bagaço de cana\nSugar Cane Bagasse",
  "Lenha\nFirewood",
  "Lixívia\nBlack Liquor",
  "Out. Fontes renováveis\nOther Renewable Sources",
  "Carvão vapor\nSteam Coal",
  "Gás natural\nNatural Gas",
  "Gás de coqueria\nCoke Oven Gas",
  "Óleo combustível\nFuel Oil",
  "Óleo diesel\nDiesel Oil",
  "Out. Fontes não renováveis\nOther Non-Renewable Sources"
)

# 7) renomear as colunas mantendo exatamente esses rótulos
setnames(dt, old = old_cols, new = new_cols)

dt <- dt[!(estado == "BRASIL" |estado == "NORTE"|estado == "NORDESTE"|estado == "SUDESTE"|estado == "SUL"|estado == "CENTRO OESTE"),]
dt <- dt[estado == "Minas Gerais" |estado == "São Paulo" |estado == "Espírito Santo"|estado == "Rio de Janeiro"|estado == "Rondônia"|estado == "Acre"|estado == "Goiás"
         |estado == "Mato Grosso"|estado == "Mato G. do Sul"|estado == "Distrito Federal",subsistema:= "Sudeste/C.Oeste" ]


dt <- dt[estado == "Rio G. do Sul" |estado == "Santa Catarina" |estado == "Paraná",subsistema:= "Sul" ]

dt <- dt[estado == "Amapá" |estado == "Amazonas" |estado == "Maranhão"|estado == "Pará"|estado == "Tocantins",subsistema:= "Norte" ]

dt <- dt[is.na(subsistema),subsistema:= "Nordeste" ]


# identifica as colunas numéricas (todas exceto estado, subsistema e year)
num_cols <- setdiff(names(dt), c("estado", "subsistema", "year"))

# agrega somando todos os valores por subsistema e ano
dt_agg <- dt[
  ,
  lapply(.SD, sum, na.rm = TRUE),
  by = .(subsistema, year),
  .SDcols = num_cols
]


geracao <- ggplot(dt_agg, aes(x = year, 
                   y = `Geração total\nTotal Generation`, 
                   color = subsistema, 
                   group = subsistema)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text(aes(label = ifelse(year == max(year), 
                               format(round(`Geração total\nTotal Generation`, 1), big.mark = "."), 
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt_agg$year),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ".", scientific = FALSE),
                     expand = expansion(mult = c(0.05, 0.1))) +
  scale_color_brewer(palette = "Set1") +
  labs(
    x = "Ano",
    y = "Geração Elétrica (GWh)",
    color = "Subsistema",
    title = "Evolução da Geração Elétrica por Subsistema",
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 15)),
    plot.caption = element_text(size = 9, color = "gray50", hjust = 1),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.major = element_line(color = "gray90", size = 0.2),
    panel.grid.minor = element_blank(),
    plot.margin = unit(c(1, 1, 1, 1), "cm")
  ) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE))


ggsave("./graphs/geracao_eletrica.jpg", plot = geracao, device = "jpg", width = 11, height = 7, units = "in")



# 1) define vetores com os nomes exatos das colunas
renew_cols <- c(
  "Hidro\nHydro",
  "Eólica\nWind",
  "Solar\nSolar",
  "Bagaço de cana\nSugar Cane Bagasse",
  "Lenha\nFirewood",
  "Lixívia\nBlack Liquor",
  "Out. Fontes renováveis\nOther Renewable Sources"
)

nonrenew_cols <- c(
  "Nuclear\nNuclear",
  "Termo\nThermal",
  "Carvão vapor\nSteam Coal",
  "Gás natural\nNatural Gas",
  "Gás de coqueria\nCoke Oven Gas",
  "Óleo combustível\nFuel Oil",
  "Óleo diesel\nDiesel Oil",
  "Out. Fontes não renováveis\nOther Non-Renewable Sources"
)

# 2) agrega somando renováveis e não-renováveis
dt_energy <- dt_agg[
  ,
  .(
    Renovável     = rowSums(.SD[, ..renew_cols],     na.rm = TRUE),
    `Não‐Renovável` = rowSums(.SD[, ..nonrenew_cols], na.rm = TRUE)
  ),
  by = .(subsistema, year),
  .SDcols = c(renew_cols, nonrenew_cols)
]

# 3) derrete para formato longo
dt_long <- melt(
  dt_energy,
  id.vars     = c("subsistema", "year"),
  measure.vars = c("Renovável", "Não‐Renovável"),
  variable.name = "Tipo",
  value.name    = "GWh"
)

# substitui só as linhas onde Tipo é "Não‐Renovável"
dt_long[Tipo == "Não‐Renovável", 
        Tipo := "Não Renovável"]

# 4) gráfico comparando renovável vs não-renovável por subsistema ao longo dos anos
geracao_reno <- ggplot(dt_long, aes(x = year, y = GWh, color = Tipo, group = Tipo)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_text(aes(label = ifelse(year == max(year), 
                               format(round(GWh, 1), big.mark = ".", decimal.mark = ","), 
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  facet_wrap(~ subsistema, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = unique(dt_long$year),
                     expand = expansion(mult = c(0.05, 0.2))) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_color_manual(values = c("Renovável" = "#2ecc71",  # Verde mais vibrante
                                "Não Renovável" = "#e74c3c"),  # Vermelho vivo
                     labels = c("Renovável", "Não Renovável")) +  # Garantindo a ordem
  labs(
    x = "Ano",
    y = "Geração Elétrica (GWh)",
    color = "Tipo de Energia",
    title = "Geração Elétrica Renovável vs Não-Renovável por Subsistema",
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y = element_text(size = 9),
    axis.title = element_text(size = 11, face = "bold"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 5)),
    plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 15), color = "gray30"),
    plot.caption = element_text(size = 9, color = "gray50", hjust = 1),
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "top",
    panel.spacing = unit(1.5, "lines"),
    strip.text = element_text(face = "bold", size = 11, color = "gray20"),
    strip.background = element_rect(fill = "gray97", color = NA),
    panel.grid.major = element_line(color = "gray90", size = 0.2),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = unit(c(1, 1, 1, 1), "cm")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1)))

ggsave("./graphs/geracao_eletrica_renovavel.jpg", plot = geracao_reno, device = "jpg", width = 11, height = 7, units = "in")


# seleciona apenas solar e eólica
sw_cols <- c("Eólica\nWind", "Solar\nSolar")

# derrete para formato longo
dt_sw <- melt(
  dt_agg,
  id.vars     = c("subsistema", "year"),
  measure.vars = sw_cols,
  variable.name = "Fonte",
  value.name    = "GWh"
)

# faz o gráfico, facete por subsistema
ggplot(dt_sw, aes(x = year, y = GWh, color = Fonte, group = Fonte)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~ subsistema) +
  scale_x_continuous(breaks = unique(dt_sw$year)) +
  labs(
    x     = "Ano",
    y     = "Geração (GWh)",
    color = "Fonte",
    title = "Evolução da Geração Solar e Eólica por Subsistema"
  ) +
  theme_minimal() +
  theme(
    axis.text.x  = element_text(angle = 45, hjust = 1),
    plot.title   = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.title = element_text(size = 12),
    legend.text  = element_text(size = 10)
  )




# 4. Preparar dados de Solar e Eólica apenas para o Nordeste
dt_sw_ne <- melt(
  dt_agg[subsistema == "Nordeste"],
  id.vars     = c("subsistema","year"),
  measure.vars= c("Eólica\nWind","Solar\nSolar"),
  variable.name = "Fonte",
  value.name    = "GWh"
)

dt_sw_ne <- dt_sw_ne[Fonte == "Eólica\nWind", Fonte:= "Eólica"]
dt_sw_ne <- dt_sw_ne[Fonte == "Solar\nSolar",Fonte:= "Solar"]

# 5. Gráfico: Evolução da Geração Solar e Eólica no Nordeste
nordeste <- ggplot(dt_sw_ne, aes(x = year, y = GWh, color = Fonte, group = Fonte)) +
  geom_line(size = 1.5, alpha = 0.9, lineend = "round") +
  geom_point(size = 4, alpha = 0.9) +
  geom_text(aes(label = ifelse(year == max(year), 
                               format(round(GWh), big.mark = ".", scientific = FALSE), "")),
            vjust = -1, size = 4.5, fontface = "bold", show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt_sw_ne$year),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ".", scientific = FALSE),
                     expand = expansion(mult = c(0.1, 0.2))) +
  scale_color_manual(values = c("Eólica" = "#3498db", 
                                "Solar" = "#f39c12")) +
  labs(
    title = "Evolução da Geração Eólica e Solar no Nordeste",
    x = "Ano",
    y = "Geração (GWh)",
    color = "Fonte de Energia:",
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(size = 14, hjust = 0.5, margin = margin(b = 20), color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    legend.position = "bottom",
    panel.grid.major.y = element_line(color = "gray90"),
    panel.grid.minor = element_blank()
  ) +
  guides(color = guide_legend(override.aes = list(size = 5)))


ggsave("./graphs/geracao_eletrica_nordeste.jpg", plot = nordeste, device = "jpg", width = 11, height = 7, units = "in")




dt <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Energia Elétrica/consumo.xlsx")
setDT(dt)

dt <- dt[,consumo:= consumo/1000]
dt <- dt[,consumo:= consumo/2]
dt <- dt[ano > 2010,]




consumo <- ggplot(dt, aes(x = ano, 
                   y = `consumo`, 
                   color = subsistema, 
                   group = subsistema)) +
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3, alpha = 0.8) +
  geom_text(aes(label = ifelse(ano == max(ano), 
                               format(round(`consumo`, 1), big.mark = "."), 
                               "")),
            hjust = -0.3, vjust = 0.5, size = 3, show.legend = FALSE) +
  scale_x_continuous(breaks = unique(dt$ano),
                     expand = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ".", scientific = FALSE),
                     expand = expansion(mult = c(0.05, 0.1))) +
  scale_color_brewer(palette = "Set1") +
  labs(
    x = "Ano",
    y = "Consumo Energia Elétrica (GWh)",
    color = "Subsistema",
    title = "Evolução do Consumo de Energia Elétrica por Subsistema",
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 15)),
    plot.caption = element_text(size = 9, color = "gray50", hjust = 1),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "bottom",
    panel.grid.major = element_line(color = "gray90", size = 0.2),
    panel.grid.minor = element_blank(),
    plot.margin = unit(c(1, 1, 1, 1), "cm")
  ) +
  guides(color = guide_legend(nrow = 1, byrow = TRUE))

ggsave("./graphs/consumo_um_grafico.jpg", plot = consumo, device = "jpg", width = 11, height = 7, units = "in")





consumo <- ggplot(dt,
                  aes(ano, consumo,
                      colour = subsistema,
                      group  = subsistema)) +
  
  geom_line(size = 1.2, alpha = 0.8) +
  geom_point(size = 3,  alpha = 0.8) +
  # ── camada de texto removida ───────────────────────────
  
  scale_x_continuous(breaks = unique(dt$ano),
                     expand  = expansion(mult = c(0.05, 0.15))) +
  scale_y_continuous(labels = \(x) format(x, big.mark = ".", scientific = FALSE),
                     expand  = expansion(mult = c(0.05, 0.10))) +
  scale_colour_brewer(palette = "Set1") +
  
  labs(
    x     = "Ano",
    y     = "Consumo de Energia Elétrica (GWh)",
    colour= "Subsistema",
    title = "Evolução do Consumo de Energia Elétrica por Subsistema"
  ) +
  
  facet_wrap(~ subsistema, scales = "free_y") +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x  = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y  = element_text(size = 9),
    axis.title   = element_text(face = "bold"),
    plot.title   = element_text(size = 16, face = "bold", hjust = 0.5,
                                margin = margin(b = 15)),
    legend.position = "bottom",
    legend.title    = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("./graphs/consumo.jpg", plot = consumo, device = "jpg", width = 11, height = 7, units = "in")





# Consumo total por subsistema (apenas 2023) -------------------------------
dt_2023_sum <- dt[ano == 2023,
                  .(consumo_total = sum(consumo, na.rm = TRUE)),
                  by = subsistema][order(-consumo_total)]

consumo <- ggplot(dt_2023_sum,
       aes(x = reorder(subsistema, -consumo_total),
           y = consumo_total,
           fill = subsistema)) +
  geom_col(width = 0.7, alpha = 0.8, colour = "white") +
  geom_text(aes(label = format(round(consumo_total, 0),
                               big.mark = ".")),
            vjust = -0.4, size = 3.5, fontface = "bold") +
  scale_y_continuous(labels = function(x) format(x, big.mark = ".", scientific = FALSE),
                     expand  = expansion(mult = c(0, 0.05))) +
  scale_fill_brewer(palette = "Set1", guide = "none") +
  labs(
    title = "Consumo de Energia Elétrica por Subsistema — 2023",
    x     = NULL,
    y     = "Consumo Energia Elétrica (GWh)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title   = element_text(size = 16, face = "bold", hjust = 0.5),
    axis.text.x  = element_text(angle = 20, hjust = 1, face = "bold"),
    axis.title.y = element_text(face = "bold"),
    panel.grid.major.x = element_blank()
  )


ggsave("./graphs/consumo_2023.jpg", plot = consumo, device = "jpg", width = 11, height = 7, units = "in")




# 3) Preparar dt_agg: filtrar e renomear
dt_ger <- dt_agg[
  subsistema != "Sistemas isolados",
  .(subsistema, year, Geração = `Geração total\nTotal Generation`)
]

# 4) Preparar dt: filtrar e renomear
dt_cons <- dt[
  subsistema != "Sistemas isolados",
  .(subsistema, year = ano, Consumo = consumo)
]

dt_ger <- dt_ger[subsistema == "Sudeste/C.Oeste", subsistema:= "Sudeste"]
dt_cons <- dt_cons[subsistema == "Sudeste/C. Oeste", subsistema:= "Sudeste"]	

# 5) Juntar geração + consumo
dt_gc <- merge(
  dt_ger, dt_cons,
  by = c("subsistema","year"))

dt_gc <- dt_gc[subsistema == "Sudeste", subsistema:= "Sudeste/C.Oeste"]

# 6) “Derreter” em formato longo
dt_gc_long <- melt(
  dt_gc,
  id.vars     = c("subsistema","year"),
  measure.vars= c("Geração","Consumo"),
  variable.name = "Tipo",
  value.name    = "GWh"
)


# Criar um data.frame só com os pontos do último ano
last_points <- dt_gc_long %>%
  group_by(subsistema, Tipo) %>%
  filter(year == max(year)) %>%
  ungroup()

# 7) Gráfico geração vs consumo por subsistema
consumo_geracao <- ggplot(dt_gc_long, aes(x = year, y = GWh, colour = Tipo, group = Tipo)) +
  geom_line(size = 1.3, alpha = 0.9) +
  geom_point(size = 3, alpha = 0.9) +
  
  geom_text(
    data = last_points,
    aes(label = format(round(GWh, 0),
                       big.mark = ".",
                       decimal.mark = ",",
                       scientific = FALSE)),
    hjust = -0.1,
    vjust = 0.5,
    size = 3,
    show.legend = FALSE
  ) +
  
  facet_wrap(~ subsistema, scales = "free_y", ncol = 2) +
  scale_x_continuous(
    breaks = unique(dt_gc_long$year),
    expand = expansion(mult = c(0.05, 0.2))  # espaço extra à direita para os rótulos
  ) +
  scale_y_continuous(
    labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  
  scale_colour_manual(
    values = c("Geração" = "#27ae60", "Consumo" = "#e74c3c"),
    labels = c("Geração", "Consumo")
  ) +
  
  labs(
    x      = "Ano",
    y      = "Energia Elétrica (GWh)",
    title  = "Geração e Consumo de Energia Elétrica por Subsistema"
  ) +
  
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x      = element_text(angle = 45, hjust = 1, size = 11),
    axis.text.y      = element_text(size = 10),
    axis.title       = element_text(size = 12, face = "bold"),
    plot.title       = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    legend.text      = element_text(size = 12, face = "bold"),
    legend.position  = "top",
    panel.spacing    = unit(1.8, "lines"),
    strip.text       = element_text(face = "bold", size = 12),
    strip.background = element_rect(fill = "gray96", color = NA),
    panel.grid.major = element_line(color = "gray92", size = 0.3),
    panel.grid.minor = element_blank(),
    plot.margin      = unit(c(1.5, 1.5, 1.5, 1.5), "cm")
  ) +
  
  guides(colour = guide_legend(override.aes = list(size = 4, alpha = 1)))

ggsave("./graphs/consumo_geracao.jpg", plot = consumo_geracao, device = "jpg", width = 12, height = 9, units = "in")




##########################################################




dt <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Energia Elétrica/consumor_setor.xlsx")
setDT(dt)
dt <- dt[,consumo:= consumo/1000]


dt_total <- dt[tipo == "total",]

# Converter para fator com ordem específica
dt_total[, setor := factor(setor, levels = c("Residencial", "Comercial", "Industrial", "Outros"))]

# Criar o gráfico
consumo_energia_setor <- ggplot(dt_total, aes(x = ano, y = consumo, color = setor)) +
  geom_line(linewidth = 1.2, alpha = 0.9) +
  geom_point(size = 2.5) +
  scale_x_continuous(breaks = seq(2004, 2023, by = 2)) +
  scale_y_continuous(
    labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    limits = c(0, max(dt_total$consumo) * 1.05),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_color_manual(
    values = c(
      "Residencial" = "#1f77b4",
      "Comercial" = "#ff7f0e",
      "Industrial" = "#2ca02c",
      "Outros" = "#9467bd"
    )
  ) +
  labs(
    x = "Ano",
    y = "Consumo de Energia (GWh)",
    #title = "Evolução do Consumo de Energia por Setor (2004-2023)",
    color = "Setor"  # Título da legenda
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 11),
    panel.grid.major = element_line(linewidth = 0.2, color = "gray90"),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5, margin = margin(b = 10)),
    plot.margin = margin(10, 15, 10, 15)
  ) +
  guides(color = guide_legend(nrow = 2, byrow = TRUE))

ggsave("./graphs/consumo_energia_setor.jpg", plot = consumo_energia_setor, device = "jpg", width = 11, height = 7, units = "in")


write_xlsx(dt_total, path = "Figura 7 – Consumo setorial de energia elétrica.xlsx")



# Filtrar e preparar os dados de 2023
dados_2023 <- dt_total[ano == 2023][order(-consumo)]  # Ordena do maior para o menor consumo
dados_2023[, setor := factor(setor, levels = setor)]  # Mantém a ordem definida

# Definir cores personalizadas (opcional)
cores_setores <- c(
  "Industrial" = "#2ca02c",     # Verde
  "Residencial" = "#1f77b4",    # Azul
  "Comercial" = "#ff7f0e",      # Laranja
  "Outros" = "#9467bd"          # Roxo
)

# Criar o gráfico de barras
consumo_energia_setor_barra <- ggplot(dados_2023, aes(x = setor, y = consumo, fill = setor)) +
  geom_col(width = 0.7, alpha = 0.9) +  # Barras com transparência
  geom_text(
    aes(label = paste0(round(consumo,0), "")), 
    vjust = -0.5, 
    size = 4.5,
    fontface = "bold",
    color = "black"
  ) +
  scale_fill_manual(values = cores_setores) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.1)),  # Espaço no topo para os rótulos
    labels = scales::number_format(big.mark = ".", decimal.mark = ",")
  ) +
  labs(
  #  title = "Consumo de Energia por Setor (2023)",
    x = NULL,  # Removendo o rótulo do eixo X (setor já está claro)
    y = "Consumo (GWh)",
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "none",  # Legenda removida (redundante)
    panel.grid.major.x = element_blank(),  # Remove linhas de grade verticais
    axis.text.x = element_text(face = "bold", size = 12),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.caption = element_text(hjust = 1, color = "grey40")
  )

ggsave("./graphs/consumo_energia_setor_barra.jpg", plot = consumo_energia_setor_barra, device = "jpg", width = 11, height = 7, units = "in")



# 1. Preparar os dados (agregar totais por ano e tipo)
dt_total <- dt[tipo %in% c("livre", "cativo"), .(consumo = sum(consumo)), by = .(ano, tipo)]

# 2. Gráfico com valores originais e legenda embaixo
consumo_energia_livre_cativo <- ggplot(dt_total, aes(x = ano, y = consumo, color = tipo)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 3) +
  scale_x_continuous(breaks = seq(min(dt_total$ano), max(dt_total$ano), by = 3)) +
  scale_y_continuous(
    labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_color_manual(
    values = c("livre" = "#0066CC", "cativo" = "#FF6600"),
    labels = c("livre" = "Mercado Livre", "cativo" = "Mercado Cativo")
  ) +
  labs(
 #   title = "Evolução do mercado livre e mercado cativo (2004-2023) ",
    x = NULL,
    y = "Consumo (GWh)",
    color = "Tipo de Mercado",
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "gray50"),
    legend.position = "bottom",  # Legenda movida para baixo
    legend.box = "horizontal",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  geom_text(
    data = dt_total[ano == max(ano)],
    aes(label = format(round(consumo), big.mark = ".", decimal.mark = ",")),
    vjust = -1, 
    size = 4, 
    show.legend = FALSE
  )


ggsave("./graphs/consumo_energia_livre_cativo.jpg", plot = consumo_energia_livre_cativo, device = "jpg", width = 11, height = 7, units = "in")



# 2. Gráfico facetado por setor
consumo_energia_livre_cativo_setor <- ggplot(dados_setor, aes(x = ano, y = consumo, color = tipo)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  facet_wrap(~setor, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = seq(min(dados_setor$ano), max(dados_setor$ano), by = 4)) +
  scale_y_continuous(
    labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    expand = expansion(mult = c(0, 0.15))
  ) +
  scale_color_manual(
    values = c("livre" = "#0066CC", "cativo" = "#FF6600"),
    labels = c("livre" = "Mercado Livre", "cativo" = "Mercado Cativo")
  ) +
  labs(
   # title = "Evolução do mercado livre e mercado cativo por setor (2004-2023) ",
    x = NULL,
    y = "Consumo (GWh)",
    color = "Tipo de Mercado",
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray50"),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
    strip.text = element_text(face = "bold", size = 12),
    strip.background = element_rect(fill = "gray95", color = NA),
    panel.spacing = unit(1.5, "lines")
  ) +
  geom_text(
    data = dados_setor[ano == max(ano)],
    aes(label = format(round(consumo), big.mark = ".", decimal.mark = ",")),
    vjust = -0.8, 
    size = 3.5,
    show.legend = FALSE
  )


ggsave("./graphs/consumo_energia_livre_cativo_setor.jpg", plot = consumo_energia_livre_cativo_setor, device = "jpg", width = 13, height = 7, units = "in")



# 1. Filtrar dados de 2023
dados_2023 <- dt[ano == 2023 & tipo %in% c("livre", "cativo"), ]

# 2. Ordenar setores pelo consumo total
ordem_setores <- dados_2023[, .(total = sum(consumo)), by = setor][order(-total), setor]
dados_2023[, setor := factor(setor, levels = ordem_setores)]

# 3. Gráfico de barras
consumo_energia_livre_cativo_setor_2023 <- ggplot(dados_2023, aes(x = setor, y = consumo, fill = tipo)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_text(
    aes(label = format(round(consumo), big.mark = ".", decimal.mark = ",")),
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
    labels = function(x) format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    expand = expansion(mult = c(0, 0.15))
  ) +
  labs(
   # title = "Comparação entre o mercado livre e cativo por setor (2023)",
    x = NULL,
    y = "Consumo (GWh)",
    fill = "Tipo de Mercado",
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray50"),
    legend.position = "bottom",
    legend.box = "horizontal",
    panel.grid.major.y = element_line(color = "gray90"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )


ggsave("./graphs/consumo_energia_livre_cativo_setor_2023.jpg", plot = consumo_energia_livre_cativo_setor_2023, device = "jpg", width = 11, height = 7, units = "in")





#########################################################3




dt <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Energia Elétrica/Capítulo 8 (Dados Estaduais).xlsx",sheet = 3)
setDT(dt)


# 1) renomeia a primeira coluna para "estado" (mantendo todas as outras intactas)
setnames(dt, names(dt)[1], "estado")

# 2) extrai o ano das linhas “ANO BASE ####” para nova coluna year
dt[, year := fifelse(
  str_detect(estado, "^ANO BASE"),
  as.integer(str_extract(estado, "\\d{4}")),
  NA_integer_
)]

# 3) preenche os NA de year com o último valor conhecido (locf)
dt[, year := nafill(year, type = "locf")]

# 4) filtra fora linhas de cabeçalho repetido ou totalmente NA
dt <- dt[
  !is.na(estado) &
    !str_detect(estado, regex("^(TABLE|ANO BASE|Estado)", ignore_case = TRUE))
]

# 5) limpa eventuais “\r\n” dos nomes em estado
dt[, estado := str_trim(str_replace_all(estado, "\\r|\\n", ""))]

# 6) identifica todas as colunas que devem virar numéricas (todas exceto estado e year)
num_cols <- setdiff(names(dt), c("estado", "year"))

# 7) aplica parse_number() a cada uma delas, preservando exatamente os nomes originais (...2, ...3, etc.)
dt[, (num_cols) := lapply(.SD, parse_number), .SDcols = num_cols]

# Resultado: dt com 'estado', as colunas originais numéricas (...2, ...3, …), e 'year'
print(dt)

dt <- dt[,`...18`:= NULL]



# 5) definir vetor com os nomes originais das colunas numéricas
old_cols <- names(dt)[!names(dt) %in% c("estado", "year")]

# 6) vetor com os novos nomes, na mesma ordem:
new_cols <- c(
  "Geração total\nTotal Generation",
  "Hidro\nHydro",
  "Eólica\nWind",
  "Solar\nSolar",
  "Nuclear\nNuclear",
  "Termo\nThermal",
  "Bagaço de cana\nSugar Cane Bagasse",
  "Lenha\nFirewood",
  "Lixívia\nBlack Liquor",
  "Out. Fontes renováveis\nOther Renewable Sources",
  "Carvão vapor\nSteam Coal",
  "Gás natural\nNatural Gas",
  "Gás de coqueria\nCoke Oven Gas",
  "Óleo combustível\nFuel Oil",
  "Óleo diesel\nDiesel Oil",
  "Out. Fontes não renováveis\nOther Non-Renewable Sources"
)

# 7) renomear as colunas mantendo exatamente esses rótulos
setnames(dt, old = old_cols, new = new_cols)

dt <- dt[estado == "BRASIL",]


# supondo que seu data.frame se chame dt
# e tenha exatamente as colunas mostradas na sua saída

dt2 <- dt %>%
  rename(
    Total     = `Geração total\nTotal Generation`,
    Hydro     = `Hidro\nHydro`,
    Wind      = `Eólica\nWind`,
    Solar     = `Solar\nSolar`,
    SteamCoal = `Carvão vapor\nSteam Coal`,
    NatGas    = `Gás natural\nNatural Gas`,
    FuelOil   = `Óleo combustível\nFuel Oil`,
    DieselOil = `Óleo diesel\nDiesel Oil`
  ) %>%
  mutate(
    Oil    = FuelOil + DieselOil,
    Others = Total - (Hydro + Wind + Solar + SteamCoal + NatGas + Oil),
    year   = as.integer(year)
  ) %>%
  select(year, Total, Hydro, Wind, Solar, NatGas, SteamCoal, Oil, Others) %>%
  pivot_longer(-c(year, Total),
               names_to  = "Source",
               values_to = "Generation") %>%
  group_by(year) %>%
  mutate(perc = Generation / Total) %>%
  ungroup() %>%
  mutate(
    Source = factor(Source,
                    levels = c("Hydro","Wind","Solar","NatGas","SteamCoal","Oil","Others"),
                    labels = c("Hidráulica","Eólica","Solar","Gás natural","Carvão","Óleo","Outros")
    )
  )
# para escala secundária
max_tot <- max(dt2$Total)

geracao_fonte_parti <- ggplot(dt2, aes(x = year, y = perc, fill = Source)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  # rótulos em todas as barras com duas casas decimais
  geom_text(aes(label = percent(perc, accuracy = 0.01)),
            position = position_dodge(width = 0.8),
            vjust = -0.3, size = 2.5) +
  facet_wrap(~ Source, ncol = 2, scales = "free_y") +
  scale_x_continuous(breaks = seq(min(dt2$year), max(dt2$year), by = 2)) +
  scale_y_continuous(
    labels = percent_format(accuracy = 0.01),
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    x        = "Ano",
    y        = "Participação (%)",
  ) +
  theme_minimal(base_size = 12) +
  theme(
    strip.text      = element_text(face = "bold"),
    axis.text.x     = element_text(angle = 45, hjust = 1),
    legend.position = "none",
    panel.spacing   = unit(1, "lines")
  )

ggsave("./graphs/geracao_fonte_parti.jpg", plot = geracao_fonte_parti, device = "jpg", width = 12, height = 7, units = "in")



# 1) extrai ano e total
total_df <- dt %>%
  rename(Total = `Geração total\nTotal Generation`) %>%
  mutate(year = as.integer(year)) %>%
  select(year, Total)

# 2) plot
geracao <- ggplot(total_df, aes(x = year, y = Total)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  # anotação em 2023 com formatação brasileira
  geom_text(
    data = total_df %>% filter(year == max(year)),
    aes(
      label = paste0(
        scales::number(Total, big.mark = ".", decimal.mark = ","),
        " GWh"
      )
    ),
    vjust = -1, size = 3.5, color = "steelblue"
  ) +
  scale_x_continuous(breaks = total_df$year) +
  scale_y_continuous(
    labels = number_format(big.mark = ".", decimal.mark = ","),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Geração Elétrica Total por Ano",
    x     = "Ano",
    y     = "Geração (GWh)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x    = element_text(angle = 45, hjust = 1),
    plot.title     = element_text(face = "bold", hjust = 0.5)
  )

ggsave("./graphs/geracao_total.jpg", plot = geracao, device = "jpg", width = 12, height = 7, units = "in")


library(writexl)

write_xlsx(dt2, path = "dados_figura_5.xlsx")
