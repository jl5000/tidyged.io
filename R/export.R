
#' Save a tidyged object to disk as a GEDCOM file
#' 
#' @details This function prepares the tidyged object and then writes it to the filepath.
#' Steps taken include escaping "@" signs (with another "@") and splitting long lines onto
#' separate lines.
#'
#' @param gedcom A tidyged object.
#' @param filepath The full filepath to write to.
#'
#' @return Nothing.
#' @export
#' @tests
#' expect_error(write_gedcom(read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged.io")), 
#'                             "my_family.txt"))
#'  file.remove("my_family.txt")
#' expect_identical(
#'   read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged.io")),
#'   read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged.io")) |> 
#'     write_gedcom("555Sample.ged") |> 
#'     read_gedcom()
#' )
#' file.remove("555Sample.ged")
write_gedcom <- function(gedcom, 
                         filepath = file.choose()) {
  
  if(tolower(stringr::str_sub(filepath, -4, -1)) != ".ged")
    stop("Output is not being saved as a GEDCOM file (*.ged)")
  
  if(file.exists(filepath)) file.remove(filepath)
  
  con <- file(filepath, encoding = "UTF-8", open = "wb")
  suppressWarnings(writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con))
  close(con)
  
  con <- file(filepath, encoding = "UTF-8", open = "a")
  on.exit(close(con))
  
  gedcom |>
    update_header_with_filename(filename = basename(filepath)) |> 
    dplyr::mutate(value = dplyr::if_else(stringr::str_detect(value, tidyged.internals::reg_xref(TRUE)),
                                         value,
                                         stringr::str_replace_all(value, "@", "@@"))) |> 
    split_gedcom_values(char_limit = .pkgenv$gedcom_phys_value_limit) |> 
    split_spouse_age_lines() |> 
    dplyr::mutate(record = dplyr::if_else(dplyr::lag(record) == record, "", record)) |> 
    dplyr::mutate(record = dplyr::if_else(record == "TR", "", record)) |> 
    tidyr::replace_na(list(record = "")) |> #First line
    dplyr::transmute(value = paste(level, record, tag, value)) |> 
    dplyr::pull(value) |> 
    stringr::str_replace("(^\\d)  ", "\\1 ") |> #remove double spaces between level and tag
    stringr::str_replace("(^\\d (@.+@)? ?\\w{3,5}) $", "\\1") |> #remove spaces after tag
    writeLines(con)
  
  invisible(filepath)
  
}


#' Update GEDCOM header with filename
#' 
#' @details 
#' If the file does not already have a filename, then one is not added.
#'
#' @param gedcom A tidyged object.
#' @param filename The name of the file (with extension).
#'
#' @return An updated tidyged object with the updated filename.
#' @tests
#' expect_snapshot_value(read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged.io")) |> 
#'                         update_header_with_filename("my_file.ged"), "json2")
#' expect_snapshot_value(read_gedcom(system.file("extdata", "MINIMAL555.GED", package = "tidyged.io")) |> 
#'                         update_header_with_filename("my_file2.ged"), "json2")
update_header_with_filename <- function(gedcom, filename) {
 
  if(nrow(dplyr::filter(gedcom, level == 1, record == "HD", tag == "FILE")) > 0) {

    gedcom <- dplyr::mutate(gedcom, 
                  value = dplyr::if_else(record == "HD" & tag == "FILE" & level == 1, filename, value))
  }
  gedcom
}


#' Convert the GEDCOM form to GEDCOM grammar
#' 
#' This function introduces CONC/CONT lines for line values that exceed the given number of characters and
#' for lines containing line breaks.
#'
#' @param gedcom A tidyged object.
#' @param char_limit Maximum string length of values.
#' 
#' @return A tidyged object in the GEDCOM grammar ready to export.
split_gedcom_values <- function(gedcom, char_limit) {

  header <- dplyr::slice(gedcom, 1:6)
  
  ged_no_head <- gedcom |> 
    dplyr::slice(-(1:6)) |> #header shouldn't contain CONT/CONC lines
    create_cont_lines() |> 
    create_conc_lines(char_limit)
  
  dplyr::bind_rows(header, ged_no_head)
  
}

