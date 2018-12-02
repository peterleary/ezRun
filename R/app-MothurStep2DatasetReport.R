###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


ezMethodMothurStep2DatasetReport = function(input=NA, output=NA, param=NA, 
                                           htmlFile="00index.html"){
  require(rmarkdown)
  require(ShortRead)
  require(phyloseq)
  require(plyr)
  require(ape)
  require(ggplot2)
  require(DESeq2)
  library(Matrix)
  library(magic)
  library(ape)
  library(limma)
  library(RColorBrewer)
  library(gplots)
  require(knitr)
  require(kableExtra)
  require(SummarizedExperiment)
  require(webshot)
  require(htmlwidgets)
  
  dataset = input$meta
  fileNames <- as.vector(input$getNames())
  isGroupThere <- param$Group
  ### Further report on Mothur pipeline and analysis of the  results with phyloseq
  
  ### create phyloseq OTU object
  otuObject <- phyloSeqOTUFromFile(basename(input$getFullPaths("OTUsCountTable")))
  ### create phyloseq Taxa object
  taxaObject <- phyloSeqTaxaFromFile(basename(input$getFullPaths("OTUsToTaxonomyFile")))
  
  ### Add sample object (TODO, derive it from step1)
  designMatrix <- ezRead.table("/srv/GT/analysis/course_sushi/public/projects/p2000/MetagenomicsCourseTestData/designMatrix.tsv")
  sampleObject <- sample_data(designMatrix)
  ##prune OTUS
  pruneLevel <- param$representativeOTUs
  
  ### create, add trees, preprocess and prune phyloseq object
  physeqPacBioNoTree = phyloseq(otuObject, taxaObject, sampleObject)
  treeObject = rtree(ntaxa(physeqObjectNoTree), rooted=TRUE, tip.label=taxa_names(physeqObjectNoTree))
  physeqFullObject <- merge_phyloseq(physeqObjectNoTree,treeObject)
  physeqFullObject <- phyloSeqPreprocess(physeqFullObject)
  myTaxa = names(sort(taxa_sums(physeqFullObject), decreasing = TRUE)[1:pruneLevel])
  physeqFullObject <- prune_taxa(myTaxa,physeqFullObject)
  
  ## Copy the style files and templates
  styleFiles <- file.path(system.file("templates", package="ezRun"),
                          c("fgcz.css", "MothurStep2DatasetReport.Rmd", 
                            "fgcz_header.html", "banner.png"))
  file.copy(from=styleFiles, to=".", overwrite=TRUE)
  rmarkdown::render(input="MothurStep2DatasetReport.Rmd", envir = new.env(),
                    output_dir=".", output_file=htmlFile, quiet=TRUE)
}
##' @template app-template
##' @templateVar method ezMethodMothurStep2DatasetReport()
##' @templateVar htmlArg )
##' @description Use this reference class to run 
EzAppMothurStep2DatasetReport <-
  setRefClass("EzAppMothurStep2DatasetReport",
              contains = "EzApp",
              methods = list(
                initialize = function()
                {
                  "Initializes the application using its specific defaults."
                  runMethod <<- ezMethodMothurStep2DatasetReport
                  name <<- "EzAppMothurStep2DatasetReport"
                  appDefaults <<- rbind(representativeOTUs = ezFrame(Type="numeric",  DefaultValue="",Description="Number of core OTUs for the samples.")
                  )
                }
              )
  )