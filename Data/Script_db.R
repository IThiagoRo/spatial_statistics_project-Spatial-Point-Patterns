library(tidyverse)
library(magrittr)
library(Amelia)

db <- read.csv("Data/Global_terrorism.csv")

#db with 8306 obs and 6 variables
db1 <- db %>% filter(., country_txt == "Colombia") %>% 
  select(., iyear, provstate, city, latitude, longitude, attacktype1_txt)


#Aprox 2% of missing data in the variables long and lat 
missmap(db1)
