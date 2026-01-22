# Pacotes
library(ggplot2)
library(dplyr)
library(scales)
library(writexl) 

# 1) Dados
df <- tibble::tibble(
  ano   = 2019:2025,
  valor = c(220, 400, 800, 3000, 3800, 6800, 10000),
  tipo  = ifelse(ano >= 2024, "Previsão", "Observado")
)

# 2) Plot
gg <- df %>%
  mutate(
    ano_f = factor(ano, levels = ano),
    lab   = format(valor, big.mark = ".", decimal.mark = ",")
  ) %>%
  ggplot(aes(x = ano_f, y = valor, fill = tipo)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = lab), vjust = -0.3, size = 3.7) +
  scale_y_continuous(
    limits = c(0, 11000),
    breaks = seq(0, 12000, 2000),
    labels = label_number(big.mark = ".", decimal.mark = ",")
  ) +
  scale_fill_manual(
    values = c("Observado" = "#2E7D32",  # verde
               "Previsão"  = "#FBC02D")  # amarelo
  ) +
  labs(
    x = NULL, y = NULL,
    fill = NULL,
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "top",
    plot.title = element_text(face = "bold")
  )

# 3) Exibir
print(gg)

# 4) Salvar (opcional)
ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_11.png", gg, width = 8, height = 4.5, dpi = 300)

write_xlsx(df,
           "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_11.xlsx")
