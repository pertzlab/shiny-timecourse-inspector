#
# Time Course Inspector: Shiny app for plotting time series data
# Author: Maciej Dobrzynski
#
# This module is for plotting individual time series
#


## UI ----

modTrajPlotUI =  function(id, label = "Plot Individual Time Series") {
  ns <- NS(id)
  
  tagList(
    
    checkboxInput(ns('chBplotStyle'),
                  'Appearance',
                  FALSE),
    conditionalPanel(
      condition = "input.chBplotStyle",
      ns = ns,
      
      fluidRow(
        column(
          3,
          numericInput(
            ns('inPlotTrajFacetNcol'),
            '#columns',
            value = PLOTNFACETDEFAULT,
            min = 1,
            width = '100px',
            step = 1
          )
        ),
        column(
          2,
          checkboxGroupInput(ns('chBPlotTrajStat'), 'Add', list('Mean' = 'mean', 
                                                                '95% CI' = 'CI', 
                                                                'SE' = 'SE'))
        ),
        column(
          3,
          sliderInput(ns('sliPlotTrajSkip'), 'Plot every n-th point', 
                      min = 1, max = 10, value = 1, step = 1),
          
          checkboxInput(ns('chBsetXbounds'), 'Bounds for X', FALSE),
          fluidRow(
            column(6,
                   uiOutput(ns('uiSetXboundsLow'))
            ),
            column(6,
                   uiOutput(ns('uiSetXboundsHigh'))
            )),
          
          checkboxInput(ns('chBsetYbounds'), 'Bounds for Y', FALSE),
          fluidRow(
            column(6,
                   uiOutput(ns('uiSetYboundsLow'))
            ),
            column(6,
                   uiOutput(ns('uiSetYboundsHigh'))
            ))
        ),
        column(
          2,
          numericInput(
            ns('inPlotTrajWidth'),
            'Width [%]',
            value = PLOTWIDTH,
            min = 10,
            width = '100px',
            step = 5
          ),
          numericInput(
            ns('inPlotTrajHeight'),
            'Height [px]',
            value = PLOTTRAJHEIGHT,
            min = 100,
            width = '100px',
            step = 50
          )
        )
      ),
      
    ),
    
    fluidRow(
      column(2,
             actionButton(ns('butPlotTraj'), 'Plot!')),
      column(2,
             checkboxInput(ns('chBplotTrajInt'), 'Interactive'))),
    uiOutput(ns('uiPlotTraj')),
    
    checkboxInput(ns('chBdownload'),
                  'Download',
                  FALSE),
    conditionalPanel(
      condition = "input.chBdownload",
      ns = ns,
      
      downPlotUI(ns('downPlotTraj'), "")
    ),
    
    modTrackStatsUI(ns('dispTrackStats'))
  )
}

## Server ----

