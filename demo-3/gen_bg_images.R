library(magick)
library(dplyr)
library(magick)
library(purrr)

bg <- "https://upload.wikimedia.org/wikipedia/commons%s" %>%
  sprintf(unlist(strsplit(split = "\n",       
"/3/3c/KTH._Avdelningen_f%C3%B6r_bergskemi..jpg
/c/ce/Kungliga_Tekniska_H%C3%B6gskolan_6.jpg
/e/e0/Kungliga_Tekniska_H%C3%B6gskolan_5.jpg
/a/a3/Kungliga_Tekniska_H%C3%B6gskolan_4.jpg
/f/f1/KTH_Kerberos.jpg")))

bg <- c(bg, 
"https://i1.wp.com/www.kth.se/blogs/studentbloggen/files/2020/01/Snapseed.jpg?resize=900%2C675&ssl=1",
"https://www.kth.se/polopoly_fs/1.956844.1581319935!/image/sdlmR1Rmsus0yg-nh.jpg",
"https://www.kth.se/polopoly_fs/1.955141.1580469111!/image/indisk%20tjej%20med%20lysdioder%20p%C3%A5%20Tekla%20Workshop_liten%201.jpg",
"https://www.kth.se/polopoly_fs/1.958087.1581506377!/image/Algodling%20l%C3%B6nsamt%20i%20Sverige_sockert%C3%A5ng_liten.jpg",
"https://www.kth.se/polopoly_fs/1.953825.1580138538!/image/Ny%20teknik%20h%C3%A4rmar%20kroppen_1000.jpg",
"https://imgs.aftonbladet-cdn.se/v2/images/2d0aae21-339b-4783-98fc-088531b0a268?fit=crop&h=729&w=1100&s=cf5938fd65f317c6d2de04b413ae5c022490d24e"
)

img_bg <- function(img)
  img %>%
  image_read() %>%
  image_resize("800x600") %>%
  image_convert(colorspace = "gray") %>%
  image_normalize() %>%
  image_colorize(opacity = 40, color = "gray50") %>%
  image_blur(radius = 15, sigma = 5) %>%
  image_contrast(sharpen = 0.5) %>%
  image_modulate(brightness = 150, saturation = 120) %>%
  image_convert(format = "png")

fn <- sprintf("docs/assets/bg/kth-%s.png", 1:length(bg))

bg_save <- function(img, filename) 
  img_bg(img) %>% image_write(path = filename)

pwalk(list(bg, fn), bg_save)
