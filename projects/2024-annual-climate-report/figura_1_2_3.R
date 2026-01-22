library(data.table)
library(readxl)
library(dplyr)
library(ggplot2)
library(forcats)
library(scales)
library(viridis)
library(tidyr)
library(writexl)

df <- read_xlsx("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/Dados nacionais v12.0.xlsx",sheet = 2)

setDT(df)

df <- df[`Setor de emissão` == "Energia" & Gás == "CO2e (t) GWP-AR5" & `Categoria emissora` == "Transportes"]



# supondo df já seja data.table; se não for:
setDT(df)

# identifica as colunas de ano (4 dígitos)
anos <- grep("^\\d{4}$", names(df), value = TRUE)

# identifica as demais colunas que você quer manter como chaves
chaves <- setdiff(names(df), c("Estado","Bioma", anos))

# agrupa por todas as chaves menos Estado, somando cada ano
df_pais <- df[, lapply(.SD, sum, na.rm = TRUE),
              by = chaves,
              .SDcols = anos]



# derrete os anos em linhas
df_long <- melt(
  df_pais,
  id.vars     = setdiff(names(df_pais), anos),  # mantém todas as demais colunas fixas
  measure.vars= anos,                           # derrete essas colunas
  variable.name= "ano",                         # nome da nova coluna que conterá o ano
  value.name   = "valor"                        # nome da coluna com o valor agregado
)

# opcional: converter 'ano' para inteiro
df_long[, ano := as.integer(as.character(ano))]

#Só considerar Emissão
df_long <- df_long[`Emissão/Remoção/Bunker` == "Emissão"]


##################################

resumo_long_sub_categoria <- df_long[
  , .(total_emissao = sum(valor, na.rm = TRUE)),
  by = .(ano, `Sub-categoria emissora`)
]





# supondo que seu data.frame se chame resumo_long_sub_categoria
df <- resumo_long_sub_categoria

# 1) Série de tempo de 2000 em diante
df_ts <- df %>% 
  filter(ano >= 2000)

