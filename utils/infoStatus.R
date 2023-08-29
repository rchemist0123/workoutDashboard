
import("glue")
getStatus = function(data, var){
  after = data[1, get(var)] 
  before = data[2, get(var)]
  delta = round((after-before)/before * 100, 1)
  if(delta > 0) {
    color = "danger"
    icon = "triangle-top"
    CSSclass = "change-value positive-change"   
    sign = "+"
  } else if (delta == 0) {
    color = "olive"
    icon = "triangle-minus"
    CSSclass <- "change-value zero-change"
    sign = ""
  } else {
    color = "lightblue"
    icon = "triangle-bottom"
    CSSclass = "change-value negative-change"   
    sign = ""
  }
  
  value = glue::glue("<span class='{CSSclass}'> {sign}{delta}%</span>")
  
  return(list(delta = delta, color=color, icon=icon, value=value))
} 