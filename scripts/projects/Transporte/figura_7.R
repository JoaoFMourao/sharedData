# ---- Pacotes ----
# install.packages(c("geobr","sf","ggplot2","dplyr","scales")) # se precisar
library(geobr)
library(sf)
library(ggplot2)
library(dplyr)
library(scales)
library(writexl)

# ---- Dados (valores do seu mapa) ----
dados_estados <- tibble::tribble(
  ~estado,                ~valor,
  "Acre",                 0.70,
  "Amazonas",             0.69,
  "Roraima",              0.77,
  "Amapá",                0.86,
  "Pará",                 0.75,
  "Rondônia",             0.75,
  "Tocantins",            0.60,
  "Maranhão",             0.71,
  "Piauí",                0.77,
  "Ceará",                0.73,
  "Rio Grande Do Norte",  0.73,
  "Paraíba",              0.74,
  "Pernambuco",           0.74,
  "Alagoas",              0.76,
  "Sergipe",              0.71,
  "Bahia",                0.72,
  "Mato Grosso",          0.60,
  "Mato Grosso Do Sul",   0.66,
  "Goiás",                0.66,
  "Distrito Federal",     0.67,
  "Minas Gerais",         0.64,
  "Espirito Santo",       0.67,
  "Rio De Janeiro",       0.70,
  "São Paulo",            0.64,
  "Paraná",               0.67,
  "Santa Catarina",       0.72,
  "Rio Grande Do Sul",    0.77
)

# ---- Geometria das UFs ----
ufs <- geobr::read_state(showProgress = FALSE) |> st_transform(4674)

# ---- Classificação: >= 70% vermelho ----
mapa <- ufs |>
  left_join(dados_estados, by = c("name_state" = "estado")) |>
  mutate(
    classe = ifelse(valor >= 0.70, "≥ 70%", "< 70%")
  )

centros <- st_point_on_surface(mapa)


p <- ggplot(mapa) +
  geom_sf(aes(fill = classe), color = "white", linewidth = 0.25) +
  geom_sf_text(
    data = centros,
    aes(label = percent(valor, accuracy = 1)),
    size = 3.3, color = "black"
  ) +
  scale_fill_manual(
    values = c("< 70%" = "#2ECC71", "≥ 70%" = "#E74C3C"),
    name = "Relação PE/PG"
  )  +
  theme_void(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    legend.position = "bottom",        # legenda embaixo
    legend.direction = "horizontal",   # formato horizontal
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 10),
    legend.background = element_rect(fill = alpha("white", 0.6), color = NA)
  )

p

# ---- Salvar ----
ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_7.png", p, width = 8.5, height = 9, dpi = 300)

write_xlsx(mapa, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_7.xlsx")
