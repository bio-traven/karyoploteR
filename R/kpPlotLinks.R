#' kpPlotLinks
#' 
#' @description 
#' 
#' Given 2 \code{GRanges} objects, plot lines or ribbons between region pairs
#' 
#' @details 
#'  
#'  This is one of the high-level, or specialized, plotting functions of karyoploteR.
#'  It takes two \code{GRanges} objects (or a single specially crafted one) and
#'  plots links (either lines or ribbons) between region pairs. Links are 
#'  plotted bewteen the first region of both objects, between the second one, etc...
#'  and therefore both objects need to have the same length. Specifying a region
#'  as negative strand, will "flip" it, so the the start of a region can be 
#'  linked to the end of its pair.
#'  
#' @note 
#'   For a link to be plotted BOTH ends must be visible in the karyoplot. In 
#'   particular, if a chromosome is not included in the plot (due to not
#'   being specified in \code{chromosomes}, for example) any link with an end
#'   on it will NOT be plotted. The same is true for zoomed in plots, where only
#'   intrachromosomal links will be visible. No warning or message will be
#'   generated.
#' 
#'
#' @usage kpPlotLinks(karyoplot, data, data2=NULL, y=0, arch.height=NULL, data.panel=1, r0=NULL, r1=NULL, ymin=NULL, ymax=NULL, col="#8e87eb", border=NULL, clipping=TRUE, ...)
#' 
#' @param karyoplot    (a \code{KaryoPlot} object) This is the first argument to all data plotting functions of \code{karyoploteR}. A KaryoPlot object referring to the currently active plot.
#' @param data    (a \code{GRanges}) A GRanges object with link start regions. If data2 is NULL, mcols(data) should be a bed-like structure with "link.chr", "link.start", "link.end" and optionally a "link.strand" columns. The first thee columns can have any name and the strand information will be extracted from the first column with "strand" in its name.
#' @param data2  (a \code{GRanges}) A GRanges object with the link end regions. If null, the end of the regions will be extracted from mcols(data). (Defaults to NULL)
#' @param y    (numeric) The y value where the origin and end of the links should be plotted (Defaults to 0)
#' @param arch.height    (numeric) The approximate arch height in links in the same chromosome in "y" scale. If NULL, it defaults to the whole span of the data panel.Also affects the curvature of links between chromosomes (Defaults to NULL)
#' @param data.panel    (numeric) The identifier of the data panel where the data is to be plotted. The available data panels depend on the plot type selected in the call to \code{\link{plotKaryotype}}. (defaults to 1)
#' @param r0    (numeric) r0 and r1 define the vertical range of the data panel to be used to draw this plot. They can be used to split the data panel in different vertical ranges (similar to tracks in a genome browser) to plot differents data. If NULL, they are set to the min and max of the data panel, it is, to use all the available space. (defaults to NULL)
#' @param r1    (numeric) r0 and r1 define the vertical range of the data panel to be used to draw this plot. They can be used to split the data panel in different vertical ranges (similar to tracks in a genome browser) to plot differents data. If NULL, they are set to the min and max of the data panel, it is, to use all the available space. (defaults to NULL)
#' @param ymin    (numeric) The minimum value to be plotted on the data panel. If NULL, it is set to 0. (deafults to NULL)
#' @param ymax    (numeric) The maximum value to be plotted on the data.panel. If NULL the maximum density is used. (defaults to NULL)
#' @param col    (color) The background color of the links. If NULL and border is specified, it defaults to a lighter version of border.
#' @param border  (color) The border color of the links. If NULL and col is specified, it defaults to a darker version of col.
#' @param clipping  (boolean) Only used if zooming is active. If TRUE, the data representation will be not drawn out of the drawing area (i.e. in margins, etc) even if the data overflows the drawing area. If FALSE, the data representation may overflow into the margins of the plot. (defaults to TRUE)
#' @param ...    The ellipsis operator can be used to specify any additional graphical parameters. Any additional parameter will be passed to the internal calls to the R base plotting functions. 
#' 
#' 
#' @return
#' 
#' Returns the original karyoplot object, unchanged.
#'  
#' @seealso \code{\link{plotKaryotype}}, \code{\link{kpPlotRibbon}}, \code{\link{kpSegments}}
#' 
#' @examples
#'  
#'  
#'  set.seed(222)
#'  
#'  starts <- sort(createRandomRegions(nregions = 15))
#'  ends <- sort(createRandomRegions(nregions = 15))
#'  
#'  kp <- plotKaryotype()
#'  kpPlotLinks(kp, data=starts, data2=ends)
#'  
#'  #Create larger regions, so they look like ribbons
#'  starts <- sort(createRandomRegions(nregions = 15, length.mean = 8e6, length.sd = 5e6))
#'  ends <- sort(createRandomRegions(nregions = 15, length.mean = 8e6, length.sd = 5e6))
#'  
#'  kp <- plotKaryotype()
#'  kpPlotLinks(kp, data=starts, data2=ends)
#'  
#'  #flip some of them to represent inversions
#'  strand(ends) <- sample(c("+", "-"), length(ends), replace = TRUE)
#'  
#'  kp <- plotKaryotype()
#'  kpPlotLinks(kp, data=starts, data2=ends)
#'  
#'
#'@importFrom bezier bezier
#'  
#'@export kpPlotLinks


