library(waiter)
library(bs4Dash)
library(DT)
library(shinyWidgets)
library(DBI)
library(shinyjs)
library(ggplot2)
library(glue)
library(echarts4r)
library(ggsci)
library(ggthemes)
library(modules)
library(shinyauthr)

const <- use("constants/constants.R")

# Modules
write_diary <- use("modules/write_diary.R")
read_diary <- use("modules/read_diary.R")
table_diary <- use("modules/table_diary.R")
chart_volume <- use("modules/chart_volume.R")
info_box <- use("modules/info_box.R")
sign_up <- use("modules/sign_up.R")
sign_in <- use("modules/sign_in.R")
# navBar = use("modules/navBar.R")

options(
  shiny.port = 7795,
  # shiny.autoreload = T,
  # shiny.reactlog = T,
  shiny.launch.browser = "chrome"
)

