# (PART\*) Getting started {-}

# Before we begin

If you've never used Shiny before, welcome! This chapter will help you install all the software you'll need to follow along with the book.

## Prerequisites {#prerequisites}

The first thing you'll need to do is install the software you'll need, if you don't have it already:

### R {-}

If you don't have R installed already, you may be reading the wrong book; you need to be proficient with R if you want to write Shiny apps. [_R for Data Science_](https://r4ds.had.co.nz/) is a great book for getting started with R.

You can download and install R by going to https://www.r-project.org and selecting one of the CRAN mirrors.

### RStudio {-}

RStudio is a free and open source *integrated development environment* (IDE) for R: a single program that includes a code editor, R console, graphics device, and many features for working productively with R.

While you can write and use Shiny apps with any R environment (including R GUI and [ESS](http://ess.r-project.org)), RStudio has some nice features specifically for authoring and debugging Shiny apps. We recommend giving it a try, but it's not required to be successful with Shiny or with this book.

You can download RStudio Desktop at:

https://www.rstudio.com/products/rstudio/download/

### Shiny {-}

Shiny is just an R package; you install it the same way you install any R package. From the R console:


```r
install.packages("shiny")
```

### Other R packages {-}

This book is heavy on code, and we will often use other R packages in our examples. You can install them all now by running this code:


```r
install.packages(c("magrittr", "lubridate", "readr", "dplyr", "ggplot2", "gt"))
```

TODO: Update this list before final draft; see [DESCRIPTION](https://github.com/jcheng5/shiny-book/blob/master/DESCRIPTION) for the definitive list.

## Cheat sheet

You may find it helpful to print a copy of our Shiny "cheat sheet", a reference card for many of the most important concepts and functions in Shiny. It won't all make sense to you yet, but as you work through the chapters you'll find it more and more helpful to refresh your memory.

https://www.rstudio.com/resources/cheatsheets/

## If you get stuck

Got a problem you can't figure out, or a question this book (and Google) can't answer? You can find help at our community site: https://community.rstudio.com/c/shiny.
