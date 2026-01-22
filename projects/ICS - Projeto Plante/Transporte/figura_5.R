library(ggplot2)
library(dplyr)
library(writexl)

# Criando o data frame com os dados de consumo (em tep) por combustível e ano
consumo_energia <- data.frame(
  Combustível = c(
    "Etanol Anidro",
    "Etanol Hidratado",
    "Gasolina A",
    "Gasolina C¹ (E27/E30)",
    "Gasolina C (E22)",
    "Biometano",
    "GNV",
    "Biodiesel",
    "Diesel A",
    "Diesel B² (BX)",
    "Diesel B (B7)",
    "Eletricidade"
  ),
  `2022` = c(
    22.26, 22.65, 87.40, 73.61, 76.76,  9.32,
    76.85, 28.40, 86.50, 81.04, 82.69, 21.78
  ),
  `2024` = c(
    22.39, 22.73, 87.40, 73.78, 76.78,  8.35,
    76.85, 28.40, 86.50, 79.06, 82.69, 20.85
  ),
  `2027` = c(
    22.04, 22.30, 87.40, 72.45, 76.73,  8.35,
    76.85, 28.11, 86.50, 78.24, 82.67, 19.89
  ),
  `2032` = c(
    21.42, 21.46, 87.40, 72.31, 76.63,  8.35,
    76.85, 27.64, 86.50, 76.49, 82.64, 25.00
  ),
  `2034` = c(
    21.11, 21.08, 87.40, 72.24, 76.57,  8.35,
    76.85, 27.45, 86.50, 75.33, 82.62, 24.31
  ),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

# Criando o data frame com os dados de consumo (em tep) por combustível e ano
#Gasolina C (E27 = gasolina A + 27% etanol anidro)
# Diesel B (B14 = diesel A + 14% biodiesel)

consumo_energia <- data.frame(
  Combustível = c(
    "Álcool Hidratado",
    "Gasolina C",
    "GNV",
    "Diesel B",
    "Eletricidade"
  ),
  `2024` = c(22.73, 73.78,
             76.85, 86.50, 20.85
  ),
  check.names = FALSE,
  stringsAsFactors = FALSE
)



# Visualizar o data frame
print(consumo_energia)


# Supondo que você já tenha o data frame 'consumo_energia' criado anteriormente

# Extrai apenas o ano de 2024
df2024 <- consumo_energia %>%
  select(Combustível, `2024`) %>%
  rename(Consumo = `2024`)

# Gráfico de barras para 2024
ggplot(df2024, aes(x = reorder(Combustível, Consumo), y = Consumo)) +
  geom_col(fill = "steelblue") +
  geom_text(
    aes(label = round(Consumo, 1)),   # rótulo com uma casa decimal (ajuste se quiser)
    hjust = -0.1,                     # empurra o texto um pouco para fora da barra
    size  = 3.5                       # tamanho da fonte em pts
  ) +
  coord_flip() +
  labs(
    title = "",
    x = "Combustível",
    y = "Intensidade de carbono (gCO2eq/MJ)"
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +  # folga à direita p/ o texto
  theme_minimal(base_size = 12)


write_xlsx(df2024, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_5.xlsx")


ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_5.jpg",
       width = 10, height = 6, units = "in")