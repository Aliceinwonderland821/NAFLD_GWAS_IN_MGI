# This script compute lambda GC for each GWAS in the input folder
# run as `Rscript step5_plot_lambda_by_MAF_MAC.R --indir input_dir --infileRegExpr regexprssion --outdir output_directory --out output prefix`

options(stringsAsFactors=F)

# load R packages
require(optparse)
library(data.table)
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(tidyverse))

# set list of command line arguments
option_list <- list(
  make_option("--indir", type="character",default="",
    help="Path to qc-ed regenie step2 output file directory"),
  make_option("--infileRegExpr", type="character",default="",
    help="regular expression of input file name"),
  make_option("--method", type="character",default="chisq",
    help="Which method to use to compute lambda GC, either chisq or pvalue, default to chisq"),
  make_option("--out", type="character",default="",
    help="output file prefix, default to NULL"),
  make_option("--outdir", type="character",default="",
    help="Path to output file folder, default to NULL"))

# list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

# Check options
if(!dir.exists(opt$outdir)){dir.create(opt$outdir)}

# Define functions
compute_lambda <- function(gwas_res, method){
  if(method == "pvalue"){
    lambda <- qchisq(median(as.numeric(gwas_res$P_VALUE),na.rm=T),1,lower.tail=FALSE)/qchisq(0.50,1,lower.tail=FALSE)
  }else if(method == "chisq"){
    lambda <- median(as.numeric(gwas_res$CHISQ),na.rm=T)/qchisq(0.50,1,lower.tail=FALSE)
  }
  lambda
}


compute_and_plot_lambda_gc <- function(df) {
  # Define MAF thresholds
  maf_thresholds <- seq(0.0001, 0.05, by = 0.0001)
  
  # Initialize a data frame to store results
  results <- data.frame(MAF_threshold = numeric(), lambda_gc = numeric())
  
  # Compute lambda GC for each MAF threshold
  for (maf_threshold in maf_thresholds) {
    # Filter df for MAF threshold
    df_filtered <- df[df$MAF >= maf_threshold,]
    
    # Compute lambda GC
    observed_median <- median(df_filtered$chisq)
    expected_median <- qchisq(0.50, 1, lower.tail = FALSE)
    lambda_gc <- observed_median / expected_median
    
    # Add results to data frame
    results <- rbind(results, data.frame(MAF_threshold = maf_threshold, lambda_gc = lambda_gc))
  }
  
  # Plot lambda GC against MAF threshold
  ggplot(results, aes(x = MAF_threshold, y = lambda_gc)) +
    geom_point() +
    xlab("Minor Allele Frequency Threshold") +
    ylab("Lambda GC") +
    ggtitle("Lambda GC vs. Minor Allele Frequency Threshold")
}

# Call the function
compute_and_plot_lambda_gc(df)