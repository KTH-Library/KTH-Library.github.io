#!/usr/bin/env Rscript

library(plumber)
pr <- plumb('/tmp/kthb_light_api.R')
pr$run(swagger = TRUE, port = 8080, host = '0.0.0.0')
