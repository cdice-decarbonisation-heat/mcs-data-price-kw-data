# MCS cost and KW capacity data tables

This repository contains data cleaning scripts for the Microgeneration Certification Scheme (MCS) data on cost and capacity for solar PV installations. The key outputs are aggregated tables showing:

- Monthly installed solar PV capacity (0-50kW) by local authority (LA).
- Average installation cost of PV systems (£1,000-£250,000) by local authority (LA).

Both tables cover the period from January 2010 to January 2024 and are stored in the `outputs` folder. The R code for creating the aggregated data is stored in the main repository folder (prefixed with `makeFile`).

**Note:** This is not an official MCS data release and relies on a snapshot of the MCS installation database, which is updated over time. This data was supplied for the purposes of research.

## Data

Monthly data on installation price and kW capacity was provided to us at postcode outcode level by the MCS in July 2024. A postcode outcode is the first part of a full postcode (e.g., CF24 instead of CF24 1AA).

### Original MCS data specification
- Sum of total installed capacity (kW) of solar PV systems (0-50kW) from January 2010 to January 2024, by short postcode.
- Average installation cost of solar PV systems (£1,000-£250,000) from January 2010 to January 2024, by short postcode. Include a count field for valid cost data.

Using outcode data, we have further aggregated outcomes to monthly data by local authority (England only).

Data on total MCS installations and other statistics can be accessed via the [MCS dashboard](https://mcscertified.com/about-the-mcs-data-dashboard/).

## Limitations

- **Outcode to LA mismatches:** There is not a perfect match between postcode outcode boundaries and LA boundaries. Some postcode outcodes are split across two or more LAs. In most cases, the vast majority of an outcode is in one LA (i.e., 95% or more of the outcode in one LA in 70% of cases). In less than 5% of cases, 60% or less of a postcode outcode is in an LA.
- **Invalid outcodes:** In a very small number of cases (< 3%), the outcode could not be found, filtering out a tiny number of installations.
- **Changes in valid sample size over time:** The accuracy of MCS price data has increased over time. In 2015, 58.9% of installations had valid price data, and this percentage rose steadily to 76.2% in 2019. In 2020, a significant improvement in accuracy led to a 97.8% validity.

## Contact

For more information, please contact:

Dr. Meng Le Zhang  
[zhangm19@cardiff.ac.uk](mailto:zhangm19@cardiff.ac.uk), [mengle.zhang@gmail.com](mailto:mengle.zhang@gmail.com)


