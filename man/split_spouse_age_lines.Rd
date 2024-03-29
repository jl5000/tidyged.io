% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/export.R
\name{split_spouse_age_lines}
\alias{split_spouse_age_lines}
\title{Split husband/wife age rows into two rows}
\usage{
split_spouse_age_lines(gedcom)
}
\arguments{
\item{gedcom}{A tidyged object.}
}
\value{
A tidyged object with husband/wife age rows split accordingly.
}
\description{
This function splits the HUSB_AGE and WIFE_AGE tags into two rows in line with the GEDCOM
specification.
}
