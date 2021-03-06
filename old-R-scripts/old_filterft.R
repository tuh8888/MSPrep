
#' Filters and imputes dataset
#'
#' Filters compounds to those found in specified percentage of subjects and
#' performs data imputation.
#'
#' @param metaf Summarized dataset output as sum_data1 from readdata() function
#' @param filterpercent Percent to filter the data
#' @return Placeholder
#' @details minval Filtered dataset with missing values replaced by 1/2 minimum
#' observed value for that compound.
#' @details bpca Filtered dataset with missing values imputed by a Bayesian PCA
#' from PCAMethods package.
#' @details withzero Filtered dataset with no imputation.
#' @details count List of all compounds and the percent present for each
#' compound.
#' @references 
#'   Oba, S.et al.(2003) A Bayesian missing value estimation for gene
#'   expression profile data. Bioinformatics, 19, 2088-2096
#'
#'   Stacklies, W.et al.(2007) pcaMethods A bioconductor package providing
#'   PCA methods for incomplete data. Bioinformatics, 23, 1164-1167.
#' @examples
#'   # Load object generated from readdata() function
#'   load("./data/test.rda")
#'
#'   test2 <- filterft(test$sum_data1, 0.80)
#'
#' @export

# Filterft to only include compounds that are found in specified percentage of
# subjects and perform imputation of missing data

# Manuscript description: 
# Filtering: The resulting summarized dataset contains all compounds with one
# observation per subject (or sample). The next processing step filters the data
# to only compounds found in a user-specified percentage of subjects.

filterft <- function (metaf, filterpercent = 0.5) {


  # count is a vector of the percent present for each compound
  # toss is indicator vector for keep (= 1) /remove (= 0) (based on what?

  # metaf   <- original matrix
  # metafin <- filtered matrix with only the compunds present >= filterpercent
  # metaimp <- metafin w/ NAs instead of 0s
  # present <- indicator matrix (dim= metaf) for present or not


  count <- matrix(NA, nrow = ncol(metaf), ncol = 1)
  rownames(count) <- colnames(metaf)
  toss <- matrix(1, nrow = eval(ncol(metaf)), ncol = 1)
  for (j in 1:eval(ncol(metaf))) {
    k <- 0
    for (i in 1:dim(metaf)[1]) {
      # sean jacobson added this so that missing data would be ignored
      if(is.na(metaf[i, j])) next
      if (metaf[i, j] == 0) {
        k <- k + 1
      }
    }
    count[j, 1] <- 1 - (k/nrow(metaf))
    if (k >= eval(dim(metaf)[1] * (1 - filterpercent))) {
      toss[j, 1] <- 0
    }
  }

  colnames(toss) <- "toss"
  tests <- cbind(toss, t(metaf))
  metafin <- t(subset(tests, toss != 0)[, -1])
  metaimp <- matrix(NA, nrow = nrow(metafin), ncol = ncol(metafin))

  # Replace 0's with NAs (all this does)
  for (i in 1:nrow(metafin)) {
    for (j in 1:ncol(metafin)) {
      # sean jacobson added this so that missing data would be ignored
      # if(is.na(metafin[i, j])) next
      if (metafin[i, j] == 0) {
        metaimp[i, j] <- NA
      }
      else {
        metaimp[i, j] <- metafin[i, j]
      }
    }
  }

  present <- matrix(1, nrow = nrow(metaf), ncol = ncol(metaf))
  colnames(present) <- colnames(metaf)
  rownames(present) <- rownames(metaf)
  for (j in 1:eval(ncol(metaf))) {
    for (i in 1:dim(metaf)[1]) {
      # sean jacobson added this for missing data
      # if(is.na(metaf[i, j])){present[i,j] <- NA; next}
      if (metaf[i, j] == 0) {
        present[i, j] <- 0
      }
    }
  }

  # Half-min val imputation
  minval <- metafin
  for (i in 1:nrow(metaf)) {
    for (j in 1:ncol(metafin)) {
      # sean jacobson added this for missing data
      # if(is.na(metafin[i, j])){minval[i,j] <- NA; next}
      if (metafin[i, j] == 0) {
        minval[i, j] <- 
          min(metaimp[, j], na.rm = TRUE) / 2
      }
      else {
        minval[i, j] <- metafin[i, j]
      }
    }
  }

#   browser() # DEBUG LINE

  metabpca <- pcaMethods::pca(metaimp, nPcs = 3, method = "bpca")
  bpca <- pcaMethods::completeObs(metabpca)
  colnames(bpca) <- colnames(metafin)
  rownames(bpca) <- rownames(metafin)
  coldrop <- 1
  for (i in 1:nrow(bpca)) {
    for (j in 1:ncol(bpca)) {
      if (bpca[i, j] < 0) {
        bpca[i, j] <- minval[i, j]
      }
    }
  }
  list(minval = as.data.frame(minval), withzero = as.data.frame(metafin), 
    bpca = as.data.frame(bpca), count = as.data.frame(count))
}


