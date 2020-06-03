library(httr)
library(rvest)
library(reticulate)
library(htmltidy)
library(purrr)

# installation may require KTHVPN be turned off temporarily
#conda_create("r-reticulate")
#conda_install("r-reticulate", "langdetect")
#use_condaenv("r-reticulate")

# create a function that wraps the "langdetect" python call
detect_lang <- function(text) {
  if (is.null(text) || nchar(text) < 1)
    return (NULL)
  lang <- import("langdetect")
  lang$detect(text)
}

# it can now be used like below

#detect_lang("Detta är en svensk text")
#detect_lang("This is a text in english")

html_rewrite_plang <- function(url) {

  # retrieve some HTML content and ..
  # pick out all paragraphs in the HTML document
  www <- url %>% GET()
  h <- www %>% content()
  p <- h %>% html_nodes(xpath = "//p") 
  
  # detect the language using pythons "langdetect"
  # set the lang attribute for the p tag to the detected language
  lang <- p %>% html_text() %>% map(detect_lang)
  walk2(p, lang, function(x, y) xml_attr(x, "lang") <- y)
  
  # output tidy xhtml variant of the HTML content
  tidy_html(h, options = list(
    TidyDocType = "html5",
    TidyMakeClean = TRUE,
    TidyHideComments = TRUE,
    TidyIndentContent = TRUE,
    TidyWrapLen = 200)
  )    
  
}

# example usage
diva_tidy <- 
  "http://kth.diva-portal.org/smash/record.jsf?pid=diva2%3A1432272&dswid=-6643" %>%
  html_rewrite_plang()

# write modified content to a file
write_html(
  diva_tidy, "~/test.html", 
  options = c("format_whitespace", "require_xhtml")
)

# and inspect
#browseURL("~/test.html")

read_html("~/test.html") %>%
  html_nodes("p")
