suppressMessages(import("DBI"))
suppressMessages(import("shiny"))
suppressMessages(import("glue"))
suppressMessages(import("data.table"))
suppressMessages(import("modules"))
suppressMessages(import("shinyWidgets"))

CONSTS <- use("constants/constants.R")

ui = function(id) {
  ns = NS(id)
  div(class="row",
      div(class="col-md-3",
          dateInput(ns("date_start"),"From",value=format(as.Date(Sys.time(),"%Y-%m-%d", tz = Sys.timezone())-60,"%Y-%m-%d"))
      ),
      div(class="col-md-3",
          dateInput(ns("date_end"),"To",value=format(as.Date(Sys.time(),"%Y-%m-%d", tz = Sys.timezone()),"%Y-%m-%d"))
      ),
      div(class="col-md-3",
          pickerInput(ns("part"),"부위", 
                      choices = c("가슴","등","어깨","하체","팔","코어"),
                      )
      )
      # div(class="col-md-3",
      #     pickerInput(ns("category"),"종목", 
      #                 choices = c("벤치프레스","플라이","머신 인클라인 벤치"), 
      #                 selected = c("벤치프레스"),
      #                 options = list(
      #                   size=5,
      #                   `actions-box` = TRUE),
      #                 multiple = T)
      # )
  )
}

server = function(id, user_id) {
  moduleServer(
    id,
    function(input, output, session) {
      dbData = reactive({
        CONSTS$dbTrigger$depend()
        query = glue_sql("SELECT * from diary
                         WHERE user_id = ({user_id})
                         ORDER BY date desc",
                         user_id = user_id,
                         .con = CONSTS$con)
        dt = as.data.table(dbGetQuery(CONSTS$con, query))
      })
      
      # observeEvent(input$part, {
      #   temp = dbData()[part == input$part,.(sum= sum(rep*set)), by=category][order(-sum)]
      #   updatePickerInput(session, "category",
      #                     label = "종목",
      #                     choices = temp$category,
      #                     selected = temp[1:2, category])
      # })
      
      return(list(dt = reactive(dbData()),
                  part = reactive(input$part),
                  date_start = reactive(input$date_start),
                  date_end = reactive(input$date_end),
                  category = reactive(input$category)))
    }
  )
}