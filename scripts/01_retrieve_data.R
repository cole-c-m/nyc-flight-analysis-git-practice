install.packages("tidyverse")
install.packages("nycflights13")

library(tidyverse)

library(nycflights13)

write_csv(flights, "data/raw/flights.csv")

write_csv(airlines, "data/raw/airlines.csv")

write_csv(weather, "data/raw/weather.csv")

write_csv(airports, "data/raw/airports.csv")

