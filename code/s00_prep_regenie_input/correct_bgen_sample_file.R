# This Rscript make bgen sample file ID_1 = ID_2
# Runs as Rscript correct_bgen_sample_file.R input_file output_file

# get args
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args) != 2) {
  stop("wrong number of args.n", call.=FALSE)
} else if (length(args)==2) {
  in_file <- args[1]
  out_file <- args[2]
}

# load package
library(data.table)
library(tidyverse)

# read and write sample file
sample_file = fread(in_file) %>% 
                mutate(ID_1 = ID_2)

write.table(sample_file, out_file, sep = "\t", quote = F, col.names = T, row.names = F)
