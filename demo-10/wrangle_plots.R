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
    `Share by Researchers` = "Rel1", 
    `Share by Library` = "Rel2",
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

# conference papers registered by role
plot_conf <- 
  total_records_by_role |> 
  mutate(Date = parse_date(Date, "%Y-%m", locale = locale(date_names=sv_abb_m))) |> 
  filter(Series != "Administration") |> 
  mutate(Series = replace(Series, Series == "Other", "Researchers")) |> 
  ggplot(aes(x = Date, y = Records, group = Series, color = Series)) +
  geom_smooth(span = 0.4, method = "loess", linetype = "dashed", alpha = 0.2, color = kth_colors("gray")) +
  #discrete_scale(palette = function(n) palette_kth_neo(n = 6)[4:5], aesthetics = c("color"), scale_name = "kth") +
  #discrete_scale("colour", "kth_neo", kth_pal()) +
  geom_step(direction = "mid") +
  # geom_step() + 
  # geom_rect(aes(
  #   xmin = Date, xmax = lead(Date), 
  #   ymin = 0, ymax = Records), 
  #   alpha = 0.4
  # ) +
  facet_wrap(~ Series, ncol = 1) +
  theme_kth_neo(fontscale_factor = 1.5) +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2019-01-01"), as.Date("2023-12-01"))
  ) +
  ylim(0, 200) +
  guides(color = "none", alpha = "none") +
  ggtitle("Conference papers registered by role") +
  theme(
    panel.grid.minor = element_blank()
  )
  #   axis.text.x = element_blank(),
  #   axis.ticks.x = element_blank()
  # )

plot_share <- 
  relative_share |>
  filter(Series == "Share by Researchers") |> 
  ggplot(aes(x = Date, y = Share, group = Series, color = Series)) +
  geom_smooth(method = "lm", color = kth_colors("gray"), alpha = 0.1, linetype = "dashed") +
  scale_color_kth() +
  geom_line() +
  xlim(as.Date("2021-01-01"), as.Date("2024-01-01")) +
  guides(color = "none", alpha = "none") +
  ylab("Share (%)") +
  xlab("Year") +
  ggtitle("Share of publications registered by researchers\n(2021 - 2024)") +
  theme_kth_neo(fontscale_factor = 1.5) +
  theme(
    panel.grid.minor = element_blank()
  )  

demo_10_plots <- list(
  plot_share = plot_share,
  plot_conf = plot_conf
)

demo_10_plots |> readr::write_rds("demo-10/plots.rds")