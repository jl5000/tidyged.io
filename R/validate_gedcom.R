
#' Validate a GEDCOM file
#' 
#' Conduct some simple (but not exhaustive) checks on a GEDCOM file. This function is called when importing a 
#' GEDCOM file. The checks contained within are relatively simple since there are a wealth of GEDCOM validators 
#' already available.
#'
#' @param gedcom A tidyged object
#' @param expected_encoding A character string given the expected file encoding. One of
#' "UTF-8", "UTF-16LE", or "UTF-16BE".
#'
#' @return Nothing
validate_gedcom <- function(gedcom, expected_encoding) {
  
  validate_header(gedcom, expected_encoding)

  if(sum(gedcom$level == 0 & gedcom$tag == "HEAD") != 1) stop("GEDCOM has no single header")
  if(sum(gedcom$level == 0 & gedcom$tag == "TRLR") != 1) stop("GEDCOM has no single trailer")
  if(sum(gedcom$level == 0 & gedcom$tag == "SUBM")  > 1) stop("File has more than one submitter record")
  if(sum(gedcom$record == "HD" & gedcom$tag == "SOUR") != 1) warning("GEDCOM header has no single system ID")
  if(sum(gedcom$record == "HD" & gedcom$tag == "GEDC") != 1) warning("GEDCOM header is lacking file information")
  
  unsupp_calendars <- c("HEBREW","FRENCH R","JULIAN","UNKNOWN")
  unsupp_calendars <- paste0("^@#D", unsupp_calendars, "@")
  
  dates <- dplyr::filter(gedcom, tag == "DATE")$value
  if(any(stringr::str_detect(dates, paste(unsupp_calendars, collapse = "|"))))
     stop("Non-Gregorian calendar dates detected. The gedcompendium does not support non-Gregorian calendars")
  
}


#' Validate a GEDCOM header
#' 
#' Check the GEDCOM header is properly formed.
#' 
#' @param gedcom A tidyged object
#' @param expected_encoding A character string given the expected file encoding. One of
#' "UTF-8", "UTF-16LE", or "UTF-16BE".
#'
#' @return Nothing
validate_header <- function(gedcom, expected_encoding) {
  
  if(!isTRUE(all.equal(gedcom$level[1:6], c(0,1,2,2,3,1))) |
     !isTRUE(all.equal(gedcom$tag[1:6], c("HEAD","GEDC","VERS","FORM","VERS","CHAR"))) |
     !isTRUE(all.equal(gedcom$value[1:5], c("", "", "5.5.5", "LINEAGE-LINKED", "5.5.5"))))
    stop("Malformed header")
  
  char <- dplyr::filter(gedcom, record == "HD", tag == "CHAR")$value
  
  if(expected_encoding == "UTF-8") {
    if(char != "UTF-8") stop("Character encodings do not match")
  } else if(expected_encoding %in% c("UTF-16BE", "UTF-16LE")) {
    if(char != "UNICODE") stop("Character encodings do not match")
  } else {
    stop("Character encoding not recognised")
  }
    
  
}

