suppressMessages(import("modules"))
suppressMessages(import("shiny"))
suppressMessages(import("DT"))
suppressMessages(import("data.table"))

CONSTS <- use("constants/constants.R")
expose("utils/aggregateData.R")

ui <- function(id){
  ns <- NS(id)
  div(
    DTOutput(ns('records'))
  )
}

server <- function(id, data, part, date_start, date_end) {
   moduleServer(
     id,
     function(input, output, session) {
        
       output$records <- renderDT({
         dt = reactive({data()[part == part() & 
                        date %between% c(date_start(), date_end())]})
         dt2 = ByCategoryDateAgg(dt())
         DT::datatable(
           dt2,
           editable = T,
           # rownames = F,
           colnames=c('종목', '일자', '총볼륨(kg)', '총세트수', '총반복수'),
           selection = "single",
           options = list(
             columnDefs = list(list(className = 'dt-center',
                                    targets=0:4
                                    ),
                               list(className = "dt-left",
                                    targets=5)),
             dom="ftp",
             pageLength = 6,
             ordering = T,
             initComplete = JS(
               "function(setting, json){",
                  "$(this.api().table().header()).css({'background-color': '#001f3f', 'color': '#fff'});",
                "}")
           )
         )
       })
       DTproxy = DT::dataTableProxy("records")
       return(list(cat_selected = reactive({data()[input$records_rows_selected,]})))
     }
   )
}