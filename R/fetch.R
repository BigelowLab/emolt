#' Fetch eMOLT ERRDAP CSV data
#' 
#' * `fetch_do` fetches eMOLT dissolved oxygen tables
#' * `fetch_temp` fetches eMOLT temperature tables
#' 
#' 
#' @export
#' @param x char, the URL of the data
#' @param filename char, the name of the file to write to
#' @param compress logical, if TRUE compres the result
#' @param overwrite logical, if the destination `filename` already exists, then 
#'   set this to TRUE to allow overwrites
#' @param timeout numeric, number of seconds before a timeout error
#' @param ... other arguments for `fetch_errdap_csv` and `download.file`
#' @return numeric, 0 for success and 1 for anything else
fetch_errdap_csv = function(x, 
                            filename = "emolt_download.csv",
                            compress = TRUE,
                            overwrite = TRUE,
                            timeout = 600,
                            ...){
  
  orig_timeout = getOption("timeout")
  
  tfile = tempfile()
  ok = 1
  
  opath = dirname(filename)
  if (!dir.exists(opath)) {
    ok = dir.create(opath, recursive = TRUE)
    if (!ok){
      stop("unable to create output path")
    }
  }
  
  on.exit({
    options(timeout = orig_timeout)
    # if all is well then cleanup
    if (ok == 0) {
      if (file.exists(tfile)) dump = unlink(tfile, force = TRUE)
    } else {
      if (file.exists(tfile)) warning("an error occured - leaving tempfile:", tfile) 
    }
  })
  
  
  r = httr::HEAD(x)
  if (httr::http_error(r)){
    warning("http issue for ", x)
    print(r)
    return(ok)
  }
  
  options(timeout = timeout)
  ok <- try(download.file(x, tfile, ...))
  if (inherits(ok, 'try-error')){
    print(ok)
    ok = 1
  }
  
  if (ok == 0){
    ok = file.copy(tfile, filename, overwrite = overwrite)
    if (ok && compress[1]){
      ok = system2("gzip", paste("-f", filename))
    } else {
      ok = 1
    }
  }
  
  ok
}


#' @export
#' @param dates POSIXct, a two element timestamp vector to select from
#' @rdname fetch_errdap_csv
fetch_do = function(dates = c(earliest_time(), current_time()),
                    filename = emolt_path("raw", "emolt_do.csv"),
                    ...){
  
  if (inherits(date, "POSIXt")) dates = format(dates, "%Y-%m-%dT%H:%M:%S")
  
  stub = "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT_LOWELL.csv"
  vars = "tow_id,time,latitude,longitude,temperature,DO,DO_percentage,water_detect_perc,sensor_type"
  #url = https://erddap.emolt.net/erddap/tabledap/eMOLT_RT_LOWELL.csv?tow_id,time,latitude,longitude,temperature,DO,DO_percentage,water_detect_perc,sensor_type&time>=2024-06-15T00:00:00Z&time<=2024-06-22T14:58:28Z

  x = sprintf("%s?%s&time>=%sZ&time<=%sZ", stub, vars, dates[1], dates[2])
  
  fetch_errdap_csv(x, filename = filename, ...)
}


#' @export
#' @param dates POSIXct, a two element timestamp vector to select from
#' @rdname fetch_errdap_csv
fetch_temp = function(dates = c(earliest_time(), current_time()),
                    filename = emolt_path("raw", "emolt_temp.csv"),
                    ...){
  
  if (inherits(date, "POSIXt")) dates = format(dates, "%Y-%m-%dT%H:%M:%S")
  
  stub = "https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csv"
  vars = "tow_id,segment_type,time,latitude,longitude,depth,temperature,sensor_type"
  #url = https://erddap.emolt.net/erddap/tabledap/eMOLT_RT.csv?tow_id,segment_type,time,latitude,longitude,depth,temperature,sensor_type&time>=2024-07-25T00:00:00Z&time<=2024-08-01T02:03:37Z
  
  x = sprintf("%s?%s&time>=%sZ&time<=%sZ", stub, vars, dates[1], dates[2])
  
  fetch_errdap_csv(x, filename = filename, ...)
}
