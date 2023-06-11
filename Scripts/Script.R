library(tidyverse)
library(sf)
library(spatstat)
library(maptools)


db <- read.csv("Data/Colombia_Terrorism.csv")
locations <- db %>% select(., latitude, longitude)
saveRDS(locations, "Data/locations.Rds")

colombia <- st_read("Maps_Shapes_and_Objects//MGN_DPTO_POLITICO.shp")
plot(colombia$geometry)
col_border <- colombia$geometry

#Changing the crs for the border
col_border <- st_transform(col_border, "+proj=utm +zone=18 +ellps=GRS80 +datum=WGS84 +units=m +no_defs")

coords <- cbind(db$longitude, db$latitude)

locations <- st_sfc(st_multipoint(as.matrix(db[, 6:5])), crs = "+proj=longlat +zone=18 +ellps=GRS80 +datum=WGS84 +units=m +no_defs")
locations <- st_transform(locations, "+proj=utm +zone=18 +ellps=GRS80 +datum=WGS84 +units=m +no_defs")
#locations <- st_as_sf(data.frame(coords), coords = c("X1", "X2"), crs = "+proj=utm +zone=18 +ellps=GRS80 +datum=WGS84 +units=m +no_defs"
locations <- st_intersection(col_border, locations)



save(col_border, locations, file = "Maps_Shapes_and_Objects/Contour_Points.RData")


plot(col_border)
plot(locations, add = T, pch = 20, col = "red")



#### PPP object ###
load("Maps_Shapes_and_Objects//Contour_Points.RData")

obs.win <- as(as(st_sf(col_border), "Spatial"), "owin")
ppp.col <- ppp(x = st_coordinates(locations)[, 1],
              y = st_coordinates(locations)[, 2],
              window = obs.win)
coord.units <- c("metre", "metres")
unitname(ppp.col) <- coord.units
plot(ppp.col)
saveRDS(ppp.col, "Maps_Shapes_and_Objects//ppp.col.Rds")


### Kernels ###
digglebw <- bw.diggle(ppp.col) %>% round(2)
scottbw <- bw.scott(ppp.col) %>% round(2)
cvlbw <- bw.CvL(ppp.col) %>% round(2)
fracbw <- bw.frac(ppp.col) %>% round(2)
pplbw <- bw.ppl(ppp.col) %>% round(2)
bwds <- list(digglebw, scottbw, cvlbw, fracbw, pplbw)
saveRDS(bwds, "Maps_Shapes_and_Objects/bandwidths.Rds")


### fitting intensity models ###
mod_lin_x <- ppm(ppp.col, ~x)
mod_lin_y <- ppm(ppp.col, ~y)
mod_lin_xy <- ppm(ppp.col, ~x+y)
mod_quad <- ppm(ppp.col, ~ x+y + I(x^2) + I(y^2))
mod_quad_xy <- ppm(ppp.col, ~polynom(x,y,2) + I(x*y))
models_list <- list(mod_lin_x, mod_lin_y, mod_lin_xy, mod_quad, mod_quad_xy)
save(models_list,file = "Maps_Shapes_and_Objects/models.RData")

plot(pcf(ppp.col), main = "Pair-Correlation estimada")
