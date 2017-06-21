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

The data, these wind radii, are available for Atlantic basin tropical storms since 1988 through the Extended Best Tract dataset, available [here]( http://rammb.cira.colostate.edu/research/tropical_cyclones/tc_extended_best_track_dataset/). A copy of the __raw data__, provided for the assignment, can be found in the `ebtrk_atlc_1988_2015.txt` file in the `data` folder of the repository.

From the documentation on line ..

_'There is one line of data for each date and time period (00, 06, 12 or 18 UTC) of each storm (see sample line listed below). The information is given in the following order: Storm identification number, storm name, month, day, time, year, latitude (deg N), longitude (deg W), maximum wind speed (kt), minimum central pressure (hPa), radius of maximum wind speed (nm), eye diameter (nm), pressure of the outer closed isobar (hPa), radius of the outer closed isobar (nm), radii (nm) of 34 kt wind to the NE, SE, SW and NW of the storm center, radii (nm) of 50 kt wind to the NE, SE, SW and NW, radii (nm) of 64 kt wind to the NE, SE, SW, NW, and a storm type code.  This code is either * for a tropical system (tropical depression, tropical storm, or hurricane), W for tropical wave, D for a tropical disturbance, S for a subtropical storm, E for an extra-tropical storm, or L for remnant low. The last record is the distance to the nearest major landmass (km), where the island of Trinidad is the smallest area considered to be land. Negative values indicate the storm center is over land. '_

The __details__, and __relevant code__, around the __cleaning of the data__ can be found in __[here](./cleaning_the_data.md)__.

A storm observation, e.g. KATRINA hurricane on 2005-08-09 at 12:00:00, in the cleaned data contains the following information

```
##       storm_id                date latitude longitude  ne  se  sw  nw  wind_speed
## 1 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6 200 200 150 100          34
## 2 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6 120 120  75  75          50
## 3 KATRINA-2005 2005-08-29 12:00:00     29.5     -89.6  90  90  60  60          64
```


