
import("DBI") |> suppressMessages()
import("shiny") |> suppressMessages()
import("modules") |> suppressMessages()
import("RPostgreSQL") |> suppressMessages()

# APP_TITLE <- "Workout Diary"
# APP_TIME_RANGE <- "January 2019 to May 2019"
# APP_VERSION <- "1.0.0"

COLORS <- list(
  white = "#FFF",
  black = "#0a1e2b",
  primary = "#0099F9",
  secondary = "#15354A",
  ash = "#B3B8BA",
  increased = "#FF1E1F",
  decreased = "dodgerblue",
  ash_light = "#e3e7e9",
  #https://www.schemecolor.com/the-green-sea.php
  NATURALSEA = c("#3E4087","#39AEC5","#76CED5","#3789C5","#1E72AE", "#245191"),
  MOSS = c("#05597D", "#2CACC6", "#94DEDB", "#01F9C6", "#59D2AC", "#05857A","#004B49","#00637C"),
  MIDNIGHT = c("#E65F8E", "#A86BD1", "#3AA5D1", "#3BB58F", "#3A63AD"),
  BERRY = c("#F88FB2", "#ED5C8B", "#D5255E", "#A31246", "#740030"),
  OCEAN = c("#77C2FE", "#249CFF", "#1578CF", "#0A579E", "#003870"),
  SUNSET = c("#FFCA3E", "#FF6F50", "#D03454", "#9C2162", "#772F67"),
  CUSTOM = c("#FF3747","#187B30","#2494CC")
)

# SQLite
con = dbConnect(
  drv = RSQLite::SQLite(),
  dbname = "db.db"
)
# conf = config::get("postgres")
# con = dbConnect(
#   dbDriver("PostgreSQL"),
#   dbname = conf$dbname,
#   host = conf$host,
#   port = conf$port,
#   user = conf$user,
#   password = conf$password,
#   options = "-c search_path=diary"
# )



# con = dbConnect(dbDriver("PostgreSQL"),
#                 dbname = "workout",
#                 host = "localhost",
#                 port=5432,
#                 user="jyh",
#                 password = "Zpflrjs94!",
#                 options="-c search_path=diary"
#                 )

cookie_expiry = 7

makeReactiveTrigger <- function(){
  rv <- reactiveValues(a=0)
  list(
    depend = function(){
      rv$a
      invisible()
    },
    trigger = function(){
      rv$a <- isolate(rv$a+1)
    }
  )
}
dbTrigger <- makeReactiveTrigger()
