# set wd 

# setwd('"/Users/aleedom/Dropbox/Projects/R Projects/Shiny_apps/Police shootings/Completed app"')


# import data 

library(zoo)
library(tidyverse)
library(lubridate)
library(leaflet)
library(leaflet.extras)
library(utils)

data <- read.csv('final_df.csv') # for map 
demos <- read.csv('state_populations_with_shootings.csv') # for line charts 

# import 


# build UI 

ui <- fluidPage( ## update layout -- maximize space for map, choose a graphic to display underneath 
    titlePanel(
        'Tracking Police Shootings -- Visualizing Data from the Washington Post'),
    selectInput('state', 'Select State:',
                choices = sort(data$state),
                selected = 'CA'),
    fluidRow(column(6, 
                    leafletOutput('map')),
             column(6,
                    h4("What's the pace of fatal police shootings?"),
                    # checkboxGroupInput('year_choose', label = 'Choose a year to include', 
                    #                    choices = c(2015, 2016, 2017, 2018, 2019, 2020), 
                    #                    selected = c(2015, 2016, 2017, 2018, 2019, 2020)),
                    plotOutput('ytd_fatalities'))),
    # fluidRow(column(3,
    #                 h4('Select state'),
    #                 )),
    fluidRow(column(6,
                    h4('Fatal shootings by demographic in selected state'),
                    plotOutput('demos')), 
             column(6, 
                    h4('How do state demographics compare to fatal shootings?'), 
                    plotOutput('state_demos'))
    ))