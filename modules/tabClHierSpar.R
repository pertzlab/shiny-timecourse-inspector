#
# Time Course Inspector: Shiny app for plotting time series data
# Author: Maciej Dobrzynski
#
# This module is for sparse hierarchical clustering using sparcl package
#

helpText.clHierSpar = c(alImportance = paste0("<p>Weight factors (WF) calculated during clustering ",
                                              "reflect the importance of time points in the clustering. ",
                                              "The following labels are used to indicate the importance:",
                                              "<li>Black - time point not taken into account</li>",
                                              "<li><p, style=\"color:DodgerBlue;\">* - low, WF∈(0, 0.1]</p></li>",
                                              "<li><p, style=\"color:MediumSeaGreen;\">** - medium, WF∈(0.1, 0.5]</p></li>",
                                              "<li><p, style=\"color:Tomato;\">*** - high, WF∈(0.5, 1.0]</p></li>",
                                              "</p><p>Witten and Tibshirani (2010): ",
                                              "<i>A framework for feature selection in clustering</i>; ",
                                              "Journal of the American Statistical Association 105(490): 713-726.</p>"),
                        downCellClSpar = "Download a CSV with cluster assignments to time series ID",
                        downDendSpar = "Download an RDS file with dendrogram object. Read later with readRDS() function.")

# UI ----
tabClHierSparUI <- function(id, label = "Sparse Hierarchical Clustering") {
  ns <- NS(id)
  
  tagList(
    h4(
      "Sparse hierarchical clustering using ",
      a("sparcl", 
        href = "https://cran.r-project.org/web/packages/sparcl/",
        title="External link",
        target = "_blank")
    ),
    p("Columns in the heatmap labeled according to their ",
      actionLink(ns("alImportance"), "importance.")),
    br(),
    fluidRow(
      column(
        3,
        selectInput(
          ns("selDiss"),
          label = ("Dissimilarity measure"),
          choices = list("Euclidean" = "squared.distance",
                         "Manhattan" = "absolute.value"),
          selected = 1
        ),
        selectInput(
          ns("selLink"),
          label = ("Linkage method"),
          choices = list(
            "Average"  = "average",
            "Complete" = "complete",
            "Single"   = "single",
            "Centroid" = "centroid"
          ),
          selected = 1
        )
      ),
      
      column(
        6,
        sliderInput(
          ns('inPlotHierSparNclust'),
          'Number of dendrogram branches to cut',
          min = 1,
          max = 20,
          value = 1,
          step = 1,
          ticks = TRUE,
          round = TRUE
        ),
        checkboxInput(ns('chBclDisp'), 'Select clusters to display'),
        uiOutput(ns('selClDispUI')),
        
        checkboxInput(ns('inHierSparAdv'),
                      'Advanced options',
                      FALSE),
        uiOutput(ns('uiPlotHierSparNperms')),
        uiOutput(ns('uiPlotHierSparNiter')),
      ),
      
      column(3,
             selectInput(
               ns("selPalDend"),
               label = "Cluster colour palette",
               choices = l.col.pal.dend.2,
               selected = 'Color Blind'
             ),
             
             downloadButton(ns('downCellClSpar'), 'Cluster assignments'),
             bsTooltip(ns("downCellClSpar"),
                       helpText.clHierSpar[["downCellClSpar"]],
                       placement = "top",
                       trigger = "hover",
                       options = NULL),
             br(),
             
             downloadButton(ns('downDendSpar'), 'Dendrogram object'),
             bsTooltip(ns("downDendSpar"),
                       helpText.clHierSpar[["downDendSpar"]],
                       placement = "top",
                       trigger = "hover",
                       options = NULL),
             
      )
    ),
    
    
    br(),
    
    tabsetPanel(
      tabPanel('Heatmap',
               br(),
               checkboxInput(ns('chBplotStyle'),
                             'Appearance',
                             FALSE),
               conditionalPanel(
                 condition = "input.chBplotStyle",
                 ns = ns,
                 fluidRow(
                   column(3,
                          selectInput(
                            ns("selectPlotHierSparPalette"),
                            label = "Heatmap\'s colour palette",
                            choices = l.col.pal,
                            selected = 'Spectral'
                          ),
                          checkboxInput(ns('inPlotHierSparRevPalette'), 'Reverse heatmap\'s colour palette', TRUE),
                          checkboxInput(ns('selectPlotHierSparKey'), 'Plot colour key', TRUE),
                          
                          checkboxInput(ns('chBsetColBounds'), 'Set bounds for colour scale', FALSE),
                          
                          fluidRow(
                            column(3,
                                   uiOutput(ns('uiSetColBoundsLow'))
                            ),
                            column(3,
                                   uiOutput(ns('uiSetColBoundsHigh'))
                            )
                          )
                   ),
                   column(3,
                          sliderInput(
                            ns('inPlotHierSparNAcolor'),
                            'Shade of grey for NA values',
                            min = 0,
                            max = 1,
                            value = 0.8,
                            step = .1,
                            ticks = TRUE
                          ),
                          checkboxInput(ns('selectPlotHierSparDend'), 'Plot dendrogram and re-order samples', TRUE),
                   ),
                   column(3,
                          numericInput(
                            ns('inPlotHierSparMarginX'),
                            'Bottom margin',
                            5,
                            min = 1,
                            width = "120px"
                          ),
                          numericInput(
                            ns('inPlotHierSparFontY'),
                            'Font size column labels',
                            1,
                            min = 0,
                            width = "180px",
                            step = 0.1
                          ),
                          numericInput(ns('inPlotHierSparHeatMapHeight'), 
                                       'Display plot height [px]', 
                                       value = 600, 
                                       min = 100,
                                       step = 50, 
                                       width = "180px")
                          
                   ),
                   column(3,
                          numericInput(
                            ns('inPlotHierSparMarginY'),
                            'Right margin',
                            20,
                            min = 1,
                            width = "120px"
                          ),
                          numericInput(
                            ns('inPlotHierSparFontX'),
                            'Font size row labels',
                            1,
                            min = 0,
                            width = "180px",
                            step = 0.1
                          )
                   )
                 )
               ),
               
               checkboxInput(ns('chBdownload'),
                             'Download',
                             FALSE),
               conditionalPanel(
                 condition = "input.chBdownload",
                 ns = ns,
                 
                 downPlotUI(ns('downPlotHMspar'), "")
               ),

               actionButton(ns('butPlot'), 'Plot!'),
               withSpinner(plotOutput(ns('outPlotHierSpar')))
               
      ),
      
      tabPanel('Cluster averages',
               br(),
               modTrajRibbonPlotUI(ns('modPlotHierSparTrajRibbon'))),
      
      tabPanel('Time series in clusters',
               br(),
               modTrajPlotUI(ns('modPlotHierSparTraj'))),
      
      tabPanel('PSD',
               br(),
               modPSDPlotUI(ns('modPlotHierSparPsd'))),
      
      tabPanel('Cluster distribution',
               br(),
               modClDistPlotUI(ns('hierClSparDistPlot')))
    )
  )
}

