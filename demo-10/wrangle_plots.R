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

monthly_pubtypes <- 
  "demo-10/records.csv" |> 
  read_csv(show_col_types = FALSE) |> 
  rename(
    role = "Roll",
    pid = "RecordIdentifier",
    date = "RecordCreationDate",
    kthid = "RecordOrigin",
    pubtype = "Genre"
  ) |> 
  filter(pubtype %in% c(
    "Article in journal", 
    "Conference paper"
  )) |> 
  filter(
    date > as.Date("2022-01-01")
  ) |> 
  mutate(Date = format(date, "%Y-%b")) |> 
  group_by(Date, pubtype, role) |> 
  summarize(
    n = n_distinct(pid)
  ) |> 
  ungroup() |> 
  mutate(Date = parse_date(Date, "%Y-%b")) |> 
  arrange(-desc(Date)) |> 
  mutate(
    role = replace(role, role %in% c("KTHB"), "KTH Library")
  ) |> 
  mutate(
    role = replace(role, role == "okänd", "Researchers")
  ) |> 
  pivot_wider(names_from = c("role", "pubtype"), values_from = n) |> 
  mutate(
    Share_Article = `Researchers_Article in journal` / (`Researchers_Article in journal` + `KTH Library_Article in journal`),
    Share_Conf = `Researchers_Conference paper` / (`Researchers_Conference paper` + `KTH Library_Conference paper`)
  ) |> 
  mutate(
    Share_Article = round(Share_Article * 100 , 1),
    Share_Conf = round(Share_Conf * 100, 1)
  )

relative_share_article <- 
  monthly_pubtypes |> select(Date, starts_with("Share_Article")) 

relative_share_conf <- 
  monthly_pubtypes |> select(Date, starts_with("Share_Conf")) 

counts_article <- 
  monthly_pubtypes |> select(Date, contains("Article in journal")) |> 
  select(-contains("admin")) |> 
  pivot_longer(cols = c(2:3), values_to = "Records") |> 
  separate(col = "name", into = c("Role", "Pubtype"), sep = "_")

counts_conf <- 
  monthly_pubtypes |> select(Date, contains("Conference")) |> 
  select(-contains("admin")) |> 
  pivot_longer(cols = c(2:3), values_to = "Records") |> 
  separate(col = "name", into = c("Role", "Pubtype"), sep = "_")
  

#total_records_by_role
#relative_share

plot_conf_1 <- 
  counts_conf |> 
  ggplot(aes(x = Date, y = Records, group = Role, color = Role)) +
  geom_smooth(span = 0.7, method = "lm", linetype = "dashed", alpha = 0.2, color = kth_colors("gray")) +
  geom_step(direction = "mid") +
  facet_wrap(~ Role, ncol = 1) +
  theme_kth_neo(fontscale_factor = 1.5) +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2022-01-01"), as.Date("2023-12-01"))
  ) +
  #ylim(0, 300) +
  guides(color = "none", alpha = "none") +
  ggtitle("Conference papers") +
  theme(
    panel.grid.minor = element_blank()
  )

plot_articles <- 
  counts_article |> 
  ggplot(aes(x = Date, y = Records, group = Role, color = Role)) +
  geom_smooth(span = 0.7, method = "lm", linetype = "dashed", alpha = 0.2, color = kth_colors("darkred")) +
  geom_step() +
  facet_wrap(~ Role, ncol = 1) +
#  geom_rect(aes(xmin = Date, xmax = lead(Date), 
#              ymin = 0, ymax = Records), 
#          color = kth_colors("darkblue"), alpha = 0.8) +
  theme_kth_neo(fontscale_factor = 1.5) +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2022-01-01"), as.Date("2023-12-01"))
  ) +
  guides(color = "none", alpha = "none") +
  ggtitle("Journal article registrations") +
  theme(
    panel.grid.minor = element_blank()
  )  


plot_conf <- 
  counts_conf |> 
  ggplot(aes(x = Date, y = Records, group = Role, color = Role)) +
  geom_smooth(span = 0.7, method = "lm", linetype = "dashed", alpha = 0.2, color = kth_colors("darkred")) +
  geom_step(direction = "mid") +
  facet_wrap(~ Role, ncol = 1) +
  theme_kth_neo(fontscale_factor = 1.5) +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2022-01-01"), as.Date("2023-12-01"))
  ) +
  #ylim(0, 200) +
  guides(color = "none", alpha = "none") +
  ggtitle("Conference paper registrations") +
  theme(
    panel.grid.minor = element_blank()
  )  


