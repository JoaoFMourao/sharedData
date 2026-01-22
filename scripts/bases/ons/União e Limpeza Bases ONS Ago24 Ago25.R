#### Título: União e Limpeza Bases ONS Ago24 Ago25
#### Motivo: unir e limpar as bases ddo ONS 08/24 até 08/25 usando os global, local e append para fins analíticos e educacionais
#### Autor: Mateus Chahin Santos, FGV Clima
#### Orientadora: Rhayana Holz, FGV Clima
#### São Paulo, Janeiro de 2026


###################
######SCRIPT#######
###################


#### PARTE 1: JUNTANDO BASES

### Limpando ambiente do R
rm(list=ls())

### Instalando e buscando bibliotecas
load.lib <- c("data.table","foreign","haven","dplyr","stargazer","ggplot2","readxl", "lmtest",
              "car", "fixest", "tidyr", "sandwich", "janitor", "stringr", "rlang", "purrr", "broom",
              "geobr", "sf","viridis", "RColorBrewer", "writexl", "readr")
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib, dependencies=TRUE)
sapply(load.lib, require, character=TRUE)

### Criando as globals para este script (atualize o path para seu compuatador)
base_ons <- "/Users/mateuschahinsantos/Desktop/Faculdade/FGV Clima/ONS - Belo Monte"

# Estabelecendo ordem cronológica
inicio <- as.Date("2024-08-01")
fim    <- as.Date("2025-08-31")
competencias <- seq(inicio, fim, by = "month")

# Criando o mapa (guia) para o loop
mapa <- data.frame(
  ano = as.integer(format(competencias, "%Y")),
  mes = as.integer(format(competencias, "%m")),
  ym  = format(competencias, "%Y_%m"),
  stringsAsFactors = FALSE
)
mapa$arquivo <- sprintf("GERACAO_USINA-2_%d_%02d.xlsx", mapa$ano, mapa$mes)
mapa$path    <- file.path(base_ons, mapa$arquivo)


# Checagem (para não gerar base incompleta)
faltando <- mapa$arquivo[!file.exists(mapa$path)]
if (length(faltando) > 0) {
  stop(paste0("ERRO: arquivos faltando:\n", paste(faltando, collapse = "\n")))
}

### Loop de leitura (segue a(s) local: base_mes_ano) + append final em ordem (2024/08 -> 2025/08)
bases_ons <- vector("list", nrow(mapa))
names(bases_ons) <- mapa$ym

for (i in seq_len(nrow(mapa))) {
  
  base_mes_ano <- readxl::read_xlsx(mapa$path[i])   # local (só desse arquivo)
  
  # Consertando erro para val_geracao:
  if ("val_geracao" %in% names(base_mes_ano)) {
    base_mes_ano$val_geracao_raw <- base_mes_ano$val_geracao   # preserva como veio
    base_mes_ano$val_geracao     <- as.character(base_mes_ano$val_geracao)  # padroniza p/ bind_rows
  }
  
  # Metadados do arquivo 
  base_mes_ano$ano_arquivo <- mapa$ano[i]
  base_mes_ano$mes_arquivo <- mapa$mes[i]
  base_mes_ano$source_file <- mapa$arquivo[i]
  base_mes_ano$competencia_arquivo <- as.Date(sprintf("%d-%02d-01", mapa$ano[i], mapa$mes[i]))
  
  # Datas observadas (sem mexer na coluna original)
  # Se existir din_instante, criamos uma versão parseada e extraímos ano/mes/dia de cada observação.
  if ("din_instante" %in% names(base_mes_ano)) {
    
    # cria coluna nova (não altera din_instante)
    if (inherits(base_mes_ano$din_instante, c("POSIXct","POSIXt"))) {
      base_mes_ano$din_instante_posix <- base_mes_ano$din_instante
      attr(base_mes_ano$din_instante_posix, "tzone") <- "America/Sao_Paulo"
    } else {
      base_mes_ano$din_instante_posix <- as.POSIXct(base_mes_ano$din_instante, tz = "America/Sao_Paulo")
    }
    
    base_mes_ano$data_obs <- as.Date(base_mes_ano$din_instante_posix)
    base_mes_ano$dia_obs  <- as.integer(format(base_mes_ano$din_instante_posix, "%d"))
    base_mes_ano$mes_obs  <- as.integer(format(base_mes_ano$din_instante_posix, "%m"))
    base_mes_ano$ano_obs  <- as.integer(format(base_mes_ano$din_instante_posix, "%Y"))
  }
  
  # Garantir append apesar de tipos mistos em val_geracao, sem perder a original (recomendação extra feita pelo ChatGPT)
  if ("val_geracao" %in% names(base_mes_ano)) {
    base_mes_ano$val_geracao_raw  <- base_mes_ano$val_geracao         # preserva exatamente como veio
    base_mes_ano$val_geracao_char <- as.character(base_mes_ano$val_geracao)  # coluna nova padronizada
  }
  
  bases_ons[[i]] <- base_mes_ano
}

# Append final
base_consolidada <- dplyr::bind_rows(bases_ons)

