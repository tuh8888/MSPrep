#' 
#' Prepare a mass spec quantification data frame for filtering, imputation,
#' and normalization. Also provides summaries of data structure (replicates,
#' subjects, spike, etc.) 
#'
#' Function reads in raw data files and summarizes technical replicates as the
#' mean of observations for compounds found in 2 or 3 replicates and with
#' coefficient of variation below specified level, or median for those found in
#' 3 replicates but excess CV.
#'
#' @param data A tidy dataframe of quantification data.
#' @param subject_id Name (string) of the subject ID column.
#' @param replicate Name (string) of the replicate column. Set to NULL if no
#' replicates. TODO: test NULL.
#' @param abundance Name (string) of the abundance column.
#' @param spike Name (string) of the spike column.
#' @param mz Mass-to-charge ratio variable name.
#' @param rt Retention time variable name.
#' @param cvmax Acceptable level of coefficient of variation between replicates.
#' @param missing_val Value of missing data in the quantification data file.
#' @param min_proportion_present  Minimum proportion present to summarize with
#' median or mean. Below this the compound will be set to 0.
#' @return An \code{msprepped} object containing summarised quantification data,
#' a dataset of compounds summarised by medians, and other related summaries.
#' @examples
#'
#' # Read in data file
#' data(msquant)
#' 
#' # Convert dataset to tidy format
#' tidy_data    <- ms_tidy(msquant, mz = "mz", rt = "rt")
#' prepped_data <- ms_prepare(tidy_data, replicate = "replicate")
#' 
#' # Or, using tidyverse/magrittr pipes 
#' library(magrittr)
#' prepped_data <- msquant %>% ms_tidy %>% ms_prepare
#'
#' str(prepped_data)
#' str(prepped_data$summary_data)
#'
#' @importFrom dplyr select
#' @importFrom dplyr mutate 
#' @importFrom dplyr mutate_at
#' @importFrom dplyr group_by 
#' @importFrom dplyr arrange 
#' @importFrom dplyr summarise 
#' @importFrom dplyr ungroup 
#' @importFrom dplyr case_when
#' @importFrom dplyr distinct
#' @importFrom dplyr filter
#' @importFrom dplyr vars
#' @importFrom rlang .data
#' @importFrom stats median
#' @importFrom stats sd
#' @export
ms_prepare <- function(data,
                       subject_id  = "subject_id",
                       replicate   = "replicate",
                       abundance   = "abundance",
                       spike       = "spike",
                       mz          = "mz",
                       rt          = "rt",
                       cvmax       = 0.50,
                       missing_val = 1,
                       min_proportion_present = 1/3) {

  # Check args
  stopifnot(is.data.frame(data))
  my_args  <- mget(names(formals()), sys.frame(sys.nframe()))

  # Replace provided variable names with standardized ones
  data <- standardize_dataset(data, subject_id, replicate, abundance, spike, mz, rt)

  # Replace miss val with NAs 
  data <- mutate_at(data, vars(abundance), replace_missing, missing_val)

  # Get replicate count for each mz/rt/spike/subject combo
  replicate_count <- length(unique(data[["replicate"]]))

  # Roughly check if all compounds are present in each replicate
  stopifnot(nrow(data) %% replicate_count == 0)

  # Calculate initial summary measures 
  #   Note;(matrix algebra would be faster --
  #     consider later)
  quant_summary <- group_by(data, subject_id, spike, mz, rt)
  quant_summary <- arrange(quant_summary, mz, rt, subject_id, spike, replicate)
  quant_summary <- summarise(quant_summary,
                             n_present        = sum(!is.na(abundance)),
                             prop_present     = n_present / replicate_count,
                             mean_abundance   = mean(abundance, na.rm = T),
                             sd_abundance     = sd(abundance, na.rm = T),
                             median_abundance = median(abundance, na.rm = T))
  quant_summary <- mutate(quant_summary, cv_abundance = sd_abundance / mean_abundance)
  quant_summary <- ungroup(quant_summary)

  # Identify and select summary measure
  quant_summary <-
    mutate(quant_summary,
           summary_measure = 
             select_summary_measure(n_present, cv_abundance, replicate_count,
                                    min_proportion_present, cvmax),
           abundance_summary = 
             case_when(summary_measure == "median" ~ median_abundance,
                       summary_measure == "mean"   ~ mean_abundance,
                       TRUE                        ~ 0))
  quant_summary <- mutate_at(quant_summary,
                             c("subject_id", "summary_measure", "spike"),
                             factor)

  # Extract summarized dataset
  summary_data  <- select(quant_summary, subject_id, spike, mz, rt,
                          abundance_summary)

  # Additional info extracted in summarizing replicates
  replicate_info <- select(quant_summary, subject_id, spike, mz, rt, n_present,
                           cv_abundance, summary_measure)

  # Summaries that used medians
  medians        <- filter(quant_summary, summary_measure == "median")
  medians        <- select(medians, subject_id, spike, mz, rt,
                           abundance_summary)

  # Total number of compounds identified
  n_compounds    <- nrow(distinct(select(quant_summary, mz, rt)))

  # Count of subject,spike pairs
  n_subject_spike_pairs  <- nrow(distinct(select(quant_summary, subject_id, spike)))

  # Subject and spike id combos
  subjects_summary <- distinct(select(quant_summary, subject_id, spike))

  # Create return object & return
  structure(list(summary_data    = summary_data,
                 replicate_info  = replicate_info,
                 clinical        = subjects_summary,
                 medians         = medians,
                 replicate_count = replicate_count,
                 cvmax           = cvmax,
                 min_proportion_present = min_proportion_present),
            class = "msprepped")

}