# conference papers registered by role
# plot_conf <- 
#   total_records_by_role |> 
#   mutate(Date = parse_date(Date, "%Y-%m", locale = locale(date_names=sv_abb_m))) |> 
#   filter(Series != "Administration") |> 
#   mutate(Series = replace(Series, Series == "Other", "Researchers")) |> 
#   ggplot(aes(x = Date, y = Records, group = Series, color = Series)) +
#   geom_smooth(span = 0.4, method = "loess", linetype = "dashed", alpha = 0.2, color = kth_colors("gray")) +
#   #discrete_scale(palette = function(n) palette_kth_neo(n = 6)[4:5], aesthetics = c("color"), scale_name = "kth") +
#   #discrete_scale("colour", "kth_neo", kth_pal()) +
#   geom_step(direction = "mid") +
#   # geom_step() + 
#   # geom_rect(aes(
#   #   xmin = Date, xmax = lead(Date), 
#   #   ymin = 0, ymax = Records), 
#   #   alpha = 0.4
#   # ) +
#   facet_wrap(~ Series, ncol = 1) +
#   theme_kth_neo(fontscale_factor = 1.5) +
#   scale_x_date(
#     date_breaks = "1 year", 
#     date_labels = "%Y", 
#     date_minor_breaks = "month",
#     limits = c(as.Date("2019-01-01"), as.Date("2023-12-01"))
#   ) +
#   ylim(0, 200) +
#   guides(color = "none", alpha = "none") +
#   ggtitle("Conference paper registrations") +
#   theme(
#     panel.grid.minor = element_blank()
#   )
#   #   axis.text.x = element_blank(),
#   #   axis.ticks.x = element_blank()
#   # )

plot_share_articles <- 
  relative_share_article |> 
  ggplot(aes(x = Date, y = Share_Article)) +
  geom_smooth(method = "lm", color = kth_colors("darkblue"), alpha = 0.1, linetype = "dashed") +
  scale_color_kth() +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2022-01-01"), as.Date("2023-02-01"))
  ) +
  geom_line(color = kth_colors("blue")) +
  #xlim(as.Date("2021-01-01"), as.Date("2024-01-01")) +
  guides(color = "none", alpha = "none") +
  ylab("Share (%)") +
  xlab("Year") +
  ggtitle("Journal articles") +
  theme_kth_neo(fontscale_factor = 1.5) +
  theme(
    panel.grid.minor = element_blank()
  )  

plot_share_conf <- 
  relative_share_conf |> 
  ggplot(aes(x = Date, y = Share_Conf)) +
  geom_smooth(method = "lm", color = kth_colors("darkblue"), alpha = 0.1, linetype = "dashed") +
  scale_color_kth() +
  scale_x_date(
    date_breaks = "1 year", 
    date_labels = "%Y", 
    date_minor_breaks = "month",
    limits = c(as.Date("2022-01-01"), as.Date("2024-02-01"))
  ) +
  geom_line(color = kth_colors("blue")) +
  #xlim(as.Date("2021-01-01"), as.Date("2024-01-01")) +
  guides(color = "none", alpha = "none") +
  ylab("Share (%)") +
  xlab("Year") +
  ggtitle("Conference proceedings") +
  theme_kth_neo(fontscale_factor = 1.5) +
  theme(
    panel.grid.minor = element_blank()
  )  


# plot_share <- 
#   relative_share |>
#   filter(Series == "Share by Researchers") |> 
#   ggplot(aes(x = Date, y = Share, group = Series, color = Series)) +
#   geom_smooth(method = "lm", color = kth_colors("gray"), alpha = 0.1, linetype = "dashed") +
#   scale_color_kth() +
#   geom_line() +
#   xlim(as.Date("2021-01-01"), as.Date("2024-01-01")) +
#   guides(color = "none", alpha = "none") +
#   ylab("Share (%)") +
#   xlab("Year") +
#   ggtitle("Share of publications registered by researchers\n(2021 - 2024)") +
#   theme_kth_neo(fontscale_factor = 1.5) +
#   theme(
#     panel.grid.minor = element_blank()
#   )  


demo_10_plots <- list(
  plot_share_articles = plot_share_articles,
  plot_share_conf = plot_share_conf,
  plot_articles = plot_articles,
  plot_conf = plot_conf
#  plot_share = plot_share,
#  plot_conf = plot_conf
)

demo_10_plots |> readr::write_rds("demo-10/plots.rds")