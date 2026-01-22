# ICS - Projeto Plante: Transporte

Scripts para geração de figuras sobre emissões e indicadores do setor de transporte brasileiro.

## Dados Utilizados

| Fonte | Descrição |
|-------|-----------|
| SEEG | Emissões de GEE por modo de transporte |
| Atlas 2024 | Matriz modal de cargas e passageiros |
| ANP | Preços de combustíveis (etanol, gasolina, diesel, biodiesel) |
| IBGE | IPCA para deflacionamento de séries |
| DENATRAN/SENATRAN | Frota de veículos elétricos |

## Figuras

| Script | Descrição |
|--------|-----------|
| `figura_1_2_3.R` | Emissões por modo de transporte (rodoviário, ferroviário, aéreo, hidroviário) e categoria de veículo |
| `figura_4.R` | Divisão modal de cargas (t·km) e passageiros (p·km) |
| `figura_5.R` | Intensidade de carbono por tipo de combustível (gCO2eq/MJ) |
| `figura_6.R` | Série temporal da razão preço etanol/gasolina (2015-2024) |
| `figura_7.R` | Mapa estadual da razão preço etanol/gasolina |
| `figura_8.R` | Comparação de preços biodiesel vs diesel |
| `figura_9.R` | Preços gasolina A vs etanol anidro deflacionados pelo IPCA |
| `figura_10.R` | Registros de veículos elétricos por categoria (2019-2024) |
| `figura_11.R` | Projeções de frota de veículos elétricos (2019-2025) |
| `figura_13.R` | Intensidade energética por modo de transporte (tep/milhão t·km ou p·km) |
| `figura_14.R` | Idade média da frota por segmento (2015-2024) |

## Dependências (R)

```r
install.packages(c(
  "data.table",
  "readxl",
  "writexl",
  "ggplot2",
  "dplyr",
  "tidyr",
  "scales",
  "forcats",
  "patchwork",
  "viridis",
  "ggrepel",
  "geobr",
  "sf"
))
```

## Estrutura de Pastas Esperada

```
Transporte/
├── input/           # Dados brutos (SEEG, Atlas, ANP)
├── output/          # Figuras geradas (.png)
└── scripts/         # Scripts R (figura_*.R)
```

## Execução

Os scripts assumem que os dados de entrada estão no diretório `input/` relativo ao script. As figuras são salvas em `output/`.

```r
source("figura_1_2_3.R")
```

## Contato

- **Projeto**: ICS - Projeto Plante
- **Instituição**: FGV Clima
