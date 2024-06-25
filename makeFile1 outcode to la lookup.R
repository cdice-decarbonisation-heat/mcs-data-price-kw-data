## makeFile1: postcode outcode to LAD21 lookup

library(tidyverse)
library(data.table)

## input
# national statistics postcode lookup (nspl)
# https://geoportal.statistics.gov.uk/datasets/9ac0331178b0435e839f62f41cc61c16/about

## Get string up to a character
# https://stackoverflow.com/questions/38291794/extract-string-before

nspl_df <-
  'data/NSPL_MAY_2022_UK.csv' %>%
  fread(
    #nrows = 1, 
    select = c('pcd2', 'laua')
    )

nspl_laua_df<-
  'data/LA_UA names and codes UK as at 04_21.csv' %>%
  read_csv


## Make the lookup of postcodes to la/ua
nspl_df_meng <-
  nspl_df %>%
  mutate(
    outcode = pcd2 %>% sub("\\ .*", "", x = .)
  )

nspl_df_meng <-
  nspl_df_meng %>% 
  group_by(outcode, laua) %>%
  summarise(n = n())
  

## Assign by max
nspl_df_meng <-
  nspl_df_meng %>%
  group_by(outcode) %>%
  mutate(prop_outcode_in_la = n / sum(n)) %>%
  filter(prop_outcode_in_la == max(prop_outcode_in_la))



# QA check the outcodes ---------------------------------------------------

nspl_df_meng %>% summary ## almost all are in top 
nspl_df_meng$prop_outcode_in_la %>% quantile(seq(0, 1, 0.05)) ## less than 5% have ambiguous (<50%) boundaries



# join to names -----------------------------------------------------------
nspl_laua_df %>% summary

nspl_df_meng <- 
  nspl_df_meng %>%
  left_join(
    nspl_laua_df,
    by = c(laua = 'LAD21CD')
    )


# clean before outputs ----------------------------------------------------


nspl_df_meng %>%
  select(outcode, LAD21NM, prop_outcode_in_la) %>%
  write_csv('outputs/outcode to la lookup.csv')
