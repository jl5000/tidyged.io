# Stop the NOTES from R CMD CHECK when creating columns with mutate()
if(getRversion() >= "2.15.1")  
  utils::globalVariables(c("level", "record", "tag", "value", "."))


.pkgenv <- new.env(parent=emptyenv())

.pkgenv$gedcom_phys_value_limit <- 248
.pkgenv$gedcom_line_length_limit <- 255

.pkgenv$BOM_UTF8 <- c("ef", "bb", "bf")
.pkgenv$BOM_UTF16_LE <- c("ff", "fe")
.pkgenv$BOM_UTF16_BE <- c("fe", "ff")

