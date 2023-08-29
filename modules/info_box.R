suppressMessages(import("shiny"))
suppressMessages(import("modules"))
suppressMessages(import("bs4Dash"))
suppressMessages(import("data.table"))

# import("bsicons")
expose("utils/aggregateData.R")
expose("utils/infoStatus.R")

const = use("constants/constants.R")

ui = function(id){
  ns = NS(id)
  tagList(
    div(class="row",
        div(class="col-sm-3",
          bs4InfoBoxOutput(ns('volume'))
          ),
        div(class="col-sm-3",
            bs4InfoBoxOutput(ns('weight_vs'))
        ),
        div(class="col-sm-3",
            bs4InfoBoxOutput(ns('set_vs'))
        ),
    div(class="col-sm-3",
        bs4InfoBoxOutput(ns('rep_vs'))
    )
    )
  )
}

server = function(id, data, part, category, date_start, date_end, selected){
  moduleServer(
    id,
    function(input, output, session){
      dt = reactive({
        data()[part == part() &
                 # category %in% category() &
                 date %between% c(date_start(), date_end()),
               .(total_volume = sum(weight * set * rep),
                 max_weight = max(weight),
                 total_rep = sum(rep*set),
                 total_set = sum(set)), by=.(date)][order(-date)]
      })

      output$volume = renderbs4InfoBox({
        total_volume = getStatus(dt(), "total_volume")
        bs4InfoBox(
            title = "볼륨 변화량",
            value = paste0(total_volume$delta, "%"),
            color = total_volume$color,
            fill = T,
            icon = icon(total_volume$icon, lib="glyphicon"),
            width = 12)
      })
      output$weight_vs = renderbs4InfoBox({
        max_weight = getStatus(dt(), "max_weight")
        bs4InfoBox(
          title = "최고 중량 변화",
          value = paste0(max_weight$delta,"%"),
          color = max_weight$color,
          fill = T,
          icon = icon(max_weight$icon, lib="glyphicon"),
          width = 12)
      })
      
      output$rep_vs = renderbs4InfoBox({
        total_count = getStatus(dt(), "total_rep")
        bs4InfoBox(
          title = "반복 수",
          value = paste0(total_count$delta,"%"),
          color = total_count$color,
          fill = T,
          icon = icon(total_count$icon, lib="glyphicon"),
          width = 12)
      })
      
      output$set_vs = renderbs4InfoBox({
        total_set = getStatus(dt(), "total_set")
        bs4InfoBox(
          title = "세트 수",
          value = paste0(total_set$delta,"%"),
          color = total_set$color,
          fill = T,
          icon = icon(total_set$icon, lib="glyphicon"),
          width = 12)
      })
      
      # output$test = renderUI({
      #   total_set = getStatus(dt(), "total_set")
      #   glue::glue('
      #     <span>{total_set$color}{total_set$delta}%</span>
      #     {total_set$value}         
      #     ') |> HTML()
      #   
      # })
      
    }
  )
}