kpPlotLinks <- function(karyoplot, data, data2=NULL, y=0, arch.height=NULL, data.panel=1, r0=NULL, r1=NULL, ymin=NULL, ymax=NULL, col="#8e87eb", border=NULL, clipping=TRUE, ...) {
  #Check parameters
  #karyoplot
  if(missing(karyoplot)) stop("The parameter 'karyoplot' is required")
  if(!methods::is(karyoplot, "KaryoPlot")) stop("'karyoplot' must be a valid 'KaryoPlot' object")
  #data
  if(missing(data)) stop("The parameter 'data' is required")
  if(!methods::is(data, "GRanges") && !methods::is(data, "SimpleRleList")) stop("'data' must be a GRanges object or a SimpleRleList")
  
  #Assign complex default values
  #arc.height
  if(is.null(arch.height)) {
    arch.height <- karyoplot$plot.params[[paste0("data", data.panel, "max")]] - karyoplot$plot.params[[paste0("data", data.panel, "min")]]
  }
  
  #colors
  prep.cols <- preprocessColors(col=col, border=border)
  col <- prep.cols$col
  border <- prep.cols$border
  
  
  #Define the link ends
  if(!is.null(data2) && !any(is.na(data2))) {
    if(!methods::is(data2, "GRanges")) {
      stop("If present, data2 must be a GRanges object")
    } else {
      if(length(data) != length(data2)) {
        stop("data and data2 must have the same length")
      }
    }
  } else {
    #if data2 is not defined, try to define it from the mcols of data
    tryCatch(data2 <- toGRanges(data.frame(mcols(data))),
             error=function(e) {stop("It was not possible to create data2 from mcols(data). ", e)})
    strand.col <- which(grepl(pattern = "strand", names(mcols(data2))))[1]
    if(length(strand.col)>0) {
      strand(data2) <- mcols(data2)[[strand.col]]
    }
  }
  
  
  #remove any links with at least one end out of the plotted regions
  to.keep <- overlapsAny(data, karyoplot$genome) & overlapsAny(data2, karyoplot$genome)
  if(any(!to.keep)) {
    data <- data[to.keep]
    data2 <- data2[to.keep]
  }
 
  
  if(length(data)==0) invisible(karyoplot) #return fast if no links will be plotted
  
  #Filter the additional arguments
  #NOTE: in this case we do not use the filter returned by prepareParameters
  #because we have a specific filtering logic due to links having two genomic 
  #regions
  dots <- filterParams(list(...), to.keep, length(to.keep))
  col <- filterParams(col, to.keep, length(to.keep))
  border <- filterParams(border, to.keep, length(to.keep))
  y <- filterParams(y, to.keep, length(to.keep))
  arch.height <- filterParams(arch.height, to.keep, length(to.keep))
  
  
  
  
  #Prepare the coordinates
  karyoplot$beginKpPlot()
  on.exit(karyoplot$endKpPlot())
  
  ccf <- karyoplot$coord.change.function
  
  #Transform the coordinates of the starts
  pp.start <- prepareParameters4("kpPlotLinks", karyoplot=karyoplot, data=data, chr=NULL, x0=NULL, x1=NULL,
                                 y0=y, y1=y, ymin=ymin, ymax=ymax, r0=r0, r1=r1,
                                 data.panel=data.panel, ...)
  
  #Transform the coordinates of the starts
  pp.end <- prepareParameters4("kpPlotLinks", karyoplot=karyoplot, data=data2, chr=NULL, x0=NULL, x1=NULL,
                               y0=y, y1=y, ymin=ymin, ymax=ymax, r0=r0, r1=r1,
                               data.panel=data.panel, ...)
  
  x0.start <- ccf(chr=pp.start$chr, x=pp.start$x0, data.panel=data.panel)$x
  x1.start <- ccf(chr=pp.start$chr, x=pp.start$x1, data.panel=data.panel)$x
  y.start <- ccf(chr=pp.start$chr, y=pp.start$y0, data.panel=data.panel)$y
  
  #swap the order of the regions in the negative strand
  aux <- numeric(length(data))
  neg.strand.start <- which(as.logical(strand(data)=="-"))
  aux[neg.strand.start] <- x0.start[neg.strand.start]
  x0.start[neg.strand.start] <- x1.start[neg.strand.start]
  x1.start[neg.strand.start] <- aux[neg.strand.start]
  
  x0.end <- ccf(chr=pp.end$chr, x=pp.end$x0, data.panel=data.panel)$x
  x1.end <- ccf(chr=pp.end$chr, x=pp.end$x1, data.panel=data.panel)$x
  y.end <- ccf(chr=pp.end$chr, y=pp.end$y0, data.panel=data.panel)$y
  
  #swap the order of the regions in the negative strand
  neg.strand.end <- which(as.logical(strand(data2)=="-"))
  aux[neg.strand.end] <- x0.end[neg.strand.end]
  x0.end[neg.strand.end] <- x1.end[neg.strand.end]
  x1.end[neg.strand.end] <- aux[neg.strand.end]
  
  
  #transform the arch height to the plot coords using ccf and prepare parameters2 to take into account r0 and r1, ymin and ymax, etc
  y.min <- prepareParameters2("kpPlotLinks", karyoplot = karyoplot, data=NULL, chr=karyoplot$chromosomes[1], x=0, y=0, r0=r0, r1=r1, ymin=ymin, ymax=ymax, data.panel=data.panel)$y
  y.max <- prepareParameters2("kpPlotLinks", karyoplot = karyoplot, data=NULL, chr=karyoplot$chromosomes[1], x=0, y=arch.height, r0=r0, r1=r1, ymin=ymin, ymax=ymax, data.panel=data.panel)$y
  
  y.ctrl <- abs(ccf(chr=rep(karyoplot$chromosomes[1], length(y.min)), x=0, y=y.min, data.panel=data.panel)$y - ccf(chr=rep(karyoplot$chromosomes[1], length(y.max)), x=0, y=y.max, data.panel=data.panel)$y)
  
  #recycle parameters
  col <- recycle.first(col, data)
  border <- recycle.first(border, data)
  y.ctrl <- recycle.first(y.ctrl, data)
  
  
  #TODO: Make this 50 a parameter (num.bezier.segments=50) and document
  t <- seq(0, 1, length=50)
  for(i in seq_along(data)) {
    #The position of the control points (above or below the start and end points) depend on the relative position of start and end and in some cases on the data.panel
    if(y.start[i]>y.end[i]) { #if the start is above the end
      bezier_points_1 <- bezier(t=t, p=list(c(x0.start[i],x0.start[i], x0.end[i], x0.end[i]), c(y.start[i],y.start[i]-y.ctrl[i],y.end[i]+y.ctrl[i],y.end[i])))
      bezier_points_2 <- bezier(t=t, p=list(c(x1.start[i],x1.start[i], x1.end[i], x1.end[i]), c(y.start[i],y.start[i]-y.ctrl[i],y.end[i]+y.ctrl[i],y.end[i])))
    } else if(y.start[i]<y.end[i]) { #if start is below the end
      bezier_points_1 <- bezier(t=t, p=list(c(x0.start[i],x0.start[i], x0.end[i], x0.end[i]), c(y.start[i],y.start[i]+y.ctrl[i],y.end[i]-y.ctrl[i],y.end[i])))
      bezier_points_2 <- bezier(t=t, p=list(c(x1.start[i],x1.start[i], x1.end[i], x1.end[i]), c(y.start[i],y.start[i]+y.ctrl[i],y.end[i]-y.ctrl[i],y.end[i])))
    } else {
      #if they are in the same chromosome, detect whether we are in an upward or downward data panel
      if(ccf(chr=as.character(seqnames(data[1])), x=0, y=0, data.panel=data.panel)$y <
         ccf(chr=as.character(seqnames(data[1])), x=0, y=1, data.panel=data.panel)$y) {
        #it's upwards
        bezier_points_1 <- bezier(t=t, p=list(c(x0.start[i],x0.start[i], x0.end[i], x0.end[i]), c(y.start[i],y.start[i]+y.ctrl[i],y.end[i]+y.ctrl[i],y.end[i])))
        bezier_points_2 <- bezier(t=t, p=list(c(x1.start[i],x1.start[i], x1.end[i], x1.end[i]), c(y.start[i],y.start[i]+y.ctrl[i],y.end[i]+y.ctrl[i],y.end[i])))
      } else {
        #it's downwards
        bezier_points_1 <- bezier(t=t, p=list(c(x0.start[i],x0.start[i], x0.end[i], x0.end[i]), c(y.start[i],y.start[i]-y.ctrl[i],y.end[i]-y.ctrl[i],y.end[i])))
        bezier_points_2 <- bezier(t=t, p=list(c(x1.start[i],x1.start[i], x1.end[i], x1.end[i]), c(y.start[i],y.start[i]-y.ctrl[i],y.end[i]-y.ctrl[i],y.end[i])))
      }
    }
    
    processClipping(karyoplot=karyoplot, clipping=clipping, data.panel=data.panel)  
    graphics::polygon(x = c(bezier_points_1[,1], rev(bezier_points_2[,1])), y=c(bezier_points_1[,2], rev(bezier_points_2[,2])), col=col[i], border=NA, ...)
    if(!is.na(border[i])) {
      graphics::lines(bezier_points_1, col=border[i], ...)
      graphics::lines(bezier_points_2, col=border[i], ...)
    }
  }
  
  
  invisible(karyoplot)
}
