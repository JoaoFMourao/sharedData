library(ggplot2)
library(scales)
library(writexl)

# dados
rel_preco <- data.frame(
  ano = 2015:2024,
  rel_preco_pct = c(66.8, 71.0, 70.7, 66.0, 66.4, 68.9, 73.2, 73.5, 68.0, 65.4)
)
rel_preco$rel_preco <- rel_preco$rel_preco_pct/100

p <- ggplot(rel_preco, aes(x = ano, y = rel_preco)) +
  # linha de referência "regra dos 70%"
  geom_hline(yintercept = 0.70, linetype = "dashed", linewidth = 0.7, color = "gray40") +
  # série
  geom_line(linewidth = 1.2, color = "#2E86AB") +
  geom_point(size = 2.8, color = "#2E86AB") +
  # rótulos em todos os pontos
  geom_text(
    aes(label = percent(rel_preco, accuracy = 0.1)),
    vjust = -1, size = 3.5, color = "black"
  ) +
  scale_y_continuous(
    labels = percent_format(accuracy = 1),
    limits = c(0.60, 0.80),
    breaks = seq(0.60, 0.80, by = 0.02),
    expand = expansion(mult = c(0.02, 0.08))
  ) +
  scale_x_continuous(breaks = rel_preco$ano) +
  labs(
    x = NULL, y = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    axis.text.x = element_text(margin = margin(t = 5)),
    plot.caption = element_text(color = "grey35", margin = margin(t = 8))
  )

p

# salvar
ggsave("C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/graph/figura_6.png",
       p, width = 8, height = 4.5, dpi = 300)


write_xlsx(rel_preco, "C:/Users/User/OneDrive - FGV/Fgv Clima/Transportes/Dados/figura_6.xlsx")
