# Scripts ONS - Geração de Usinas

Scripts R para limpeza e consolidação de dados de geração de energia do Operador Nacional do Sistema Elétrico (ONS).

## Autoria

- **Autor:** Mateus Chahin Santos, FGV Clima
- **Orientadora:** Rhayana Holz, FGV Clima

## Scripts

### 1. Limpeza Base ONS.R

Script para limpeza de um único arquivo mensal de geração de usinas do ONS.

**Funcionalidades:**
- Importação de arquivo Excel (`GERACAO_USINA-2_YYYY_MM.xlsx`)
- Adição de metadados de rastreamento (arquivo fonte, data de importação)
- Criação de dicionário de nomes de variáveis
- Tratamento de datas (`din_instante`) com extração de dia/mês/ano
- Conversão de valores numéricos (`val_geracao`) com suporte a formatos BR e EN
- Normalização de textos (encoding, espaços, valores missing)
- Flags de inconsistência (data vs competência do arquivo)
- Detecção de duplicatas por chave natural (`din_instante` + `id_ons`)
- Diagnóstico de valores NA por linha e coluna

**Outputs:**
- `ONS_GERACAO_USINA_YYYY_MM_clean.rds`
- `ONS_GERACAO_USINA_YYYY_MM_clean.xlsx`
- `ONS_GERACAO_USINA_YYYY_MM_dic_nomes.csv`

### 2. União e Limpeza Bases ONS Ago24 Ago25.R

Script para consolidação e limpeza de múltiplos arquivos mensais (agosto/2024 a agosto/2025).

**Parte 1 - Consolidação:**
- Loop de leitura de 13 arquivos mensais em ordem cronológica
- Verificação de existência de todos os arquivos antes do processamento
- Padronização de tipos de colunas para compatibilidade no append
- Adição de metadados por arquivo (competência, fonte)
- União em base consolidada única

**Parte 2 - Limpeza:**
- Aplicação das mesmas rotinas de limpeza do script individual
- Tratamento de datas e criação de colunas temporais
- Conversão numérica e normalização de textos
- Flags de inconsistência e duplicatas
- Diagnóstico de NA

**Outputs:**
- `ONS_GERACAO_CONSOLIDADO.rds` (base bruta consolidada)
- `ONS_GERACAO_CONSOLIDADA_cleaned.rds` (base limpa consolidada)

## Dependências

```r
data.table, foreign, haven, dplyr, stargazer, ggplot2, readxl,
lmtest, car, fixest, tidyr, sandwich, janitor, stringr, rlang,
purrr, broom, geobr, sf, viridis, RColorBrewer, writexl, readr
```

## Configuração

Antes de executar, altere o diretório de trabalho para o local dos arquivos fonte:

```r
setwd("/caminho/para/seus/arquivos")
# ou
base_ons <- "/caminho/para/seus/arquivos"
```

## Estrutura dos Dados

Os scripts esperam arquivos Excel no formato:
- Nome: `GERACAO_USINA-2_YYYY_MM.xlsx`
- Colunas principais: `din_instante`, `id_ons`, `val_geracao`
