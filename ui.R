# CONSTS <- use("constants/constants.R")

ui <- dashboardPage(
  preloader = list(html=tagList(spin_1(), "Loading...")),
  title = "점진적 과부하",
  scrollToTop = T,
  header = dashboardHeader(
    uiOutput("welcome"),
    div(class = "pull-right", logoutUI(id="logout"))
  ),
  sidebar = dashboardSidebar(
    sidebarUserPanel(
      image = "https://cdn-icons-png.flaticon.com/128/5203/5203764.png",
      name = "점진적 과부하"
    ),
    sidebarMenu(
      id="sidebarmenu",
      menuItem(
        "기록",
        tabName="write",
        icon = icon("pencil")
      ),
      menuItem(
        "대시보드",
        tabName="dashboard",
        icon = icon("signal")
      )
    )
  ),
  body = dashboardBody(
    tags$head(includeCSS("www/style.css")),
    loginUI(id="login", 
            title = "Sign in",
            user_title = "ID",
            pass_title = "PW",
            cookie_expiry = const$cookie_expiry),
    tabItems(
      tabItem(
        tabName="write",
        uiOutput("write_diary")
      ),
      tabItem(
        tabName = "dashboard",
        uiOutput("dashboard")
      )
    )
  )
)




  