#' Split husband/wife age rows into two rows
#' 
#' This function splits the HUSB_AGE and WIFE_AGE tags into two rows in line with the GEDCOM
#' specification.
#' 
#' @param gedcom A tidyged object.
#'
#' @return A tidyged object with husband/wife age rows split accordingly.
split_spouse_age_lines <- function(gedcom){
  
  unique_delim <- "<>delimiter<>"
  spouse_rows <- which(gedcom$tag %in% c("HUSB_AGE","WIFE_AGE"))
  
  if(length(spouse_rows) == 0) return(gedcom)
  
  gedcom$tag[spouse_rows] <- stringr::str_remove(gedcom$tag[spouse_rows], "_AGE")
  gedcom$record[spouse_rows] <- paste(gedcom$record[spouse_rows], gedcom$record[spouse_rows],
                                      sep = unique_delim)
  gedcom$level[spouse_rows] <- paste(gedcom$level[spouse_rows], gedcom$level[spouse_rows] + 1,
                                      sep = unique_delim)
  gedcom$tag[spouse_rows] <- paste(gedcom$tag[spouse_rows], "AGE", sep = unique_delim)
  gedcom$value[spouse_rows] <- paste("", gedcom$value[spouse_rows], sep = unique_delim)
  gedcom |> 
    tidyr::separate_rows(dplyr::everything(), sep = unique_delim) |> 
    dplyr::mutate(level = as.integer(level))
}

#' Create CONTinuation lines
#'
#' @param lines Lines of a tidyged object.
#'
#' @return The same lines of the tidyged object, potentially with additional continuation lines.
create_cont_lines <- function(lines) {
  
  lines |> 
    dplyr::mutate(value = stringr::str_replace_all(value, "\n\r|\r\n", "\n"),
                  value = stringr::str_replace_all(value, "\r", "\n")) |>
    dplyr::mutate(split = stringr::str_detect(value, "\n"), #mark rows to split
                  row = dplyr::row_number()) |> # mark unique rows
    tidyr::separate_rows(value, sep = "\n") |> 
    dplyr::mutate(tag = dplyr::if_else(split & dplyr::lag(split) & row == dplyr::lag(row), "CONT", tag)) |> 
    dplyr::mutate(level = dplyr::if_else(split & dplyr::lag(split) & row == dplyr::lag(row), level + 1, level)) |> 
    dplyr::select(-split, -row)  #remove temporary columns
  
}

#' Create CONCatenation lines
#'
#' @param lines Lines of a tidyged object.
#' @param char_limit Character limit of line values.
#'
#' @return The same lines of the tidyged object, potentially with additional concatenation lines.
create_conc_lines <- function(lines, char_limit) {
  
  # A suitably unique string
  unique_delim <- "<>delimiter<>"
  
  lines |> 
    dplyr::mutate(split = nchar(value) > char_limit, #mark rows to split
                  row = dplyr::row_number()) |> # mark unique rows
    dplyr::mutate(value = gsub(paste0("(.{", char_limit, "})"), #add delimiters where
                               paste0("\\1", unique_delim), #the splits should occur
                               value)) |> 
    dplyr::mutate(value = gsub(paste0(unique_delim, "$"), "", value)) |> #remove last delimiter
    tidyr::separate_rows(value, sep = unique_delim) |> 
    dplyr::mutate(tag = dplyr::if_else(split & dplyr::lag(split) & row == dplyr::lag(row), "CONC", tag)) |> # use CONC tags
    dplyr::mutate(level = dplyr::if_else(split & 
                                           dplyr::lag(split) & 
                                           row == dplyr::lag(row) & 
                                           !dplyr::lag(tag) %in% c("CONT", "CONC"), 
                                         level + 1, level)) |> # increase levels (not if previous is cont/conc)
    dplyr::select(-split, -row)  #remove temporary columns
  
}



