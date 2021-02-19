
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyged.io <img src='man/figures/logo.png' align="right" height="138" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/jl5000/tidyged.io/workflows/R-CMD-check/badge.svg)](https://github.com/jl5000/tidyged.io/actions)
[![](https://codecov.io/gh/jl5000/tidyged.io/branch/main/graph/badge.svg)](https://codecov.io/gh/jl5000/tidyged.io)
[![CodeFactor](https://www.codefactor.io/repository/github/jl5000/tidyged.io/badge)](https://www.codefactor.io/repository/github/jl5000/tidyged.io)
[![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

Import and export family tree GEDCOM files to and from tidy dataframes.

The package is part of the `gedcompendium` ecosystem of packages. This
ecosystem enables the handling of `tidyged` objects (tibble
representations of GEDCOM files), and the main package of this ecosystem
is [`tidyged`](https://jl5000.github.io/tidyged/).

<img src="man/figures/allhex.png" width="65%" style="display: block; margin: auto;" />

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jl5000/tidyged.io")
```

## Example

The easiest way to create a `tidyged` object is to import an existing
GEDCOM file. The package comes with some sample GEDCOM files, which can
be imported using the `read_gedcom()` function:

``` r
library(tidyged.io)
#> When importing existing GEDCOM files, you should ensure that they are error free.
#> This package assumes imported GEDCOM files are valid and very few validation checks are carried out.
#> Several GEDCOM validators are available, including an online validator at http://ged-inline.elasticbeanstalk.com/

read_gedcom(system.file("extdata", "555SAMPLE.GED", package = "tidyged.io")) %>% 
  print(n = Inf)
#> # A tibble: 97 x 4
#>    level record tag   value                                                     
#>    <dbl> <chr>  <chr> <chr>                                                     
#>  1     0 HD     HEAD  ""                                                        
#>  2     1 HD     GEDC  ""                                                        
#>  3     2 HD     VERS  "5.5.5"                                                   
#>  4     2 HD     FORM  "LINEAGE-LINKED"                                          
#>  5     3 HD     VERS  "5.5.5"                                                   
#>  6     1 HD     CHAR  "UTF-8"                                                   
#>  7     1 HD     SOUR  "GS"                                                      
#>  8     2 HD     NAME  "GEDCOM Specification"                                    
#>  9     2 HD     VERS  "5.5.5"                                                   
#> 10     2 HD     CORP  "gedcom.org"                                              
#> 11     3 HD     ADDR  ""                                                        
#> 12     4 HD     CITY  "LEIDEN"                                                  
#> 13     3 HD     WWW   "www.gedcom.org"                                          
#> 14     1 HD     DATE  "2 Oct 2019"                                              
#> 15     2 HD     TIME  "0:00:00"                                                 
#> 16     1 HD     FILE  "555Sample.ged"                                           
#> 17     1 HD     LANG  "English"                                                 
#> 18     1 HD     SUBM  "@U1@"                                                    
#> 19     0 @U1@   SUBM  ""                                                        
#> 20     1 @U1@   NAME  "Reldon Poulson"                                          
#> 21     1 @U1@   ADDR  ""                                                        
#> 22     2 @U1@   ADR1  "1900 43rd Street West"                                   
#> 23     2 @U1@   CITY  "Billings"                                                
#> 24     2 @U1@   STAE  "Montana"                                                 
#> 25     2 @U1@   POST  "68051"                                                   
#> 26     2 @U1@   CTRY  "United States of America"                                
#> 27     1 @U1@   PHON  "+1 (406) 555-1232"                                       
#> 28     0 @I1@   INDI  ""                                                        
#> 29     1 @I1@   NAME  "Robert Eugene /Williams/"                                
#> 30     2 @I1@   SURN  "Williams"                                                
#> 31     2 @I1@   GIVN  "Robert Eugene"                                           
#> 32     1 @I1@   SEX   "M"                                                       
#> 33     1 @I1@   BIRT  ""                                                        
#> 34     2 @I1@   DATE  "2 Oct 1822"                                              
#> 35     2 @I1@   PLAC  "Weston, Madison, Connecticut, United States of America"  
#> 36     2 @I1@   SOUR  "@S1@"                                                    
#> 37     3 @I1@   PAGE  "Sec. 2, p. 45"                                           
#> 38     1 @I1@   DEAT  ""                                                        
#> 39     2 @I1@   DATE  "14 Apr 1905"                                             
#> 40     2 @I1@   PLAC  "Stamford, Fairfield, Connecticut, United States of Ameri…
#> 41     1 @I1@   BURI  ""                                                        
#> 42     2 @I1@   PLAC  "Spring Hill Cemetery, Stamford, Fairfield, Connecticut, …
#> 43     1 @I1@   FAMS  "@F1@"                                                    
#> 44     1 @I1@   FAMS  "@F2@"                                                    
#> 45     1 @I1@   RESI  ""                                                        
#> 46     2 @I1@   DATE  "from 1900 to 1905"                                       
#> 47     0 @I2@   INDI  ""                                                        
#> 48     1 @I2@   NAME  "Mary Ann /Wilson/"                                       
#> 49     2 @I2@   SURN  "Wilson"                                                  
#> 50     2 @I2@   GIVN  "Mary Ann"                                                
#> 51     1 @I2@   SEX   "F"                                                       
#> 52     1 @I2@   BIRT  ""                                                        
#> 53     2 @I2@   DATE  "BEF 1828"                                                
#> 54     2 @I2@   PLAC  "Connecticut, United States of America"                   
#> 55     1 @I2@   FAMS  "@F1@"                                                    
#> 56     0 @I3@   INDI  ""                                                        
#> 57     1 @I3@   NAME  "Joe /Williams/"                                          
#> 58     2 @I3@   SURN  "Williams"                                                
#> 59     2 @I3@   GIVN  "Joe"                                                     
#> 60     1 @I3@   SEX   "M"                                                       
#> 61     1 @I3@   BIRT  ""                                                        
#> 62     2 @I3@   DATE  "11 Jun 1861"                                             
#> 63     2 @I3@   PLAC  "Idaho Falls, Bonneville, Idaho, United States of America"
#> 64     1 @I3@   FAMC  "@F1@"                                                    
#> 65     1 @I3@   FAMC  "@F2@"                                                    
#> 66     2 @I3@   PEDI  "adopted"                                                 
#> 67     1 @I3@   ADOP  ""                                                        
#> 68     2 @I3@   DATE  "16 Mar 1864"                                             
#> 69     0 @F1@   FAM   ""                                                        
#> 70     1 @F1@   HUSB  "@I1@"                                                    
#> 71     1 @F1@   WIFE  "@I2@"                                                    
#> 72     1 @F1@   CHIL  "@I3@"                                                    
#> 73     1 @F1@   MARR  ""                                                        
#> 74     2 @F1@   DATE  "Dec 1859"                                                
#> 75     2 @F1@   PLAC  "Rapid City, Pennington, South Dakota, United States of A…
#> 76     0 @F2@   FAM   ""                                                        
#> 77     1 @F2@   HUSB  "@I1@"                                                    
#> 78     1 @F2@   CHIL  "@I3@"                                                    
#> 79     0 @S1@   SOUR  ""                                                        
#> 80     1 @S1@   DATA  ""                                                        
#> 81     2 @S1@   EVEN  "BIRT, DEAT, MARR"                                        
#> 82     3 @S1@   DATE  "FROM Jan 1820 TO DEC 1825"                               
#> 83     3 @S1@   PLAC  "Madison, Connecticut, United States of America"          
#> 84     2 @S1@   AGNC  "Madison County Court"                                    
#> 85     1 @S1@   TITL  "Madison County Birth, Death, and Marriage Records"       
#> 86     1 @S1@   ABBR  "Madison BMD Records"                                     
#> 87     1 @S1@   REPO  "@R1@"                                                    
#> 88     2 @S1@   CALN  "13B-1234.01"                                             
#> 89     0 @R1@   REPO  ""                                                        
#> 90     1 @R1@   NAME  "Family History Library"                                  
#> 91     1 @R1@   ADDR  ""                                                        
#> 92     2 @R1@   ADR1  "35 N West Temple Street"                                 
#> 93     2 @R1@   CITY  "Salt Lake City"                                          
#> 94     2 @R1@   STAE  "Utah"                                                    
#> 95     2 @R1@   POST  "84150"                                                   
#> 96     2 @R1@   CTRY  "United States of America"                                
#> 97     0 TR     TRLR  ""
```

Many other GEDCOM readers will carry out extensive checks on every line
of a GEDCOM file ensuring all tags and values are legal, and the grammar
is used correctly. The `tidyged.io` package carries out very few checks,
relying on the user to check their files beforehand (as described when
loading the package). The few checks that are carried out include:

  - Ensuring the file has a valid Byte Order Mark which is consistent
    with that described in the file;
  - Ensuring no lines exceed the character limit;
  - Ensuring the header is correctly formed;
  - Ensuring there is only one header, trailer, and submitter record
    defined.

In the future, the `gedcompendium` ecosystem may include a dedicated
validation package, but this is currently a low priority.

If you want to export your file as a valid GEDCOM file, you can use the
`write_gedcom()` function.

## References

  - [The GEDCOM 5.5.5 Specification](https://www.gedcom.org/gedcom.html)
