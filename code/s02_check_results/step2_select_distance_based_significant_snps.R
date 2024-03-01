# This R script conducts QC on Regenie GWAS output
# Runs like Rscript step2_select_distance_based_significant_snps.R --indir input_dir --infile file_name --minMAF 0.0001 --minINFO 0.85 --out suffix --outdir output_directory

options(stringsAsFactors=F)

# load R packages
require(optparse)
library(data.table)
library(tidyverse)

# set list of command line arguments
option_list <- list(
  make_option("--indir", type="character",default="",
    help="Path to regenie step2 output dir "),
  make_option("--infile", type="character",default="",
    help="regenie step2 output file name"),
  make_option("--minMAF", type="integer",default="0.0001",
    help="mininum minor allele frequency, default 0.0001"),
  make_option("--minINFO", type="numeric",default="0.85",
    help="mininum INFO score, default 0.85"),
  make_option("--out", type="character",default=".qced",
    help="suffix of output file"),
    make_option("--outdir", type="character",default="",
    help="Path to save snps passed QC"))

# list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

# Define function: This function comes from antonio
orient_alleles <- function(data){
    # Filter the data to only include rows where BETA is greater than or equal to 0
    data_pos <- data %>% 
      filter(BETA >= 0)
    # Filter the data to only include rows where BETA is less than 0
    data_neg <- data %>% 
      filter(BETA < 0) %>% 
      # For these rows, multiply BETA by -1, subtract EAF from 1, and swap the values of OA and EA
      mutate(
        BETA = -BETA,
        EAF = 1 - EAF,
        temp = OA,
        OA = EA,
        EA = temp) %>% 
      select(-temp) # Remove the temporary column used for swapping
    
    # Combine the data with positive and negative BETA values and sort by CHR and POS
    res_data <- bind_rows(data_pos, data_neg) %>% 
                arrange(CHR, POS)
    
    res_data   
  }