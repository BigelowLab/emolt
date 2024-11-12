#' Read an ERRDAP data
#' 
#' * `read_erddap_raw` reads the downloaded data
#' * `read_erddap_sf` reads the sf formatted data
#' 
#' @export
#' @param what char, one of "do" or "temp"
#' @param form char, one of "raw" or "sf"
#' @return tibble or sf table
read_emolt = function(what = c("do", "temp")[2],
                      form = c("raw", "sf")[2]){
  filename = paste0("emolt_", what[1], ".csv.gz")
  filename = emolt_path("raw", filename)
  
  x = read_erddap_raw(filename)
  if (tolower(form[1]) == "sf"){
    u = attr(x, "emolt_units")
    x = sf::st_as_sf(x, coords = c("longitude", "latitude"), crs = 4326)
    ix = grepl("degrees_north", u, fixed = TRUE) |
         grepl("degrees_south", u, fixed = TRUE)
    attr(x, "emolt_units") <- u[!ix]
  }
 x 
}

#' @export
#' @rdname read_emolt
read_erddap_raw = function(filename){
  
  hdr = readLines(filename, n = 2) |>
    strsplit(",", fixed = TRUE)
  n1 = length(hdr[[1]])
  n2 = length(hdr[[2]])
  if (n2 < n1) hdr[[2]] <- c(hdr[[2]], rep("", n1-n2))
  
  if ("DO" %in% hdr[[1]]) {
    col_types = readr::cols(
      tow_id = readr::col_character(),
      time = readr::col_datetime(format = ""),
      latitude = readr::col_double(),
      longitude = readr::col_double(),
      temperature = readr::col_double(),
      DO = readr::col_double(),
      DO_percentage = readr::col_double(),
      water_detect_perc = readr::col_double(),
      sensor_type = readr::col_character())
  } else if ("temperature" %in% hdr[[1]]){
    col_types = readr::cols(
      tow_id = readr::col_character(),
      segment_type = readr::col_character(),
      time = readr::col_datetime(format = ""),
      latitude = readr::col_double(),
      longitude = readr::col_double(),
      depth = readr::col_double(),
      temperature = readr::col_double(),
      sensor_type = readr::col_character()
    )
  } else {
    col_types = NULL
  }
  
  x = readr::read_csv(filename,
                      skip = 2,
                      col_types = col_types,
                      col_names = hdr[[1]],
                      show_col_types = FALSE)
  attr(x, "emolt_units") <- hdr[[2]]
  x
}