### Salvando outputs
saveRDS(base_consolidada, "ONS_GERACAO_CONSOLIDADO.rds")



#### PARTE 2: LIMPANDO

### Criando cópia da base (não sobrescreve o raw)
base_raw   <- base_consolidada
base_clean_consolidada <- base_raw

### Dicionário de nomes (não renomeia a base; apenas registra)
dic_nomes <- data.frame(
  original = names(base_raw),
  clean    = janitor::make_clean_names(names(base_raw)),
  stringsAsFactors = FALSE
)


### Funções auxiliares 
parse_num <- function(x) {
  if (is.numeric(x)) return(as.numeric(x))
  
  x <- as.character(x)
  x <- trimws(x)
  
  x[x %in% c("", " ", "-", ".", "NA", "N/A", "NULL", "null")] <- NA
  x <- gsub("[^0-9,\\.-]", "", x)
  
  both <- !is.na(x) & grepl("\\.", x) & grepl(",", x, fixed = TRUE)
  x[both] <- gsub("\\.", "", x[both])
  
  x <- gsub(",", ".", x, fixed = TRUE)
  
  suppressWarnings(as.numeric(x))
}

norm_text <- function(x) {
  x <- as.character(x)
  x <- stringr::str_replace_all(x, "\u00A0", " ")
  x <- stringr::str_squish(x)
  
  x[x %in% c("", "-", ".", "NA", "N/A", "NULL", "null")] <- NA
  
  x2 <- iconv(x, from = "latin1", to = "UTF-8")
  x2[is.na(x2) & !is.na(x)] <- x[is.na(x2) & !is.na(x)]
  
  x2
}

### Datas explícitas: dia / mês / ano

if ("din_instante" %in% names(base_clean_consolidada)) {
  
  # cria versão parseada sem “bagunçar” a original
  if (inherits(base_clean_consolidada$din_instante, c("POSIXct","POSIXt"))) {
    base_clean_consolidada$din_instante_posix <- base_clean_consolidada$din_instante
    attr(base_clean_consolidada$din_instante_posix, "tzone") <- "America/Sao_Paulo"
  } else {
    base_clean_consolidada$din_instante_posix <- as.POSIXct(base_clean_consolidada$din_instante, tz = "America/Sao_Paulo")
  }
  
  base_clean_consolidada$dia <- as.integer(format(base_clean_consolidada$din_instante_posix, "%d"))
  base_clean_consolidada$mes <- as.integer(format(base_clean_consolidada$din_instante_posix, "%m"))
  base_clean_consolidada$ano <- as.integer(format(base_clean_consolidada$din_instante_posix, "%Y"))
}


### Colunas numéricas *_num (preservando originais)
# Aqui entram todas as colunas que devem ter versão numérica 
cols_num_desejadas <- c("val_geracao")

# cria *_chr e *_num para cada uma
for (cc in cols_num_desejadas) {
  if (cc %in% names(base_clean_consolidada)) {
    base_clean_consolidada[[paste0(cc, "_chr")]] <- as.character(base_clean_consolidada[[cc]])
    base_clean_consolidada[[paste0(cc, "_num")]] <- parse_num(base_clean_consolidada[[cc]])
  }
}

### Limpeza de textos *_clean (todas as colunas character)
char_cols <- names(base_clean_consolidada)[sapply(base_clean_consolidada, is.character)]
for (cc in char_cols) {
  base_clean_consolidada[[paste0(cc, "_clean")]] <- norm_text(base_clean_consolidada[[cc]])
}


### Flags úteis (não removem nada)

# Inconsistência entre data observada e competência do arquivo (se existirem)
if (all(c("mes","ano","mes_arquivo","ano_arquivo") %in% names(base_clean_consolidada))) {
  base_clean_consolidada$flag_mes_ano_inconsistente <- with(
    base_clean_consolidada,
    !is.na(mes) & !is.na(ano) & (mes != mes_arquivo | ano != ano_arquivo)
  )
}

# Duplicidade por chave natural (se existirem as colunas)
if (all(c("din_instante_posix","id_ons") %in% names(base_clean_consolidada))) {
  base_clean_consolidada$key_registro <- paste(base_clean_consolidada$din_instante_posix, base_clean_consolidada$id_ons, sep = "__")
  base_clean_consolidada$n_por_chave  <- ave(base_clean_consolidada$key_registro, base_clean_consolidada$key_registro, FUN = length)
  base_clean_consolidada$flag_dup_key <- base_clean_consolidada$n_por_chave > 1
}

# Diagnóstico de NA por linha
base_clean_consolidada$n_campos_na_linha     <- rowSums(is.na(base_clean_consolidada))
base_clean_consolidada$n_campos_preenchidos  <- rowSums(!is.na(base_clean_consolidada))
base_clean_consolidada$flag_linha_toda_na    <- base_clean_consolidada$n_campos_preenchidos == 0

### Salvando outputs
saveRDS(base_clean_consolidada, "ONS_GERACAO_CONSOLIDADA_cleaned.rds")
