# ====================================================
# 03_analise_comexBR — Geração de gráfico setorial
# ====================================================
# Objetivo:
# - Ler a base agregada (preços constantes) gerada no 02_tratamento_comexBR
# - Transformar para formato "longo" (Exportações, Importações, Saldo)
# - Plotar barras empilhadas com Importações negativas
# - Facetar por Setor (categorias), eixo em milhões de USD FOB

# Pacotes
library(data.table)
library(ggplot2)
library(openxlsx)
library(scales)

# ----------------------------------------------------
# 1) Ler base final
# ----------------------------------------------------

dt <- fread(
  "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/output/balança_comercial_2000_2024.csv",
  na.strings = c("", "NA", "NaN", "null"),
  strip.white = TRUE,
  colClasses = list(
    integer = "CO_ANO",   # 
    character = "categoria", # 
    numeric  = "exportacao",
    numeric = "importacao",
    numeric = "saldo_comercial" 
  )
)


# ----------------------------------------------------
# 2) Preparar dados para o gráfico (formato longo)
# ----------------------------------------------------
# Converte valores para milhões (ajuste a unidade se necessário)
dt[, `:=`(
  exportacao_m      = exportacao/1e6,
  importacao_m      = importacao/1e6,
  saldo_comercial_m = saldo_comercial/1e6
)]

# Mantém (opcional) apenas anos do gráfico
dt <- dt[CO_ANO >= 2000 & CO_ANO <= 2024]

# (opcional) Se quiser excluir o "Total" dos facet:
# dt <- dt[categorias != "Total"]


setDT(dt)
# Derrete para longo
dados_grafico <- melt(
  dt,
  id.vars = c("CO_ANO", "categoria"),
  measure.vars = c("exportacao_m", "importacao_m", "saldo_comercial_m"),
  variable.name = "Categoria",
  value.name = "Valor"
)


setDT(dados_grafico )

# Renomeia rótulos para o gráfico
dados_grafico[, Categoria := fcase(
  Categoria == "exportacao_m",      "Exportações",
  Categoria == "importacao_m",      "Importações",
  Categoria == "saldo_comercial_m", "Saldo"
)]

# Organiza fatores (ordem da legenda)
dados_grafico[, Categoria := factor(Categoria, levels = c("Exportações","Importações","Saldo"))]

# Cria coluna Setor (só para bater com a estética do plot fornecido)
dados_grafico[, Setor := categoria]

# ----------------------------------------------------
# 3) Plot 
# ----------------------------------------------------
p <- ggplot(
  dados_grafico[Setor == "Metalurgia"],
  aes(x = CO_ANO,
      y = ifelse(Categoria == "Importações", -Valor, Valor),
      fill = Categoria)
) +
  geom_col(position = "identity", width = 0.8) +  # ← não empilha, plota cada categoria
  facet_wrap(~Setor, scales = "free_y") +
  scale_fill_manual(values = c("Exportações" = "#084594",
                               "Importações" = "#4292C6",
                               "Saldo"        = "#9ECAE1")) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 2)) +
  labs(x = "Ano",
       y = "Valor (milhões de USD FOB)",
       fill = "Categoria") +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 12)
  )

print(p)

write.xlsx(dt, file = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/output/figura_16.xlsx")

# ----------------------------------------------------
# 4) Salvar figura (opcional)
# ----------------------------------------------------
# Ajuste o caminho/nome se preferir
ggsave(
  filename = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/graph/metalurgia_2000_2024.png",
  plot = p, width = 11, height = 7
)


#####################################





# ----------------------------------------------------
# 3) Plot (exatamente como solicitado)
# ----------------------------------------------------
p <- ggplot(
  dados_grafico[Setor == "Óleo e Gás"],
  aes(x = CO_ANO,
      y = ifelse(Categoria == "Importações", -Valor, Valor),
      fill = Categoria)
) +
  geom_col(position = "identity", width = 0.8) +  # ← não empilha, plota cada categoria
  facet_wrap(~Setor, scales = "free_y") +
  scale_fill_manual(values = c("Exportações" = "#084594",
                               "Importações" = "#4292C6",
                               "Saldo"        = "#9ECAE1")) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 2)) +
  labs(x = "Ano",
       y = "Valor (milhões de USD FOB)",
       fill = "Categoria") +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 12)
  )

print(p)

