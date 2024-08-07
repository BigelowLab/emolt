#' Retrieve useful times in UTC
#' 
#' * `earliest_time` retrieves a reasonable early timestamp
#' * `current_time` retrieves the current timestamp
#' 
#' @export
#' @return POSIXct time
earliest_time = function(){
  as.POSIXct("2018-01-01", tz = "UTC")
}

#' @rdname earliest_time
current_time = function(){
  Sys.time() |>
    format("%Y-%m-%dT%H:%M:%S") |>
    as.POSIXct(tz = "UTC")
}

#' Convert raw data to sf or vice versa
#' 
#' @export
#' @param x tibble of raw data or an sf object
#' @return sf table or a tibble
raw_as_sf = function(x){
  sf::st_as_sf(x, coords = c("longitude", "latitude"), crs = 4326)
}

#' @rdname raw_as_sf
sf_as_raw = function(x){
  xy = sf::st_coordinates(x) |>
    dplyr::as_tibble() |>
    rlang::set_names(x)
  sf::st_drop_geometry(x) |>
    dplyr::bind_cols(xy)
}
