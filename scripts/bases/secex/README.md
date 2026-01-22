# SECEX - Comércio Exterior Brasileiro

Scripts para processamento e análise dos dados de comércio exterior do Brasil (SECEX/MDIC).

## Sobre a Base

A SECEX (Secretaria de Comércio Exterior) disponibiliza microdados de exportações e importações brasileiras por NCM (Nomenclatura Comum do Mercosul), país e período.

**Fonte**: [ComexStat - MDIC](https://comexstat.mdic.gov.br/)

## Scripts

| Script | Descrição |
|--------|-----------|
| `01_coleta_comexBR_2000_2024.R` | Coleta e agregação dos microdados de exportação/importação |
| `02_tratamento_comexBR.R` | Deflacionamento, mapeamento NCM→CNAE e classificação setorial |
| `03_analise_comexBR.R` | Geração de gráficos setoriais da balança comercial |
| `Pais.R` | Análise por país de destino/origem (Top 15, agregação UE) |
| `produto_ncm_cnae.R` | Análise de correspondência NCM→CNAE por produto |

## Pipeline de Processamento

```
┌─────────────────────┐
│  01_coleta          │  Microdados EXP_*.csv / IMP_*.csv
│  (2000-2024)        │  → Agregação por NCM e Ano
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│  02_tratamento      │  → Deflacionamento (CPI)
│                     │  → Mapeamento NCM → CNAE 2.0
│                     │  → Classificação setorial
└─────────┬───────────┘
          ▼
┌─────────────────────┐
│  03_analise         │  → Gráficos por setor
│  Pais.R             │  → Análise por país
└─────────────────────┘
```

## Tratamentos Aplicados

### Deflacionamento
- Índice utilizado: CPI (Consumer Price Index)
- Valores convertidos para preços constantes

### Mapeamento NCM → CNAE
O script trata as mudanças de classificação ao longo do tempo:

| Período | Tabela de Correspondência |
|---------|---------------------------|
| 2012-2024 | NCM 2012 × CNAE 2.0 |
| 2007-2011 | NCM 2007 × CNAE 2.0 |
| 2004-2006 | NCM 2004 × CNAE 1.0 → 2.0 |
| 2002-2003 | NCM 2002 × CNAE → 1.0 → 2.0 |
| 2000-2001 | NCM 96 × CNAE → 1.0 → 2.0 |

### Tratamento de Duplicidades
Quando um NCM mapeia para múltiplos CNAEs, o valor FOB é dividido igualmente entre eles.

## Classificação Setorial

| Categoria | Códigos CNAE |
|-----------|--------------|
| Cimento | 232* |
| Metalurgia | 24* |
| Elétrico | 351* |
| Óleo e Gás | 06*, 192*, 1931* |
| Mineração | 05*, 07*, 099*, 08991* |
| Transporte | 29*, 30*, 49*, 50*, 51*, 52*, 53* |
| Transformação | 10-33 |
| Base | 05-09, 17, 19, 20, 22, 23, 27-30, 33 |
| Agricultura | 01-03 |

## Variáveis de Saída

| Variável | Descrição |
|----------|-----------|
| `CO_ANO` | Ano de referência |
| `cnae` | Código CNAE 2.0 |
| `categoria` | Classificação setorial |
| `exportacao` | Valor FOB de exportação (USD deflacionado) |
| `importacao` | Valor FOB de importação (USD deflacionado) |
| `saldo_comercial` | Exportação - Importação |

## Arquivos de Entrada

```
~/secex/
├── exp/
│   ├── EXP_2000.csv
│   ├── EXP_2001.csv
│   └── ... (até 2024)
└── imp/
    ├── IMP_2000.csv
    ├── IMP_2001.csv
    └── ... (até 2024)
```

### Tabelas Auxiliares

| Arquivo | Descrição |
|---------|-----------|
| `CPI.xlsx` | Índice de preços para deflacionamento |
| `NCM2012XCNAE20.xls` | Correspondência NCM 2012 × CNAE 2.0 |
| `NCM2007XCNAE10XCNAE20ABRIL2010.xls` | Correspondência NCM 2007 |
| `NCM2004XCNAE10.xls` | Correspondência NCM 2004 |
| `NCM2002XCNAE.xls` | Correspondência NCM 2002 |
| `NCM96XCNAE.xls` | Correspondência NCM 96 |
| `CNAE20_Correspondencia10x20.xls` | Conversão CNAE 1.0 → 2.0 |
| `PAIS.csv` | Tabela de países (código e nome) |
| `NCM.csv` | Descrições dos códigos NCM |

## Saídas

| Arquivo | Descrição |
|---------|-----------|
| `exportacoes_2000_2024.csv` | Exportações agregadas por NCM/ano |
| `importacoes_2000_2024.csv` | Importações agregadas por NCM/ano |
| `balança_comercial_2000_2024.csv` | Balança por setor/ano (deflacionado) |

### Gráficos Gerados

- `metalurgia_2000_2024.png` - Balança comercial da metalurgia
- `oleo_gas_2000_2024.png` - Balança comercial de óleo e gás
- `metalurgia_2024_pais.png` - Top 15 países (exportação/importação)
- `parcipacao_transformação_total_2000_2024.png` - Participação setorial

## Dependências (R)

```r
install.packages(c(
  "data.table",
  "readxl",
  "stringr",
  "ggplot2",
  "scales",
  "dplyr",
  "tidyr",
  "openxlsx",
  "gridExtra"
))
```

## Observações

- Valores FOB em dólares americanos
- NCM padronizado com 8 dígitos (zeros à esquerda)
- Código de país padronizado com 3 dígitos
- Países da UE são agregados como "UE" na análise por país
