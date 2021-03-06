# 
# #' Generate histograms of three datasets returned from filterft function
# #' 
# #' Generates histograms of withzero, minval, and bpca datasets.
# #' 
# #' @param directory Location to save pdf of histograms.
# #' @param minval Name of minval dataset
# #' @param withzero Name of withzero dataset
# #' @param bpca Name of BPCA dataset
# #' @param meanval1 Minimum value to keep.
# #' @param meanval2 Maximum value to keep.
# #' @param xmax1 X limit for withzero graph
# #' @param ymax1 Y limit for withzero graph
# #' @param xmax2 X limit for minval graph
# #' @param ymax2 Y limit for minval graph
# #' @param xmax3 X limit for bpca graph
# #' @param ymax3 Y limit for bpca graph
# #' @param nbreaks Number of breaks in histogram
# #' @details The meanval1 and meanval2 allow removal of any individual extreme
# #' values or ability to generate a focused histogram of abundances of interest.
# #' nbreaks will need increased as the number of subjects*compounds increases.
# #' @return Placeholder
# #' @examples
# #'   load("test2.Rdata")
# #'   
# #'   directory <- "C:/Users/Hazy/Dropbox/Metabolomics/Programs/MSProcess/"
# #'   minval    <- test2$minval
# #'   withzero  <- test2$withzero
# #'   bpca      <- test2$bpca
# #'   
# #'   graphimputations(directory, minval, withzero, bpca,fname, meanval1 = 0,
# #'                    meanval2 = 200000, xmax1 = 400000, ymax1 = 800, 
# #'                    xmax2 = 20, ymax2 = 600, xmax3 = 20, ymax3 = 175, 
# #'                    nbreaks = 200)
# #' 
# #'
# #' @export 
# graphimputations <- function (directory, minval, withzero, bpca, meanval1 = 0, meanval2 = 1e+06, 
#                               xmax1 = 5e+05, ymax1 = 25000, xmax2 = 20, ymax2 = 1000, xmax3 = 20, 
#                               ymax3 = 1500, nbreaks = 500) 
# {
#   compounds <- ncol(bpca)
#   subjects <- nrow(bpca)
#   stackdata <- function(dset) {
#     temp <- matrix(NA, ncol = 5, nrow = ncol(dset) * nrow(dset))
#     comps <- ncol(dset)
#     subjects <- nrow(dset)
#     for (j in 0:eval(comps - 1)) {
#       for (i in 1:subjects) {
#         temp[(subjects * j + i), 1] <- as.character(dset[i, 
#                                                     j + 1])
#       }
#     }
#     return(temp)
#   }
#   keeper <- matrix(0, nrow = compounds, ncol = 1)
#   log_zer <- matrix(NA, nrow = subjects, ncol = compounds)
#   log_min <- matrix(NA, nrow = subjects, ncol = compounds)
#   log_bpca <- matrix(NA, nrow = subjects, ncol = compounds)
#   for (i in 1:compounds) {
#     if (mean(withzero[, i]) >= meanval1 && mean(withzero[, 
#                                                 i]) <= meanval2) {
#       keeper[i, 1] <- i
#     }
#     for (j in 1:subjects) {
#       if (withzero[j, i] == 0) {
#         log_zer[j, i] <- log(1, 2)
#       }
#       else {
#         log_zer[j, i] <- log(withzero[j, i], 2)
#       }
#       log_min[j, i] <- log(minval[j, i], 2)
#       log_bpca[j, i] <- log(bpca[j, i], 2)
#     }
#   }
#   keep <- subset(keeper, keeper[, 1] > 0)
#   minst <- stackdata(minval[, keep])
#   zerst <- stackdata(withzero[, keep])
#   bpcast <- stackdata(bpca[, keep])
#   lminst <- stackdata(log_min[, keep])
#   lzerst <- stackdata(log_zer[, keep])
#   lbpcast <- stackdata(log_bpca[, keep])
#   pdf(paste(directory, "ImpMethods_CompsBetween_", meanval1, 
#             "-", as.character(meanval2), "_bk", nbreaks, "_", Sys.Date(), 
#             ".pdf", sep = ""))
#   par(mfrow = c(2, 1))
#   ylim1 <- c(0, ymax1)
#   xlim1 <- c(0, xmax1)
#   ylim2 <- c(0, ymax2)
#   xlim2 <- c(0, xmax2)
#   ylim3 <- c(0, ymax3)
#   xlim3 <- c(0, xmax3)
#   x <- (as.numeric(as.character(zerst[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "With Zeros", 
#        main = "Histogram of Abundances with Zeros", ylim = ylim1, 
#        xlim = xlim1)
#   x <- (as.numeric(as.character(lzerst[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "With Zeros", 
#        main = "Histogram of Log2 Abundances with Zeros", ylim = ylim2, 
#        xlim = xlim2)
#   x <- (as.numeric(as.character(minst[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "With Min Val", 
#        main = "Histogram of Abundances with 1/2 Minimum Value Replacement", 
#        ylim = ylim1, xlim = xlim1)
#   x <- (as.numeric(as.character(lminst[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "With Min Val", 
#        main = "Histogram of Log2 Abundances with 1/2 Minimum Value Replacement", 
#        ylim = ylim3, xlim = xlim2)
#   x <- (as.numeric(as.character(bpcast[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "BPCA", main = "Histogram of Abundances with BPCA Imputation", 
#        ylim = ylim1, xlim = xlim1)
#   x <- (as.numeric(as.character(lbpcast[, 1])))
#   hist(x, breaks = nbreaks, col = "red", xlab = "BPCA", main = "Histogram of Log2 Abundances with BPCA Imputation", 
#        ylim = ylim3, xlim = xlim2)
#   dev.off()
# }
# 