# SERVER ----
tabClHierSpar <- function(input, output, session, 
                          in.dataWide, 
                          in.data4trajPlot, 
                          in.data4stimPlot) {
  
  ns = session$ns
  
  # Return the number of clusters from the slider 
  # and delay by a constant in milliseconds defined in auxfunc.R
  intNclust = reactive({
    return(input$inPlotHierSparNclust)
  }) %>% debounce(MILLIS)
  
  
  # UI for advanced options
  output$uiPlotHierSparNperms = renderUI({
    ns <- session$ns
    if (input$inHierSparAdv)
      sliderInput(
        ns('inPlotHierSparNperms'),
        'Number of permutations',
        min = 1,
        max = 20,
        value = 1,
        step = 1,
        ticks = TRUE
      )
  })
  
  output$uiSetColBoundsLow = renderUI({
    ns <- session$ns
    
    if(input$chBsetColBounds) {
      
      loc.dt = in.data4trajPlot()
      
      numericInput(
        ns('inSetColBoundsLow'),
        label = 'Lower',
        step = 0.1, 
        value = floor(min(loc.dt[['y']], na.rm = T))
      )
    }
  })
  
  
  output$uiSetColBoundsHigh = renderUI({
    ns <- session$ns
    
    if(input$chBsetColBounds) {
      
      loc.dt = in.data4trajPlot()
      
      numericInput(
        ns('inSetColBoundsHigh'),
        label = 'Upper',
        step = 0.1, 
        value = ceil(max(loc.dt[['y']], na.rm = T))
      )
    }
  })
  
  # UI for advanced options
  output$uiPlotHierSparNiter = renderUI({
    ns <- session$ns
    
    if (input$inHierSparAdv)
      sliderInput(
        ns('inPlotHierSparNiter'),
        'Number of iterations',
        min = 1,
        max = 50,
        value = 1,
        step = 1,
        ticks = TRUE
      )
  })
  
  # Manually choose clusters to display
  output$selClDispUI = renderUI({
    ns <- session$ns
    
    if(input$chBclDisp) {
      selectInput(ns('selClDisp'), 'Select clusters to display', 
                  choices = seq(1, intNclust(), 1),
                  multiple = TRUE, 
                  selected = 1)
    }
  })
  
  
  objHclust <- reactive({
    cat(file = stderr(), 'objHclust \n')
    
    dm.t = in.dataWide()
    if (is.null(dm.t)) {
      return()
    }
    
    #cat('rownames: ', rownames(dm.t), '\n')
    #cat('=============\ndimensions:', dim(dm.t), '\n')
    
    perm.out <- HierarchicalSparseCluster.permute(
      dm.t,
      wbounds = NULL,
      nperms = ifelse(input$inHierSparAdv, input$inPlotHierSparNperms, 1),
      dissimilarity = input$selDiss
    )
    
    locHC <- HierarchicalSparseCluster(
      dists = perm.out$dists,
      wbound = perm.out$bestw,
      niter = ifelse(input$inHierSparAdv, input$inPlotHierSparNiter, 1),
      method = input$selLink,
      dissimilarity = input$selDiss
    )
    
    #cat('=============\nlocHC:\n')
    #print(locHC$hc)
    
    return(locHC)
  })
  
  
  
  # Return a cut dendrogram with branches coloured according to a chosen palette.
  dendCutColor <- reactive({
    if (DEB) {
      cat(file = stderr(), 'tabClHierSpar:dendCutColor\n')
    }
    
    # calculate sparse hierarchical clustering
    locHC = objHclust()
    if (is.null(locHC)) {
      return(NULL)
    }
    
    # number of clusters at which dendrogram is cut
    locK = intNclust()
    
    locDend = LOCdendCutColor(inHclust = locHC$hc,
                              inK = locK,
                              inColPal = input$selPalDend)
    
    return(locDend)
  })
  
  # Returns a table prepared with f-n getClCol
  # for hierarchical clustering.
  # The table contains colours assigned to clusters.
  # Colours are obtained from the dendrogram using dendextend::get_leaves_branches_col
  getClColHierSpar <- reactive({
    cat(file = stderr(), 'getClColHierSpar \n')
    
    locDend = dendCutColor()
    if (is.null(locDend))
      return(NULL)
    
    # obtain relations between cluster and colors from the dendrogram
    locVecCol = LOCvecColWithCl(locDend, 
                                input$inPlotHierSparNclust)
    
    return(locVecCol)
  })
  
  
  # return all unique track object labels (created in dataMod)
  # This will be used to display in UI for trajectory highlighting
  getDataTrackObjLabUni_afterTrim <- reactive({
    cat(file = stderr(), 'getDataTrackObjLabUni_afterTrim\n')
    loc.dt = in.dataWide()
    
    if (is.null(loc.dt))
      return(NULL)
    else
      return(rownames(loc.dt))
  })
  
  # return dt with cell IDs and their corresponding condition name
  # The condition is the column defined by facet groupings
  getDataCond <- reactive({
    cat(file = stderr(), 'getDataCond\n')
    loc.dt = in.data4trajPlot()
    
    if (is.null(loc.dt))
      return(NULL)
    else
      return(unique(loc.dt[, .(id, group)]))
    
  })
  
  # prepare data for plotting trajectories per cluster
  # outputs dt as data4trajPlot but with an additional column 'cl' that holds cluster numbers
  # additionally some clusters are omitted according to manual selection
  data4trajPlotClSpar <- reactive({
    cat(file = stderr(), 'data4trajPlotClSpar: in\n')
    
    loc.dt = in.data4trajPlot()
    
    if (is.null(loc.dt)) {
      cat(file = stderr(), 'data4trajPlotClSpar: dt is NULL\n')
      return(NULL)
    }
    
    cat(file = stderr(), 'data4trajPlotClSpar: dt not NULL\n')
    
    #cat('rownames: ', rownames(in.dataWide()), '\n')
    
    # get cellIDs with cluster assignments based on dendrogram cut
    loc.dt.cl = LOCgetDataClSpar(dendCutColor(), 
                                 input$inPlotHierSparNclust, 
                                 getDataTrackObjLabUni_afterTrim())
    
    # Keep only clusters manually specified in input$selClDisp
    # The order of clusters in the input field doesn't matter!
    if(input$chBclDisp) {
      if (length(input$selClDisp) > 0) {
        loc.dt.cl = loc.dt.cl[get(COLCL) %in% input$selClDisp]
      } else {
        return(NULL)
      }
    }
    
    # add the column with cluster assignment to the main dataset
    loc.dt = merge(loc.dt, loc.dt.cl, by = COLID)
    
    return(loc.dt)    
  })
  
  data4stimPlotClSpar <- reactive({
    cat(file = stderr(), 'data4stimPlotClSpar: in\n')
    
    loc.dt = in.data4stimPlot()
    
    if (is.null(loc.dt)) {
      cat(file = stderr(), 'data4stimPlotClSpar: dt is NULL\n')
      return(NULL)
    }
    
    cat(file = stderr(), 'data4stimPlotClSpar: dt not NULL\n')
    return(loc.dt)
  })
  
  
  # download a CSV with a list of cellIDs with cluster assignments
  output$downCellClSpar <- downloadHandler(
    filename = function() {
      paste0('clust_hierSpar_data_',
             ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
             '_',
             input$selLink, '.csv')
    },
    
    content = function(file) {
      write.csv(x = LOCgetDataClSpar(dendCutColor(), 
                                     input$inPlotHierSparNclust, 
                                     getDataTrackObjLabUni_afterTrim()), 
                file = file, row.names = FALSE)
    }
  )
  
  # download an RDS file with dendrogram objet
  output$downDendSpar <- downloadHandler(
    filename = function() {
      paste0('clust_hierSpar_dend_',
             input$selDiss,
             '_',
             input$selLink, '.rds')
    },
    
    content = function(file) {
      saveRDS(object = dendCutColor(), file = file)
    }
  )
  
  # prepare data for barplot with distribution of items per condition  
  data4clSparDistPlot <- reactive({
    cat(file = stderr(), 'data4clSparDistPlot: in\n')
    
    # get cell IDs with cluster assignments depending on dendrogram cut
    locDend <- dendCutColor()
    if (is.null(locDend)) {
      cat(file = stderr(), 'plotClSparDist: locDend is NULL\n')
      return(NULL)
    }
    
    # get cell id's with associated cluster numbers
    locDTcl = LOCgetDataClSpar(locDend, input$inPlotHierSparNclust, getDataTrackObjLabUni_afterTrim())
    
    # get cellIDs with condition name
    locDTgr = getDataCond()
    if (is.null(locDTgr)) {
      cat(file = stderr(), 'plotClSparDist: locDTgr is NULL\n')
      return(NULL)
    }
    
    locDT = merge(locDTcl, 
                  locDTgr, 
                  by = COLID)
    
    # Keep only clusters manually specified in input$selClDisp
    # The order of clusters in the input field doesn't matter!
    if(input$chBclDisp) {
      if (length(input$selClDisp) > 0) {
        locDT = locDT[get(COLCL) %in% input$selClDisp]
      } else {
        return(NULL)
      }
    }
    
    # Count the number of time series per group, per cluster
    locDTaggr = locDT[, 
                      .(xxx = .N), 
                      by = c(COLGR, 
                             COLCL)]
    
    setnames(locDTaggr, "xxx", COLNTRAJ)
    
    return(locDTaggr)
    
  })
  
  # Function instead of reactive as per:
  # http://stackoverflow.com/questions/26764481/downloading-png-from-shiny-r
  # This function is used to plot and to download a pdf
  plotHierSpar <- function() {
    cat(file = stderr(), 'plotHierSpar: in\n')
    
    # make the f-n dependent on the button click
    locBut = input$butPlot
    
    # Check if main data exists
    # Thanks to isolate all mods in the left panel are delayed 
    # until clicking the Plot button
    loc.dm = shiny::isolate(in.dataWide())
    locHC = shiny::isolate(objHclust())
    locDend = shiny::isolate(dendCutColor())
    
    shiny::validate(
      shiny::need(!is.null(loc.dm), "Nothing to plot. Load data first!"),
      shiny::need(!is.null(locHC), "Did not cluster"),
      shiny::need(!is.null(locDend), "Did not create dendrogram")
    )
    
    # Dummy dependency to redraw the heatmap without clicking Plot
    # when changing the number of clusters to highlight
    locK = intNclust()
    
    # create column labels according to importance weights
    loc.colnames = paste0(ifelse(locHC$ws == 0, "",
                                 ifelse(
                                   locHC$ws <= 0.1,
                                   "* ",
                                   ifelse(locHC$ws <= 0.5, "** ", "*** ")
                                 )),  colnames(loc.dm))
    
    # add color to column labels according to importance weights
    loc.colcol   = ifelse(locHC$ws == 0,
                          "black",
                          ifelse(
                            locHC$ws <= 0.1,
                            "blue",
                            ifelse(locHC$ws <= 0.5, "green", "red")
                          ))
    
    loc.col.bounds = NULL
    if (input$chBsetColBounds)
      loc.col.bounds = c(input$inSetColBoundsLow, input$inSetColBoundsHigh)
    else 
      loc.col.bounds = NULL
    
    
    loc.p = LOCplotHMdend(loc.dm,
                          locDend, 
                          palette.arg = input$selectPlotHierSparPalette, 
                          palette.rev.arg = input$inPlotHierSparRevPalette, 
                          dend.show.arg = input$selectPlotHierSparDend, 
                          key.show.arg = input$selectPlotHierSparKey, 
                          margin.x.arg = input$inPlotHierSparMarginX, 
                          margin.y.arg = input$inPlotHierSparMarginY, 
                          nacol.arg = input$inPlotHierSparNAcolor, 
                          colCol.arg = loc.colcol,
                          labCol.arg = loc.colnames,
                          font.row.arg = input$inPlotHierSparFontX, 
                          font.col.arg = input$inPlotHierSparFontY, 
                          breaks.arg = loc.col.bounds,
                          title.arg = paste(
                            "Distance measure: ",
                            input$selDiss,
                            "\nLinkage method: ",
                            input$selLink
                          ))
    
    return(loc.p)
  }
  
  getPlotHierSparHeatMapHeight <- function() {
    return (input$inPlotHierSparHeatMapHeight)
  }
  
  createFnameHeatMap = reactive({
    
    paste0('clust_hierSparse_heatMap_',
           ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
           '_',
           input$selLink,
           '.png')
  })
  
  createFnameTrajPlot = reactive({
    
    paste0('clust_hierSparse_tCourses_',
           ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
           '_',
           input$selLink, 
           '.pdf')
  })
  
  createFnameRibbonPlot = reactive({
    
    paste0('clust_hierSparse_tCoursesMeans_',
           ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
           '_',
           input$selLink, 
           '.pdf')
  })
  
  createFnamePsdPlot = reactive({
    
    paste0('clust_hierSparse_tCoursesPsd_',
           ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
           '_',
           input$selLink, 
           '.pdf')
  })
  
  createFnameDistPlot = reactive({
    
    paste0('clust_hierSparse_clDist_',
           ifelse(input$selDiss == "squared.distance", "euclidean", "manhattan"),
           '_',
           input$selLink, '.pdf')  
  })
  
  # Sparse Hierarchical - Heat Map - download pdf
  callModule(downPlot, "downPlotHMspar", createFnameHeatMap, plotHierSpar)
  
  # plot individual trajectories withina cluster  
  callModule(modTrajPlot, 'modPlotHierSparTraj', 
             in.data = data4trajPlotClSpar, 
             in.data.stim = data4stimPlotClSpar,
             in.facet = COLCL, 
             in.facet.color = getClColHierSpar,
             in.fname = createFnameTrajPlot)
  
  # plot cluster means
  callModule(modTrajRibbonPlot, 'modPlotHierSparTrajRibbon', 
             in.data = data4trajPlotClSpar, 
             in.data.stim = data4stimPlotClSpar,
             in.group = COLCL,  
             in.group.color = getClColHierSpar,
             in.fname = createFnameRibbonPlot)
  
  # plot cluster PSD
  callModule(modPSDPlot, 'modPlotHierSparPsd',
             in.data = data4trajPlotClSpar,
             in.facet = COLCL,
             in.facet.color = getClColHierSpar,
             in.fname = createFnamePsdPlot)
  
  # plot distribution barplot
  callModule(modClDistPlot, 'hierClSparDistPlot', 
             in.data = data4clSparDistPlot,
             in.colors = getClColHierSpar,
             in.fname = createFnameDistPlot)
  
  
  
  # Sparse Hierarchical - display heatmap
  output$outPlotHierSpar <- renderPlot({
    plotHierSpar()
  }, height = getPlotHierSparHeatMapHeight)
  
  # Pop-overs ----
  
  addPopover(session, 
             ns("alImportance"),
             title = "Variable importance",
             content = helpText.clHierSpar[["alImportance"]],
             trigger = "click")
  
}


