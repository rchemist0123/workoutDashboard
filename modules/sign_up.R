import("shiny") |> suppressMessages()
suppressMessages(import("DBI"))
suppressMessages(import("RPostgreSQL"))


CONSTS <- use("constants/constants.R")
ui <- function(id){
  ns <- NS(id)
  div(
    style="text-align:center",
      title = "Sign up",
      status = "info",
      textInput(ns("id"),"ID"),
      passwordInput(ns("pw"),"PW"),
      textInput(ns("name"),"Name"),
      actionButton(ns("signup_submit"),"Sign up")
  )
}

server <- function(id){
  moduleServer(
    id,
    function(input, output, session) {
      observeEvent(input$signup_submit, {
        # record <- list(
        #   id = input$id,
        #   pw = input$pw,
        #   name = input$name
        # )
        if(input$id=="" |
           input$pw=="" |
           input$name==""){
          shinyWidgets::show_alert(
            type = 'error',
            title='Oops!!',
            text = "모든 항목을 입력하세요.")
        }
        else {
          query = sqlInterpolate(CONSTS$con,
                                  'INSERT INTO diary.user (id, pw, name)
                     VALUES (?id, ?pw, ?name);',
                                  id = input$id,
                                  pw = sodium::password_store(input$pw),
                                  name = input$name
          )
          dbExecute(CONSTS$con, query)
          CONSTS$dbTrigger$trigger()
          shinyWidgets::show_alert(
            type='success',
            title='Success !!',
            text = "회원가입이 완료되었습니다.")
          Sys.sleep(1)
          session$reload()
        }
      })
    }
  )
}