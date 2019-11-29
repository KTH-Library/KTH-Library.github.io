library(readr)
library(dplyr)

## DOAJ - Directory of Open Access Journals

doaj <- 
  read_csv("https://doaj.org/csv")

#' Example data from DOAJ
doaj %>% select(
  `Journal title`,
  `Journal ISSN (print version)`, 
  `Journal EISSN (online version)`,
  `Journal article processing charges (APCs)`,
  `APC amount`
  )

#' Complete set of columns available
colnames(doaj)

#' Count for number of registered Open Access journals:
doaj %>% distinct(`Journal ISSN (print version)`) %>% nrow

## TODO work from here

#' Proportion of open access journals requiring article processing charges (APCs)
#' ie publication fees

table(doaj$`APC amount`)
doaj$`APC amount`
doaj %>% tally(`APC amount`)

table(doaj$`APC amount`)

doaj$
apc.table <- data.frame(table(unlist(doaj$Publication.fee)))
apc.table$Perc <- apc.table$Freq / sum(apc.table$Freq) * 100
colnames(apc.table) <-c("Fee", "Journals", "Share")

knitr::kable(apc.table[order(apc.table$Journals, decreasing = T),], row.names = FALSE, digits = 2)
```

You may also wish to explore the growth of DOAJ by APC applicability.

```{r simpleplot, echo=TRUE, fig.height=8/2.54, fig.width=18/2.54, warning = FALSE, message = FALSE}
#exclude journals with blank APC info
doaj <- doaj[!doaj$Publication.fee == "",]
doaj <- droplevels(doaj)

# transform to date object
doaj$Added.on.date <- as.Date(doaj$Added.on.date, format="%Y-%m-%d")

# relevel
doaj$Publication.fee <- factor (doaj$Publication.fee, 
                                levels = c(rownames(data.frame(rev(sort(table(doaj$Publication.fee)))))))

#prepare df for ggplotting
tt <- data.frame(table(doaj$Publication.fee, doaj$Added.on.date))
tt$Cumsum<-ave(tt$Freq,tt$Var1,FUN=cumsum) 

#plot

ggplot2::ggplot(tt, aes(as.Date(Var2),Cumsum, group = Var1)) + 
  geom_line(aes(colour = Var1, show_guide=FALSE)) +
  xlab("Date added to DOAJ") + ylab("Cumulative Sum") + 
  scale_colour_brewer("Publication Fee",palette=2, type="qual") +
  theme_bw(base_size= 16) +
  opts(legend.key=theme_rect(fill="white",colour="white"))
```

This little exploration demonstrates that the DOAJ journal title master list is an excellent source (not only) to study the longitudinal growth of Open Access journal publishing. As we have shown, by reusing such a file, you can also write your study in a reproducible manner.

We hope that the DOAJ will continue its bulk download service in order to provide an convenient way to monitor Open Access journal publishing.  At Bielefeld University Library, for instance, we use the `csv` download to answer our DFG reporting requirements. 

## Bielefeld University Paid APCs 2012/13 Dataset

With the [Bielefeld University Paid APCs 2012/13 Dataset](data/unibi12-13.csv), we publish information on paid Article Processing Charges (APC) by the [Open Access Publication Fund of Bielefeld University](http://oa.uni-bielefeld.de/publikationsfonds.html). The fund is supported by the German Research Foundation (DFG) under its [Open-Access Publishing Programme](http://www.dfg.de/en/research_funding/programmes/infrastructure/lis/funding_opportunities/open_access_publishing/index.html).


### Load Data

```{r}
my.df <- read.csv("data/unibi12-13.csv", header = TRUE, sep =",")
head(my.df)
```

The dataset covers the accounting periods 2012 and 2013 (`Period`). For every single article,  the `doi` is provided. Journal titles (`Journal`), publisher names (`Publisher`) and the International Standard Serial Numbers (`issn.1` and `issn.2`) are normalized according to CrossRef metadata store. In addition, `PUBID` references the copy stored in the institutional repository [PUB - Publications at Bielefeld University](http://pub.uni-bielefeld.de/en).

With this step, we follow Wellcome Trust example to share data on paid APCs. See:
  
  Neylon, Cameron (2014): Wellcome Trust Article Processing Charges by Article 2012/13.
[https://github.com/cameronneylon/apcs](https://github.com/cameronneylon/apcs)


### Paid APCs

Column `EURO` contains the author processing charge  for each paper including VAT. 

In total, we paid

```{r}
sum(my.df$EURO)
```

for 
```{r}
nrow(my.df)
```
articles.


DFG funding covered 75%.

```{r}
sum(my.df$EURO) * 0.75
```

#### APC per accounting period

Column `EURO` contains the author processing charge paid for each paper in Euro including VAT. 

To obtain the yearly costs for 2012 and 2013:
  
  ```{r}
tapply(my.df$EURO, my.df$Period, sum)
```


#### APC per Publisher 

To calculate APC paid per publisher and accounting period  and print it as pretty markdown table:
  
  ```{r, results='asis', tab.cap ='Bielefeld University publication fund: APCs paid in EURO (incl VAT)'}
# relevel publishers according to sorting
my.df$Publisher <- factor (my.df$Publisher, 
                           levels = c(rownames(data.frame(rev(sort(table(my.df$Publisher)))))))

# calculate and print
knitr::kable(tapply(my.df$EURO, list(my.df$Publisher, my.df$Period), sum))
```

Mean APCs paid:
  
  ```{r, results='asis', tab.cap ='Bielefeld University publication fund: Mean APCs paid in EURO (incl VAT)'}
knitr::kable(tapply(my.df$EURO, list(my.df$Publisher, my.df$Period), mean))
```

### Licence

The Bielefeld University Paid APCs 2012/13 Dataset is made available under the Open Database License: http://opendatacommons.org/licenses/odbl/1.0/. Any rights in individual contents of the database are licensed under the Database Contents License: http://opendatacommons.org/licenses/dbcl/1.0/ 
  
  ### Contact
  
  Najko Jahn < najko.jahn [ at ] uni-bielefeld.de >
  
  Dirk Pieper < dirk.pieper [ at ] uni-bielefeld.de >
