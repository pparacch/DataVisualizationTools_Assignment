# Building Data Visualization Tools - Assignment
Pier Lorenzo Paracchini, 17.06.2017  



## Purpose

The purpose of this assignment is to use the knowledge acquired in the "Building Data Visualization Tools" course on a real challenge.

## The Problem

_"Hurricanes can have asymmetrical wind fields, with much higher winds on one side of a storm compared to the other. Hurricane wind radii report how far winds of a certain intensity (e.g., 34, 50, or 64 knots) extended from a hurricane’s center, with separate values given for the northeast, northwest, southeast, and southwest quadrants of the storm. The 34 knot radius in the northeast quadrant, for example, reports the furthest distance from the center of the storm of any location that experienced 34-knot winds in that quadrant. This wind radii data provide a clearer picture of the storm structure than the simpler measurements of a storm’s position and maximum winds. For example, if a storm was moving very quickly, the forward motion of the storm might have contributed significantly to wind speeds to the right of the storm’s direction of forward motion, and wind radii might be much larger for the northeast quadrant of the storm than the northwest quadrant."_

An example of the expected result can be found in the following image:

![The radii Visualization](imgs/expectedResult.png)


## Assignment

* Build a custom __geom__ for ggplot2 that can be used to add the expected result for a single storm observation to a map
* Use the custom __geom__ to map the expected result at one observation time for the Hurricane Ike which occured in Setptember 2008 (use an observatyion when the storm was near or over the United States).


## Step-By-Step Approach

* Get the data for all storms in the Atlantic basin from 1988-2015

* Clean the data
    * Add a column for storm_id that combines storm name and year (unique identifier). Note that the same storm name can be used in different years
    * Format the longitude to ensure that it is numeric and has negative values for locations in the Western emisphere
    * Format and combine columns describing date and time to create a single variable with the date and time for each observation
    * Convert the data to a long format with separate rows for each of the three wind speed (34 knots, 50 knots and 64 knots)

* Subset the specific hurricane under interest, __Hurricane Ike__ and get a single observation time for that hurricane

* Write the code for the custom __geom__ named _geam\_hurricane_ that plots the expected graph for a single hurricane observation in time

```
ggplot(data = katrina) +
  geom_hurricane(aes(x = longitude, y = latitude,
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     fill = wind_speed, color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow")) 
```

* Test to ensure that you can use the __geom__ to add a hurricane wind radii chart to a base map.

```
map_data <- get_map("Louisiana", zoom = 6, maptype = "toner-background")
base_map <- ggmap(map_data, extent = "device")

base_map +
  geom_hurricane(data = katrina, aes(x = longitude, y = latitude,
                                       r_ne = ne, r_se = se,
                                       r_nw = nw, r_sw = sw,
                                       fill = wind_speed,
                                       color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
```

### The Data

