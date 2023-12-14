library(readr)
spotify_2000_2023 <- read_delim("Datos/spotify_2000_2023.csv", 
                                delim = ";", escape_double = FALSE, trim_ws = TRUE)
View(spotify_2000_2023)
glimpse(spotify_2000_2023)


library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(DT)
library(readr)
library(janitor)
library(openxlsx)

Spotify <- read_delim("Datos/spotify_2000_2023.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)

Spotify <- Spotify |>
  clean_names ()

year <- sort(unique(Spotify$year))  
genre <- unique(Spotify$top_genre)

ui <- dashboardPage(
  skin = "purple",
  dashboardHeader(title = "Spotify 2000 al 2023", titleWidth = 300),
  dashboardSidebar(
    width = 300,
    fluidRow(
      offset = 1, 
      align = "center",
      selectInput("year_filter", "Seleccione el Año:", choices = year, selected = year)
    ),
    fluidRow(
      offset = 1, 
      align = "center",
      selectInput("genre_filter", "Seleccione el Género:", choices = genre, selected = NULL)
    ),
    fluidRow(
      offset = 1, 
      align = "center",
      downloadButton("download_btn", "Descargar Información seleccionada")
    )
  ),
  dashboardBody(
    box(
      title = "Grafico de dispersión",
      status = "primary",
      solidHeader = TRUE,
      fluidRow(
        column(3, offset = 1, align = "center",
               selectInput(
                 inputId = "VariableX", 
                 label = "Selecciona la variable para el eje X", 
                 choices = c("bpm", "energy", "danceability", "dB", "liveness", "valence", "duration", "acousticness", "speechiness"),
                 multiple = FALSE
               )
        ),
        column(3, offset = 1, align = "center",
               actionButton("enter_scatter_plot", "Generar gráfico de dispersión")
        )
      ),
      plotlyOutput("scatter_plot")
    ),
    box(
      title = "Tabla con características de las Canciones",
      status = "primary",
      solidHeader = TRUE,
      DTOutput("filtered_table")
    )
  )
)
  
server <- function(input, output, session) {
  
  Spotify <- reactive({
    read_delim("Datos/spotify_2000_2023.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
  })
  
  output$download_btn <- downloadHandler(
    filename = function() {
      paste("filtered_Spotify_", input$year_filter, " ", input$genre_filter, ".xlsx", sep = "")
    },
    content = function(file) {
      filtered_Spotify <- Spotify() |>
        filter(year == as.numeric(input$year_filter)) |> 
        filter(top_genre == input$genre_filter | is.null(input$genre_filter))
      
      write.csv(filtered_Spotify, file, rowNames = FALSE)
    }
  )
  
  output$scatter_plot <- renderPlotly({
    filtered_Spotify <- Spotify() |>
      filter(year == as.numeric(input$year_filter)) |> 
      filter(top_genre == input$genre_filter | is.null(input$genre_filter))
    
    plot_ly(filtered_Spotify, 
            x = ~input$VariableX, 
            y = ~popularity, 
            text = ~title,  
            type = "scatter", 
            mode = "markers") |>
      layout(title = paste("Interactive Scatter Plot of Energy vs Popularity (", input$year_filter, ")"),
             xaxis = list(title = input$VariableX),
             yaxis = list(title = "Popularity"))
  })
  
  output$filtered_table <- renderDT({
    filtered_Spotify <- Spotify() |>
      filter(year == as.numeric(input$year_filter)) |> 
      filter(top_genre == input$genre_filter | is.null(input$genre_filter))
    
    datatable(filtered_Spotify, options = list(pageLength = 10))
  })
}
shinyApp(ui, server)

  