# Scripts FINBRA - Finanças do Brasil

Script R para processamento de dados do FINBRA (Finanças do Brasil) do Tesouro Nacional.

## Autoria

- **Autor:** Rafael Parfitt, FGV Clima
- **Data:** 22/05/2025

## Script

### Finbra Data.R

Script para extração e tratamento de dados de receitas municipais relacionadas à compensação financeira do petróleo.

**Funcionalidades:**

1. **Importação:** Carrega base FINBRA em formato CSV com encoding Latin-1

2. **Filtragem:** Seleciona apenas registros de "Receitas Brutas Realizadas" para contas específicas:
   - `RECEITAS (EXCETO INTRA-ORÇAMENTÁRIAS) (I)` - Receita total
   - `1.7.1.2.52.0.0` - Cota-parte da Compensação Financeira pela Produção de Petróleo
   - `1.7.1.2.52.4.0` - Cota-Parte do Fundo Especial do Petróleo (FEP)

3. **Classificação:** Cria coluna `Receita_tipo` categorizando os tipos de receita:
   - `Receita_total`
   - `Receita_cota_petroleo`
   - `Receita_cota_especial_petroleo`

4. **Reestruturação:** Transforma dados de formato longo para largo (wide) usando `dcast`

5. **Exportação:** Salva resultado em formato Stata (.dta)

**Variáveis de saída:**
- `Instituição` - Nome do município
- `Cod.IBGE` - Código IBGE do município
- `UF` - Unidade federativa
- `População` - População do município
- `Receita_total` - Receita total do município
- `Receita_cota_petroleo` - Receita de compensação do petróleo
- `Receita_cota_especial_petroleo` - Receita do Fundo Especial do Petróleo

## Dependências

```r
data.table, foreign, haven, microdatasus, remotes, dplyr, stargazer,
ggplot2, viridis, hrbrthemes, lmtest, devtools, fixest, modelsummary, jtools
```

## Configuração

Antes de executar, altere os caminhos de entrada e saída:

```r
# Entrada
finbra <- fread("caminho/para/finbra.csv", encoding = "Latin-1")

# Saída
write.dta(final_wide, "caminho/para/final_wide.dta", version = 13)
```

## Fonte dos Dados

Os dados FINBRA são disponibilizados pelo Tesouro Nacional através do SICONFI (Sistema de Informações Contábeis e Fiscais do Setor Público Brasileiro) e contêm informações sobre receitas e despesas dos municípios brasileiros.
