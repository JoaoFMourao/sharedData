# SICOR - Rural Credit Operations System

Scripts for processing SICOR (Sistema de Operações do Crédito Rural e do Proagro) data from Brazil's Central Bank.

## Overview

SICOR is the registry of all rural credit and Proagro (agricultural insurance) operations in Brazil. The database is relational, with a main operations table linked to auxiliary domain tables containing additional information about programs, products, modalities, etc.

## Directory Structure

```
sicor/
├── _documentation/
│   ├── Leia-me.txt                    # Main documentation
│   ├── manualDadosSicor_V7.pdf        # Data dictionary (main)
│   ├── manualDadosComplementaresSicor_V10.pdf  # Data dictionary (complement)
│   ├── tabelas_sicor_MDCR_2021/       # Domain tables 2021
│   ├── tabelas_sicor_MDCR_2023/       # Domain tables 2023
│   └── tabelas_sicor_MDCR_2024/       # Domain tables 2024
└── code/
    ├── 1_prepare_sicor_main.R
    ├── 2_merge_empreendimento.R
    └── 3_merge_comp_basic.R
```

## Scripts

| Script | Description |
|--------|-------------|
| `1_prepare_sicor_main.R` | Load yearly files (2013-2024), clean, join into single dataset |
| `2_merge_empreendimento.R` | Add enterprise info (finalidade, atividade, modalidade, produto) |
| `3_merge_comp_basic.R` | Add basic complement (municipality, subsidized credit only) |

## Workflow

### Step 1: Main Database
- Reads `SICOR_OPERACAO_BASICA_ESTADO_XXXX.csv` for each year
- Standardizes variable types across years
- Creates `ano_base` (database year) variable
- Outputs: `sicor_main_2013_2024.Rds`

### Step 2: Enterprise Information
- Joins with `Empreendimento.csv` auxiliary table
- Adds: finalidade, atividade, modalidade, produto
- Outputs: `sicor_main_2013_2024_empreendimento.Rds`

### Step 3: Basic Complement
- Joins with `SICOR_COMPLEMENTO_OPERACAO_BASICA.csv`
- Adds municipality info (subsidized credit only, ~80% of operations)
- Outputs: `sicor_main_2013_2024_basic_complement.Rds`

## Data Source

- **Provider**: Banco Central do Brasil (BCB), DEROP
- **URL**: https://www.bcb.gov.br/estabilidadefinanceira/tabelas-credito-rural-proagro
- **Update frequency**: Wednesdays and Saturdays
- **Current extraction**: 2024-10-16

## Key Identifiers

| Variable | Description |
|----------|-------------|
| `ref_bacen` | Central Bank reference number |
| `nu_ordem` | Order number |
| `ref_bacen` + `nu_ordem` | Unique operation identifier |

## Data Components

1. **Base** (`rawData/base/`) — Main operations data
2. **Auxiliary** (`rawData/auxiliary/`) — Domain tables (Programa, Empreendimento, Modalidade, etc.)
3. **Complement** (`rawData/complement/`) — Additional info for subsidized credit (municipality, CPF, coordinates)

## Important Notes

- Database is large (~10GB) — use servers with high memory capacity
- Always download all related files on the same date to ensure consistency
- Complement data available only for subsidized credit (~80% of operations, ~45% of value)
- Validate against BCB's Rural Credit Data Matrix: https://www.bcb.gov.br/estabilidadefinanceira/micrrural

## Dependencies

```r
tidyverse, data.table, janitor, lubridate, bit64, glue, geobr
```

## Authors

- Wagner F. Oliveira
- Renan Morais
- Mariana Stussi
- Marcelo Sessim
