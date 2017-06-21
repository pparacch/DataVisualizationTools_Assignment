# Building a Geom: playground
Pier Lorenzo Paracchini  
20 juni 2017  



## How to build a new geom

```
(1st) create a new class from the Geom class
 required_aes = <a character vector of required aesthetics>,
 default_aes = aes(<default values for certain aesthetics>),
 draw_key = <a function used to draw the key in the legend>,
 draw_panel = function(data, panel_scales, coord) {
   Function that returns a grid grob that will 
   be plotted (this is where the real work occurs)

(2nd) create the corrisponding geom function
```


### Example 1


```r
GeomMyPoint <- ggproto("GeomMyPoint", Geom, 
                 required_aes = c("x", "y"),
                 default_aes = aes(shape = 19),
                 draw_key = draw_key_point,
                 draw_panel = function(data, panel_scales, coord){
                   #Transform the data
                   coords <- coord$transform(data, panel_scales)
                   
                   #Print out the transofrmed data
                   str(coords)
                   
                   #Create a grid grob
                   pointsGrob(
                     x = coords$x,
                     y = coords$y,
                     pch = coords$shape
                   )
                 })

geom_mypoint <- function(mapping = NULL, data = NULL, stat = "identity",
                       position = "identity", na.rm = FALSE,
                       show.legend = NA, inherit.aes = TRUE, ...){
  layer(
    geom = GeomMyPoint, mapping = mapping,
    data = data, stat = stat, position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm,...)
  )
}

ggplot(data = worldcup, mapping = aes(x = Time, y = Shots)) + geom_mypoint()
```

![](build_geom_playground_files/figure-html/example1-1.png)<!-- -->

```
## 'data.frame':	595 obs. of  5 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.0791 0.1128 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
```

### Example 2


```r
GeomAutoTransparent <- ggproto("GeomAutoTransparent", Geom, 
                 required_aes = c("x", "y"),
                 default_aes = aes(shape = 19),
                 draw_key = draw_key_point,
                 draw_panel = function(data, panel_scales, coord){
                   #Transform the data
                   coords <- coord$transform(data, panel_scales)
                   
                   #Print out the transofrmed data
                   str(coords)
                   
                   #Compute the transparency factor
                   n <- nrow(data)
                   
                   if(n > 100 && n <= 200){
                     coords$alpha <- 0.3
                   }else if(n > 200){
                     coords$alpha <- 0.15
                   }else{
                     coords$alpha <- 1
                   }
                   
                   #Print out the transofrmed data
                   str(coords)
                   
                   #Create a grid grob
                   pointsGrob(
                     x = coords$x,
                     y = coords$y,
                     pch = coords$shape,
                     gp = gpar(alpha = coords$alpha)
                   )
                 })

geom_tranparentpoint <- function(mapping = NULL, data = NULL, stat = "identity",
                       position = "identity", na.rm = FALSE,
                       show.legend = NA, inherit.aes = TRUE, ...){
  layer(
    geom = GeomAutoTransparent, mapping = mapping,
    data = data, stat = stat, position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm,...)
  )
}

ggplot(data = worldcup, mapping = aes(x = Time, y = Shots)) + 
  geom_tranparentpoint()
```

![](build_geom_playground_files/figure-html/example2-1.png)<!-- -->

```
## 'data.frame':	595 obs. of  5 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.0791 0.1128 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	595 obs. of  6 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.0791 0.1128 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 ...
##  - attr(*, "vars")= chr "PANEL"

ggplot(data = worldcup[1:150,], mapping = aes(x = Time, y = Shots)) + 
  geom_tranparentpoint()
```

![](build_geom_playground_files/figure-html/example2-2.png)<!-- -->

```
## 'data.frame':	150 obs. of  5 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1061 0.1667 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	150 obs. of  6 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1061 0.1667 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ...
##  - attr(*, "vars")= chr "PANEL"

ggplot(data = worldcup[1:60,], mapping = aes(x = Time, y = Shots)) + 
  geom_tranparentpoint()
```

![](build_geom_playground_files/figure-html/example2-3.png)<!-- -->

```
## 'data.frame':	60 obs. of  5 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1212 0.197 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	60 obs. of  6 variables:
##  $ x    : num  0.0694 0.6046 0.3314 0.4752 0.1174 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1212 0.197 ...
##  $ PANEL: int  1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  1 1 1 1 1 1 1 1 1 1 ...
##  - attr(*, "vars")= chr "PANEL"

ggplot(data = worldcup, mapping = aes(x = Time, y = Shots)) + 
  geom_tranparentpoint() +
  facet_wrap(~ Position, ncol = 2)
```

