\name{filteroutBam}
\alias{filteroutBam}
\title{
  Filter bam
}
\description{
  Filter bam file by removing...
}
\usage{
  filteroutBam(inBam, outBam, cores = ezThreads(), chrs = NA)
}
  
\arguments{
  \item{inBam}{
    \code{character}(1): the input bam file.
  }
  \item{outBam}{
    \code{character}(1): the output bam file.
  }
  \item{cores}{
    \code{integer}(1): the number of threads to use.
  }
  \item{chrs}{
    \code{character}(n): the chromosomes to filter out.
  }
  \item{mapQ}{
    \code{integer}(1): The minimal mapping quality for alignments.
  }
}
\value{
  invisible \code{outBam} file
}
\author{
  Ge Tan
}
\examples{
  inBam <- system.file("extdata", "ex1.bam", package="Rsamtools", 
                       mustWork=TRUE)
  outBam <- tempfile(pattern="test-", fileext=".bam")
  filteroutBam(inBam, outBam, chrs="seq1", mapQ=10)
}