The data, these wind radii, are available for Atlantic basin tropical storms since 1988 through the Extended Best Tract dataset, available [here]( http://rammb.cira.colostate.edu/research/tropical_cyclones/tc_extended_best_track_dataset/). The __raw data__, provided for the assignment, can be found in the `ebtrk_atlc_1988_2015.txt` file in the `data` folder of the repository.

From the documentation on line ..

_'There is one line of data for each date and time period (00, 06, 12 or 18 UTC) of each storm (see sample line listed below). The information is given in the following order: Storm identification number, storm name, month, day, time, year, latitude (deg N), longitude (deg W), maximum wind speed (kt), minimum central pressure (hPa), radius of maximum wind speed (nm), eye diameter (nm), pressure of the outer closed isobar (hPa), radius of the outer closed isobar (nm), radii (nm) of 34 kt wind to the NE, SE, SW and NW of the storm center, radii (nm) of 50 kt wind to the NE, SE, SW and NW, radii (nm) of 64 kt wind to the NE, SE, SW, NW, and a storm type code.  This code is either * for a tropical system (tropical depression, tropical storm, or hurricane), W for tropical wave, D for a tropical disturbance, S for a subtropical storm, E for an extra-tropical storm, or L for remnant low. The last record is the distance to the nearest major landmass (km), where the island of Trinidad is the smallest area considered to be land. Negative values indicate the storm center is over land. '_

#### Reading the Data


```r
ext_tracks_widths <- c(7, 10, 2, 2, 3, 5, 5, 6, 4, 5, 4, 4, 5, 3, 4, 3, 3, 3,
                       4, 3, 3, 3, 4, 3, 3, 3, 2, 6, 1)
ext_tracks_colnames <- c("storm_id", "storm_name", "month", "day",
                          "hour", "year", "latitude", "longitude",
                          "max_wind", "min_pressure", "rad_max_wind",
                          "eye_diameter", "pressure_1", "pressure_2",
                          paste("radius_34", c("ne", "se", "sw", "nw"), sep = "_"),
                          paste("radius_50", c("ne", "se", "sw", "nw"), sep = "_"),
                          paste("radius_64", c("ne", "se", "sw", "nw"), sep = "_"),
                          "storm_type", "distance_to_land", "final")

ext_tracks <- read_fwf("./data/ebtrk_atlc_1988_2015.txt", 
                       fwf_widths(ext_tracks_widths, ext_tracks_colnames),
                       na = "-99")
```

__Data Info__

```r
str(ext_tracks)
## Classes 'tbl_df', 'tbl' and 'data.frame':	11824 obs. of  29 variables:
##  $ storm_id        : chr  "AL0188" "AL0188" "AL0188" "AL0188" ...
##  $ storm_name      : chr  "ALBERTO" "ALBERTO" "ALBERTO" "ALBERTO" ...
##  $ month           : chr  "08" "08" "08" "08" ...
##  $ day             : chr  "05" "06" "06" "06" ...
##  $ hour            : chr  "18" "00" "06" "12" ...
##  $ year            : int  1988 1988 1988 1988 1988 1988 1988 1988 1988 1988 ...
##  $ latitude        : num  32 32.8 34 35.2 37 38.7 40 41.5 43 45 ...
##  $ longitude       : num  77.5 76.2 75.2 74.6 73.5 72.4 70.8 69 67.5 65.5 ...
##  $ max_wind        : int  20 20 20 25 25 25 30 35 35 35 ...
##  $ min_pressure    : int  1015 1014 1013 1012 1011 1009 1006 1002 1002 1004 ...
##  $ rad_max_wind    : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ eye_diameter    : int  NA NA NA NA NA NA NA NA NA NA ...
##  $ pressure_1      : int  NA NA NA NA NA NA 1012 1012 1008 1008 ...
##  $ pressure_2      : int  NA NA NA NA NA NA 90 60 50 50 ...
##  $ radius_34_ne    : int  0 0 0 0 0 0 0 100 100 NA ...
##  $ radius_34_se    : int  0 0 0 0 0 0 0 100 100 NA ...
##  $ radius_34_sw    : int  0 0 0 0 0 0 0 50 50 NA ...
##  $ radius_34_nw    : int  0 0 0 0 0 0 0 50 50 NA ...
##  $ radius_50_ne    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_50_se    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_50_sw    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_50_nw    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_64_ne    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_64_se    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_64_sw    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ radius_64_nw    : int  0 0 0 0 0 0 0 0 0 0 ...
##  $ storm_type      : chr  "*" "*" "*" "*" ...
##  $ distance_to_land: int  218 213 149 126 197 193 150 118 144 22 ...
##  $ final           : chr  "." "." "." "." ...
##  - attr(*, "spec")=List of 2
##   ..$ cols   :List of 29
##   .. ..$ storm_id        : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ storm_name      : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ month           : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ day             : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ hour            : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ year            : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ latitude        : list()
##   .. .. ..- attr(*, "class")= chr  "collector_double" "collector"
##   .. ..$ longitude       : list()
##   .. .. ..- attr(*, "class")= chr  "collector_double" "collector"
##   .. ..$ max_wind        : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ min_pressure    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ rad_max_wind    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ eye_diameter    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ pressure_1      : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ pressure_2      : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_34_ne    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_34_se    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_34_sw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_34_nw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_50_ne    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_50_se    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_50_sw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_50_nw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_64_ne    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_64_se    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_64_sw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ radius_64_nw    : list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ storm_type      : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   .. ..$ distance_to_land: list()
##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
##   .. ..$ final           : list()
##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
##   ..$ default: list()
##   .. ..- attr(*, "class")= chr  "collector_guess" "collector"
##   ..- attr(*, "class")= chr "col_spec"
```

#### Cleaning the Data


```r
#Select only the relevant cols
#create a storm_id as the concatenation of the storm name and year
#create a data_time variable describing when the storm was happening
#format the longitute to ensure that has negative values for Western emisphere
#  longitude in raw data is measured in degree West

data_tmp <- ext_tracks %>%
  select(storm_id, storm_name, month, day, hour, year, latitude, longitude, starts_with("radius_")
         ) %>%
  rename(original_id = storm_id) %>%
  mutate(storm_id = paste(storm_name, year, sep = "-"),
         date = make_datetime(year = as.integer(year), 
                              month = as.integer(month), 
                              day = as.integer(day),
                              hour = as.integer(hour),
                              tz = "UTC"),
         longitude = -longitude)

data_p <- data_tmp  %>%
  select(storm_id, date, latitude, longitude, starts_with("radius_"))

ggplot(data = data_p, mapping = aes(y = latitude)) +
  geom_point(aes(x = longitude))
```

![](README_files/figure-html/cleaningData-1.png)<!-- -->

```r
#convert the data to a long format
##       storm_id                date latitude longitude wind_speed  ne  nw  se  sw
## 1 Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         34 200 100 200 150

data_p_34 <- data_p %>%
  select(storm_id, date, latitude, longitude,starts_with("radius_34_")) %>%
  rename(ne = radius_34_ne, se = radius_34_se, nw = radius_34_nw, sw = radius_34_sw) %>%
  mutate(wind_speed = 34)

data_p_50 <- data_p %>%
  select(storm_id, date, latitude, longitude,starts_with("radius_50_")) %>%
  rename(ne = radius_50_ne, se = radius_50_se, nw = radius_50_nw, sw = radius_50_sw) %>%
  mutate(wind_speed = 50)

data_p_64 <- data_p %>%
  select(storm_id, date, latitude, longitude,starts_with("radius_64_")) %>%
  rename(ne = radius_64_ne, se = radius_64_se, nw = radius_64_nw, sw = radius_64_sw) %>%
  mutate(wind_speed = 64)

data_p_long <- rbind(data_p_34, data_p_50, data_p_64) %>%
  arrange(storm_id, date, wind_speed)

data_p_long[data_p_long$storm_id == "KATRINA-2005" & data_p_long$date == ymd_hms("2005-08-29 12:00:00"),]
```

```
## # A tibble: 3 × 9
##       storm_id                date latitude longitude    ne    se    sw
##          <chr>              <dttm>    <dbl>     <dbl> <int> <int> <int>
## 1 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6   200   200   150
## 2 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6   120   120    75
## 3 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6    90    90    60
## # ... with 2 more variables: nw <int>, wind_speed <dbl>
```

### Experiment with the `geosphere` package

_'As a hint, notice that the wind radii geom essentially shows a polygon for each of the wind levels. One approach to writing this geom is therefore to write the hurricane stat / geom combination that uses the wind radii to calculate the points along the boundary of the polygon and then create a geom that inherits from a polygon geom.'_

__Point at distance and bearing__

As suggested the `destPoint` function can create polygons that can be used to map the wind extension in each quadrant. See the example below. 


```r
center <- c(-89.6, 29.5)
#p: longitude and latitude (degrees) of the starting point
#b: bearing in degress
#d: distance in meters
circle <- destPoint(center, b=0:365, d = 1000)

circle_ne <- destPoint(center, b=0:90, d=800)
circle_ne <- rbind(center, circle_ne)

circle_se <- destPoint(center, b=90:180, d=600)
circle_se <- rbind(center, circle_se)

circle_sw <- destPoint(center, b=180:270, d=400)
circle_sw <- rbind(center, circle_sw)

circle_nw <- destPoint(center, b=270:360, d=200)
circle_nw <- rbind(center, circle_nw)

plot(circle, type='l')
polygon(circle_ne, col = "red")
polygon(circle_se, col = "blue")
polygon(circle_sw, col = "gray")
polygon(circle_nw, col = "orange")
```

![](README_files/figure-html/experimentGeosphere-1.png)<!-- -->