![](build_geom_playground_files/figure-html/example2-4.png)<!-- -->

```
## 'data.frame':	188 obs. of  5 variables:
##  $ x    : num  0.331 0.264 0.208 0.475 0.132 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1128 0.0455 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	188 obs. of  6 variables:
##  $ x    : num  0.331 0.264 0.208 0.475 0.132 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.1128 0.0455 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 1 1 1 1 1 1 1 1 1 1 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	143 obs. of  5 variables:
##  $ x    : num  0.1174 0.1589 0.0966 0.2132 0.2611 ...
##  $ y    : num  0.1128 0.0455 0.0455 0.1128 0.2138 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 2 2 2 2 2 2 2 2 2 2 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	143 obs. of  6 variables:
##  $ x    : num  0.1174 0.1589 0.0966 0.2132 0.2611 ...
##  $ y    : num  0.1128 0.0455 0.0455 0.1128 0.2138 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 2 2 2 2 2 2 2 2 2 2 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	36 obs. of  5 variables:
##  $ x    : num  0.475 0.475 0.619 0.116 0.907 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.0455 0.0455 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 3 3 3 3 3 3 3 3 3 3 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	36 obs. of  6 variables:
##  $ x    : num  0.475 0.475 0.619 0.116 0.907 ...
##  $ y    : num  0.0455 0.0455 0.0455 0.0455 0.0455 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 3 3 3 3 3 3 3 3 3 3 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  1 1 1 1 1 1 1 1 1 1 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	228 obs. of  5 variables:
##  $ x    : num  0.0694 0.6046 0.4752 0.0774 0.4752 ...
##  $ y    : num  0.0455 0.0455 0.0791 0.2138 0.0791 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 4 4 4 4 4 4 4 4 4 4 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	228 obs. of  6 variables:
##  $ x    : num  0.0694 0.6046 0.4752 0.0774 0.4752 ...
##  $ y    : num  0.0455 0.0455 0.0791 0.2138 0.0791 ...
##  $ PANEL: Factor w/ 4 levels "1","2","3","4": 4 4 4 4 4 4 4 4 4 4 ...
##  $ group: int  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
##  $ shape: num  19 19 19 19 19 19 19 19 19 19 ...
##  $ alpha: num  0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 ...
##  - attr(*, "vars")= chr "PANEL"
```

### Build the Hurricane Geom


