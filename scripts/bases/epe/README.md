# EPE - Empresa de Pesquisa Energética

Scripts para processamento e visualização de dados do setor elétrico brasileiro.

## Sobre a Base

Os dados são provenientes do Balanço Energético Nacional (BEN) e outros relatórios da EPE, incluindo:
- Geração elétrica por fonte e estado
- Consumo de energia por subsistema e setor
- Mercado livre e cativo de energia

**Fonte**: [EPE - Empresa de Pesquisa Energética](https://www.epe.gov.br/)

## Estrutura dos Scripts

Os scripts estão organizados em módulos sequenciais:

### Setup e Configuração

| Script | Descrição |
|--------|-----------|
| `00_setup.R` | Bibliotecas, configurações e funções auxiliares |

### Geração Elétrica

| Script | Descrição |
|--------|-----------|
| `01_geracao_leitura.R` | Leitura e limpeza dos dados de geração por estado |
| `02_geracao_subsistema.R` | Gráfico de geração total por subsistema |
| `03_geracao_renovavel.R` | Análise renovável vs não-renovável |
| `04_geracao_solar_eolica.R` | Evolução de solar e eólica (destaque Nordeste) |
| `10_geracao_brasil.R` | Geração nacional por fonte de energia |

### Consumo de Energia

| Script | Descrição |
|--------|-----------|
| `05_consumo_leitura.R` | Leitura dos dados de consumo |
| `06_consumo_subsistema.R` | Consumo por subsistema elétrico |
| `07_consumo_geracao.R` | Comparação geração vs consumo |
| `08_consumo_setor.R` | Consumo setorial (Residencial, Comercial, Industrial) |
| `09_mercado_livre_cativo.R` | Análise mercado livre vs cativo |

## Pipeline de Execução

```
┌─────────────────────┐
│    00_setup.R       │  Configurações globais
└─────────┬───────────┘
          ▼
┌─────────────────────┐     ┌─────────────────────┐
│ 01_geracao_leitura  │     │ 05_consumo_leitura  │
│    (estados)        │     │   (subsistemas)     │
└─────────┬───────────┘     └─────────┬───────────┘
          ▼                           ▼
┌─────────────────────┐     ┌─────────────────────┐
│ 02_geracao_subsist. │     │ 06_consumo_subsist. │
│ 03_geracao_renovav. │     │ 07_consumo_geracao  │
│ 04_geracao_sol_eol. │     │ 08_consumo_setor    │
│ 10_geracao_brasil   │     │ 09_merc_livre_cativ │
└─────────────────────┘     └─────────────────────┘
```

## Subsistemas Elétricos

Os dados são agregados pelos 4 subsistemas do SIN (Sistema Interligado Nacional):

| Subsistema | Estados |
|------------|---------|
| **Sudeste/C.Oeste** | MG, SP, ES, RJ, RO, AC, GO, MT, MS, DF |
| **Sul** | RS, SC, PR |
| **Nordeste** | BA, SE, AL, PE, PB, RN, CE, PI |
| **Norte** | AP, AM, MA, PA, TO |

## Fontes de Energia

### Renováveis
- Hidráulica (Hydro)
- Eólica (Wind)
- Solar
- Bagaço de cana
- Lenha
- Lixívia (Black Liquor)
- Outras fontes renováveis

### Não-Renováveis
- Nuclear
- Térmica
- Carvão vapor
- Gás natural
- Gás de coqueria
- Óleo combustível
- Óleo diesel
- Outras fontes não-renováveis

## Arquivos de Entrada

| Arquivo | Descrição |
|---------|-----------|
| `Capítulo 8 (Dados Estaduais).xlsx` | Geração por estado e fonte (BEN) |
| `consumo.xlsx` | Consumo por subsistema |
| `consumor_setor.xlsx` | Consumo por setor e tipo de mercado |

## Gráficos Gerados

| Arquivo | Descrição |
|---------|-----------|
| `geracao_eletrica.jpg` | Evolução da geração por subsistema |
| `geracao_eletrica_renovavel.jpg` | Renovável vs não-renovável por subsistema |
| `geracao_eletrica_nordeste.jpg` | Solar e eólica no Nordeste |
| `geracao_fonte_parti.jpg` | Participação por fonte (Brasil) |
| `geracao_total.jpg` | Geração total do Brasil |
| `consumo.jpg` | Consumo por subsistema (facetado) |
| `consumo_um_grafico.jpg` | Consumo por subsistema (linhas) |
| `consumo_2023.jpg` | Consumo por subsistema em 2023 |
| `consumo_geracao.jpg` | Comparação geração vs consumo |
| `consumo_energia_setor.jpg` | Consumo setorial (evolução) |
| `consumo_energia_setor_barra.jpg` | Consumo setorial 2023 (barras) |
| `consumo_energia_livre_cativo.jpg` | Mercado livre vs cativo |
| `consumo_energia_livre_cativo_setor.jpg` | Mercado por setor |
| `consumo_energia_livre_cativo_setor_2023.jpg` | Mercado por setor 2023 |

## Dependências (R)

```r
install.packages(c(
  "data.table",
  "dplyr",
  "tidyr",
  "readr",
  "readxl",
  "writexl",
  "stringr",
  "ggplot2",
  "scales",
  "RColorBrewer"
))
```

## Como Executar

1. Execute primeiro o `00_setup.R` para carregar configurações
2. Execute `01_geracao_leitura.R` e `05_consumo_leitura.R` para processar os dados
3. Execute os demais scripts conforme necessário

```r
# Exemplo de execução completa
source("00_setup.R")
source("01_geracao_leitura.R")
source("05_consumo_leitura.R")
source("02_geracao_subsistema.R")
# ... demais scripts
```

## Observações

- Valores de geração e consumo em GWh
- Dados estaduais agregados por subsistema elétrico
- Gráficos salvos em formato JPG (11x7 polegadas)
- Formatação numérica no padrão brasileiro (ponto como separador de milhar)
