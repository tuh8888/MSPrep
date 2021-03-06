#' Package for summarizing, filtering, imputing, and normalizing metabolomics data.
#' 
#' This package performs summarization of replicates, filtering by frequency,
#' three different options for handling/imputing missing data, and five options for normalizing
#' data. 
#'
#' @author Grant Hughes
#' @author Matt Mulvahill
#' @author Sean Jacobson
#' @author Katerina Kechris
#' @author Harrison Pielke-Lombardo
#' @docType package
#' @name MSPrep 
#' @details
#' Package for processing of mass spectrometry quantification data. Five functions are provided
#' and are intended to be used in sequence (as a pipeline) to produce cleaned and normalized data.
#' These are ms_tidy, ms_prepare, ms_filter, ms_impute, and ms_normalize.
#' 
#' 
#' @references
#' Bolstad, B.M.et al.(2003) A comparison of normalization methods for high
#' density oligonucleotide array data based on variance and bias.
#' Bioinformatics, 19, 185-193
#' 
#' DeLivera, A.M.et al.(2012) Normalizing and Integrating Metabolomic Data.
#' Anal. Chem, 84, 10768-10776.
#' 
#' Gagnon-Bartsh, J.A.et al.(2012) Using control genes to correct for unwanted
#' variation in microarray data. Biostatistics, 13, 539-552.
#' 
#' Johnson, W.E.et al.(2007) Adjusting batch effects in microarray expression
#' data using Empirical Bayes methods. Biostatistics, 8, 118-127.
#' 
#' Leek, J.T.et al.(2007) Capturing Heterogeneity in Gene Expression Studies by
#' Surrogate Variable Analysis. PLoS Genetics, 3(9), e161.
#' 
#' Oba, S.et al.(2003) A Bayesian missing value estimation for gene expression
#' profile data. Bioinformatics, 19, 2088-2096
#' 
#' Redestig, H.et al.(2009) Compensation for Systematic Cross-Contribution
#' Improves Normalization of Mass Spectrometry Based Metabolomics Data. Anal.
#' Chem., 81, 7974-7980.
#' 
#' Stacklies, W.et al.(2007) pcaMethods: A bioconductor package providing PCA
#' methods for incomplete data. Bioinformatics, 23, 1164-1167.
#' 
#' Wang, W.et al.(2003) Quantification of Proteins and Metabolites by Mass
#' Spectrometry without Isotopic Labeling or Spiked Standards. Anal. Chem., 75,
#' 4818-4826.
#' 
#' @examples
#'    #  #library(crmn)
#'    #  #library(preprocessCore)
#'    #  #library(sva)
#'    #  #library(psych)
#'    #  #library(Hmisc)
#'    #  #library(limma)
#'    #  #library(pcaMethods)
#'    #  #library(multcomp)
#'    #  
#'    #  
#'    #  ### Specify primary directory for input dataset
#'    #  #my_dir <- c("<my_dir>")
#'    #  #data(test2)
#'    #  
#'    #  ### Specify location of data files
#'    #  #clinicalfile       <- c("Clinical.csv")
#'    #  #quantificationfile <- c("Quantification.csv")
#'    #  #linkfile           <- c("SubjectLinks.csv")
#'    #  
#'    #  ### Set variables for program
#'    #  cvmax   <- 0.5
#'    #  missing <- 1
#'    #  linktxt <- "LCMS_Run_ID"
#'    #  
#'    #  test <- readdata(directory, clinicalfile, quantificationfile, linkfile,
#'    #                   cvmax = 0.50, missing = 1, linktxt)
#'    #  
#'    #  test2 <- filterft(test$sum_data1, 0.80)
#'    #  
#'    #  directory <- "/home/grant/"
#'    #  minval    <- test2$minval
#'    #  withzero  <- test2$withzero
#'    #  bpca      <- test2$bpca
#'    #  
#'    #  graphimputations(directory, minval, withzero, bpca, meanval1 = 0,
#'    #                   meanval2 = 200000, xmax1 = 400000, ymax1 = 800, 
#'    #                   xmax2 = 20, ymax2 = 600, xmax3 = 20, ymax3 = 175, 
#'    #                   nbreaks = 200)
#'    #  
#'    #  metafin  <- test2$bpca
#'    #  clindat  <- test$clinical
#'    #  link1    <- "SubjectID"
#'    #  pheno    <- "Spike"
#'    #  batch    <- "Operator"
#'    #  ncont    <- 10
#'    #  controls <- c()
#'    #  ncomp    <- 2
#'    #  
#'    #  test3 <- normdata(metafin, clindat, link1, pheno, batch, ncont = 10,
#'    #                    controls, ncomp)
#'    #  
#'    #  testobj   <- test3
#'    #  clindat   <- test$clinical
#'    #  link1     <- "SubjectID"
#'    #  pheno     <- "Spike"
#'    #  batch     <- "Operator"
#'    #  directory <- "/home/grant/"
#'    #  ylim2     <- c(10,28)
#'    #  ### For median
#'    #  ylim1     <- c(-15,15)
#'    #  ### for crmn
#'    #  ylim3     <- c(18,37)
#'    #  
#'    #  diagnosticgen(testobj, clindat, link1, batch, pheno, directory, ylim1,
#'    #                ylim2, ylim3)
#' 
NULL
