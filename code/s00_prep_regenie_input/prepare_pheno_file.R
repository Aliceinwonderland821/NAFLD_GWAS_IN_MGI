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
raw_pheno <- fread(in_file_name) %>% as_tibble()

# Change to regenie format
clean_pheno <- raw_pheno %>%
                    rename(IID = DeID_PatientID) %>%
                    mutate(FID = IID) %>%
                    relocate(FID, .before = IID) %>%
                    mutate(NAFLD_EUR = case_when(majority_ancestry == "EUR" ~ NAFLD,
                                                 .default = NA),
                           NAFLD_AFR = case_when(majority_ancestry == "AFR" ~ NAFLD,
                                                 .default = NA),
                           NAFLD_AMR = case_when(majority_ancestry == "AMR" ~ NAFLD,
                                                  .default = NA),
                           NAFLD_CSA = case_when(majority_ancestry == "CSA" ~ NAFLD,
                                                  .default = NA),
                           NAFLD_EAS = case_when(majority_ancestry == "EAS" ~ NAFLD,
                                                  .default = NA),
                           NAFLD_WAS = case_when(majority_ancestry == "WAS" ~ NAFLD,
                                                  .default = NA),
                           NAFLD_F = case_when(SNPSEX == 2 ~ NAFLD,
                                                  .default = NA),
                           NAFLD_M = case_when(SNPSEX == 1 ~ NAFLD,
                                                   .default = NA),
                           NAFLD_EUR_F = case_when(SNPSEX == 2 & majority_ancestry == "EUR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_EUR_M = case_when(SNPSEX == 1 & majority_ancestry == "EUR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_AFR_F = case_when(SNPSEX == 2 & majority_ancestry == "AFR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_AFR_M = case_when(SNPSEX == 1 & majority_ancestry == "AFR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_AMR_F = case_when(SNPSEX == 2 & majority_ancestry == "AMR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_AMR_M = case_when(SNPSEX == 1 & majority_ancestry == "AMR" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_CSA_F = case_when(SNPSEX == 2 & majority_ancestry == "CSA" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_CSA_M = case_when(SNPSEX == 1 & majority_ancestry == "CSA" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_EAS_F = case_when(SNPSEX == 2 & majority_ancestry == "EAS" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_EAS_M = case_when(SNPSEX == 1 & majority_ancestry == "EAS" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_EAS_F = case_when(SNPSEX == 2 & majority_ancestry == "EAS" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_EAS_M = case_when(SNPSEX == 1 & majority_ancestry == "EAS" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_WAS_F = case_when(SNPSEX == 2 & majority_ancestry == "WAS" ~ NAFLD,
                                                    .default = NA),
                           NAFLD_WAS_M = case_when(SNPSEX == 1 & majority_ancestry == "WAS" ~ NAFLD,
                                                    .default = NA))

# write output
write.table(clean_pheno, out_file_name, quote = F, na = "NA", col.names = T, row.names = F, sep = "\t")
