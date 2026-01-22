# FGV Clima - Dados Compartilhados

Repositório de scripts para processamento de bases de dados e projetos de pesquisa do FGV Clima.

## Estrutura

```
fgv-clima/
├── README.md
├── scripts/
│   ├── bases/       # Scripts para processamento de bases de dados
│   └── projects/    # Scripts específicos de projetos
└── .gitignore
```

## Organização

### `scripts/bases/`
Scripts para download, limpeza e processamento de bases de dados compartilhadas:
- Dados climáticos (ERA5, INMET, CHIRPS)
- Uso do solo (MapBiomas, PRODES, DETER)
- Emissões (SEEG, SIRENE)
- Socioeconômicos (IBGE, PNAD)
- Geoespaciais (limites administrativos, biomas)

### `scripts/projects/`
Scripts específicos de cada projeto de pesquisa.

## Padrões

- **CRS padrão:** SIRGAS 2000 (EPSG:4674)
- **Códigos municipais:** IBGE 7 dígitos
- **Linguagens:** Python, R

## Contato

- **FGV Clima**: https://clima.fgv.br
- **Email**: clima@fgv.br
