library(shiny)


shinyUI(navbarPage("Software Reliability Assessment in R",
                   tabPanel("Select, Analyze, and Filter Data",
                            
                            sidebarLayout(
                              sidebarPanel(h4("Select, Analyze, and Filter Failure Data"),
                                           fluidRow(
                                             column(10, fileInput("dataFile", label = h5("Select a failure data file")))
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    h5("Specify how failure data is plotted."),
                                                    
                                                    selectInput("dataPlotChoice", label = h6("Specify the data view"), 
                                                                choices = list("Times Between Failures" = 1, "Cumulative Failures" = 2,
                                                                               "Failure Rates" = 3), selected = 1)
                                                    )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    radioButtons("radioDataPlotType", label = h6("Specify how to draw the plot"),
                                                                 choices = list("Data points and lines" = 1, "Data points only" = 2, "Lines only" = 3),
                                                                 selected = 1)
                                             )
                                           ),

                                           fluidRow(
                                             column(12, 
                                                    br(),
                                                    h5("Examine the data for reliability growth."),
                                                    selectInput("trendPlotChoice", label = h6("Select a trend test"), 
                                                                choices = list("Laplace Test" = 1, "Running Arithmetic Average" = 2))
                                             ),
                                             br(),
                                             column(12,
                                                    numericInput("dataTrendSig", 
                                                                 label = h6("Specify the significance level"),
                                                                 min = 0, max = 1, step = 0.001,
                                                                 value = .05)
                                             ),
                                             br(),
                                             column(12, textOutput("trendMessage"))
                                           ),
                                           
                                           fluidRow(
                                             br(),
                                             column(12, downloadButton('saveTrendTable', 'Save Trend Test to Disk'))
                                           ),
                                           
                                           fluidRow(
                                             br(),
                                             h5("Filter the failure data or change its type."),
                                             column(12,
                                                    selectInput("dataSubsetChoice", label = h6("Select one or more failure categories to retain"), 
                                                                choices = list("Category 1" = 1, "Category 2" = 2,
                                                                               "Category 3" = 3, "Category 4" = 4), multiple=TRUE)  
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12,
                                                    actionButton("convertDataType", label = "Convert to Failure Counts") 
                                             ),
                                             br(), br(),
                                             column(7, downloadButton('saveData', 'Save Data to Disk')),
                                             column(4, actionButton("undoFilterConvert", label = "Undo"))
                                           )
                                           
                              ),
                              
                              mainPanel("Placeholder - data and trend plots go here")
                            )
                   ),
                   
                   tabPanel("Set Up and Apply Models",
                            
                            sidebarLayout(
                              sidebarPanel(h4("Configure and Apply Models"),
                                           h5("Set up the modeling data range, the initial parameter estimation interval, and the number of failures for which the models will make predictions"),
                                           fluidRow(
                                             column(12,
                                                    sliderInput("modelDataRange", h6("Specify the data to which the models will be applied."),
                                                                min = 1, max = 150, value = c(1, 120))
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12,
                                                    sliderInput("parmEstIntvl", h6("Specify the last data point for the initial parameter estimation interval."),
                                                                min = 1, max = 150, value = 60)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12,
                                                    numericInput("modelNumPredSteps", 
                                                                 label = h6("Specify for how many failures into the future the models will predict"),
                                                                 min = 1, value = 1)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12,
                                                    actionButton("runModels", label = "Run Models")
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    br(),
                                                    h5("Choose the model results to display."),
                                                    selectInput("modelResultChoice", label = h6("Choose one or more sets of model results"), 
                                                                choices = list("Musa Basic" = 1, "Musa Okumoto" = 2,
                                                                               "Geometric" = 3, "Littlewood-Verrall Linear"=4, "Littlewood-Verrall Quadratic"=5), 
                                                                multiple=TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    h5("Choose the type of plot for model results."),
                                                    selectInput("modelPlotChoice", label = h6("Choose a plot type"), 
                                                                choices = list("Times Between Failures" = 1, "Cumulative Failures" = 2,
                                                                               "Failure Intensity" = 3, "Reliability" = 4), selected = 1)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    checkboxInput("checkboxDataOnPlot", label = "Show data on plot", value = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    radioButtons("radioModelPlotType", label = h6("Specify how to draw the plot"),
                                                                 choices = list("Data points and lines" = 1, "Data points only" = 2, "Lines only" = 3),
                                                                 selected = 1)
                                             )
                                           )
                                           
                              ),
                              
                              mainPanel("Placeholder - model result plots go here")
                            )
                   ),
                   tabPanel("Query Model Results",
                            sidebarLayout(
                              sidebarPanel(h4("Make Detailed Predictions From Model Results"),
                                           fluidRow(
                                             column(12, 
                                                    br(),
                                                    h5("Choose one or more models for which detailed predictions will be made."),
                                                    selectInput("modelDetailPredChoice", label = h6("Choose one or more models"), 
                                                                choices = list("Musa Basic" = 1, "Musa Okumoto" = 2,
                                                                               "Geometric" = 3, "Littlewood-Verrall Linear"=4, "Littlewood-Verrall Quadratic"=5), 
                                                                multiple=TRUE)
                                             ),
                                             
                                             column(12, 
                                                    h5("How much time will be required to observe the next N failures")
                                             ),
                                             
                                             column(12,
                                                    numericInput("modelDetailPredTime", 
                                                                 label = h6("Specify the number of failures that are to be observed."),
                                                                 min = 1, value = 1)
                                             ),
                                             
                                             column(12, 
                                                    h5("How many failures will be observed over the next N seconds?")
                                             ),
                                             
                                             column(12,
                                                    numericInput("modelDetailPredFailures", 
                                                                 label = h6("Specify the amount of additional time for which the software will run."),
                                                                 min = 1, value = 1)
                                             )
                                           )
                              ),
                              
                              mainPanel("Placeholder - model evaluation plots and tables go here")
                            )
                            
                   ),
                   tabPanel("Evaluate Models",
                            sidebarLayout(
                              sidebarPanel(h4("Evaluate Model Goodness-of-Fit and Applicability"),
                                           fluidRow(
                                             column(12, 
                                                    h5("Select a model evaluation to display."),
                                                    selectInput("modelEvalChoice", label = h6("Choose a model evaluation test"), 
                                                                choices = list("Kolmogorov-Smirnov GOF Test" = 1, "-ln Prequential Likelihood" = 2,
                                                                               "Prequential Likelihood Ratio" = 3, "Model Bias" = 4, "Scatter Plot of u(i)" = 5, "Model Bias Trend" = 6, "Model Noise" = 7), selected = 1)
                                             ),
                                             column(12,
                                                    numericInput("numericEvalSigValue", 
                                                                 label = h6("Specify the significance level for the selected test"),
                                                                 min = 0, max = 1, step = 0.001,
                                                                 value = .05)
                                             )
                                             
                                           ),
                                           
                                           fluidRow(
                                             h5("Rank models by evaluation criteria"),
                                             column(1, ""),
                                             column(11, 
                                                    radioButtons("radioGOFRankEvalOrder", label = h6("Goodness of Fit"),
                                                                 choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5),
                                                                 selected = 1, inline = TRUE)
                                             ),
                                             column(2, ""),
                                             column(10, 
                                                    checkboxInput("checkboxGOFScreen", label = "Use GOF test as screen", value = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(1, ""),
                                             column(11, 
                                                    radioButtons("radioPLRankEvalOrder", label = h6("Prequential Likelihood"),
                                                                 choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5),
                                                                 selected = 2, inline = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(1, ""),
                                             column(11, 
                                                    radioButtons("radioBiasRankEvalOrder", label = h6("Model Bias"),
                                                                 choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5),
                                                                 selected = 3, inline = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(1, ""),
                                             column(11, 
                                                    radioButtons("radioBiasTrendRankEvalOrder", label = h6("Model Bias Trend"),
                                                                 choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5),
                                                                 selected = 4, inline = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(1, ""),
                                             column(11, 
                                                    radioButtons("radioNoiseRankEvalOrder", label = h6("Model Noise"),
                                                                 choices = list("1" = 1, "2" = 2, "3" = 3, "4" = 4, "5" = 5),
                                                                 selected = 5, inline = TRUE)
                                             )
                                           ),
                                           
                                           fluidRow(
                                             column(12, 
                                                    radioButtons("radioEvalPlotType", label = h5("Specify how to draw plots"),
                                                                 choices = list("Data points and lines" = 1, "Data points only" = 2, "Lines only" = 3),
                                                                 selected = 1)
                                             )
                                           )
                                           
                              ),
                              
                              mainPanel("Placeholder - model evaluation plots and tables go here")
                            )
                   )
))
