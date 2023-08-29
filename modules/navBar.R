import("shiny") |> suppressMessages()
import("DT") |> suppressMessages()
import("modules") |> suppressMessages()

ui = function(id) {
  ns = NS(id)
  # )
  div(class="col-md-12",
      selectInput(ns("selectCatBig"),"종목",
                  choices = c("", "가슴","등","어깨","하체","코어","이두","삼두")
      )
  )
}

server = function(id, data){
  moduleServer(
    id,
    function(input, output, session){
      observeEvent(input$selectCatBig, {
        if(nchar(input$selectCatBig)>0){
          # print(data()[cat_big==input$selectCatBig])
          return(list(cat_selected = reactive({data()[cat_big==input$selectCatBig,]})))
        }
      })
    }
  )
}