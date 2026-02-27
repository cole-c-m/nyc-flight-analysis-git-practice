library(tidyverse)
library(arrow)

# read parquet

flights_cleaned <- read_parquet("data/clean/flights_cleaned.parquet")

glimpse(flights_cleaned)

# create function for plotting column charts

plot_delay_risk <- function(data, group_var, plot_title, x_label) {
  data |>
    group_by({{ group_var }}, arrival_delay) |>
    summarise(n = n(), .groups = "drop") |>
    group_by({{ group_var }}) |>
    mutate(percent = n / sum(n) * 100) |>
    filter(arrival_delay %in% c("High", "Significant")) |>
    
    ggplot(aes(
      x = reorder({{ group_var }}, percent),
      y = percent,
      fill = arrival_delay
    )) +
    geom_col(position = "dodge") +
    coord_flip() +
    labs(
      x = x_label,
      y = "Percent of Flights",
      fill = "Delay Severity",
      title = plot_title
    )
  
}

# assign plot for delays by hour of day


delay_hour_pct_plot <- flights_cleaned |>
  mutate(hour_of_day = hour(date_time)) |>
  group_by(hour_of_day, arrival_delay) |>
  summarise(n = n(), .groups = "drop") |>
  group_by(hour_of_day) |>
  mutate(percent = (n/sum(n)*100)) |>
  filter(arrival_delay %in% c("High", "Significant")) |>
  
  ggplot(aes(
    x = hour_of_day,
    y = percent,
    color = arrival_delay
  )) +
  geom_line() +
  geom_point() +
  labs(
    x = "time",
    y = "Percent of Flights",
    color= "Delay Severity",
    title = "Risk Meaningful delays over time of day"
  ) 

# Plot delay by origin airport, airline and day

plot_delay_risk(flights_cleaned, airline_name, "Risk of meaningful arrival delays by airlines", "Airline")

plot_delay_risk(flights_cleaned, airport_origin_name, "Risk of meaningful arrival delays by origin airport", "Airport Origin")

plot_delay_risk(flights_cleaned, day_of_week, "Risk of meaningful arrival delays by day", "Day")

# generate plot for delay by hour of day

print(delay_hour_pct_plot)
