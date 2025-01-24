source("data_setup.R")

server <- function(input, output) {
  filtered_acc_plot <- reactive({
    accident_graph_data <- accident_data %>% 
      filter(input$time[1] < time, input$time[2] > time) %>% 
      filter(input$district ==  District.Sector) %>% 
      mutate(time.round = floor(time))
  })
  
  filtered_acc_plot_one <- reactive({
    count(filtered_acc_plot(), vars = time.round)
  })
  

  data <- reactiveValues()
  
  # click interaction: graph one
  data$selected_time_one <- ""
  data$selected_freq <- ""
  data$selected_time <- ""
  
  # click interaction: graph two
  #data$selected_location <- ""
  data$selected_time_two <- ""
  data$selected_dist <- ""

  
  # GRAPH ONE
  output$acc_graph_one <- renderPlot({
    ggplot(data = filtered_acc_plot_one()) +
      geom_point(mapping = aes(
        x = vars, y = n,
        color = (vars == data$selected_time)
      ), size = 3) +
      guides(color = FALSE) +
      labs(
        y = "Count of traffic accidents",
        x = "Time (hour)"
      ) 

  })
  
  # click interaction: graph one
  output$select_time_one <- renderText({
    data$selected_time_one
  })
  
  output$freq <- renderText({
    data$selected_freq
  })
  
  observeEvent(input$plot_click_time, {
    selected <- nearPoints(filtered_acc_plot_one(), input$plot_click_time)
    data$selected_time_one <- paste0(selected$vars, ":00")
    data$selected_time <- selected$vars
    data$selected_freq <- selected$n
  })
  
  
  # GRAPH TWO
  output$acc_graph_two <- renderPlot({
    ggplot(data = filtered_acc_plot()) +
      geom_point(mapping = aes(
        x = Longitude, y = Latitude,
        color = (District.Sector == data$selected_dist)
      ), size = 1.5) +
      guides(color = FALSE) +
      coord_equal() +
      labs(
        title = "Seattle District Mapping"
      )
  })
  
  #click interaction: graph two
  #output$location <- renderText({
  #  data_selected_location
  #})
  
  output$num_selected <- renderText({
    length(data$selected_time_two)
  })
  
  output$select_time_two <- renderText({
    paste(sort(data$selected_time_two), collapse = ", ")
  })
  
  output$select_dist <- renderText({
    data$selected_dist[1]
  })
  
  observeEvent(input$plot_click_map, {
    selected <- nearPoints(filtered_acc_plot(), input$plot_click_map)
    #data$selected_location <- selected$HUNDREDBLOCKLOCATION
    data$selected_time_two <- selected$time
    data$selected_dist <- selected$District.Sector[1]
  })
  
}

shinyServer(server)