#' Title
#'
#' @param input 
#' @param output 
#' @param session 
#' @param in.data time-series data in long format (data.table)
#' @param in.data.stim segments for plotting perturbations underneath time series (data.table)
#' @param in.fname string with a file name for saving plots
#' @param in.facet string with the grouping column for facetting
#' @param in.facet.color named vector with colours, named according to groups
#' @param in.ylab y-axis label (unused atm)
#'
#' @return
#' @export
#'
#' @examples
modTrajPlot = function(input, output, session, 
                       in.data, 
                       in.data.stim,
                       in.fname,
                       in.facet = COLGR, 
                       in.facet.color = NULL,
                       in.ylab = NULL) {
  
  ns <- session$ns
  
  ## UI rendering ----
  output$uiPlotTraj = renderUI({
    if (input$chBplotTrajInt)
      withSpinner(plotlyOutput(
        ns("outPlotTrajInt"),
        width = paste0(input$inPlotTrajWidth, '%'),
        height = paste0(input$inPlotTrajHeight, 'px'))
      ) else
        withSpinner(plotOutput(
          ns("outPlotTraj"),
          width = paste0(input$inPlotTrajWidth, '%'),
          height = paste0(input$inPlotTrajHeight, 'px'))
        )
  })
  
  # UI for bounding the x-axis
  output$uiSetXboundsLow = renderUI({
    ns <- session$ns
    
    if(input$chBsetXbounds) {
      
      loc.dt = in.data()
      
      if (is.null(loc.dt)) {
        cat(file = stderr(), 'uiSetXboundsLow: dt is NULL\n')
        return(NULL)
      }
      
      if (nrow(loc.dt) < 1)
        return(NULL)
      
      numericInput(
        ns('inSetXboundsLow'),
        label = 'Lower',
        step = 0.1, 
        value = floor(min(loc.dt[[COLRT]], na.rm = T))
      )
    }
  })
  
  
  output$uiSetXboundsHigh = renderUI({
    ns <- session$ns
    
    if(input$chBsetXbounds) {
      
      loc.dt = in.data()
      
      if (is.null(loc.dt)) {
        cat(file = stderr(), 'uiSetXboundsHigh: dt is NULL\n')
        return(NULL)
      }
      
      if (nrow(loc.dt) < 1)
        return(NULL)
      
      numericInput(
        ns('inSetXboundsHigh'),
        label = 'Upper',
        step = 0.1, 
        value = ceil(max(loc.dt[[COLRT]], na.rm = T))
      )
    }
  })
  
  
  # UI for bounding the y-axis
  output$uiSetYboundsLow = renderUI({
    ns <- session$ns
    
    if(input$chBsetYbounds) {
      
      loc.dt = in.data()
      
      if (is.null(loc.dt)) {
        cat(file = stderr(), 'uiSetYboundsLow: dt is NULL\n')
        return(NULL)
      }
      
      if (nrow(loc.dt) < 1)
        return(NULL)
      
      numericInput(
        ns('inSetYboundsLow'),
        label = 'Lower',
        step = 0.1, 
        value = min(loc.dt[[COLY]], na.rm = T)
      )
    }
  })
  
  
  output$uiSetYboundsHigh = renderUI({
    ns <- session$ns
    
    if(input$chBsetYbounds) {
      
      loc.dt = in.data()
      
      if (is.null(loc.dt)) {
        cat(file = stderr(), 'uiSetYboundsHigh: dt is NULL\n')
        return(NULL)
      }
      
      if (nrow(loc.dt) < 1)
        return(NULL)
      
      numericInput(
        ns('inSetYboundsHigh'),
        label = 'Upper',
        step = 0.1, 
        value = max(loc.dt[[COLY]], na.rm = T)
      )
    }
  })
  
  ## Plotting ====
  
  output$outPlotTraj <- renderPlot({
    
    loc.p = plotTraj()
    if(is.null(loc.p))
      return(NULL)
    
    return(loc.p)
  })
  
  output$outPlotTrajInt <- renderPlotly({
    # This is required to avoid
    # "Warning: Error in <Anonymous>: cannot open file 'Rplots.pdf'"
    # When running on a server. Based on:
    # https://github.com/ropensci/plotly/issues/494
    if (names(dev.cur()) != "null device")
      dev.off()
    pdf(NULL)
    
    loc.p = plotTraj()
    if(is.null(loc.p))
      return(NULL)
    
    return(ggplotly(loc.p))
  })
  
  plotTraj <- function() {
    cat(file = stderr(), 'plotTraj: in\n')
    
    # make the f-n dependent on the button click
    locBut = input$butPlotTraj
    
    # Check if data exists
    # Thanks to isolate all mods in the left panel are delayed 
    # until clicking the Plot button
    loc.dt = shiny::isolate(in.data())
    shiny::validate(
      shiny::need(!is.null(loc.dt), "Nothing to plot. Load data first!")
    )
    
    if (is.null(loc.dt)) {
      cat(file = stderr(), 'plotTraj: dt is NULL\n')
      
      return(NULL)
    }
    
    if (nrow(loc.dt) < 1) {
      cat(file = stderr(), 'plotTraj: dt has 0 rows\n')
      
      return(NULL)
    }
    
    # check if stim data exists
    loc.dt.stim = shiny::isolate(in.data.stim())
    
    if (is.null(loc.dt.stim)) {
      cat(file = stderr(), 'plotTraj: dt.stim is NULL\n')
    }
    
    # Future: change such that a column with colouring status is chosen by the user
    # colour trajectories, if dataset contains mid.in column
    # with filtering status of trajectory
    if (sum(names(loc.dt) %in% 'mid.in') > 0)
      loc.line.col.arg = 'mid.in'
    else
      loc.line.col.arg = NULL
    
    # select every other point for plotting
    loc.dt = loc.dt[, 
                    .SD[seq(1, 
                            .N, 
                            input$sliPlotTrajSkip)], 
                    by = id]
    
    # check if columns with XY positions are present
    if (sum(names(loc.dt) %like% 'pos') == 2)
      locPos = TRUE
    else
      locPos = FALSE
    
    # check if column with ObjectNumber is present
    if (sum(names(loc.dt) %like% 'obj.num') == 1)
      locObjNum = TRUE
    else
      locObjNum = FALSE
    
    # in.facet.color is typically used when plotting time series per clusters.
    # The number of colours in the palette has to be equal to the number of groups.
    # This might differ if the user selects manually groups (e.g. clusters) to display.
    if (is.null(in.facet.color)) {
      loc.facet.color = NULL
    } else {
      loc.facet.color = in.facet.color()
    }
    
    
    loc.xlim.arg = NULL
    if(input$chBsetXbounds) {
      loc.xlim.arg = c(input$inSetXboundsLow, input$inSetXboundsHigh)
    } 
    
    loc.ylim.arg = NULL
    if(input$chBsetYbounds) {
      loc.ylim.arg = c(input$inSetYboundsLow, input$inSetYboundsHigh)
    } 
    
    p.out = LOCplotTraj(
      dt.arg = loc.dt,
      x.arg = COLRT,
      y.arg = COLY,
      group.arg = COLID,
      facet.arg = in.facet,
      facet.ncol.arg = input$inPlotTrajFacetNcol,
      facet.color.arg = loc.facet.color, 
      dt.stim.arg = loc.dt.stim, 
      x.stim.arg = c('tstart', 'tend'),
      y.stim.arg = c('ystart', 'yend'), 
      stim.bar.width.arg = 1,
      xlab.arg = 'Time',
      line.col.arg = loc.line.col.arg,
      aux.label1 = if (locPos) COLPOSX else NULL,
      aux.label2 = if (locPos) COLPOSY else NULL,
      aux.label3 = if (locObjNum) COLOBJN else NULL,
      stat.arg = input$chBPlotTrajStat,
      ylim.arg = loc.ylim.arg,
      xlim.arg = loc.xlim.arg
    )
    
    return(p.out)
  }
  
  ## Download ----
  
  # Trajectory plot - download pdf
  callModule(downPlot, "downPlotTraj", 
             in.fname, 
             plotTraj, 
             TRUE)
  
  ## Modules ----
  
  callModule(modTrackStats, 'dispTrackStats',
             in.data = in.data,
             in.bycols = in.facet)
  
}