ggplot(df_ts, aes(x = ano, y = total_emissao, color = `Sub-categoria emissora`)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  labs(
    title = "Emissões por modo de transporte (2000–2023)",
    x     = "Ano",
    y     = "Total de Emissão",
    color = "Modo"
  ) +
  theme_minimal()

# 2) Barra percentual para 2023
df_2023 <- df %>% 
  filter(ano == 2023) %>% 
  mutate(
    pct = total_emissao / sum(total_emissao) * 100
  )


 ggplot(df_2023, aes(
  x = reorder(`Sub-categoria emissora`, pct), 
  y = pct, 
  fill = `Sub-categoria emissora`
)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", pct)), 
            vjust = -0.5, size = 3) +
  labs(
    title = "",
    x     = "",
    y     = "Percentual (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
 
write_xlsx(df_2023, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_2.xlsx")

ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/emissao_modo_transporte.jpg",
       width = 10, height = 6, units = "in")


#################################



resumo_long_detalhamento <- df_long[
  , .(total_emissao = sum(valor, na.rm = TRUE)),
  by = .(ano, Detalhamento)
]



# supondo que seu data.frame se chame resumo_long_detalhamento
df_det <- resumo_long_detalhamento
# 1) Calcular participação de cada Detalhamento em cada ano
df_ts_det_pct <- resumo_long_detalhamento %>%
  filter(ano >= 2000) %>%
  group_by(ano) %>%
  mutate(pct = total_emissao / sum(total_emissao) * 100) %>%
  ungroup()

# 2) Gráfico de série temporal em %  
ggplot(df_ts_det_pct, aes(x = ano, y = pct, color = Detalhamento)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = function(x) sprintf("%.0f%%", x)) +
  labs(
    title = "Participação percentual das emissões por Detalhamento (2000–2023)",
    x     = "Ano",
    y     = "Percentual (%)",
    color = "Detalhamento"
  ) +
  theme_minimal()

# 2) Barra percentual para 2023
df_2023_det <- df_det %>% 
  filter(ano == 2023) %>% 
  mutate(
    pct = total_emissao / sum(total_emissao) * 100
  )

ggplot(df_2023_det, aes(
  x = reorder(Detalhamento, pct), 
  y = pct, 
  fill = Detalhamento
)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", pct)), 
            vjust = -0.5, size = 3) +
  labs(
    title = "Participação percentual das emissões por Detalhamento (2023)",
    x     = "Detalhamento",
    y     = "Percentual (%)"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  coord_flip()  # opcional: vira para facilitar leitura se houver muitos níveis


# vetores dos detalhamentos rodoviários
det_rod <- c("Caminhões", "Automóveis", "Ônibus", "Comerciais leves", "Motocicletas")
passageiros <- c("Motocicletas", "Ônibus", "Automóveis")

# prepara dados de 2023 só para rodoviário, com classificação Passageiros x Carga
df_2023_rod <- resumo_long_detalhamento %>%
  filter(ano == 2023, Detalhamento %in% det_rod) %>%
  mutate(
    Tipo = if_else(Detalhamento %in% passageiros, "Passageiros", "Carga"),
    pct  = total_emissao / sum(total_emissao) * 100
  ) %>%
  arrange(Tipo, desc(pct)) %>%
  mutate(Detalhamento = factor(Detalhamento, levels = unique(Detalhamento)))


ggplot(df_2023_rod, aes(
  x = fct_reorder(Detalhamento, pct),  # ordena do menor para o maior
  y = pct,
  fill = Tipo
)) +
  geom_col() +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            vjust = -0.5, size = 3) +
  scale_y_continuous(labels = scales::percent_format(scale = 1)) +
  scale_fill_manual(values = c("Passageiros" = "#377EB8",  # azul
                               "Carga"       = "#D73027")) +
  labs(
    x = "", y = "Percentual (%)", fill = NULL
  ) +
  theme_minimal() +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

write_xlsx(df_2023_rod, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_3.xlsx")

ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/emissao_detalhamento_transporte.jpg",
       width = 10, height = 6, units = "in")
########################################
resumo_long_atividade_geral <- df_long[
  , .(total_emissao = sum(valor, na.rm = TRUE)),
  by = .(ano, `Atividade geral`)
]




# 1) Filtra só 2023
df_2023_prod <- df_long %>%
  filter(ano == 2023)

# 2) Gráfico de barras facetado por Detalhamento
ggplot(df_2023_prod, aes(
  x = reorder(`Produto ou sistema`, valor), 
  y = valor, 
  fill = `Produto ou sistema`
)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ Detalhamento, scales = "free_y") +
  labs(
    title = "Emissões por Produto ou sistema em 2023, por Detalhamento",
    x     = "Produto ou sistema",
    y     = "Emissão (t CO2e)"
  ) +
  theme_minimal(base_size = 12)




########################


dt <- fread(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/categoria_emissao.csv",
  header       = TRUE,       # 1ª linha vira nomes de colunas
  check.names  = FALSE        # evita alterar nomes numéricos em "1990", "1991"...
)


# identifica as colunas de ano (4 dígitos)
anos <- grep("^\\d{4}$", names(dt), value = TRUE)

# derrete para o formato long
dt_long <- melt(
  dt,
  id.vars      = "Categoria",  # mantém essa coluna fixa
  measure.vars = anos,         # derrete essas colunas
  variable.name= "ano",        # nome da nova coluna de anos
  value.name   = "valor"       # nome da coluna com os valores
)

# opcional: converte 'ano' para inteiro
dt_long[, ano := as.integer(as.character(ano))]






# 1) Calcular % por ano e categoria
df_pct <- dt_long %>%
  group_by(ano) %>%
  mutate(pct = valor / sum(valor, na.rm = TRUE) * 100) %>%
  ungroup()

# 2) Série temporal em %
ggplot(df_pct, aes(x = ano, y = pct, color = Categoria)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = function(x) sprintf("%.0f%%", x)) +
  labs(
    title = "Participação percentual das emissões por Categoria (1990–2023)",
    x     = "Ano",
    y     = "Percentual (%)",
    color = "Categoria"
  ) +
  theme_minimal()

# 3) Gráfico de barras em % para 2023
df_2023_pct <- df_pct %>%
  filter(ano == 2023)

ggplot(df_2023_pct, aes(
  x = reorder(Categoria, pct), 
  y = pct, 
  fill = Categoria
)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), 
            vjust = -0.5, size = 3) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "",
    x     = "",
    y     = "Percentual (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

write_xlsx(df_2023_pct, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_1.xlsx")



ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/emissao_categoria.jpg",
       width = 10, height = 6, units = "in")





###########################################

dt <- fread(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/setor_emissao.csv",
  header       = TRUE,       # 1ª linha vira nomes de colunas
  check.names  = FALSE        # evita alterar nomes numéricos em "1990", "1991"...
)


# identifica as colunas de ano (4 dígitos)
anos <- grep("^\\d{4}$", names(dt), value = TRUE)

# derrete para o formato long
dt_long <- melt(
  dt,
  id.vars      = "Categoria",  # mantém essa coluna fixa
  measure.vars = anos,         # derrete essas colunas
  variable.name= "ano",        # nome da nova coluna de anos
  value.name   = "valor"       # nome da coluna com os valores
)

# opcional: converte 'ano' para inteiro
dt_long[, ano := as.integer(as.character(ano))]



# 1) Calcular % por ano e categoria
df_pct <- dt_long %>%
  group_by(ano) %>%
  mutate(pct = valor / sum(valor, na.rm = TRUE) * 100) %>%
  ungroup()

setDT(df_pct)

# 2) Série temporal em %
ggplot(df_pct[ano > 1999], aes(x = ano, y = pct, color = Categoria)) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = function(x) sprintf("%.0f%%", x)) +
  labs(
    title = "",
    x     = "",
    y     = "Percentual (%)",
    color = ""
  ) +
  theme_minimal()

