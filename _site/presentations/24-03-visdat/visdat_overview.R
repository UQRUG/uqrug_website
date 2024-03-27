---
title: "visdat Overview"
output: html_document
date: "2024-03-26"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

#install.packages("visdat")
library(visdat)
library(tidyverse)
```

## visdat

visdat is a package which allows you to get a quick visual glance at the variable classes of a dataframe to identify problems or unexpected features.\
Are you just trying to get a vibe for the data?\
Are there unexpected NAs, strangely large values, or strings out of place?

visdat can help check these things before you start trying to clean and wrangle your messy data

## An example

Let's look at the airquality dataset

```{r airquality}
airquality <- airquality

head(airquality)
```

## vis_dat()

We can use vis_dat() to get an overview of the classes of data and any NAs present

```{r vis_dat()}
vis_dat(airquality)
```

We can also facet

```{r facet}
vis_dat(airquality, facet = Month)
```

## vis_miss()

vis_miss() is similar to vis_dat() but it will show you the percentage of missing data

```{r vis_miss()}
vis_miss(airquality)
```

There isn't a strong use for vis_miss() over vis_dat() but it will give you the percentage of NAs in your dataset, which is useful if there are very few NAs

```{r miss vs dat}
test_miss_df <- data.frame(x1 = 1:10000,
                           x2 = rep("A", 10000),
                           x3 = c(rep(1L, 9999), NA))

vis_dat(test_miss_df)
vis_miss(test_miss_df)
```

## vis_compare()

vis_compare() will allow you to compare two dataframes (of the same length!) to highlight their differences and similarities

```{r vis_compare()}
set.seed(2019-04-03-1105)
chickwts_diff <- chickwts
chickwts_diff[sample(1:nrow(chickwts), 30),sample(1:ncol(chickwts), 2)] <- NA

vis_compare(chickwts_diff, chickwts)
```

## vis_expect() - very useful

I think vis_expect() is a very useful function, as it can allow you to set thresholds for checking data using binary operators. What percentage of values are over 25? Are there strange outliers?

```{r vis_expect()}
vis_expect(airquality, ~.x >= 25)

```

Perhaps there are strings that shouldn't be strings. You could simply clean this with a bad_strings vector, but we can also have a look at where those issues lie more broadly, and potentially find patterns. If you clean your data without knowing the cause, you could end up hiding problems, rather than resolving them.

```{r na checking}
common_nas <- c(
  "NA",
  "N A",
  "N/A",
  "na",
  "n a",
  "n/a"
)

dat_ms <- tibble::tribble(~x,  ~y,    ~z,
                          "1",   "A",   -100,
                          "3",   "N/A", -99,
                          "NA",  NA,    -98,
                          "N A", "E",   -101,
                          "na", "F",   -1)

vis_expect(dat_ms, ~.x %in% common_nas)
```

## vis_cor()

This will show you correlations in your data - not super exciting

```{r vis_cor()}
vis_cor(airquality)
```

## vis_value()

vis_value() provides a nice overview of the relative differences in the columns of your data, allowing you to potentially find outliers at a glance

```{r vis_value()}
vis_value(airquality)
```

If you're using a dataset that has non-numeric data, you will get an error

```{r gapminder, error=TRUE}
gapminder <- read.csv("https://raw.githubusercontent.com/resbaz/r-novice-gapminder-files/master/data/gapminder-FiveYearData.csv")

vis_value(gapminder)
```

We can use dplyr to select just the numeric columns from our dataset

```{r numeric}
gapminder %>% 
  select(where(is.numeric)) %>% 
  vis_value()
```

## vis_binary()

I'm not sure how often this would come up either, but it allows you to quickly visualise the spread of binary data.

```{r vis_binary()}
vis_binary(dat_bin)

```

## vis_guess() - very useful

vis_guess() is a standout for me. It will take a stab at guessing what class of data is in each cell. Do you have numbers in strings, or intergers in numeric classes?

```{r vis_guess()}
messy_vector <- c(TRUE,
                  T,
                  "TRUE",
                  "T",
                  "01/01/01",
                  "01/01/2001",
                  NA,
                  NaN,
                  "NA",
                  "Na",
                  "na",
                  "10",
                  10,
                  "10.1",
                  10.1,
                  "abc",
                  "$%TG")

set.seed(2019-04-03-1106)
messy_df <- data.frame(var1 = messy_vector,
                       var2 = sample(messy_vector),
                       var3 = sample(messy_vector))


vis_guess(messy_df)
vis_dat(messy_df)
```

Let's look at gapminder too

```{r gapminder guess}
vis_guess(gapminder)

```

And that's visdat! Hopefully you find it useful, or interesting, or at least encourages you to have methods to properly check your data before cleaning and analysis.
