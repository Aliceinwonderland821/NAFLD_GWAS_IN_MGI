# This R script conducts QC on Regenie GWAS output
# Runs like Rscript step1_regenie_result_qc.R --indir input_dir --infile file_name --minMAF 0.0001 --minINFO 0.85 --out suffix --outdir output_directory
# To get help, run `Rscript step1_regenie_result_qc.R --help`

options(stringsAsFactors=F)

## load R libraries
require(optparse)
library(data.table)
suppressPackageStartupMessages(library(tidyverse))

## set list of command line arguments
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

## list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

## set input file name and output file name
input_file <- paste0(opt$indir, opt$infile)
output_file <- paste0(opt$outdir, opt$infile, opt$out)
if (!dir.exists(opt$outdir)) {dir.create(opt$outdir)}

## Read in results
raw_res <- fread(opt$infile)

## QC variants based on INFO score and MAF
#-----------------------------------------------------------------------------------
## Regenie output colnames 
## CHROM GENPOS ID ALLELE0 ALLELE1 A1FREQ INFO N TEST BETA SE CHISQ LOG10P EXTRA
#-----------------------------------------------------------------------------------

qced_res <- raw_res %>% 
             filter(A1FREQ > opt$minMAF, INFO > opt$minINFO) %>%
             mutate(P_VALUE = 10^(-LOG10P)) %>%
             select(CHR=CHROM, POS=GENPOS, SNPID=ID, EA=ALLELE1, OA=ALLELE0, EAF=A1FREQ, INFO, N, BETA, SE, CHISQ, P_VALUE, LOG10P, INFO, TEST) 


fwrite(qced_res, output_file, sep="\t", quote=F, row.names=F, col.names=T)