
#### Webscraping in R with RVest ####

# Sites I used 
# https://rvest.tidyverse.org/articles/rvest.html
# https://www.r-bloggers.com/2020/04/tutorial-web-scraping-in-r-with-rvest/
# https://www.r-bloggers.com/2020/07/tutorial-web-scraping-of-multiple-pages-using-r/
# https://betterdatascience.com/r-web-scraping/

# load libraries
library(tidyverse)
library(rvest)
library(XML)

#### 1. HTML Basics ####

# <html>
#   <head>
#     <title>Page title</title>
#   </head>
#<body>
#   <h1 id='first'>A heading</h1>
#     <p>Some text &amp; <b>some bold text.</b></p>
#     <div>
#       <img src='myimg.png' width='100' height='100'>
#     </div>
#</body>


### 2. The rvest tutorial ####

# Start by reading a HTML page with read_html():
starwars <- read_html("https://rvest.tidyverse.org/articles/starwars.html")

# Then find elements that match a css selector or XPath expression
# using html_elements(). In this example, each <section> corresponds
# to a different film
films <- starwars %>% html_elements(".table_table") %>% 
  html_table()
films

write.csv()

# Then use html_element() to extract one element per film. Here
# we the title is given by the text inside <h2>
title <- films %>% 
  html_element("h2") %>% 
  html_text2()
title

# Or use html_attr() to get data out of attributes. html_attr() always
# returns a string so we convert it to an integer using a readr function
episode <- films %>% 
  html_element("h2") %>% 
  html_attr("data-id") %>% 
  readr::parse_integer()
episode




#### 3. A specific example ####

# read in the website
html <- read_html("https://en.wikipedia.org/wiki/List_of_English_monarchs")

# extract the tables by using CSS selectors in the html_elements() function
tables <- html %>% 
  html_elements(".wikitable") 
tables[1]

# how did I know what the right html element was? Well, we can use your browsers built-in inspector tool to do this (often Ctrl + Shift + i)

# format the tables in a readable format
vis_table <- tables |> 
  html_table() 

# this is more readable, but this just makes another list of dataframes
vis_table

# we can turn this list into a dataframe
df <- bind_rows(vis_table)

# it's not pretty so we need to remove some extra columns
df2 <- df |> 
  select(c("Name", "Birth", "Marriage(s)", "Death", "Claim"))

# some of this is good, but it strips the useful formatting that the xml gave us, and it's not very clean
View(df2)

# instead of using CSS selectors, we can also use an xpath
# you can also use the inspector tool in your browser to find the xpath
monarch <- html_nodes(tables, xpath = "/html/body/div/div/div/main/div/div/div/table/tbody/tr/td/b/a") %>% 
  html_text()

# but this has issues where it can be too specific and miss data that doesn't quite fit that path
urls <- html_nodes(tables, xpath = "/html/body/div/div/div/main/div/div/div/table/tbody/tr/td/b/a") %>% 
  html_attr("href") 

# we can get better data by being more specific with the elements we choose, and use that XML formatting to our advantage
individuals <- html %>% 
  html_elements(".wikitable") |> 
  html_elements("b")
individuals

# extract html <a> attributes like the href URL
urls <- html %>% 
  html_elements(".wikitable") |> 
  html_elements("b") |> 
  html_elements("a") |> 
  html_attr("href") 
urls

# and other meta data in that same <a> tag like the titles 
titles <- html %>% 
  html_elements(".wikitable") |> 
  html_elements("b") |> 
  html_elements("a") |> 
  html_attr("title") 
titles

# the table formatting on these pages aren't great for extracting more data cleanly
# now that we have a list of monarchs and links to their wiki pages, we can crawl those sites too

onepage <- read_html("https://en.wikipedia.org/wiki/Alfred_the_Great")%>% 
  html_element(".infobox.vcard") %>% 
  html_table(header = FALSE) |> 
  data.frame()

View(onepage)

# we can put this into a function to scrape a specific url
monarch_data <- function(monarch){
  read_html(paste0("https://en.wikipedia.org", urls[monarch])) %>% 
    html_element(".infobox.vcard") %>% 
    html_table(header = FALSE) |> 
    data.frame()
}

# and then filter that further to get the data we want
monarch_data(1) %>% 
  filter(X1 == "Died") %>% 
  select(X2)

# now we can do this for all of our pages with a loop

output <- vector("character")
data <- data.frame()
for (i in seq_along(titles)){
  output <- monarch_data(i)|> 
    filter(X1 == "Died") |> 
    mutate(died = X2) |> 
    select(died) 
  data <- rbind(data, output)
}
data

# we can then out all this together into a dataframe
scraped <- data.frame(
  Monarch = titles,
  URL =urls,
  Died = data
)

View(scraped)
#### 4. Scraping from Bing ####

url <- "https://www.bing.com/search?q=R+User+Groups&sp=-1&ghc=1&lq=0&pq=r+user+group&sc=10-12&qs=n&sk=&cvid=64380926D8A64535A12305FB86740629&ghsh=0&ghacc=0&ghpl=&FPIG=F515DEFCDB7440F681458E6C19149D3F&first=1&FORM=PERE"
first_page <- read_html(url)
html_text(first_page)

pages <- first_page %>% 
  html_elements("h2") %>% 
  html_elements("a")

headings <- pages %>%
  html_text()

links <- pages %>%  
  html_attr("href")


# we can then out all this together into a dataframe
bing_result <- data.frame(
  Headings = headings,
  URL = links
)

View(bing_result)

for (j in 1:3){
  pg = 1 + (j * 10) - 10
  url <- paste0("https://www.bing.com/search?q=R+User+Groups&sp=-1&ghc=1&lq=0&pq=r+user+group&sc=10-12&qs=n&sk=&cvid=64380926D8A64535A12305FB86740629&ghsh=0&ghacc=0&ghpl=&FPIG=F515DEFCDB7440F681458E6C19149D3F&first=",j,"&FORM=PERE")
  first_page <- read_html(url)
  html_text(first_page)
  
  pages <- first_page %>% 
    html_elements("h2") %>% 
    html_elements("a")
  
  headings <- pages %>%
    html_text()
  
  links <- pages %>%  
    html_attr("href")
  
  # we can then out all this together into a dataframe
  output <- data.frame(
    Headings = headings,
    URL = links
  )
  
  bing_results <- rbind(bing_result, output)

}

View(bing_results)
