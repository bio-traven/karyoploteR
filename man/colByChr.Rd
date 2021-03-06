% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/color.R
\name{colByChr}
\alias{colByChr}
\title{colByChr}
\usage{
colByChr(data, colors="2grays", all.chrs=NULL, default.col="black")
}
\arguments{
\item{data}{Either a vector of characters or a GRanges object}

\item{colors}{The name of a color set ("2grays", "blackgreen", "rainbow"...) or a vector of colors. If the vector is named, names are expected to be the chromosome names. (defaults to "2grays")}

\item{all.chrs}{A vector with all possible chromosomes. If NULL, the list will be extracted from data (using seqlevels if available). (defaults to NULL)}

\item{default.col}{The default color to return when something is unavailable}
}
\value{
A vector of colors
}
\description{
Given a set of data elements, return a color for each one based on their chromosome
}
\details{
Returns a color for each data element based on its chromosome. The returned colors might
com from one of the predefined color sets or passed in as a parameter.

If \code{colors} is the name of one of the available color sets, it the color set is used. 
If it's a named character vector with the chromosome as names, they will be assigned by name
and any missing chromosome will be \code{default.col}. If it's a non-named chraracter vector,
will be used in order and recycled if necessary.

Data might be either a GRanges object or a vector of chromosomes.
}
\note{
Available color.sets:
"2grays"=c("#888888", "#444444"),
"2blues"=c("#6caeff", "#2b5d9b")
"blackgreen"=c("black", "green"),
"greengray"=c("#c6ffb7", "#888888"),
"brewer.set1"=c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999")
"brewer.set2"=c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3")
"brewer.set3"=c("#8DD3C7", "#FFFFB3", "#BEBADA", "#FB8072", "#80B1D3", "#FDB462", "#B3DE69", "#FCCDE5", "#D9D9D9", "#BC80BD", "#CCEBC5", "#FFED6F")
"brewer.pastel1"=c("#FBB4AE", "#B3CDE3", "#CCEBC5", "#DECBE4", "#FED9A6", "#FFFFCC", "#E5D8BD", "#FDDAEC", "#F2F2F2"),
"brewer.pastel2"=c("#B3E2CD", "#FDCDAC", "#CBD5E8", "#F4CAE4", "#E6F5C9", "#FFF2AE", "#F1E2CC", "#CCCCCC"),
"rainbow"=rainbow(n=length(all.chrs))
}
\examples{

chrs <- c("chr1", "chr2", "chr2", "chr1", "chr5")
points <- toGRanges(paste0("chr", c(1:22, "X", "Y")), rep(10e6, 24), rep(10e6, 24))

colByChr(chrs)
colByChr(points)

kp <- plotKaryotype(plot.type=4, labels.plotter=NULL, ideogram.plotter=NULL)
kpAddChromosomeNames(kp, srt=45)
kpAddChromosomeSeparators(kp)

total.tracks <- 6

kpPoints(kp, points, col=colByChr(points), y=0.5, cex=1, r0=autotrack(1,total.tracks)$r0, r1=autotrack(1,total.tracks)$r1)
colors <- NULL
kpPoints(kp, points, y=0.5, col=colByChr(points, colors=colors), cex=1, r0=autotrack(2,total.tracks)$r0, r1=autotrack(2,total.tracks)$r1)
colors <- c("red", "blue")
kpPoints(kp, points, y=0.5, col=colByChr(points, colors=colors), cex=1, r0=autotrack(3,total.tracks)$r0, r1=autotrack(3,total.tracks)$r1)
colors <- c(chr1="red", chr7="blue")
kpPoints(kp, points, y=0.5, col=colByChr(points, colors=colors), cex=1, r0=autotrack(4,total.tracks)$r0, r1=autotrack(4,total.tracks)$r1)
kpPoints(kp, points, y=0.5, col=colByChr(points, colors=colors, default.col="green"), cex=1, r0=autotrack(5,total.tracks)$r0, r1=autotrack(5,total.tracks)$r1)
colors <- c("red", "yellow", 3, "orchid", "blue")
kpPoints(kp, points, y=0.5, col=colByChr(points, colors=colors), cex=1, r0=autotrack(6,total.tracks)$r0, r1=autotrack(6,total.tracks)$r1)

#Color sets
pp <- getDefaultPlotParams(plot.type=4)
pp$leftmargin <- 0.2
kp <- plotKaryotype(plot.type=4, labels.plotter=NULL, ideogram.plotter=NULL, plot.params=pp)
kpAddChromosomeNames(kp, srt=45)
kpAddChromosomeSeparators(kp)

color.sets <- c( "2grays", "2blues", "blackgreen", "greengray", "brewer.set1",
                   "brewer.set2", "brewer.set3", "brewer.pastel1", "brewer.pastel2", "rainbow" )
total.tracks <- length(color.sets)
for(i in seq_len(length(color.sets))) {
    kpPoints(kp, points, y=0.5, col=colByChr(points, colors=color.sets[i]), cex=1, r0=autotrack(i,total.tracks)$r0, r1=autotrack(i,total.tracks)$r1)
    kpAddLabels(kp, labels=color.sets[i], cex=0.7, r0=autotrack(i,total.tracks)$r0, r1=autotrack(i,total.tracks)$r1)
}

}
\seealso{
\code{\link{kpPoints}}
}
