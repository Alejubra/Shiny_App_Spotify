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
    
  }
  
  # App
  shinyApp(ui = ui, server = server)
  