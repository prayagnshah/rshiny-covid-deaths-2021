# Deaths during the year 2021

https://prayagnshah.shinyapps.io/rshiny-covid-deaths-2021/ - Link to see the filtered data of deaths canadian province-wise during covid-19

## Deployment:

[Shiny Server](https://www.shinyapps.io/) - Back end software that builds a web server for shiny apps

## Packages:

* shiny
* leaflet
* tidyverse

## Geo-spatial map:

* (https://www150.statcan.gc.ca/n1/en/catalogue/45280001) - Created the map of Canada with the help of .shp file
    * Transformed the file with the help of Canadian projections

## Explanation:

* Analysis includes the data of deaths due to Covid-19 during the year 2021. We can filter out the data according to the province, gender and age-group. We can also select multiple provinces and other parameters to see the consolidated values. App also allows to search for data with the help of search bar.

## Dataset taken from:

* https://www.r-bloggers.com/2018/12/canada-map/ - Used to create the map of Canada

* https://www150.statcan.gc.ca/n1/en/type/data - Used to get the covid-19 data




