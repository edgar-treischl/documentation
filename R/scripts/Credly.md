This is a raw script to get infos from credly. 

```r
#| label: d4735e3a
library(rvest)
pr_site <- "https://www.credly.com/users/edgar-treischl/badges"

# read_html reads the website
pr_html <- read_html(pr_site)

# Body node with all children
#pr_html |>
  #html_node("body") |>
  #html_children()

badges_title <- pr_html |> 
  html_elements(".cr-standard-grid-item-content__title")|>
  html_text2()
  
badges_title
```


> ```
> ​[1​] "Python Essentials"                                           
>  ​[2​] "Machine Learning with Python"                                
>  ​[3​] "SQL for Data Science"                                        
>  ​[4​] "NoSQL Database Essentials"                                   
>  ​[5​] "Linux Commands & Shell Scripting"                            
>  ​[6​] "Relational Database Basics"                                  
>  ​[7​] "Data Engineering Basics for Everyone"                        
>  ​[8​] "SQL Concepts for Data Engineers"                             
>  ​[9​] "Relational Database Administration Essentials"               
> ​[10​] "Building ETL and Data Pipelines with Bash, Airflow and Kafka"
> ```

```r
#| label: 76a50887
badges <- pr_html |>  
  html_elements("a") |>
  html_attr("href")
  
badges
```



We need to extract the badges and add the urls:

```r
#| label: 98a3ab7c
badges <- stringr::str_subset(badges, "/badges/")
url <- "https://www.credly.com"
badges_url <- stringr::str_c(url, badges)
tibble::tibble(badges_title, badges_url)
```

> [!OUTPUT]+ {#output-98a3ab7c}
> ```
> ​# A tibble: 10 x 2
>    badges​_title                                                 badges​_url      
>    <chr​>                                                        <chr​>           
>  1 Python Essentials                                            https://www.cre~
>  2 Machine Learning with Python                                 https://www.cre~
>  3 SQL for Data Science                                         https://www.cre~
>  4 NoSQL Database Essentials                                    https://www.cre~
>  5 Linux Commands & Shell Scripting                             https://www.cre~
>  6 Relational Database Basics                                   https://www.cre~
>  7 Data Engineering Basics for Everyone                         https://www.cre~
>  8 SQL Concepts for Data Engineers                              https://www.cre~
>  9 Relational Database Administration Essentials                https://www.cre~
> 10 Building ETL and Data Pipelines with Bash, Airflow and Kafka https://www.cre~
> ```


Get Github

```r
#| label: 3346f2bb
pr_site <- "https://github.com/edgar-treischl"
#pr_site <- "https://github.com/hadley"

# read_html reads the website
pr_html <- read_html(pr_site)

# Get tables
#pr_html |>
  #html_element("table") |>
  #html_table()

pr_html |>
  html_elements("span") |>
  html_elements(".repo")|>
  html_text2()
```


```r
#| label: d2f48367
h2s <- pr_html |>
  html_elements("h2")|>
  html_text2()

h2s <- as.vector(h2s)
h2s
```



```r
#| label: 05ada863
search <- "contributions in the last year"
ss_num <- stringr::str_which(h2s, search)


contributions <- h2s[ss_num]
contributions
```