```r
#Load the cleaned data
data_hurricane <- read_csv(file = "./data/ebtrk_atlc_1988_2015.cleaned.txt")
## Parsed with column specification:
## cols(
##   storm_id = col_character(),
##   date = col_datetime(format = ""),
##   latitude = col_double(),
##   longitude = col_double(),
##   ne = col_integer(),
##   se = col_integer(),
##   sw = col_integer(),
##   nw = col_integer(),
##   wind_speed = col_integer()
## )
#Get one observation
storm_observation <- data_hurricane[data_hurricane$storm_id == "KATRINA-2005" & 
                                data_hurricane$date == ymd_hms("2005-08-29 12:00:00"),]

storm_observation$wind_speed <- as.factor(storm_observation$wind_speed)

#create geom skeleton
GeomHurricane <- ggplot2::ggproto(
  "GeomHurricane", 
  Geom,
  required_aes = c("x", "y", "r_ne", "r_se", "r_sw", "r_nw"),
  default_aes = aes(colour = "NA", fill = "grey20", size = 0.5, linetype = 1, alpha = 0.8, scale_radii = 1),
  draw_key = draw_key_polygon,
  draw_group = function(data, panel_scales, coord){
    str(data)
    
    point_obs = c(data[1,]$x, data[1,]$y)
    color <- data[1,]$colour
    fill <- data[1,]$fill
    alpha <- data[1,]$alpha
    scale_radii = data[1,]$scale_radii
    
    points_polygon = geosphere::destPoint(p = point_obs, b=1:90, d = data[1,]$r_ne * 1852 * scale_radii)
    data_ne <- data.frame(x = c(points_polygon[,"lon"], point_obs[1]),
                          y = c(points_polygon[,"lat"], point_obs[2])
                          )
    str(data_ne)
    
    points_polygon = geosphere::destPoint(p = point_obs, b=90:180, d = data[1,]$r_se * 1852 * scale_radii)
    data_se <- data.frame(x = c(points_polygon[,"lon"], point_obs[1]),
                          y = c(points_polygon[,"lat"], point_obs[2])
                          )
    str(data_se)
    
    points_polygon = geosphere::destPoint(p = point_obs, b=180:270, d = data[1,]$r_sw * 1852 * scale_radii)
    data_sw <- data.frame(x = c(points_polygon[,"lon"], point_obs[1]),
                          y = c(points_polygon[,"lat"], point_obs[2])
                          )
    str(data_sw)
    
    points_polygon = geosphere::destPoint(p = point_obs, b=270:360, d = data[1,]$r_nw * 1852 * scale_radii)
    data_nw <- data.frame(x = c(points_polygon[,"lon"], point_obs[1]),
                          y = c(points_polygon[,"lat"], point_obs[2])
                          )
    str(data_nw)
    
    
    
    data_all <- rbind(data_ne, data_se, data_nw, data_sw)
    coords <- coord$transform(data_all, panel_scales)
    
    grid::polygonGrob(x = coords$x,
                      y = coords$y,
                      gp = grid::gpar(col = color, fill = fill, alpha = alpha))
  }
)

geom_hurricane <- function(mapping = NULL, data = NULL, stat = "identity",
                       position = "identity", na.rm = FALSE,
                       show.legend = NA, inherit.aes = TRUE, ...){
  layer(
    geom = GeomHurricane, mapping = mapping,
    data = data, stat = stat, position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm,...)
  )
}

library(ggmap)
## Google Maps API Terms of Service: http://developers.google.com/maps/terms.
## Please cite ggmap if you use it: see citation("ggmap") for details.
## 
## Attaching package: 'ggmap'
## The following object is masked from 'package:magrittr':
## 
##     inset

map_plot <- get_map("Lousiana", zoom = 6, maptype = "toner-background") 
## maptype = "toner-background" is only available with source = "stamen".
## resetting to source = "stamen"...
## Source : https://maps.googleapis.com/maps/api/staticmap?center=Lousiana&zoom=6&size=640x640&scale=2&maptype=terrain
## Source : https://maps.googleapis.com/maps/api/geocode/json?address=Lousiana
## Source : http://tile.stamen.com/toner-background/6/14/24.png
## Source : http://tile.stamen.com/toner-background/6/15/24.png
## Source : http://tile.stamen.com/toner-background/6/16/24.png
## Source : http://tile.stamen.com/toner-background/6/14/25.png
## Source : http://tile.stamen.com/toner-background/6/15/25.png
## Source : http://tile.stamen.com/toner-background/6/16/25.png
## Source : http://tile.stamen.com/toner-background/6/14/26.png
## Source : http://tile.stamen.com/toner-background/6/15/26.png
## Source : http://tile.stamen.com/toner-background/6/16/26.png
## Source : http://tile.stamen.com/toner-background/6/14/27.png
## Source : http://tile.stamen.com/toner-background/6/15/27.png
## Source : http://tile.stamen.com/toner-background/6/16/27.png

map_plot %>%
  ggmap(extent = "device") +
  geom_hurricane(data = storm_observation,
                 aes(x = longitude, y = latitude, 
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     color = wind_speed, fill = wind_speed)) + 
  scale_color_manual(name = "Wind speed (kts)", 
                     values = c("red", "orange", "yellow")) + 
  scale_fill_manual(name = "Wind speed (kts)", 
                    values = c("red", "orange", "yellow"))
```

![](build_geom_playground_files/figure-html/geomHurricane-1.png)<!-- -->

