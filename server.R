# data <- read.csv('final_df.csv') # for map 
# demos <- read.csv('state_populations_with_shootings.csv') # for line charts 

library(zoo)
library(tidyverse)
library(lubridate)
library(leaflet)
library(leaflet.extras)
library(utils)

data <- read.csv('final_df.csv') # for map 
demos <- read.csv('state_populations_with_shootings.csv') # for line charts 

server <- function(input,output, session){
    
    filterData = reactiveVal(data)
    
    filtered_df <- reactive({
        filterData <- filterData() %>% filter(state == input$state)
    })
    
    filterStates <- reactiveVal(data)
    
    state_totals <- reactive({
        
        state_totals <- filterStates() %>% dplyr::arrange(date) %>%  group_by(state, date) %>%  mutate(total = sum(id)) %>%
            ungroup()
        
        state_totals %>% 
            filter(state == input$state) %>% 
            mutate(day_of_year = yday(date), 
                   year = year(date)) %>%
            group_by(year) %>%
            mutate(cv = cumsum(total)) 
        
    })
    
    state_demos <- reactive({
        
        demos %>% 
            filter(state == input$state) %>% 
            mutate(start = 0, 
                   end = 1)
        
    })
    
    output$map <- renderLeaflet({
        leaflet(options = leafletOptions(dragging = T, 
                                         maxZoom = 10)) %>% 
            addProviderTiles(provider = 'CartoDB.PositronNoLabels') %>% 
            setView(lat = 39.8278515, 
                    lng = -98.5883632, 
                    zoom = 4) %>% 
            addCircleMarkers(group = data$city_state,
                             lng = data$lon, lat = data$lat, 
                             stroke = F, 
                             radius = 3,
                             label = paste0(data$name, data$armed), 
                             clusterOptions = markerClusterOptions())
        # add counties 
        
    })
    
    output$demos <- renderPlot({ # needs better aesthetics 
        ggplot(filtered_df(), aes(x = year(ymd(date)))) + 
            geom_density( alpha = .9, position = 'identity') +
            facet_grid(body_camera ~race, labeller = labeller(body_camera = c('True' = 'Body camera enabled',
                                                                              'False' = 'No body camera'))) + 
            scale_color_brewer(palette = 'YlOrBr') + 
            theme(panel.grid = element_blank(), 
                  panel.background = element_blank(), 
                  axis.text.x = element_text(angle = 45, hjust = 1)) + 
            xlab('Number of fatal police shootings by year') + 
            ylab('Was the officer wearing a body camera?')
    })
    
    output$ytd_fatalities <- renderPlot({ # needs better aesthetics 
        ggplot(state_totals(), aes(x = day_of_year, y = cv, color = factor(year))) + 
            geom_point(aes(shape = factor(year), color = factor(year))) + 
            geom_line() + scale_color_brewer(palette = 'YlOrBr') + 
            theme(axis.text.y.left = element_blank()) + 
            theme(panel.background = element_blank()) +
            xlab('Day of the Year') + 
            ylab('Cumulative Fatal Shootings by Police')
    })
    
    output$state_demos <- renderPlot({
        ggplot(state_demos(), aes( label = race, color = race)) + 
            geom_segment(aes(x = start, 
                             xend = end, 
                             y = pct_of_pop, 
                             yend = racial_total)) + 
            geom_label(aes(x = 0, 
                           y = pct_of_pop)) + 
            theme_bw() + 
            xlab('Relative share of population vs relative share of fatal shootings') + 
            ylab('Percentage of Population')
        
        
    })
    
}