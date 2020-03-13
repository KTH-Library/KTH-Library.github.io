library(pdftools)
library(magrittr)
library(httr)
library(rvest)
library(purrr)
library(tibble)
library(dplyr)
library(magick)
library(stringr)
library(roadoi)

#* @apiTitle KTH Library Bibliometrics Data API "Light"
#* @apiDescription Exposes some open publicly available data for example from KTH's DiVA portal and SwePub etc
#* @apiTag Data for the KTH Library
#* @apiVersion 0.0.0.900

diva_search_fulltext <- function(diva_id) {
  "https://kth.diva-portal.org/smash/resultList.jsf?searchType=SIMPLE&query=%s" %>%
    sprintf(diva_id) %>%
    GET() %>% content() %>%
    html_nodes("a[id$='fullText']") %>% 
    #formSmash\\:items\\:resultList\\:0\\:j_idt1531\\:0\\:fullText") %>%
    map_chr(.f = function(x) html_attr(x, "href")) %>%
    tibble(id = diva_id, url = sprintf("https://kth.diva-portal.org/smash/%s", .)) %>%
    select(id, url)
}

#* Retrieve fulltext given a DiVA identifier
#* @get /DiVA/fulltext
#* @param diva_id the DiVA publication identifier, try for example "247301"
#* @tag DiVA
#* @response 400 Invalid input.
diva_fetch_fulltext <- function(diva_id) {
  
  url <- diva_search_fulltext(diva_id) %>% pull(url)
  
  txt <- pdf_text(url)
  
  if (all(txt == "")) {
    message("PDF text is empty, it might hold a scanned image... Using OCR to get text.")
    txt <- url %>% image_read_pdf() %>% image_ocr()
  }
  
  paste(collapse = "", txt)
  
}

#* Fetch full-text link from best Open Access location given a DOI
#* @get /fulltext/doi
#* @param doi the identifier to use, for example "10.1186/s12864-016-2566-9"
#* @tag Open Access publications
#* @response 400 Invalid input.
doi_fetch <- function(doi) {
  roadoi::oadoi_fetch(dois = doi, email = "najko.jahn@gmail.com") %>%
    dplyr::mutate(
      urls = purrr::map(best_oa_location, "url") %>% 
        purrr::map_if(purrr::is_empty, ~ NA_character_) %>% 
        purrr::flatten_chr()
    ) %>%
    .$urls
}


#* Retrieve search results from SwePub at Kungliga Biblioteket (Royal Library)
#* @get /swepub/bibliometrics/kth
#* @param org try for example "kth"
#* @param year_from try for example 2013
#* @param year_to for example 2020
#* @param subject for example 102
#* @param publicationStatus for example "published"
#* @param swedishList for example "true"
#* @param genreForm for example "publication"
#* @tag SwePub
#* @response 400 Invalid input.
swepub_bibliometrics <- function(org = "kth", year_from = 2013, year_to = 2020, 
  subject = 102, publicationStatus = "published", swedishList = "true", genreForm = "publication") {
  params <- sprintf(paste0('{"org":["%s"],"years":{"from":"%s","to":"%s"},',
    '"subject":["%s"],"genreForm":[],"keywords":"","publicationStatus":["%s"],',
    '"contentMarking":[],"swedishList":%s,"match-genreForm":["%s"],',
    '"fields":["recordId","ORCID","DOI","scopusId","PMID","electronicLocator"]}'),
    org, year_from, year_to, subject, publicationStatus, swedishList, genreForm)
  json_body <- jsonlite::toJSON(params)
  httr::set_config(config(ssl_verifypeer = FALSE))  # NB: uses TERENA SSL cert!
  resp <- POST("http://bibliometri.swepub.kb.se/api/v1/bibliometrics/", 
    body = params, add_headers(`Content-Type` = "application/json", Accept = "text/csv"))
  parsed <- content(resp)
  parsed
}

serializer_csv <- function(){
  function(val, req, res, errorHandler){
    tryCatch({
      res$setHeader("Content-Type", "text/plain")
      res$setHeader("Content-Disposition", 'attachment; filename="xxx.csv"')
      res$body <- paste0(val, collapse="\n")
      return(res$toResponse())
    }, error=function(e){
      errorHandler(req, res, e)
    })
  }
}
#plumber::addSerializer("csv", serializer_csv)

############ Only included as example code scraping and paging scenario

swepub_search <- function(term) {
  
  search <- 
    "http://swepub.kb.se/hitlist?q=%s" %>%
    sprintf(force(term)) %>%
    GET() %>% content()
  
  n_hits <- 
    search %>%
    html_nodes(".blabox li:nth-child(1) span:nth-child(2)") %>% 
    html_text() %>% as.numeric()
  
  n_pages <- n_hits %/% 10 + ifelse(n_hits %% 10 > 0, 1, 0)
  
  page_urls <-
    "http://swepub.kb.se/hitlist?d=swepub&q=coronavirus&f=simp&p=%s" %>%
    sprintf(1:n_pages)
  
  list(n_hits = n_hits, n_pages = n_pages, page_urls = page_urls)
  
}


parse_post <- function(post) {
  headings <- c(
    "author", "title", "year", "partof", "pubtype", "abstract"
  )
  post %>%
    html_nodes("li") %>%
    html_text() %>%
    as.list() %>% setNames(letters[1:length(.)]) %>% as_tibble() %>%
    mutate_all(str_trim)
}

parse_post_possibly <- possibly(parse_post, NULL)

parse_page <- function(page) {
  
  posts <- 
    page %>%
    GET() %>% content() %>% 
    html_nodes(".trafftabell .post")
  
  posts %>% map_df(parse_post_possibly)
  
}

#* Retrieve search results from SwePub at Kungliga Biblioteket (Royal Library)
#* @get /swepub/search
#* @param term the fulltext search term, try for example "coronavirus"
#* @tag SwePub
#* @response 400 Invalid input.
fetch_swepub <- function(term) {
  search <- swepub_search(term)$page_urls
  search %>% map_df(parse_page)
}
