# makeFile2 longform MCS p

library(tidyverse)
library(lubridate)


## the capacity data
mcs_1_df <- 
  'data/MCS data/mcs pv capacity 2010-2019.csv' %>%
  read_csv(skip = 2)

mcs_2_df <- 
  'data/MCS data/mcs pv capacity 2020-2024.csv' %>%
  read_csv(skip = 2)


## count data 
mcs_1_n_df <- 
  'data/MCS data/mcs pv capacity 2010-2019 (counts).csv' %>%
  read_csv(skip = 2)

mcs_2_n_df <- 
  'data/MCS data/mcs pv capacity 2020-2024 (counts).csv' %>%
  read_csv(skip = 2)


outcode_lookup_df <-read_csv('outputs/outcode to la lookup.csv')


# QA check ----------------------------------------------------------------

check_dfs <- 
  list(mcs_1_df, mcs_2_df,
       mcs_1_n_df, mcs_2_n_df) 

check_dfs %>%
  map(names)


missing_QA <- 
  check_dfs %>% 
  map(
    .f = function(x){
      x %>% 
        filter(
          !(
            toupper(`Short Postcode`) %in% outcode_lookup_df$outcode
          )
        )  
    }
  )

missing_QA
missing_QA[[1]]$...122 %>% sum() ## this many total unlinked,,  

## find the worst offenders
missing_QA[[1]] %>%
  arrange(-...122) %>%
  select(`Short Postcode`, ...122)


### issues and fixes
# - Some PCD had lower case -- fixed now to all upper
# - get rid of ...122 col 


# QA mcs2 file ------------------------------------------------------------
no_join_df <-
  mcs_2_df %>%
  filter(
    !(
      toupper(`Short Postcode`) %in% toupper(mcs_1_df$`Short Postcode`) 
    )
  )

## only 114 unmacthed? 
## I think due to incorrect outcode? 

missing_QA <- 
  mcs_2_df %>% 
  filter(
    !(
      toupper(`Short Postcode`) %in% outcode_lookup_df$outcode
    )
  )

## issues
# - smaller list but i guess valid 
# - i can see a few msitakes due to data inputs should be okay to join




# 1. postcode outcode -----------------------------------------------------

mcs_capacity_df <-
  mcs_1_df %>%
  mutate(`Short Postcode` = `Short Postcode` %>% toupper) %>%
  ## full join to combine all 
  full_join(
    mcs_2_df %>%
      mutate(`Short Postcode` = `Short Postcode` %>% toupper) 
  )

## The full join should add additional NA counts for dates not originally in a dataset
## Get if BS20 has no entries in the 2020-2024 table -- 
## the full join will add cols and give it NA entries

## Fixes
mcs_capacity_df <-
  mcs_capacity_df %>%
  mutate(`Short Postcode` = `Short Postcode` %>% toupper) %>%
  select(-...122)


## pivot
mcs_capacity_df <-
  mcs_capacity_df %>%
  pivot_longer(!`Short Postcode`, names_to = 'month', values_to = 'kw_capacity')

mcs_capacity_df <-
  mcs_capacity_df %>%
  rename(outcode = `Short Postcode`) %>%
  left_join(
    outcode_lookup_df
  )


# 2. format the count data ------------------------------------------------

mcs_capacity_n_df <-
  mcs_1_n_df %>%
  mutate(`Short Postcode` = `Short Postcode` %>% toupper) %>%
  ## full join to combine all 
  full_join(
    mcs_2_n_df %>%
      mutate(`Short Postcode` = `Short Postcode` %>% toupper) 
  )

## pivot
mcs_capacity_n_df <-
  mcs_capacity_n_df %>%
  pivot_longer(!`Short Postcode`, names_to = 'month', values_to = 'kw_capacity_n')

mcs_capacity_n_df <-
  mcs_capacity_n_df %>%
  rename(outcode = `Short Postcode`) 

## join ----------------------------------------
mcs_capacity_df <-
  mcs_capacity_df %>%
  left_join(
    mcs_capacity_n_df
  )


## replace NA with zeros
mcs_capacity_df <-
  mcs_capacity_df %>%
  replace_na(
    list(kw_capacity = 0, kw_capacity_n = 0 )
  )




## 2. Change data format -------------------------------------------------
## working with dates 
# %b = abbreviated month
# %y = two digit year 

# mcs_capacity_df$month[1:10]
# mcs_capacity_df$month[1:10] %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month 


mcs_capacity_df <-
  mcs_capacity_df %>%
  mutate(
    month = month %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month
  )



# QA and data validation  ------------------------------------------------------
# check for avg prices without counts (and vice versa)
mcs_capacity_df %>%
  filter(
    (kw_capacity >0) & (kw_capacity_n == 0)
  )

mcs_capacity_df %>%
  filter(
    (kw_capacity  == 0) & (kw_capacity_n > 0)
  )
## okay some invalid eneries

mcs_capacity_df <-
  mcs_capacity_df %>%
  filter(
    !(
        (kw_capacity  == 0) & (kw_capacity_n > 0)
      
    )
  )



## 3. Aggregate to LA level ---------------------------------------------------



mcs_capacity_df <-
  mcs_capacity_df %>%
  group_by(LAD21NM, month) %>%
  summarise(
    kw_capacity = sum(kw_capacity, na.rm = T),
    kw_capacity_n = sum(kw_capacity_n, na.rm = T)
  )


# output ------------------------------------------------------------------

mcs_capacity_df %>% write_csv('outputs/mcs capacity per month (2010-2024).csv')
