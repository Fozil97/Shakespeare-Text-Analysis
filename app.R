library(shiny)
library(tidyverse)
library(wordcloud)
library(ggplot2)
library(shinythemes)
library(RColorBrewer)
library(tidytext)
library(shinythemes)

# task4: add in getFreq function for pre-processing
getFreq <- function(book, stopwords = TRUE) {
  # check that only one of three books is selected
  if (!(book %in% books))
    stop("Unknown book")
  
  text <-  tibble(text = readLines(sprintf("./data/%s.txt", book), encoding="UTF-8"))
  
  # could also pass column of text/character instead
  text <- text %>%
    unnest_tokens(word, text) %>%
    count(word, sort = TRUE) 
  
  if(stopwords){
    text <- text %>%
      anti_join(stop_words)
  }
  
  return(text)
}


# The list of valid books
books <- list("A Mid Summer Night's Dream" = "summer",
              "The Merchant of Venice" = "merchant",
              "Romeo and Juliet" = "romeo")


# task6: add in shinythemes function
ui <- fluidPage(theme = shinytheme("cerulean"),
  titlePanel("Shakespeare's Plays Word Frequencies"), # Application title
  
  # task1: add in the sidebarLayout with sidebarPanel and mainPanel
  sidebarLayout(
    
    # task2: add in the inputs in the sidebarPanel
    sidebarPanel(
      selectInput(inputId = "selectbook", label = "Choose a book:", choices = books),
      checkboxInput(inputId = "stopwords", label = "Stop words:", value = TRUE),
      actionButton(inputId = "Rerun", label = "Rerun"),
      hr(),
      h3("Word Cloud Settings"),
      sliderInput(inputId = "maxwords", label = "Max # of Words:", min = 10, max = 200, value = 100, step = 10),
      sliderInput(inputId = "sizelargewords", label = "Size of largest words:", min = 1, max = 8, value = 4),
      sliderInput(inputId = "sizesmallwords", label = "Size of smallest words:", min = 0.1, max = 4, value = 0.5),
      hr(),
      h3("Word Count Settings"),
      sliderInput(inputId = "minwords", label = "Minimum words for Counts Chart:", min = 10, max = 100, value = 25),
      sliderInput(inputId = "fontsizewords", label = "Word size for Counts Chart:", min = 8, max = 30, value = 14)
      
    ),
    
    # task1: within the mainPanel, create two tabs (Word Cloud and Frequency)
    mainPanel(
      tabsetPanel(
        # task3: add in the outputs in the sidebarPanel
        # task6: and modify your figure heights
        tabPanel("Word Cloud", plotOutput("cloud", height = "600px")), 
        tabPanel("Word Counts", plotOutput("freq", height = "600px")), 
      )
    )
  )
  
)

server <- function(input, output) {
  
  sidebarPanel(
    # Inputs excluded for brevity
  )
  mainPanel(
    # Outputs excluded for brevity 
  )
  
  # task5: add in reactivity for getFreq function based on inputs
  freq <- reactive({
    withProgress({
      setProgress(message = "Processing corpus...")
      getFreq(input$selectbook, input$stopwords) # ... = replace with the two inputs from Task 2
    })
  })
  
  rerun_button <- eventReactive(input$Rerun, {
    freq()
  })
  
  output$cloud <- renderPlot({
    v <- freq()
    pal <- brewer.pal(8,"Dark2")

    v %>%
      with(
        wordcloud(
          word,
          n,
          scale = c(input$sizelargewords, input$sizesmallwords),
          random.order = FALSE,
          max.words = input$maxwords,
          colors=pal))

  })
  
  output$freq <- renderPlot({
    v <- freq()
    v %>%
      filter(n>input$minwords)%>%
      ggplot(aes(x=reorder(word, n), y=n)) +
        geom_col() +
        coord_flip() +
        theme(text = element_text(size = input$fontsizewords),
              axis.title.x=element_blank(),
              axis.title.y=element_blank())
  })
  
}

shinyApp(ui = ui, server = server)
