#' Load Data from Coursera into a Tibble
#'
#' This is a function that is copied from Coursera website
#' It first gives column widths as 'ext_tracks_widths' and names column names as 'ext_track_names'
#' Then reads the file 'ebtrk_atlc_1988_2015.txt' that is downloaded from Coursera
#' as variable 'ext_tracks'
#'
#' @param filename the file you have downloaded
#'
#' @importFrom readr read_fwf fwf_widths
#'
#' @return a tibble contains the filename with column names and column widths as described
#'
#' @examples load_data("ebtrk_atlc_1988_2015.txt")
#'
#' @export
load_data <-function(filename){

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

    ext_tracks <- read_fwf(filename,
                           fwf_widths(ext_tracks_widths, ext_tracks_colnames),
                           na = "-99")

}

#' Tidy the tibbel into the form as Required
#'
#' This is a function that clean the tibble into the form as Coursera requires
#'
#' @param data the tibble you want to tidy
#'
#' @importFrom dplyr mutate_ select_
#' @importFrom stringr str_c str_to_title
#' @importFrom tidyr gather spread
#'
#' @return a tibble with nine cloumns as Coursera website requires
#'
#' @example tidy_data(data)
#'
#' @export
tidy_data <-function(data){
data %>%
    # Make the storm_id and date
    dplyr::mutate_(storm_id = ~stringr::str_c(stringr::str_to_title(storm_name), year, sep = '-'),
                   date = ~stringr::str_c(year, '-', month, '-', day, ' ', hour, ':', '00', ':', '00'),
                   longitude = ~-longitude
    ) %>%
    # Select only the relevant columns
    dplyr::select_(.dots = c('storm_id', 'date', 'longitude', 'latitude',
                             'radius_34_ne', 'radius_34_se', 'radius_34_sw', 'radius_34_nw',
                             'radius_50_ne', 'radius_50_se', 'radius_50_sw', 'radius_50_nw',
                             'radius_64_ne', 'radius_64_se', 'radius_64_sw', 'radius_64_nw')
    ) %>%

    tidyr::gather(variable, value, -storm_id, -date,-latitude, -longitude, -storm_id, -date) %>%
        mutate_(wind_speed = ~str_extract(variable, "(34|50|64)"),
        variable = ~str_extract(variable, "(ne|nw|se|sw)")) %>%
        tidyr::spread(variable, value) %>%
        select_(.dots = c('storm_id', 'date', 'latitude', 'longitude', 'wind_speed', 'ne', 'nw', 'se', 'sw'))
}

#' Filter the data by Hurricane Name and Observation Time
#'
#' This function can filter the data by hurricane name and time
#'
#' @param data the tibble you want to filer information
#' @param hurricane_name the name of hurricane you are interested in
#' @param time the time that hurricane is observed
#'
#' @importFrom dplyr filter_
#'
#' @return a tibble contains only the information of Hurricane name and observation time
#'
#' @examples filtered_data(wind, "Alberto-1988", "1988-08-05 18:00:00")
#'
#' @export
filtered_data <- function(data, hurricane_name, observation_time){
    data <- filter_(data, ~storm_id == hurricane_name & date == observation_time)
}

