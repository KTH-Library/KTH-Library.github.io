library(readr)
library(dplyr)
library(purrr)

apc_se <- paste0(
  "https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/openapc-se/",
  "apc_se.csv"
)

df1 <- 
  apc_se %>%
  read_csv()

apc_se_rich <- paste0(
    "https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/openapc-se/",
    "apc_se_enriched.csv"
  )

df2 <- 
  apc_se_rich %>%
  read_csv() %>%
  filter(!is.na(doi))

apc_se_pre <- paste0(
  "https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/openapc-se/",
  "apc_se_preprocessed.csv"
)

df3 <-
  apc_se_pre %>%
  read_csv() %>%
  filter(!is.na(doi))


library(rpivotTable)

rpivotTable(df2)
