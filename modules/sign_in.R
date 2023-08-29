import("shiny") |> suppressMessages()
import("shinyauthr") |> suppressMessages()
suppressMessages(import("modules"))
suppressMessages(import("data.table"))
suppressMessages(import("dplyr"))
suppressMessages(import("DBI"))
suppressMessages(import("RPostgreSQL"))
suppressMessages(import("glue"))
suppressMessages(import("lubridate"))
CONSTS <- use("constants/constants.R")



ui <- function(id){
  ns <- NS(id)
  div(
    style="text-align:center",
    logoutUI(id=ns("logout")),
    loginUI(id=ns("login"), 
            cookie_expiry = CONSTS$cookie_expiry)
  )
}

server <- function(id){
  moduleServer(
    id,
    function(input, output, session){
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
        RPostgreSQL::dbWriteTable(conn = conn, 
                                  name = 'session_users', 
                                  value = tbl, append=T)
      }
      
      get_session_from_db = function(conn = const$con, expiry = const$cookie_expiry) {
        RPostgreSQL::dbReadTable(conn, "session_users") |> 
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
      
      observe({
        print(credentials()$info$user)
        print(credentials()$user_auth)
      })
      
      return(
        list(
          user_id = reactive(credentials()$info$user),
          auth = reactive(credentials()$user_auth)
          )
        )
      
    }
  )
}
