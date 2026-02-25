install.packages("janitor")
install.packages("arrow")

library(tidyverse)
library(arrow)
library(janitor)


# reading data

flights_raw <- read_csv("data/raw/flights.csv")

airlines_raw <- read_csv("data/raw/airlines.csv") |>
  rename(airline_name = name)

airports_raw <- read_csv("data/raw/airports.csv") |>
  rename(airport_name = name)

airports_raw_filtered <- airports_raw[ ,c("faa","airport_name")] 

# joining data

flights_raw_filtered <- flights_raw[ ,c("flight","carrier","origin","dest","time_hour","dep_delay","arr_delay")] |>
  mutate(flight_id = row_number()) |>
  left_join(airlines_raw, by = "carrier") |>
  left_join(airports_raw_filtered, by = join_by("origin" == "faa")) |>
  rename(airport_origin_name = airport_name) |>
  left_join(airports_raw_filtered, by = join_by("dest" == "faa")) |>
  rename(airport_destination_name = airport_name)

# Each row = one scheduled commercial departure from NYC 

# generating month, day, renaming 

flights_joined <- flights_raw_filtered[ , c("flight_id", "flight", "airline_name","airport_origin_name","airport_destination_name","dep_delay","arr_delay","time_hour")] |>
  mutate(day_of_week = wday(time_hour, label = TRUE, abbr = FALSE)) |>
  mutate(month = month(time_hour, label = TRUE, abbr = FALSE)) |>
  rename(date_time = time_hour) |>
  mutate(arrival_delay = case_when(
    arr_delay > 60 ~ "Significant",
    arr_delay > 15 ~ "High",
    arr_delay > 0 ~ "Low" , 
    TRUE ~ "None"
     )) |>
  mutate(departure_delay = case_when(
    dep_delay > 60 ~ "Significant",
    dep_delay > 15 ~ "High",
    dep_delay > 0 ~ "Low",
    TRUE ~ "None"
  ))

# removing invalid flights and duplicates

flights_clean <- flights_joined |>
  filter(!is.na(dep_delay)) |>
  filter(!is.na(arr_delay)) |>
  filter(!is.na(airport_destination_name)) |>
  filter(!is.na(airport_origin_name)) |>
  filter(!is.na(airline_name)) |>
  distinct(airline_name, flight, airport_origin_name, airport_destination_name, dep_delay, arr_delay, date_time, .keep_all = TRUE) |>
  filter(year(date_time) == 2013)

summary(flights_clean)
glimpse(flights_clean)

# save data as parquet

write_parquet(flights_clean, "data/clean/flights_cleaned.parquet")