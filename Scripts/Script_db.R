library(tidyverse)
library(magrittr)
library(Amelia)

db <- read.csv("Data/Global_terrorism.csv")

#db with 181.691 obs and 6 variables
db1 <- db %>% filter(., country_txt == "Colombia" & iyear == "2017") %>% 
  select(., iyear, provstate, city, latitude, longitude, attacktype1_txt)


#Aprox 2% of missing data in the variables long and lat 
missmap(db1)

#Removed NA, Db with 352 obs and 6 variables
db1 %<>% na.omit()

write.csv(db1, "Data/Colombia_Terrorism.csv")
