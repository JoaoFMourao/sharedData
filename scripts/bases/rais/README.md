# RAIS - Relação Anual de Informações Sociais

Scripts para processamento da base RAIS do Ministério do Trabalho e Emprego.

## Sobre a RAIS

A RAIS é um registro administrativo de periodicidade anual que contém informações sobre o mercado de trabalho formal brasileiro: vínculos empregatícios, remunerações, ocupações e características dos trabalhadores.

**Fonte**: [Ministério do Trabalho e Emprego](https://www.gov.br/trabalho-e-emprego/pt-br/assuntos/estatisticas-trabalho/rais)

## Scripts

| Script | Descrição |
|--------|-----------|
| `rais_cleaning.R` | Limpeza e padronização dos microdados RAIS 2024 |

## Processamento (`rais_cleaning.R`)

### Entrada

Microdados RAIS em formato TXT, organizados por região:
- `RAIS_VINC_PUB_MG_ES_RJ.txt`
- `RAIS_VINC_PUB_NI.txt`
- `RAIS_VINC_PUB_NORDESTE.txt`
- `RAIS_VINC_PUB_NORTE.txt`
- `RAIS_VINC_PUB_SP.txt`
- `RAIS_VINC_PUB_SUL.txt`
- `RAIS_VINC_PUB_CENTRO_OESTE.txt`

### Filtros Aplicados

- **Vínculos ativos em 31/12**: Apenas trabalhadores com vínculo ativo no final do ano

### Variáveis de Saída

| Variável | Descrição |
|----------|-----------|
| `Município` | Código IBGE do município (7 dígitos) |
| `Gênero` | Male, Female, Typo, Ignored |
| `Skill_CBO` | Código CBO 2002 da ocupação |
| `Salário` | Remuneração nominal em dezembro |
| `Escolaridade` | Nível de escolaridade (11 categorias) |
| `cnae_2_0` | CNAE 2.0 Subclasse (7 dígitos) |
| `cbo_group` | Primeiro dígito do CBO |
| `Skill_Class` | High-skill (CBO 1-3) ou Low-skill (demais) |

### Classificação de Escolaridade

| Código | Descrição |
|--------|-----------|
| 1 | Analfabeto |
| 2 | Até 5º incompleto |
| 3 | 5º completo / Fundamental |
| 4 | 6º ao 9º / Fundamental |
| 5 | Fundamental completo |
| 6 | Médio incompleto |
| 7 | Médio completo |
| 8 | Superior incompleto |
| 9 | Superior completo |
| 10 | Mestrado |
| 11 | Doutorado |

### Classificação de Habilidade (CBO)

- **High-skill**: Grupos 1, 2 e 3 (Dirigentes, Profissionais das ciências, Técnicos)
- **Low-skill**: Demais grupos ocupacionais

### Saída

```
~/Rais/clean_base_2024_completo.csv
```

## Dependências (R)

```r
install.packages(c("data.table", "geobr", "sf"))
```

## Observações

- Encoding dos arquivos originais: `Latin-1`
- Códigos CNAE são padronizados para 7 dígitos com zeros à esquerda
- Códigos CBO são padronizados para 4 dígitos
