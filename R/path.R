#' Retrieve the eMOLT root path
#' 
#' @export
#' @param filename char, the name of the file that has the eMOLT data path
#' @return char the root path
emolt_root = function(filename = "~/.emolt"){
  readLines(filename)[1]
}

#' Build an emolt path
#' 
#' @export
#' @param ... components of a path to build
#' @param root char, the root filepath
#' @return a fully formed file patha ala file.path
emolt_path = function(..., root = emolt_root()){
  file.path(root, ...)
}


#' Test if a data path config file exists
#' 
#' @export
#' @param filename char, the name of the config files
#' @return logical TRUE if the config file exists
has_data_path <- function(filename = "~/.emolt"){
  file.exists(filename[1])
}

#' Write the path configuration file
#' 
#' @export
#' @param path char, the path to the data - like '/mnt/ecocast/coredata/emolt'
#' @param filename char, the name of the config files
set_data_path <- function(path, filename = "~/.emolt"){
  cat(path[1], sep = "\n", file = filename[1])
}
