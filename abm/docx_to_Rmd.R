library(rmarkdown)
library(devtools)

# conversion of .docx files to HTML

docx <- fs::path_abs("abm/ABM_guide.docx")
rmd <- fs::path_abs("abm/ABM_guide.Rmd")
pandoc_convert(docx, to = "markdown", output = rmd, options=c("--extract-media=."))
render(rmd, output_format = "html_document")

# OCR and conversion of PDF file to HTML

library(magick)
library(tesseract)

beslut <- image_read_pdf("abm/Beslut_ABM.pdf")
ocr <- image_ocr(beslut, language = "swe")
fn <- sprintf("abm/media/b%s.png", 1:length(beslut))

# output embedded images
1:length(beslut) %>% purrr::walk(function(x) image_write(beslut[x], fn[x]))

# create a rough .Rmd file with the contents below
cat(beslut[1])

# A third approach is to open the .docx in LibreOffice, save as .docx and then convert



# [x] Guide to the Annual Bibliometric Monitoring at KTH
# [x] President decision about the Annual Bibliometric Monitoring



# [] Description of data, methods and indicators in KTH Annual Bibliometric Monitoring
# [] Formal definitions of field normalized citation indicators at KTH
# [] Information about DiVA and the registration process - Handle publications in DiVA
# [] Report on Open Access publishing at KTH
