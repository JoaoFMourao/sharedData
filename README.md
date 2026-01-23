# FGV Clima - Dados Compartilhados

Repositório de scripts R para análise de dados e geração de outputs para os projetos do FGV Clima.

## Estrutura do Repositório

```
sharedData/
├── README.md
├── scripts/
│   ├── bases/          # Scripts de limpeza de bases de dados
│   │   ├── epe/        # Dados de energia (EPE)
│   │   ├── finbra/     # Finanças municipais (Tesouro Nacional)
│   │   ├── ons/        # Operador Nacional do Sistema Elétrico
│   │   ├── rais/       # Relação Anual de Informações Sociais
│   │   └── secex/      # Comércio exterior (SECEX/MDIC)
│   │
│   └── projects/       # Scripts de projetos específicos
│       ├── Indústria/  # Análise setorial industrial
│       ├── Mineral/    # Setor de mineração
│       ├── O&G/        # Óleo e Gás
│       └── Transporte/ # Setor de transportes
│
└── _reference/         # Materiais de referência
```

---

## Diferença entre `bases/` e `projects/`

### `scripts/bases/` - Limpeza de Bases de Dados

Scripts para **limpeza e tratamento de bases de dados** que:
- Ainda não foram implementadas em um projeto específico
- São de **interesse geral** e úteis para diversos projetos
- Transformam dados brutos (raw) em dados limpos prontos para análise

**Características:**
- Foco em ETL (Extract, Transform, Load)
- Código reutilizável entre projetos
- Documentação das transformações aplicadas

### `scripts/projects/` - Projetos Específicos

Scripts de **projetos específicos** que geram outputs finais (figuras, tabelas, análises).

**Regra fundamental:** Cada projeto deve conter **todos os códigos necessários** para reproduzir seus outputs em uma pasta específica.

**Características:**
- Código completo e autocontido
- Pode haver duplicação de código entre projetos (isso é aceitável)
- Inclui geração de figuras, tabelas e análises estatísticas

> **Nota:** A diferença entre `bases/` e `projects/` pode ser tênue em alguns casos. Use bom senso: se o código é primariamente de limpeza/preparação de dados reutilizáveis, vai em `bases/`. Se é código específico para gerar outputs de um relatório/projeto, vai em `projects/`.

---

## Gestão de Dados no SharePoint

Todas as bases de dados devem ser armazenadas no SharePoint:

```
Gestão de projetos > Técnico > 05-Base de dados
```

### Estrutura de Pastas

```
05-Base de dados/
├── input/          # Dados brutos (raw)
│   ├── RAIS/
│   ├── FINBRA/
│   ├── ONS/
│   ├── EPE/
│   ├── SECEX/
│   └── [Nome do Projeto]/
│
└── output/         # Dados processados e outputs
    ├── data/       # Bases limpas prontas para análise
    ├── figures/    # Gráficos e visualizações
    └── tables/     # Tabelas exportadas
```

### Regras de Organização

#### `input/`
- Crie pastas com o **nome da base de dados** e/ou **nome do projeto**
- Coloque apenas **dados crus** (raw) sem nenhuma modificação
- Mantenha os arquivos originais intactos

#### `output/data/`
- Bases de dados **limpas e tratadas**
- Prontas para gerar outputs (figuras, tabelas, análises estatísticas)
- Formatos: `.rds`, `.dta`, `.csv`, `.parquet`

#### `output/figures/`
- Gráficos e visualizações geradas
- Formatos: `.png`, `.pdf`, `.svg`

#### `output/tables/`
- Tabelas exportadas
- Formatos: `.csv`, `.xlsx`

---

## Bases Disponíveis

### EPE - Empresa de Pesquisa Energética
Scripts para análise de dados de geração e consumo de energia elétrica no Brasil.

| Script | Descrição |
|--------|-----------|
| `00_setup.R` | Configuração inicial e bibliotecas |
| `01_geracao_leitura.R` | Leitura de dados de geração |
| `02_geracao_subsistema.R` | Geração por subsistema |
| `03_geracao_renovavel.R` | Geração renovável |
| `04_geracao_solar_eolica.R` | Geração solar e eólica |
| `05_consumo_leitura.R` | Leitura de dados de consumo |
| `06_consumo_subsistema.R` | Consumo por subsistema |
| `07_consumo_geracao.R` | Relação consumo/geração |
| `08_consumo_setor.R` | Consumo por setor |
| `09_mercado_livre_cativo.R` | Mercado livre vs cativo |
| `10_geracao_brasil.R` | Geração agregada Brasil |

### FINBRA - Finanças do Brasil
Processamento de dados de receitas municipais do Tesouro Nacional (SICONFI).

| Script | Descrição |
|--------|-----------|
| `Finbra Data.R` | Extração de receitas de compensação do petróleo |

### ONS - Operador Nacional do Sistema Elétrico
Limpeza de dados de geração de usinas.

| Script | Descrição |
|--------|-----------|
| `Limpeza Base ONS.R` | Limpeza de arquivo mensal |
| `União e Limpeza Bases ONS Ago24 Ago25.R` | Consolidação de múltiplos meses |

### RAIS - Relação Anual de Informações Sociais
Tratamento de dados do mercado de trabalho formal.

| Script | Descrição |
|--------|-----------|
| `rais_cleaning.R` | Limpeza e padronização da RAIS |

### SECEX - Comércio Exterior
Análise de dados de exportação e importação do Brasil.

| Script | Descrição |
|--------|-----------|
| `01_coleta_comexBR_2000_2024.R` | Coleta de dados 2000-2024 |
| `02_tratamento_comexBR.R` | Tratamento e limpeza |
| `03_analise_comexBR.R` | Análises descritivas |
| `Pais.R` | Classificação de países |
| `produto_ncm_cnae.R` | Correspondência NCM-CNAE |

---

## Projetos

### Indústria
Análise multi-setorial industrial com foco em cimento e metalurgia.
- Tabela comparativa entre setores
- Mapas estaduais de emprego e salário
- Intensidade de emprego por valor adicionado

### Mineral
Análise do setor de mineração brasileiro.
- Estatísticas municipais de emprego
- Comparação salarial entre setores
- Mapas de distribuição geográfica

### O&G - Óleo e Gás
Análise completa do setor de óleo e gás.
- Dependência municipal de royalties
- Comparação setorial de salários e valor adicionado
- Múltiplas figuras para relatório

### Transporte
Análise do setor de transportes.
- Figuras 1-14 para relatório setorial

---

## Dependências Comuns

```r
# Manipulação de dados
data.table, dplyr, tidyr, stringr, janitor

# Leitura/escrita
readxl, haven, foreign, readr, writexl

# Visualização
ggplot2, viridis, ggrepel, scales, RColorBrewer

# Mapas
sf, geobr

# Estatística
fixest, lmtest, sandwich, broom, modelsummary
```

---

## Padrões

- **CRS padrão:** SIRGAS 2000 (EPSG:4674)
- **Códigos municipais:** IBGE 7 dígitos
- **Linguagem principal:** R

---

## Boas Práticas

1. **Sempre documente** o que cada script faz no cabeçalho
2. **Inclua autor e data** de criação/modificação
3. **Use caminhos relativos** ou variáveis globais para paths
4. **Mantenha dados brutos intactos** - nunca modifique arquivos em `input/`
5. **Versionamento**: commite frequentemente com mensagens claras
6. **Reprodutibilidade**: qualquer pessoa deve conseguir rodar o código

---

## Contato

- **FGV Clima**: https://clima.fgv.br
- **Email**: clima@fgv.br
