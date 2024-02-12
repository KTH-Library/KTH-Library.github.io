library(ggplot2)
library(ktheme)
library(readr)
library(dplyr)
library(tidyr)

total_records_by_role <- 
  "demo-10/monthly_conference_paper_by_role.csv" |> 
  read_csv(show_col_types = FALSE) |> 
  rename(date = "RecordCreationDate", `KTH Library` = "KTHB", Administration = "admin", Other = "okänd") |> 
  pivot_longer(cols = -c("date")) |> 
  rename(Series = "name", Date = date, Records = value)

sv_abb_m <- date_names_lang("sv")
sv_abb_m$mon_ab <- substr(sv_abb_m$mon_ab, 1, 3)

relative_share <- 
  "demo-10/kth_diva_dauf.csv" |> 
  read_delim(delim = ";", show_col_types = FALSE) |> 
  rename(
    Date = "RecordCreationDate", `KTH Library` = "KTHB", 
    Administration = `admin`, Other = "other", 
    Total = "Summa"
  ) |> 
  mutate(
    Rel1 = parse_number(Rel1) / 100,
    Rel2 = parse_number(Rel2) / 100
  ) |> 
  mutate(Date = parse_date(Date, "%y-%b", locale = locale(date_names = sv_abb_m))) |> 
  rename(
    `Share by Library` = "Rel1", 
    `Share by Researchers` = "Rel2",
  ) |> 
  pivot_longer(cols = -c(1)) |>
  filter(grepl("Share", name)) |> 
  rename(
    Series = "name",
    Share = "value"
  ) |> 
  mutate(
    Share = round(Share * 100, 2)
  )

total_records_by_role
relative_share

total_records_by_role |> 
  filter(Series != "Administration") |> 
  ggplot(aes(x = Date, y = Records, group = Series, color = Series)) +
  geom_smooth(method = "loess") +
  geom_line() +
  facet_wrap(~ Series, ncol = 1) +
  theme_kth_neo() +
  theme(axis.text.x = element_blank())

relative_share |>
  ggplot(aes(x = Date, y = Share, group = Series, color = Series)) +
  geom_smooth(method = "loess") +
  geom_line() +
  theme_kth_neo()
