####### Rafael Parfitt 22/05/2025
####### Dados Finbra 

#install.packages("remotes")
#remotes::install_github("rfsaldanha/microdatasus", force = TRUE)

### Limpando ambiente do R
rm(list=ls())

### Escolhendo os Packages (e instalando se for necessÃÂ¡rio)
load.lib <- c("data.table","foreign","haven","microdatasus","remotes","dplyr","stargazer","ggplot2","viridis",
              "hrbrthemes","lmtest","devtools","fixest","modelsummary", "jtools","remotes")

### Instalando e carregando os pacotes solicitados
install.lib <- load.lib[!load.lib %in% installed.packages()]
for(lib in install.lib) install.packages(lib,dependencies=TRUE)
sapply(load.lib, require, character=TRUE)

finbra <- fread("C:/Users/Rafael/Desktop/FGV Clima/Dados/Raw/Finbra/finbra.csv", encoding = "Latin-1")
as.data.table(finbra)
targets <- c("Receitas Brutas Realizadas")

# Filter the dataset
finbra_filtered <- finbra[Coluna=="Receitas Brutas Realizadas"]

# Define the target values exactly as they appear (copy-paste literally if needed)
targets <- c(
  "RECEITAS (EXCETO INTRA-ORÇAMENTÁRIAS) (I)",
  "1.7.1.2.52.0.0 - Cota-parte da Compensação Financeira pela Produção de Petróleo",
  "1.7.1.2.52.4.0 - Cota-Parte do Fundo Especial do Petróleo ¿ FEP")

# Filter the dataset
finbra_filtered <- finbra_filtered[Conta %in% targets]


# Assuming your filtered dataset is called `finbra_filtered`
finbra_filtered[, Receita_tipo := fifelse(
  Conta == "RECEITAS (EXCETO INTRA-ORÇAMENTÁRIAS) (I)",
  "Receita_total",
  fifelse(
    Conta == "1.7.1.2.52.0.0 - Cota-parte da Compensação Financeira pela Produção de Petróleo",
    "Receita_cota_petroleo",
    fifelse(
      Conta == "1.7.1.2.52.4.0 - Cota-Parte do Fundo Especial do Petróleo ¿ FEP",
      "Receita_cota_especial_petroleo",
      fifelse(
        Conta == "1.7.1.2.99.0.0 - Outras Transferências decorrentes de Compensação Financeira pela Exploração de Recursos Naturais",
        "Receita_outras_transferencias",
        NA_character_
      )
    )
  )
)]

finbra_filtered
Final <- finbra_filtered[, .(Instituição, Cod.IBGE, UF, População, Valor, Receita_tipo)]
Final[, Valor := as.numeric(gsub(",", ".", Valor))]

final_wide <- dcast(
  Final,
  Instituição + Cod.IBGE + UF + População ~ Receita_tipo,
  value.var = "Valor",
  fun.aggregate = sum
)

write.dta(final_wide, "C:\\Users\\Rafael\\Desktop\\FGV Clima\\Dados\\Output\\final_wide.dta", version = 13)
