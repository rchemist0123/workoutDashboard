
# import("glue")

suppressMessages(import("modules"))
suppressMessages(import("data.table"))
suppressMessages(import("DBI"))
suppressMessages(import("shiny"))
suppressMessages(import("bs4Dash"))

const <- use("constants/constants.R")

ui <- function(id) {
  ns <- NS(id)
  box(
    width = 12,
    id = "write_box",
    title = "운동일지 작성",
    solidHeader = T,
    status = "primary",
    dateInput(ns('date'), strong('일자'), value=Sys.Date()),
    selectInput(ns('part'),strong('대분류'),
                choices=c('등','가슴','어깨', '하체','팔','코어')
    ),
    selectInput(ns('category'), strong('종류'), choices = ""),
    textAreaInput(ns('memo'), strong('메모')),
    div(
      style="text-align: center",
      class="records_diary"),
    div(
      style= "text-align: center",
      class="records_btn",
      bs4Dash::actionButton(ns('add'), strong('세트 추가'),
                            status = "danger",
                            icon = icon('plus', lib = 'glyphicon')),
      bs4Dash::actionButton(ns("rm"), strong("세트 삭제"),
                            status = "warning",
                            icon = icon("minus", lib="glyphicon")),
      tags$br(),
      bs4Dash::actionButton(ns('write'), strong('저장'),
                   status = "primary",
                   icon = icon('floppy-save', lib = 'glyphicon'))
    ))
  }

server <- function(id, user_id){
  moduleServer(
    id,
    function(input, output, session){
      set_id = NULL
      ns <- NS(id)
      
      # update lists
      observeEvent(input$part,{
        switch(input$part,
               '가슴' = updateSelectInput(session,'category', label = "종류",
                                        selected=NA,
                                        choices=c('벤치프레스','딥스','머신 플라이',"머신 인클라인 벤치", "푸시업")),
               '등' = updateSelectInput(session,'category',label = "종류",
                                       selected=NA,
                                       choices=c('풀업','랫풀다운','내로우 랫풀다운', '데드리프트','케이블 로우', "머신 로우",
                                                 "머신 티바로우", '원암덤벨로우')),
               '어깨' = updateSelectInput(session,'category', label = "종류",
                                        selected=NA,
                                        choices=c('밀리터리 프레스', "머신 숄더프레스", "덤벨 숄더프레스",  '사레레','후면삼각근')),
               '하체' = updateSelectInput(session,'category', label = "종류",
                                      selected=NA,
                                      choices=c('스쿼트','데드리프트','런지','레그프레스')),
               '팔' = updateSelectInput(session,'category', label = "종류",
                                      selected=NA,
                                      choices=c('이두컬', '삼두 익스텐션', '삼두 킥백')),
               "코어" = updateSelectInput(session,'category', label = "종류",
                                      selected=NA,
                                      choices=c('레그레이즈', '앱슬라이드')))
      })
      
      # add set input
      input_counter = reactiveVal(0)
      input_weight = reactiveVal(1)
      observeEvent(input$add, {
        input_counter(input_counter() + 1)
        weight_before= input[[paste0("weight",input_counter()-1)]]
        insertUI(
          selector = "div.records_diary", where = "beforeEnd",
          ui = div(id = paste0("set", input_counter()),
                   strong(paste0("#",input_counter())),
                   numericInput(ns(paste0("weight", input_counter())), 
                                label = "무게(kg)", value = weight_before),
                   numericInput(ns(paste0("rep", input_counter())), 
                                label = "반복수", value = 1),
                   numericInput(ns(paste0("set", input_counter())),
                                label = "세트수", value = 1)
                   )
        )
      })
      observeEvent(input$rm, {
        removeUI(
          selector = paste0("#set", input_counter()),
        )
        input_counter(input_counter()-1)
      })
      
      # write data
      observeEvent(input$write, {
        if(input$category==""){
          shinyWidgets::show_alert(
            type = 'error',
            title='Oops!!',
            text = "빈칸이 존재합니다!")
        } else {
            if(input_counter() == 0) {
              shinyWidgets::show_alert(
                type = 'error',
                title='Oops!!',
                text = "운동기록이 없습니다!")
            } else {
              for(i in 1:input_counter()){
                weights = paste0("weight",i)
                reps = paste0("rep",i)
                no_of_set = paste0("set", i)
                query <- sqlInterpolate(const$con,
                                        "INSERT INTO diary ([user_id], [date], [part], [category], [weight], [rep], [set], [memo])
                                         VALUES (?user_id, ?date, ?part, ?category, ?weight, ?rep, ?set, ?memo)",
                           user_id = user_id,
                           date = input$date,
                           part = input$part,
                           category = input$category,
                           weight = input[[weights]],
                           rep = input[[reps]],
                           set = input[[no_of_set]],
                           memo = input$memo)
                dbExecute(const$con, query)
                const$dbTrigger$trigger()
                removeUI(selector = paste0("div#set", input_counter()))
                input_counter(input_counter()-1)
              }
              shinyWidgets::show_alert(
                type='success',
                title='Success!!',
                text = "기록이 저장되었습니다.")
            }
        }
      })
    }
  )
}