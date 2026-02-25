install.packages("janitor")
install.packages("arrow")

library(tidyverse)
library(arrow)
library(janitor)

flights_raw <- read_csv("data/raw/flights.csv")
weather_raw <- read_csv("data/raw/weather.csv")
airlines_raw <- read_csv("data/raw/airlines.csv")
airports_raw <- read_csv("data/raw/airports.csv")

head(flights_raw)
glimpse(flights_raw)
summary(flights_raw)

head(weather_raw)
summary(weather_raw)

head(airlines_raw)

head(airports_raw)