```
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "red"
##  $ fill       : chr "red"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 200
##  $ r_se       : int 200
##  $ r_nw       : int 100
##  $ r_sw       : int 150
##  $ PANEL      : int 1
##  $ group      : int 1
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 1
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.5 -89.5 -89.4 -89.3 -89.3 ...
##  $ y: num  32.8 32.8 32.8 32.8 32.8 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -85.8 -85.8 -85.8 -85.8 -85.8 ...
##  $ y: num  29.4 29.4 29.3 29.3 29.2 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.7 -89.7 -89.8 ...
##  $ y: num  27 27 27 27 27 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -91.5 -91.5 -91.5 -91.5 -91.5 ...
##  $ y: num  29.5 29.5 29.5 29.6 29.6 ...
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "orange"
##  $ fill       : chr "orange"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 120
##  $ r_se       : int 120
##  $ r_nw       : int 75
##  $ r_sw       : int 75
##  $ PANEL      : int 1
##  $ group      : int 2
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 1
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.6 -89.5 -89.5 -89.4 -89.4 ...
##  $ y: num  31.5 31.5 31.5 31.5 31.5 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -87.3 -87.3 -87.3 -87.3 -87.3 ...
##  $ y: num  29.5 29.4 29.4 29.4 29.3 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.7 -89.7 ...
##  $ y: num  28.2 28.2 28.2 28.2 28.2 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -91 -91 -91 -91 -91 ...
##  $ y: num  29.5 29.5 29.5 29.6 29.6 ...
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "yellow"
##  $ fill       : chr "yellow"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 90
##  $ r_se       : int 90
##  $ r_nw       : int 60
##  $ r_sw       : int 60
##  $ PANEL      : int 1
##  $ group      : int 3
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 1
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.6 -89.5 -89.5 -89.5 -89.4 ...
##  $ y: num  31 31 31 31 31 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -87.9 -87.9 -87.9 -87.9 -87.9 ...
##  $ y: num  29.5 29.5 29.4 29.4 29.4 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.7 -89.7 ...
##  $ y: num  28.5 28.5 28.5 28.5 28.5 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -90.7 -90.7 -90.7 -90.7 -90.7 ...
##  $ y: num  29.5 29.5 29.5 29.5 29.6 ...

map_plot %>%
  ggmap(extent = "device") +
  geom_hurricane(data = storm_observation,
                 aes(x = longitude, y = latitude, 
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     color = wind_speed, fill = wind_speed), scale_radii = 0.5) + 
  scale_color_manual(name = "Wind speed (kts)", 
                     values = c("red", "orange", "yellow")) + 
  scale_fill_manual(name = "Wind speed (kts)", 
                    values = c("red", "orange", "yellow"))
```

![](build_geom_playground_files/figure-html/geomHurricane-2.png)<!-- -->

```
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "red"
##  $ fill       : chr "red"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 200
##  $ r_se       : int 200
##  $ r_nw       : int 100
##  $ r_sw       : int 150
##  $ PANEL      : int 1
##  $ group      : int 1
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 0.5
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.6 -89.5 -89.5 -89.5 -89.4 ...
##  $ y: num  31.2 31.2 31.2 31.2 31.2 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -87.7 -87.7 -87.7 -87.7 -87.7 ...
##  $ y: num  29.5 29.5 29.4 29.4 29.4 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.7 -89.7 ...
##  $ y: num  28.2 28.2 28.2 28.2 28.2 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -90.6 -90.6 -90.6 -90.6 -90.6 ...
##  $ y: num  29.5 29.5 29.5 29.5 29.6 ...
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "orange"
##  $ fill       : chr "orange"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 120
##  $ r_se       : int 120
##  $ r_nw       : int 75
##  $ r_sw       : int 75
##  $ PANEL      : int 1
##  $ group      : int 2
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 0.5
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.5 -89.5 -89.5 ...
##  $ y: num  30.5 30.5 30.5 30.5 30.5 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -88.5 -88.5 -88.5 -88.5 -88.5 ...
##  $ y: num  29.5 29.5 29.5 29.4 29.4 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.6 -89.6 ...
##  $ y: num  28.9 28.9 28.9 28.9 28.9 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -90.3 -90.3 -90.3 -90.3 -90.3 ...
##  $ y: num  29.5 29.5 29.5 29.5 29.5 ...
## 'data.frame':	1 obs. of  14 variables:
##  $ colour     : chr "yellow"
##  $ fill       : chr "yellow"
##  $ x          : num -89.6
##  $ y          : num 29.5
##  $ r_ne       : int 90
##  $ r_se       : int 90
##  $ r_nw       : int 60
##  $ r_sw       : int 60
##  $ PANEL      : int 1
##  $ group      : int 3
##  $ size       : num 0.5
##  $ linetype   : num 1
##  $ alpha      : num 0.8
##  $ scale_radii: num 0.5
##  - attr(*, "vars")= chr "PANEL"
## 'data.frame':	91 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.5 -89.5 ...
##  $ y: num  30.3 30.3 30.3 30.2 30.2 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -88.7 -88.7 -88.7 -88.7 -88.7 ...
##  $ y: num  29.5 29.5 29.5 29.5 29.4 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -89.6 -89.6 -89.6 -89.6 -89.6 ...
##  $ y: num  29 29 29 29 29 ...
## 'data.frame':	92 obs. of  2 variables:
##  $ x: num  -90.2 -90.2 -90.2 -90.2 -90.2 ...
##  $ y: num  29.5 29.5 29.5 29.5 29.5 ...
```

