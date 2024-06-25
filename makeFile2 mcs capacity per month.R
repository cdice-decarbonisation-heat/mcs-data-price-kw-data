# makeFile2 longform MCS p

library(tidyverse)
library(lubridate)

mcs_1_df <- 
  'data/MCS data/mcs pv capacity 2010-2019.csv' %>%
  read_csv(skip = 2)

outcode_lookup_df <-read_csv('outputs/outcode to la lookup.csv')



# QA check ----------------------------------------------------------------

names(mcs_1_df) ## I think the last col is the total number

missing_QA <- 
  mcs_1_df %>% 
  filter(
    !(
      toupper(`Short Postcode`) %in% outcode_lookup_df$outcode
      )
  )

missing_QA %>% nrow() ## this many unlinked
missing_QA$...122 %>% sum() ## this many total unlinked,,  

## find the worst offenders
missing_QA %>%
  arrange(-...122) %>%
  select(`Short Postcode`, ...122)


### issues and fixes
# - Some PCD had lower case -- fixed now to all upper
# - get rid of ...122 col 

# 1. postcode outcode -----------------------------------------------------


## Fixes
mcs_1_df <-
  mcs_1_df %>%
  mutate(`Short Postcode` = `Short Postcode` %>% toupper) %>%
  select(-...122)


## pivot
mcs_1_df <-
  mcs_1_df %>%
  pivot_longer(!`Short Postcode`, names_to = 'month', values_to = 'kw_capacity')

mcs_1_df <-
  mcs_1_df %>%
  rename(outcode = `Short Postcode`) %>%
  left_join(
    outcode_lookup_df
  )

## replace NA with zeros
mcs_1_df <-
  mcs_1_df %>%
  replace_na(
    list(kw_capacity = 0)
  )


## 2. Change data format -------------------------------------------------
## working with dates 
# %b = abbreviated month
# %y = two digit year 

# mcs_1_df$month[1:10]
# mcs_1_df$month[1:10] %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month 


mcs_1_df <-
  mcs_1_df %>%
  mutate(
    month = month %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month
  )

## 3. Aggregate to LA level ---------------------------------------------------



mcs_1_df <-
  mcs_1_df %>%
  group_by(LAD21NM, month) %>%
  summarise(
    kw_capacity = sum(kw_capacity)
  )


# output ------------------------------------------------------------------

mcs_1_df %>% write_csv('outputs/mcs capacity per month (2010-2019).csv')
