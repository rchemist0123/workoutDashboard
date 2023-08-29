suppressMessages(import("shiny"))
suppressMessages(import("echarts4r"))
suppressMessages(import("modules"))
suppressMessages(import("data.table"))
suppressMessages(import("bs4Dash"))
suppressMessages(import("shinyWidgets"))
# export("ui")
# export("chart_server")

expose("utils/aggregateData.R")

const <- use("constants/constants.R")

ui <- function(id){
  ns <- NS(id)
  tagList(
    div(
      class="row",
          box(
            title = "운동 볼륨",
            width = 6,
            status = "navy",
            solidHeader = T,
            sidebar = boxSidebar(
              easyClose = T,
              width = 30,
              id = "chartColor",
              selectInput(ns("color_theme"),"Color", 
                          width = "80%",
                          choices = c("NATURALSEA", "MOSS","MIDNIGHT","BERRY","OCEAN","SUNSET"),
                          selected = "NATURALSEA"),
              pickerInput(ns("category"),"종목", choices = c("벤치프레스","플라이","머신 인클라인 벤치"),
                          options = list(size=5, `actions-box` = TRUE),
                          multiple = T)
              ),
            echarts4rOutput(ns('volume_charts'))
            ),
          box(
            width=6,
            status="navy",
            solidHeader = T,
            title="1세트 평균 볼륨 수",
            echarts4rOutput(ns("set_mean_weight"))
          )
      ),
    div(
      class="row",
      box(
        width=6,
        status="navy",
        solidHeader = T,
        title="운동 성향",
        echarts4rOutput(ns("sets_radar_chart"))
      ),
      box(
        width=6,
        title = "부위 총 볼륨",
        status = "navy",
        solidHeader = T,
        echarts4rOutput(ns('volume_line_chart'))
      )
    )
  )
}

server <- function(id, data, part, date_start, date_end){
  moduleServer(id,
   function(input, output, session){
     observeEvent(part(),{
       temp = data()[part == part(),.(sum= sum(rep*set)), by=category][order(-sum)]
        updatePickerInput(session, "category",
                           label = "종목",
                           choices = temp$category,
                           selected = temp[1:2, category])
     })
     
     dt = reactive({
       data()[part == part() &
                date %between% c(date_start(), date_end())]
     })
     output$volume_charts <- renderEcharts4r({
       dt2 = ByCategoryDateAgg(dt())
       dt2[category %in% input$category]|>
         group_by(category) |>
         e_charts(x = date2) |>
         e_bar(
           serie=total_volume,
           emphasis = list(focus="series"),
           itemStyle = list(
             borderRadius = c(6,6,0,0)
           ),
         ) |>
         e_color(
           color = const$COLORS[[input$color_theme]]
         ) |>
         e_add_nested("custom", c(date2, category, total_volume, total_set, total_rep)) |> 
         e_tooltip(
           trigger = "item",
           formatter = htmlwidgets::JS("
                function(params) {
                  const {date2, category, total_volume, total_set, total_rep } = params.data.custom;
                  return `
                    <strong>종류: </strong>${category}<br>
                    <strong>일자: </strong>${date2}<br>
                    <strong>총 볼륨: </strong>${total_volume}kg<br>
                    <strong>총 세트: </strong>${total_set}<br>
                    <strong>총 횟수: </strong>${total_rep}<br>
                    `}
              "))
       })
       
       output$set_mean_weight = renderEcharts4r({
         dt2 = ByDateWeightMean(dt())
         dt2 |> 
           group_by(category) |> 
           e_charts(x = date2) |>
           e_line(
             serie=mean_w_by_set,
             emphasis = list(focus="series"),
           ) |> 
           e_color(
             color = const$COLORS$NATURALSEA
           ) |> 
           e_add_nested("custom", c(date2, mean_w_by_set)) |>
           e_tooltip(
             trigger = "item",
             formatter = htmlwidgets::JS("
               function(param){
                 const {date2, mean, total_volume, total_set, total_rep } = params.data.custom;
                 return(param.value[1].toString().replace(/(\\d)(?=(\\d{3})+(?!\\d))/g, '$1,') +  'kg')
               }")
           )
         
       })
       output$volume_line_chart = renderEcharts4r({
         dt2 = ByDateAgg(dt())
         dt2 |> 
           e_charts(x = date2) |>
           e_line(
             serie=total_volume,
             emphasis = list(focus="series"),
             areaStyle = list(
               opacity = 0.3
             )
           ) |> 
           e_add_nested("custom", c(date2, total_volume)) |>
           e_tooltip(
             trigger = "item",
             formatter = htmlwidgets::JS("
               function(param){
                 const volume = param.value[1].toString().replace(/(\\d)(?=(\\d{3})+(?!\\d))/g, '$1,') +  'kg';
                 const date = param.value[0]
                 return(`
                    <strong>주차</strong>: ${date} <br>
                    <strong>볼륨</strong>: ${volume}
               `)
               }")
           )
       })
       
       output$sets_radar_chart = renderEcharts4r({
         dt_custom = data()[date %between% c(date_start(), date_end()),
                       .N, keyby=part]
         dt_part = data()[date %between% c(date_start(), date_end()), .(vol_sum = sum(set*rep*weight)), keyby=part]
         dt_set_sum = data()[date %between% c(date_start(), date_end()), .(no_set = sum(set)), keyby=part]
         dt_rep_sum = data()[date %between% c(date_start(), date_end()), .(no_rep = sum(set*rep)), keyby=part]
         dt_part[dt_set_sum, on=.(part), set_sum := i.no_set]
         dt_part[dt_rep_sum, on=.(part), rep_sum := i.no_rep]
         target = dt_part[,.SD, .SDcols=patterns("_sum")] |> names()
         dt_part[,(target) := lapply(.SD, \(x)(x-min(x))/(max(x)-min(x))) ,.SDcols=target]

         dt_part |> 
           e_charts(part) |>
           e_radar(vol_sum, max=1, name="볼륨") |> 
           e_radar(rep_sum, max=1, name="반복횟수") |> 
           e_radar(set_sum, max=1, name="세트수") |> 
           e_radar_opts(
               splitLine = list(show=F),
               splitArea = list(show=F)
           ) |> 
           e_color(color = const$COLORS$CUSTOM)
       })
       
       
   }
  )
}
