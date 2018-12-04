
###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


##' @title Prepares all the prodigal-associated files
##' @description Prepares all the prodigal-associated plots
##' @param  a pridgal.gff prediction file
##' @return Returns the full DF and the subest to partial =00

### get input files
prodigalFileReport <- function(x,meth){
prodigalGffImport <- import.gff(x)
prodigalSummaryDF <- data.frame(mcols(prodigalGffImport), stringsAsFactors = F)
prodigalSummaryDF$gc_cont <- as.numeric(prodigalSummaryDF$gc_cont)
prodigalSummaryDF$conf <- as.numeric(prodigalSummaryDF$conf)
prodigalSummaryDF$method <- meth
subsetDataToPartial00DF <- prodigalSummaryDF[prodigalSummaryDF$partial =="00" 
                                           & (prodigalSummaryDF$start_type == "ATG"|
                                                prodigalSummaryDF$start_type == "GTG"),]
subsetDataToPartial00DF$method <- meth
return(list(fullSumm=prodigalSummaryDF,subsetDataToPartial00=subsetDataToPartial00DF))
}




###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


##' @title Prepares all the interproscan-associated files; the sceond extracts topN from the list
##' @description Prepares all the interproscan-associated plots
##' @param  a interproscan.gff prediction file
##' @return Returns the full DF
## extract N entries with top frequency 
extractTopN <- function(DF,column,N){
  col <- vector()
  tabNoNa <- DF[DF[[column]] != "NA",]
  tab <- table(tabNoNa[[column]])
  tab_s <- sort(tab)                                           
  col <- data.frame(tail(names(tab_s), N), stringsAsFactors = F)
  colnames(col) <- column
  topN <- data.frame(cbind(col, abundance = tail(as.data.frame(tab_s)$Freq, N)),
                     stringsAsFactors = F)
  topN <- topN[order(topN$abundance), ]
  topN[[column]] <- gsub("\"","",topN[[column]])
  return(topN)
}

interproscanFileReport <- function(x,N,meth){
IPSGffImport <- import.gff(x)
description <- mcols(IPSGffImport)$signature_desc
description[sapply(description,function(x) length(x)==0)] <- "NA"
description <- sapply(description,function(x)x[1])
ontology <- mcols(IPSGffImport)$Ontology_term
ontology[sapply(ontology,function(x) length(x)==0)] <- "NA" 
ontology <- sapply(ontology,function(x)x[1])
IPSGffSummaryDF <- data.frame(score = as.numeric(mcols(IPSGffImport)$score),
                              description = description, 
                              GOterm = ontology,
                              type = mcols(IPSGffImport)$type,
                              stringsAsFactors = F)
IPSGffSummaryDF <- IPSGffSummaryDF[IPSGffSummaryDF$type == "protein_match",
                                   c("score","description","GOterm")]
IPSGffSummaryDF_topN_GO <- extractTopN(IPSGffSummaryDF,"GOterm",N)
IPSGffSummaryDF_topN_desc <- extractTopN(IPSGffSummaryDF,"description",N)
IPSGffSummaryDF$method <- meth
IPSGffSummaryDF_topN_GO$method <- meth
IPSGffSummaryDF_topN_desc$method <- meth
  return(list(summDF=IPSGffSummaryDF,
              topN_GO=IPSGffSummaryDF_topN_GO,
              topN_desc=IPSGffSummaryDF_topN_desc))
}


###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


##' @title Prepares all the prodigal-associated plots
##' @description Prepares all the prodigal-associated plots
##' @param  a pridgal.gff prediction file
##' @return Returns ggplots

summaryScorePlot <- function(x){
p <-  ggplot(x,aes(x=score)) + geom_histogram(binwidth=10) +  
  facet_grid(rows = vars(start_type), cols = vars(partial)) + 
  labs(title="Summary of the gene prediction scores")
return(p)
}

summaryConfPlot <- function(x){
  p <-  ggplot(x,aes(x=conf)) + geom_histogram(binwidth=5) +  
    facet_grid(rows = vars(start_type), cols = vars(partial),labeller = label_both)+ 
    labs(title="Summary of the gene prediction confidence")
  return(p)
  }

summaryGcContPlot <- function(x){
  p <- ggplot(x,aes(x=gc_cont)) + geom_histogram(binwidth=0.001) +  
    facet_grid(rows = vars(start_type), cols = vars(partial),labeller = label_both) + labs(title="Summary of the GC-content")
  return(p)
}

### summary rbs_spacer hist
summaryRBSSpacePlot <-  function(x){
  p<- ggplot(x,aes(x=rbs_spacer)) + geom_bar() +  
    facet_grid(rows = vars(start_type), cols = vars(partial), labeller = label_both) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(title="RBS-spacer distribution")
  return(p)
}
### summary rbs_motif hist
summaryRBSMotifPlot <- function(x){
  p<- ggplot(x,aes(x=rbs_motif)) + 
    geom_bar() +  facet_grid(rows = vars(start_type), cols = vars(partial), labeller = label_both) + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title="RBS-motif distribution")
  return(p)
} 


###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


##' @title Prepares all the IPS-associated plots
##' @description Prepares all the prodigal-associated plots
##' @param  a pridgal.gff prediction file
##' @return Returns ggplots

summaryMatchScorePlot <- function(x){
  p<- ggplot(x,aes(x=-log(score))) + geom_histogram(binwidth = 5) +
  labs(title="Summary of protein match score") + facet_grid(cols = vars(method))
  return(p)
}

### topNcateg plots: GO
summaryGOPlot <- function(x,numberOfTopNCategories){
  DFforSummProtGO <- x
GOdesc <- sapply(DFforSummProtGO$GOterm,function(x)Term(GOTERM)[names(Term(GOTERM))%in%DFforSummProtGO], USE.NAMES = F)
DFforSummProtGO$GOterm <- paste(DFforSummProtGO$GOterm,GOdesc)
## expand palette colour to numberOfTopNCategories
getPalette = colorRampPalette(brewer.pal(9, "Set1"))
expandedPalette <- getPalette(numberOfTopNCategories)
summaryGOPlot <- ggplot(DFforSummProtGO,aes(x=reorder(GOterm, -abundance),y=abundance, fill = GOterm)) 
summaryGOPlot <- summaryGOPlot + geom_bar(stat = "Identity")+
  theme(axis.text.x = element_blank(), axis.title.x = element_blank(),legend.position = "bottom",legend.text = element_text(size =7)) + scale_color_manual(expandedPalette)
p <- summaryGOPlot  +
  labs(title="Most represented GO terms") + facet_grid(cols = vars(method))
  return(p)
}

### topNcateg plots: protein family
summaryFamilyPlot <- function(x,numberOfTopNCategories){
  DFforSummProtFamilies <- x
  ## expand palette colour to numberOfTopNCategories
  getPalette = colorRampPalette(brewer.pal(9, "Set1"))
  expandedPalette <- getPalette(numberOfTopNCategories)
  init <- ggplot(DFforSummProtFamilies,aes(x=reorder(description, -abundance),y=abundance, fill = description)) 
  init <- init + geom_bar(stat = "Identity")+theme(axis.text.x = element_blank(), axis.title.x = element_blank(), 
                                                   legend.position = "bottom",legend.text = element_text(size =7)) + 
    scale_color_manual(expandedPalette)
p <- init + guides(fill=guide_legend(ncol=2, byrow=F,title.position = "top"))  +
  labs(title="Most represented  protein families")+ facet_grid( cols = vars(method))
return(p)
}