# ----------------------------------------------------
# 4) Salvar figura (opcional)
# ----------------------------------------------------
# Ajuste o caminho/nome se preferir
ggsave(
  filename = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/graph/oleo_gas_2000_2024.png",
  plot = p, width = 11, height = 7
)



############################################




# ----------------------------------------------------
# 3) Plot (exatamente como solicitado)
# ----------------------------------------------------
p <- ggplot(
  dados_grafico[Setor == "Petróleo cru e Gás natural"],
  aes(x = CO_ANO,
      y = ifelse(Categoria == "Importações", -Valor, Valor),
      fill = Categoria)
) +
  geom_col(position = "identity", width = 0.8) +  # ← não empilha, plota cada categoria
  facet_wrap(~Setor, scales = "free_y") +
  scale_fill_manual(values = c("Exportações" = "#084594",
                               "Importações" = "#4292C6",
                               "Saldo"        = "#9ECAE1")) +
  scale_x_continuous(breaks = seq(2000, 2024, by = 2)) +
  labs(x = "Ano",
       y = "Valor (milhões de USD FOB)",
       fill = "Categoria") +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 12)
  )

print(p)

# ----------------------------------------------------
# 4) Salvar figura (opcional)
# ----------------------------------------------------
# Ajuste o caminho/nome se preferir
ggsave(
  filename = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/graph/Petróleo_cru_e_Gás natural_2000_2024.png",
  plot = p, width = 11, height = 7
)








####################################################




# Converter para data.table
dados_grafico <- as.data.table(dados_grafico)

# Filtrar apenas dados de exportação das categorias relevantes
dados_export <- dados_grafico[Categoria == "Exportações" & 
                                categoria %in% c("Total", "Base", "Transformação", "Metalurgia","Agricultura")]

# Preparar dados para gráfico de evolução
dados_evolucao <- dados_export %>%
  mutate(categoria = factor(categoria, 
                            levels = c("Total", "Base", "Transformação", "Metalurgia","Agricultura")))

# Gráfico 1: Evolução das Exportações por Tipo de Indústria
ggplot(dados_evolucao, aes(x = CO_ANO, y = Valor, color = categoria, group = categoria)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(title = "Evolução das Exportações Industriais Brasileiras (2000-2024)",
       subtitle = "Valores em USD",
       x = "Ano",
       y = "Valor das Exportações (USD)",
       color = "Setor") +
  scale_color_manual(values = c("Total" = "#1f77b4", 
                                "Base" = "#ff7f0e", 
                                "Transformação" = "#2ca02c",
                                "Metalurgia" = "#d62728",
                                "Agricultura" = "#8c564b")) +
  theme_minimal() +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 16),
        plot.subtitle = element_text(size = 12)) +
  scale_y_continuous(labels = dollar_format(prefix = "USD ", big.mark = ".", decimal.mark = ","))

# Calcular participação da metalurgia no total industrial
participacao_metalurgia <- dados_export %>%
  select(CO_ANO, categoria, Valor) %>%
  pivot_wider(names_from = categoria, values_from = Valor) %>%
  mutate(Participacao_Metalurgia = (Metalurgia/Transformação) * 100)

# Gráfico 2: Participação Percentual da Metalurgia
p <- ggplot(participacao_metalurgia, aes(x = CO_ANO, y = Participacao_Metalurgia)) +
  geom_area(fill = "#d62728", alpha = 0.3) +
  geom_line(color = "#d62728", size = 1.2) +
  geom_point(color = "#d62728", size = 2) +
  labs(title = "",
       subtitle = "",
       x = "Ano",
       y = "Participação (%)") +
  theme_minimal() +
  scale_y_continuous(labels = function(x) paste0(round(x, 1), "%")) +
  geom_hline(yintercept = mean(participacao_metalurgia$Participacao_Metalurgia, na.rm = TRUE), 
             linetype = "dashed", color = "gray50") +
  annotate("text", x = max(participacao_metalurgia$CO_ANO), 
           y = mean(participacao_metalurgia$Participacao_Metalurgia, na.rm = TRUE) + 1,
           label = paste("Média:", round(mean(participacao_metalurgia$Participacao_Metalurgia, na.rm = TRUE), 1), "%"),
           hjust = 1, vjust = 0) +
  theme(plot.title = element_text(face = "bold", size = 16),
        plot.subtitle = element_text(size = 12))



ggsave(
  filename = "C:/Users/User/OneDrive - FGV/Fgv Clima/Indústria/graph/parcipacao_transformação_total_2000_2024.png",
  plot = p, width = 11, height = 7
)


