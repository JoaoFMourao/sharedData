#### Título: Limpeza Base ONS
#### Motivo: limpar os dados crus da base do ONS para fins analíticos e educacionais
#### Autor: Mateus Chahin Santos, FGV Clima
#### Orientadora: Rhayana Holz, FGV Clima
#### São Paulo, Dezembro de 2025


###################
######SCRIPT#######
###################

### Importando base, localizando diretório e outras funcionalidades básicas


### Limpando ambiente do R
rm(list=ls())

### Localizando diretório (nota: altere o diretório para seu computador)
getwd()
setwd("/Users/mateuschahinsantos/Desktop/Faculdade/FGV Clima/ONS - Belo Monte")
file.exists("GERACAO_USINA-2_2025_08.xlsx")

### Instalando e buscando bibliotecas

load.lib <- c("data.table","foreign","haven","dplyr","stargazer","ggplot2","readxl", "lmtest",
              "car", "fixest", "tidyr", "sandwich", "janitor", "stringr", "rlang", "purrr", "broom",
              "geobr", "sf","viridis", "RColorBrewer", "writexl")
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib, require, character=TRUE)

### Abrindo base "raw" 
base_raw <- read_xlsx("GERACAO_USINA-2_2025_08.xlsx")

### Criando cópia da base (não sobrescreve o raw)
base_clean <- base_raw

### Metadados de importação (rastreamento)
base_clean$source_file <- "GERACAO_USINA-2_2025_08.xlsx"
base_clean$import_date <- Sys.time()

### Dicionário de nomes (não renomeia a base; apenas registra)
dic_nomes <- data.frame(
  original = names(base_raw),
  clean    = janitor::make_clean_names(names(base_raw)),
  stringsAsFactors = FALSE
)

### Garantindo classe de tempo e criando colunas de calendário (dia/mês/ano)
if ("din_instante" %in% names(base_clean)) {
  
  # tenta garantir POSIXct 
  if (!inherits(base_clean$din_instante, c("POSIXct","POSIXt"))) {
    base_clean$din_instante <- as.POSIXct(base_clean$din_instante, tz = "America/Sao_Paulo")
  } else {
    attr(base_clean$din_instante, "tzone") <- "America/Sao_Paulo"
  }
  
  base_clean$dia <- as.integer(format(base_clean$din_instante, "%d"))
  base_clean$mes <- as.integer(format(base_clean$din_instante, "%m"))
  base_clean$ano <- as.integer(format(base_clean$din_instante, "%Y"))
}

### Competência a partir do nome do arquivo 
base_clean$mes_arquivo <- 8L
base_clean$ano_arquivo <- 2025L

### Flag de inconsistência 
if (all(c("mes","ano","mes_arquivo","ano_arquivo") %in% names(base_clean))) {
  base_clean$flag_mes_ano_inconsistente <- with(
    base_clean,
    !is.na(mes) & !is.na(ano) & (mes != mes_arquivo | ano != ano_arquivo)
  )
}

### Limpando/convertendo números 
parse_num <- function(x) {
  if (is.numeric(x)) return(as.numeric(x))
  
  x <- as.character(x)
  x <- trimws(x)
  
  # padronizando “missing”
  x[x %in% c("", " ", "-", ".", "NA", "N/A", "NULL", "null")] <- NA
  
  # remove tudo exceto dígitos, vírgula, ponto e sinal
  x <- gsub("[^0-9,\\.-]", "", x)
  
  # se tiver ponto e vírgula, assume pt-BR 
  both <- !is.na(x) & grepl("\\.", x) & grepl(",", x, fixed = TRUE)
  x[both] <- gsub("\\.", "", x[both])
  
  # vírgula -> ponto (decimal)
  x <- gsub(",", ".", x, fixed = TRUE)
  
  suppressWarnings(as.numeric(x))
}

### Cria versões “chr” e numérica de val_geracao 
if ("val_geracao" %in% names(base_clean)) {
  base_clean$val_geracao_chr <- as.character(base_clean$val_geracao)
  base_clean$val_geracao_num <- parse_num(base_clean$val_geracao)
}

### Função para limpar texto (whitespace, NA “falso”, tentativa de corrigir encoding)
norm_text <- function(x) {
  x <- as.character(x)
  
  # remove espaço não-quebrável e normaliza espaços
  x <- stringr::str_replace_all(x, "\u00A0", " ")
  x <- stringr::str_squish(x)
  
  # padroniza “missing”
  x[x %in% c("", "-", ".", "NA", "N/A", "NULL", "null")] <- NA
  
  # tentativa de corrigir “mojibake” comum (sem destruir os já corretos)
  x2 <- iconv(x, from = "latin1", to = "UTF-8")
  x2[is.na(x2) & !is.na(x)] <- x[is.na(x2) & !is.na(x)]
  
  x2
}

### Adiciona colunas *_clean para todas as colunas character 
char_cols <- names(base_clean)[sapply(base_clean, is.character)]
for (cc in char_cols) {
  base_clean[[paste0(cc, "_clean")]] <- norm_text(base_clean[[cc]])
}

### Chave “natural” + diagnóstico de duplicata 
if (all(c("din_instante","id_ons") %in% names(base_clean))) {
  base_clean$key_registro <- paste(base_clean$din_instante, base_clean$id_ons, sep = "__")
  base_clean$n_por_chave  <- ave(base_clean$key_registro, base_clean$key_registro, FUN = length)
  base_clean$flag_dup_key <- base_clean$n_por_chave > 1
}

### Diagnóstico de NA por linha 
base_clean$n_campos_na_linha     <- rowSums(is.na(base_clean))
base_clean$n_campos_preenchidos  <- rowSums(!is.na(base_clean))
base_clean$flag_linha_toda_na    <- base_clean$n_campos_preenchidos == 0

### Diagnóstico de NA por coluna 
diag_na_cols <- data.frame(
  variavel = names(base_clean),
  n_na     = sapply(base_clean, function(x) sum(is.na(x))),
  pct_na   = sapply(base_clean, function(x) mean(is.na(x))),
  stringsAsFactors = FALSE
)

### Salvando outputs 
saveRDS(base_clean, "ONS_GERACAO_USINA_2025_08_clean.rds")
write.csv(dic_nomes, "ONS_GERACAO_USINA_2025_08_dic_nomes.csv", row.names = FALSE)
writexl::write_xlsx(base_clean, "ONS_GERACAO_USINA_2025_08_clean.xlsx")