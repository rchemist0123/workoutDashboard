library(dplyr)
library(data.table)
library(shinyWidgets)
library(shinyjs)
library(RSQLite)
library(glue)
library(data.table)
library(lubridate)

if(!"sessionids" %in% dbListTables(const$con)) {
  dbCreateTable(const$con, "sessionids", c(user="TEXT",sessionid="TEXT", login_time="TEXT"))
}

shiny::shinyServer(function(input, output, session){
  ns <- session$ns
  # user_db = dbGetQuery(const$con, "SELECT * from diary.users;") |> as.data.table()
  

  user_base <- data.table(
    user = c("jyhoon94", "meiling"),
    password = c("Zpflrjs94!", "123"),
    permissions = c("admin", "standard"),
    name = c("장연훈", "홍미령")
  )
  
  logout_init = logoutServer(
    "logout",
    active=reactive(credentials()$user_auth)
  )
  
  set_session_to_db = function(user, sessionid, conn=const$con) {
    tbl = data.table(user = user, sessionid = sessionid, login_time=as.character(now()))
    dbWriteTable(conn = conn, name = 'sessionids',  value = tbl, append=T)
  }

  get_session_from_db = function(conn = const$con, expiry = const$cookie_expiry) {
    dbReadTable(conn, "sessionids") |> 
      mutate(login_time = ymd_hms(login_time)) |>
      as_tibble() |>
      dplyr::filter(login_time > now() - days(expiry))
  }
  
  credentials = loginServer(
    "login",
    data = user_base,
    user_col = "user",
    pwd_col = "password",
    # sodium_hashed = T,
    cookie_logins = T,
    sessionid_col = "sessionid",
    cookie_getter = get_session_from_db,
    cookie_setter = set_session_to_db,
    log_out = reactive(logout_init())
  )
  
  # Write data to DB
  write_diary$server("write_diary", user_id = credentials()$info$user)
  data = read_diary$server("read_diary", user_id = credentials()$info$user)
  chart_volume$server("volume", data=data$dt,
                            part = data$part,
                            date_start = data$date_start,
                            date_end = data$date_end)
  table_diary$server("records", data=data$dt,
                     part = data$part,
                     date_start = data$date_start,
                     date_end = data$date_end)
  info_box$server("infobox", 
                  data=data$dt, 
                  part = data$part, 
                  date_start = data$date_start,
                  date_end = data$date_end,
                  category = data$category, 
                  selected = selected$cat_selected)
  
  output$welcome = renderUI({
    req(credentials()$user_auth)
    tagList(
      h2(paste0("Welcome, ", credentials()$info$user,"!     "))
    )
  })
  
  output$write_diary = renderUI({
    req(credentials()$user_auth)
    write_diary$ui("write_diary")
  })
  
  output$dashboard = renderUI({
    req(credentials()$user_auth)
    tagList(
          read_diary$ui("read_diary"),
          info_box$ui("infobox"),
          chart_volume$ui("volume"),
          table_diary$ui("records")
    )
  })
  
  # Reading data from DB
  # Table ----------------------------------
  # table 데이터 변경 시 DB에도 반영 필요
  # observeEvent(input$records_cell_edit, {
  #   row  <- input$records_cell_edit$row; print(row)
  #   column <- input$records_cell_edit$col; print(column)
  #   value <- input$records_cell_edit$value; print(value)
  #   target_id <-  dt()[row, id] # 변경id
  # 
  #   edited_col_name <- names(dt())[column+1]
  #   dt()[row, col := input$records_cell_edit$value,
  #                      env= list(col = edited_col_name)]
  # 
  #   query <- dbSendQuery(con,
  #                        paste0("UPDATE diary SET '",edited_col_name,"' = ? where id = ?"),
  #                           params=c(value, target_id)
  #   )
  #   DBI::dbClearResult(query)
  #   dbTrigger$trigger()
  # })
  values = reactiveValues(sessionID = NULL)
  values$sessionId = as.integer(runif(1,1, 100000))
  session$onSessionEnded(function() {
    session$onSessionEnded(function() {
      observe(cat(paste0("Ended: ", values$sessionId)))
    })
  })
})