# 3) Gráfico de barras em % para 2023
df_2023_pct <- df_pct %>%
  filter(ano == 2023)

ggplot(df_2023_pct, aes(
  x = reorder(Categoria, pct), 
  y = pct, 
  fill = Categoria
)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.1f%%", pct)), 
            vjust = -0.5, size = 3) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "",
    x     = "",
    y     = "Percentual (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/emissao_geral.jpg",
       width = 10, height = 6, units = "in")






# 1) Calcula crescimento % entre 2000 e 2023
growth <- dt_long %>%
  filter(ano %in% c(2000, 2023)) %>%
  select(Categoria, ano, valor) %>%
  pivot_wider(names_from = ano, values_from = valor, names_prefix = "ano_") %>%
  mutate(crescimento = (ano_2023 / ano_2000 - 1) * 100)

# 2) Plot com destaque para "Energia"
ggplot(growth, aes(
  x = reorder(Categoria, crescimento),
  y = crescimento,
  fill = Categoria == "Energia"   # TRUE para Energia, FALSE para as outras
)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.1f%%", crescimento)),
            vjust = -0.3, size = 3.5, family = "sans") +
  scale_fill_manual(
    values = c("TRUE"  = "#1F78B4",   # azul para Energia
               "FALSE" = "gray80")   # cinza suave para as demais
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title    = "",
    x        = NULL,
    y        = "(%)"
  ) +
  theme_minimal(base_family = "sans", base_size = 14) +
  theme(
    plot.title        = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle     = element_text(size = 12, hjust = 0.5, margin = margin(b = 15)),
    axis.text.x       = element_text(angle = 45, hjust = 1),
    axis.text.y       = element_text(size = 11),
    axis.title.y      = element_text(size = 12),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(color = "gray90", size = 0.3)
  )



ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/crescimento energia.jpg",
       width = 10, height = 6, units = "in")
