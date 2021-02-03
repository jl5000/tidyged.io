
#' Save a tidyged object to disk as a GEDCOM file
#' 
#' @details This function prepares the tidyged object and then writes it to the filepath.
#' Steps taken include escaping "@" signs (with another "@") and splitting long lines onto
#' separate lines.
#'
#' @param gedcom A tidyged object.
#' @param filepath The full filepath to write to.
#'
#' @return Nothing
#' @export
write_gedcom <- function(gedcom, filepath) {
  #expect_warning(write_gedcom(gedcom(), "my_family.txt") %>% file.remove("my_family.txt"))
  if(file.exists(filepath)) file.remove(filepath)
  
  con <- file(filepath, encoding = "UTF-8", open = "a")
  suppressWarnings(writeChar("\ufeff", con, eos = NULL))
  on.exit(close(con))
  
  if(tolower(stringr::str_sub(filepath, -4, -1)) != ".ged")
    warning("Output is not being saved as a GEDCOM file (*.ged)")
  
  gedcom %>%
    update_header_with_filename(filename = basename(filepath)) %>% 
    dplyr::mutate(value = dplyr::if_else(stringr::str_detect(value, xref_pattern()),
                                         value,
                                         stringr::str_replace_all(value, "@", "@@"))) %>% 
    split_gedcom_values(char_limit = .pkgenv$gedcom_phys_value_limit) %>% 
    dplyr::mutate(record = dplyr::if_else(dplyr::lag(record) == record, "", record)) %>% 
    dplyr::mutate(record = dplyr::if_else(record == "TR", "", record)) %>% 
    tidyr::replace_na(list(record = "")) %>% 
    dplyr::transmute(value = paste(level, record, tag, value)) %>% 
    dplyr::pull(value) %>% 
    stringr::str_replace_all("  ", " ") %>%
    writeLines(con)
  
}


#' Update GEDCOM header with filename
#'
#' @param gedcom A tidyged object.
#' @param filename The name of the file (with extension).
#'
#' @return An updated tidyged object with the updated filename.
update_header_with_filename <- function(gedcom, filename) {
  # expect_snapshot_value(gedcom(subm("Me")) %>% 
  #                         update_header_with_filename("my_file.ged") %>% 
  #                         remove_dates_for_tests(), "json2")
  # expect_snapshot_value(read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged")) %>% 
  #                         update_header_with_filename("my_file.ged") %>% 
  #                         remove_dates_for_tests(), "json2")
  if(nrow(dplyr::filter(gedcom, record == "HD", tag == "FILE")) == 0) {
    
    tibble::add_row(gedcom, 
                    tibble::tibble(level = 1, record = "HD", tag = "FILE", value = filename),
                    .before = find_insertion_point(gedcom, "HD", 0, "HEAD"))
    
  } else if(nrow(dplyr::filter(gedcom, record == "HD", tag == "FILE")) == 1) {
    
    dplyr::mutate(gedcom, 
                  value = dplyr::if_else(record == "HD" & tag == "FILE", filename, value))
  }
  
}


#' Convert the GEDCOM form to GEDCOM grammar
#' 
#' This function introduces CONC/CONT lines for line values that exceed the given number of characters.
#' This function only uses the CONC(atenation) tag for splitting values, and does
#' not use the CONT(inuation) tag. This is because it is easier to implement.
#'
#' @param gedcom A tidyged object.
#' @param char_limit Maximum string length of values.
#' @return A tidyged object in the GEDCOM grammar ready to export.
split_gedcom_values <- function(gedcom, char_limit) {
  # expect_snapshot_value(
  #                 gedcom(subm("Me")) %>% 
  #                   add_source(title = paste(rep("a", 4095), collapse = "")) %>%
  #                   remove_dates_for_tests() %>% 
  #                   split_gedcom_values(248), "json2")
  unique_delim <- "<>delimiter<>"
  header <- dplyr::filter(gedcom, record == "HD")
  
  gedcom %>% 
    dplyr::filter(record != "HD") %>% #header shouldn't contain CONT/CONC lines
    dplyr::mutate(split = nchar(value) > char_limit, #mark rows to split
                  row = dplyr::row_number()) %>% # mark unique rows
    dplyr::mutate(value = gsub(paste0("(.{", char_limit, "})"), #add delimiters where
                               paste0("\\1", unique_delim), #the splits should occur
                               value)) %>% 
    dplyr::mutate(value = gsub(paste0(unique_delim, "$"), "", value)) %>% #remove last delimiter
    tidyr::separate_rows(value, sep = unique_delim) %>% 
    dplyr::mutate(tag = dplyr::if_else(split & dplyr::lag(split) & row == dplyr::lag(row), "CONC", tag)) %>% # use CONC tags
    dplyr::mutate(level = dplyr::if_else(split & dplyr::lag(split) & row == dplyr::lag(row), level + 1, level)) %>% # increase levels
    dplyr::select(-split, -row) %>%  #remove temporary columns
    dplyr::bind_rows(header, .)
  
  
}

