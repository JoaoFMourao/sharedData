# ============================================================
# 00_setup.R - Configurações e bibliotecas comuns
# ============================================================
# Carrega todas as bibliotecas necessárias para os scripts EPE
# Execute este script antes de qualquer outro
# ============================================================

# Manipulação de dados
library(data.table)
library(dplyr)
library(tidyr)
library(readr)

# Leitura de arquivos
library(readxl)
library(writexl)

# Manipulação de strings
library(stringr)

# Visualização
library(ggplot2)
library(scales)
library(RColorBrewer)

# Configuração do diretório de trabalho
setwd("C:/Users/User/OneDrive - FGV/Fgv Clima")

# Diretórios de entrada e saída
INPUT_DIR <- "C:/Users/User/OneDrive - FGV/Fgv Clima/Energia Elétrica"
OUTPUT_DIR <- "./graphs"

# Criar diretório de saída se não existir
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

# Tema padrão para gráficos
theme_epe <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = base_size - 2),
      axis.text.y = element_text(size = base_size - 2),
      axis.title = element_text(size = base_size, face = "bold"),
      plot.title = element_text(size = base_size + 4, face = "bold", hjust = 0.5, margin = margin(b = 15)),
      plot.caption = element_text(size = base_size - 3, color = "gray50", hjust = 1),
      legend.title = element_text(size = base_size, face = "bold"),
      legend.text = element_text(size = base_size - 2),
      legend.position = "bottom",
      panel.grid.major = element_line(color = "gray90", size = 0.2),
      panel.grid.minor = element_blank(),
      plot.margin = unit(c(1, 1, 1, 1), "cm")
    )
}

# Função para formatar números no padrão brasileiro
formato_br <- function(x, decimals = 0) {
  format(round(x, decimals), big.mark = ".", decimal.mark = ",", scientific = FALSE)
}

# Mensagem de confirmação
message("Setup carregado com sucesso!")
message(paste("Diretório de trabalho:", getwd()))
