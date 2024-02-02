# This scripts prepares Regenie input file
# `Rscript step0_prepare_pheno_file.R raw_file_name out_file_name`

# get system envrionment variables
pheno_in = Sys.getenv("PHENO_IN")
pheno_out = Sys.getenv("PHENO_DIR")


# get args
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2){
  stop("wrong number of args", call.=FALSE)
  } else if (length(args)== 2) {
    in_file = args[1]
    out_file = args[2]
  }


# Set path
in_file_name <- paste0(pheno_in, in_file)
out_file_name <- paste0(pheno_out, out_file)

# Load packages
library(data.table)
library(tidyverse)

# Load data
raw_pheno <- fread(in_file_name)

# Change to regenie format
clean_pheno <- raw_pheno %>%
                    rename(IID = DeID_PatientID) %>%
                    mutate(FID = IID) %>%
                    relocate(FID, .before = IID)

# write output
write.table(clean_pheno, out_file_name, quote = F, na = "NA", col.names = T, row.names = F, sep = "\t")
