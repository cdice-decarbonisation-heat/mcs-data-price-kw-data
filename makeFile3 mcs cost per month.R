# makeFile2 longform MCS p

library(tidyverse)
library(lubridate)

## cost data
mcs_1_df <- 
  'data/MCS data/mcs pv cost 2010-2019.csv' %>%
  read_csv(skip = 2)

mcs_2_df <- 
  'data/MCS data/mcs pv cost 2020-2024.csv' %>%
  read_csv(skip = 2)


## counts -- eligible counts 
mcs_1_n_df <- 
  'data/MCS data/mcs pv cost 2010-2019 (counts).csv' %>%
  read_csv(skip = 2)

mcs_2_n_df <- 
  'data/MCS data/mcs pv cost 2020-2024 (counts).csv' %>%
  read_csv(skip = 2)


## outcode to la lookup
outcode_lookup_df <-
  read_csv('outputs/outcode to la lookup.csv')


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
  
## similar issues to the capacity file 
missing_QA
missing_QA %>% nrow() ## this many unlinked

### issues and fixes -- mcs1
# - Some PCD had lower case -- fixed now to all upper
# - remove £ sign and commas0

## issues - mcs 2
# - smaller list but i guess valid 
# - i can see a few msitakes due to data inputs should be okay to join




# 1. postcode outcode -----------------------------------------------------

mcs_price_df <-
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


## pivot
mcs_price_df <-
  mcs_price_df %>%
  pivot_longer(!`Short Postcode`, names_to = 'month', values_to = 'avg_price')


## Fix price data
mcs_price_df <-
  mcs_price_df %>%
  mutate(
    avg_price = avg_price %>% gsub('<a3>|,|£', '', x = .)
  ) 
  
mcs_price_df <-
  mcs_price_df %>%
  mutate(
    avg_price = avg_price %>% as.numeric
  )

# check <- mcs_price_df%>% na.omit
##


# 2. format the count data ------------------------------------------------

mcs_price_n_df <-
  mcs_1_n_df %>%
  mutate(`Short Postcode` = `Short Postcode` %>% toupper) %>%
  ## full join to combine all 
  full_join(
    mcs_2_n_df %>%
      mutate(`Short Postcode` = `Short Postcode` %>% toupper) 
  )

## The full join should add additional NA counts for dates not originally in a dataset
## Get if BS20 has no entries in the 2020-2024 table -- 
## the full join will add cols and give it NA entries


## pivot
mcs_price_n_df <-
  mcs_price_n_df %>%
  pivot_longer(!`Short Postcode`, names_to = 'month', values_to = 'avg_price_n')



## 3. join together and join to la ---------------------------------------------------------

mcs_price_df <-
  mcs_price_df %>%
  left_join(
    mcs_price_n_df
  )


mcs_price_df <-
  mcs_price_df %>%
  rename(outcode = `Short Postcode`) %>%
  left_join(
    outcode_lookup_df
  )


## replace NA with zeros
mcs_price_df <-
  mcs_price_df %>%
  replace_na(
    list(avg_price = 0,
         avg_price_n = 0)
  )


## 2. Change data format -------------------------------------------------
## working with dates 
# %b = abbreviated month
# %y = two digit year 

# mcs_price_df$month[1:10]
# mcs_price_df$month[1:10] %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month 


mcs_price_df <-
  mcs_price_df %>%
  mutate(
    month = month %>% lubridate::as_date(format = '%b-%y') ## sets as first of the month
  )



# QA and data validation  ------------------------------------------------------
# check for avg prices without counts (and vice versa)
mcs_price_df %>%
  filter(
    (avg_price >0) & (avg_price_n == 0)
  )

mcs_price_df %>%
  filter(
    (avg_price  == 0) & (avg_price_n > 0)
  )
## okay 1 valid entry but lack

mcs_price_df <-
  mcs_price_df %>%
  filter(
    !(
      (avg_price  == 0) & (avg_price_n > 0) ## essentially free panels
    )
  )

## 3. Aggregate to LA level ---------------------------------------------------



mcs_price_df <-
  mcs_price_df %>%
  group_by(LAD21NM, month) %>%
  summarise(
    total_price = sum(avg_price*avg_price_n),
    total_price_n = sum(avg_price_n),
    avg_price_la = weighted.mean(avg_price, avg_price_n)
  )

# output ------------------------------------------------------------------

mcs_price_df %>% write_csv('outputs/mcs price per month (2010-2024).csv')
