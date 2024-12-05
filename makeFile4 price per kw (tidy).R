## makeFile 04 -- price per KW (estimated)
## Turn into one big data file 

library(tidyverse)

mcs_capacity_df <-
  read_csv('outputs/mcs capacity per month (2010-2024).csv')

mcs_price_df <- 
  read_csv('outputs/mcs price per month (2010-2024).csv')


full_capacity_price <-
  mcs_capacity_df %>%
  full_join(
    mcs_price_df
  )

## checks how often capacity is reported but not price

full_capacity_price %>%
  filter(
    kw_capacity_n != total_price_n
  )
## only in 4 cases so actually pretty good -- we'll omit values for these


full_capacity_price <- 
  full_capacity_price %>%
  mutate(
    price_per_kw = total_price/ kw_capacity,
    price_per_kw_n = total_price_n
  ) %>%
  ## omit dates where valid price != valid kw
  mutate(
    price_per_kw = ifelse(kw_capacity_n != total_price_n, NA, price_per_kw),
    price_per_kw_n = ifelse(kw_capacity_n != total_price_n, NA, price_per_kw_n)
  )
  

## save data
full_capacity_price %>% 
  write_csv('outputs/mcs price-kw-cost (full).csv')

