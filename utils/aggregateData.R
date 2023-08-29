suppressMessages(import("data.table"))
suppressMessages(import("shiny"))
suppressMessages(import("lubridate")) 
justAggregate = function(data){
  print(data)
}

weekMonth = function(date) {
  std_date = as.Date(paste0(substr(date,1,8),"01"))
  week = ceiling(as.numeric(difftime(date, std_date, units="week"))+1)
  return(week)
}

addMonthWeek = function(data){
  data$date2 = paste0(month(data$date), "월 ", weekMonth(data$date),"주차")
  return(data)
}

ByCategoryDateAgg = function(dt){
  dt2 = addMonthWeek(dt)
  aggData = dt2[,.(total_volume = sum(weight * set * rep),
                   total_set = sum(set),
                   total_rep = sum(set*rep)),
               by=.(date2, category)][order(date2, -total_volume)]
  return(aggData)
}


ByDateWeightMean = function(dt){
  dt2 = addMonthWeek(dt)
  aggData = dt2[,.(mean_w_by_set = round(sum(weight * set * rep)/sum(set)),1), by=.(date2,category)][order(date2)]
  return(aggData)
}


ByDateAgg = function(dt){
  dt2 = addMonthWeek(dt)
  aggData = dt2[,.(total_volume = sum(weight * set * rep),
          total_set = sum(set), total_rep = sum(set*rep)), 
       by=.(date2)][order(date2, -total_volume)]
  return(aggData)
}