print.msprepped <- function(x) {
  cat("prepped msprep object\n")
  cat("    Replicate count: ", x$replicate_count, "\n")
  cat("    Patient count: ", length(unique(x$clinical$subject_id)), "\n")
  cat("    Count of spike levels: ", length(unique(x$clinical$spike)), "\n")
  cat("    Count patient-spike combinations: ", nrow(x$clinical), "\n")
  cat("    Count of patient-spike compounds summarized by median: ", nrow(x$medians), "\n")
  cat("    User-defined parameters \n")
  cat("        cvmax = ", x$cvmax, "\n")
  cat("        min_proportion_present = ", round(x$min_proportion_present, digits=3), "\n")
  cat("    Summarized dataset:\n")
  print(x$summary_data, n = 6)
}




replace_missing <- function(abundance, missing_val) {
  ifelse(abundance == missing_val, NA, abundance)
}



#' @importFrom dplyr case_when
select_summary_measure <- function(n_present,
                                   cv_abundance,
                                   n_replicates,
                                   min_proportion_present,
                                   cv_max) {

  case_when((n_present / n_replicates) <= min_proportion_present
              ~ "none: proportion present <= min_proportion_present",
            cv_abundance > cv_max & (n_replicates == 3 & n_present == 2) 
              ~ "none: cv > cvmax & 2 present",
            cv_abundance > cv_max & (n_present == n_replicates) 
              ~ "median",
            TRUE ~ "mean")

}




#' @importFrom dplyr rename
#' @importFrom rlang sym
#' @importFrom rlang UQ
standardize_dataset <- function(data, subject_id, replicate, abundance, spike,
                                mz, rt) {

  # Rename required variables
  subject_id = sym(subject_id)
  abundance  = sym(abundance)
  mz         = sym(mz)
  rt         = sym(rt)

  data <- data %>% 
    rename("subject_id" = UQ(subject_id),
           "abundance"  = UQ(abundance),
           "mz"         = UQ(mz),
           "rt"         = UQ(rt))

  # Rename optional variables if present
  if (!is.null(replicate)) {
    replicate  = sym(replicate)
    data <- data %>%
      rename("replicate" = UQ(replicate))
  } else {
    data$replicate <- "None"
  }

  if (!is.null(spike)) {
    spike  = sym(spike)
    data <- data %>%
      rename("spike" = UQ(spike))
  } else {
    data$spike <- "Not provided"
  }

  return(data)

}