#' Create 'geom_hurricane_proto' class
#'
#' We use ggproto function to create a new geom class 'geom_hurricane_proto'
#'
#' @param required_aes required aesthetic arguments for the geom_hurricane supplied in character vector
#' @param default_aes default values for aesthetic arguments
#' @param draw_key the function to draw the legend with the associated geom
#' @param draw_group where the bulk of this geom is constructed
#'
#' @importFrom ggplot2 ggproto
#' @importFrom base data.frame as.character
#' @importFrom dplyr bind_rows rename_ mutate_
#' @importFrom grid polygonGrob gpar
#'
#' @return a geom class that can be used to add the hurricane wind radii chart for a single storm observation to a map
#'
#' @examples geom_hurricane_proto
#'
#' @export
library(grid)
geom_hurricane_proto <- ggplot2::ggproto("geom_hurricane_proto", Geom,
                                         required_aes = c("x", "y",
                                                          "r_ne", "r_se", "r_nw", "r_sw"
                                         ),
                                         default_aes = aes(fill = 1, colour = 1, alpha = 1, scale_radii = 1),
                                         draw_key = draw_key_polygon,
                                         draw_group = function(data, panel_scales, coord) {

                                             ## Transform the data first
                                             coords <- coord$transform(data, panel_scales)

                                             # Convert nautical miles to meters and multiply by scale factor
                                             data <- data %>% mutate_(r_ne = ~r_ne*1609*scale_radii,
                                                                      r_se = ~r_se*1609*scale_radii,
                                                                      r_sw = ~r_sw*1609*scale_radii,
                                                                      r_nw = ~r_nw*1609*scale_radii
                                             )


                                             # Loop over the data and create the points for each quandrant
                                             for (i in 1:nrow(data)) {

                                                 # Create the Northwest Quandrant
                                                 df_nw <- base::data.frame(colour = data[i,]$colour,
                                                                           fill = data[i,]$fill,
                                                                           geosphere::destPoint(p = c(data[i,]$x, data[i,]$y),
                                                                                                b = 270:360,
                                                                                                d = data[i,]$r_nw),
                                                                           group = data[i,]$group,
                                                                           PANEL = data[i,]$PANEL,
                                                                           alpha = data[i,]$alpha
                                                 )

                                                 # Create the Northeast Quandrant
                                                 df_ne <- base::data.frame(colour = data[i,]$colour,
                                                                           fill = data[i,]$fill,
                                                                           geosphere::destPoint(p = c(data[i,]$x, data[i,]$y),
                                                                                                b = 1:90,
                                                                                                d = data[i,]$r_ne),
                                                                           group = data[i,]$group,
                                                                           PANEL = data[i,]$PANEL,
                                                                           alpha = data[i,]$alpha
                                                 )

                                                 # Create the Southeast Quandrant
                                                 df_se <- base::data.frame(colour = data[i,]$colour,
                                                                           fill = data[i,]$fill,
                                                                           geosphere::destPoint(p = c(data[i,]$x, data[i,]$y),
                                                                                                b = 90:180,
                                                                                                d = data[i,]$r_se),
                                                                           group = data[i,]$group,
                                                                           PANEL = data[i,]$PANEL,
                                                                           alpha = data[i,]$alpha
                                                 )

                                                 # Create the Southwest Quandrant
                                                 df_sw <- data.frame(colour = data[i,]$colour,
                                                                     fill = data[i,]$fill,
                                                                     geosphere::destPoint(p = c(data[i,]$x, data[i,]$y),
                                                                                          b = 180:270,
                                                                                          d = data[i,]$r_sw),
                                                                     group = data[i,]$group,
                                                                     PANEL = data[i,]$PANEL,
                                                                     alpha = data[i,]$alpha
                                                 )

                                                 # bind all the rows into a dataframe
                                                 df_points <- dplyr::bind_rows(list(df_nw, df_ne, df_se, df_sw))

                                             }


                                             # Rename columns x and y from lon and lat repectively
                                             df_points <- df_points %>% dplyr::rename_('x' = 'lon',
                                                                                       'y' = 'lat'
                                             )

                                             # Convert to character
                                             df_points$colour <- base::as.character(df_points$colour)
                                             df_points$fill <- base::as.character(df_points$fill)


                                             ## transform data points
                                             coords_df <- coord$transform(df_points, panel_scales)

                                             ## Construct grid polygon
                                             grid::polygonGrob(
                                                 x= coords_df$x,
                                                 y = coords_df$y,
                                                 gp = grid::gpar(col = coords_df$colour, fill = coords_df$fill, alpha = coords_df$alpha)
                                             )

                                         }

)

#' Create function that will build a layer based on specified geom
#'
#' With the created geom class, we create the actually function that will build a layer based on your geom specification.
#'
#' @param mapping
#' @param data
#' @param stat
#' @param position
#' @param na.rm
#' @param show.legend
#' @param inherit.aes
#'
#' @importFrom ggplot2 layer
#'
#' @examples geom_hurricane()
#'
#' @retrun a function that will build a layer based on geom_hurricane_proto geom.
#'
#' @export
geom_hurricane <- function(mapping = NULL, data = NULL, stat = 'identity',
                           position = 'identity', na.rm = FALSE,
                           show.legend = NA, inherit.aes = TRUE, ...) {
    ggplot2::layer(
        geom = geom_hurricane_proto, mapping = mapping,
        data = data, stat = stat, position = position,
        show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)

    )
}

## Read data and filter Hurricane Katrina at Observation time 2005-08-25 18:00:00
Ike_2008 <- load_data('ebtrk_atlc_1988_2015.txt') %>%
    tidy_data() %>%
    filtered_data(hurricane = 'Ike-2008', observation = '2008-09-13 12:00:00')

## Plot a wind radii for a single hurricane observation
ggplot(data = Ike_2008) +
    geom_hurricane(aes(x = longitude, y = latitude,
                       r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                       fill = wind_speed, color = wind_speed)) +
    scale_color_manual(name = "Wind speed (kts)",
                       values = c("red", "orange", "yellow")) +
    scale_fill_manual(name = "Wind speed (kts)",
                      values = c("red", "orange", "yellow"))

## Test to ensure that you can use this geom to add a hurricane wind radii chart to a base map
library(ggmap)
get_map("Louisiana", zoom = 6, maptype = "toner-background") %>%
    ggmap(extent = "device") +
    geom_hurricane(data = Ike_2008,
                   aes(x = longitude, y = latitude,
                       r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                       fill = wind_speed, color = wind_speed)) +
    scale_color_manual(name = "Wind speed (kts)",
                       values = c("red", "orange", "yellow")) +
    scale_fill_manual(name = "Wind speed (kts)",
                      values = c("red", "orange", "yellow"))
