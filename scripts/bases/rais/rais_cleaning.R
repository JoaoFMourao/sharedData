library(data.table)
library(geobr)   # official shapefiles for Brazil
library(sf)      # spatial data manipulation

# 1) Vector of regions (subfolder names / filenames without extension)
regions <- c(
  "MG_ES_RJ",
  "NI",
  "NORDESTE",
  "NORTE",
  "SP",
  "SUL",
  "CENTRO_OESTE"
)

# 2) Build full paths and read each file into a list
dt_list <- lapply(regions, function(reg) {
  path <- sprintf("~/Rais/2024_completo/RAIS_VINC_PUB_%s.txt", reg)
  fread(path, encoding = "Latin-1")
})

# 3) Stack them all into one data.table
dt_all <- rbindlist(dt_list, use.names = TRUE, fill = TRUE)

# 4) Filter for formal employment (positive active ties on Dec 31)
dt_base <- dt_all[`Ind Vínculo Ativo 31/12 - Código` > 0]

# 5) Select and rename the columns we need
dt_base <- dt_base[, .(
  Município   = `Município - Código`,
  Gênero         = `Sexo - Código`,
  Skill_CBO      = `CBO 2002 Ocupação - Código`,
  Salário         = `Vl Rem Dezembro Nom`,
  Escolaridade      = `Escolaridade Após 2005 - Código`,
  cnae_2_0       = `CNAE 2.0 Subclasse - Código`
)]

# 6) Ensure the CNAE code has 7 digits with leading zeros
dt_base[, cnae_2_0 := sprintf("%07d", as.integer(cnae_2_0))]

# 7) Clean up temporary objects
rm(dt_all, dt_list)

# 8) Recode gender from numeric codes to labels
gender_dict <- c(
  "1"  = "Male",
  "2"  = "Female",
  "9"  = "Typo",
  "-1" = "Ignored"
)
dt_base[, Gênero := gender_dict[ as.character(Gênero) ]]

# 9) Recode education levels
education_dict <- c(
  "1"   = "Illiterate",
  "2"   = "Up to 5th incomplete",
  "3"   = "5th complete / Elementary",
  "4"   = "6th–9th / Elementary",
  "5"   = "Elementary complete",
  "6"   = "High school incomplete",
  "7"   = "High school complete",
  "8"   = "Some college",
  "9"   = "SUP. COMP",
  "10"  = "MESTRADO",
  "11"  = "DOUTORADO",
  "99"  = "Code not in official dictionary",
  "-1"  = "Ignored"
)
dt_base[, Escolaridade := education_dict[ as.character(Escolaridade) ]]

# 10) Format CBO codes and create a simple skill grouping
dt_base[, Skill_CBO := sprintf("%04s", Skill_CBO)]       # pad with leading zeros
dt_base[, cbo_group := substr(Skill_CBO, 1, 1)]          # first digit
dt_base[, Skill_Class := fifelse(
  cbo_group %in% c("1", "2", "3"), "High-skill",
  "Low-skill"
)]

# 11) Export the cleaned dataset
fwrite(dt_base, "~/Rais/clean_base_2024_completo.csv")
