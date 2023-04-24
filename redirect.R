library(shiny)

ui <- fluidPage(
  tags$style(HTML("
    html, body {
      width: 100%;
      height: 100%;
      margin: 0;
      padding: 0;
    }
    #target-iframe {
      width: 100%;
      height: 100%;
      border: none;
    }
  ")),
  tags$iframe(id = "target-iframe", src = "https://apps.analyticadss.com/flightrisk/")
)

server <- function(input, output) {}

shinyApp(ui, server)
