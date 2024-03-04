# This R script conducts QC on Regenie GWAS output
# Runs like Rscript step2_select_distance_based_significant_snps.R --indir input_dir --infileRegExpr regexprssion --pthreshold 5e-08 --out output_prefix --outdir output_directory

options(stringsAsFactors=F)

# load R packages
require(optparse)
library(data.table)
library(stringr)
library(magrittr)
suppressPackageStartupMessages(library(tidyverse))

# set list of command line arguments
option_list <- list(
  make_option("--indir", type="character",default="",
    help="Path to regenie step2 output dir (i.e. gwas results) "),
  make_option("--infileRegExpr", type="character",default="",
    help="regular expression of input file name"),
  make_option("--pthreshold", type="numeric",default="5e-08",
    help="p-value threshold"),
  make_option("--minMAF", type="numeric",default="0.0001",
    help="mininum minor allele frequency, default 0.0001"),
  make_option("--minINFO", type="numeric",default="0.85",
    help="mininum INFO score, default 0.85"),
  make_option("--maxdist", type="integer",default="500000",
    help="maximum distance to select independent snp, default 500,000"),
  make_option("--out", type="character",default="",
    help="output file prefix, default to NULL"),
  make_option("--outdir", type="character",default="",
    help="Path to save independent snps file folder"))

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

# Create output directory 
if(!dir.exists(opt$outdir)){dir.create(opt$outdir)}

list_gwas <- dir(opt$indir, opt$infileRegExpr)

# Use lapply to read each file into a data frame
chr_res_list <- lapply(list_gwas, function(file, input_folder) {
  as_tibble(fread(paste0(input_folder,"/",file)))
}, opt$indir)
# Use bind_rows to combine all data frames into one tibble
input_res_all <- bind_rows(chr_res_list)


  input_res <- 
    input_res_all %>% 
    filter(
      (if(!is.null(opt$pthreshold)){P_VALUE < opt$pthreshold} else {P_VALUE < 1}),
      (OA %in% c("A","T","C","G") & EA %in% c("A","T","C","G")), # remove indels and keep only snps
      between(EAF, opt$minMAF, 1 - opt$minMAF),
      INFO > opt$minINFO
    )
  
  if(nrow(input_res)>0){
    
    input_res %<>%
      orient_alleles()
    
    candidate_SNPs = input_res
    
    chosen_SNPs = candidate_SNPs[-c(1:nrow(candidate_SNPs)),]
    
    res_chosen_SNPs <- 
    do.call(
      bind_rows,
      lapply(
        #cl,
        sort(unique(input_res$CHR)),
        function(
            i,
            candidate_SNPs,
            chosen_SNPs
        ){
          
          candidate_SNPs_chr <- 
            candidate_SNPs %>% 
            filter(
              CHR == i
            ) 
          
          chosen_SNPs_chr <- chosen_SNPs
          
          while(nrow(candidate_SNPs_chr)>0){
            
            print(paste0("CHR: ", i, ", # remaining candidate SNPs for this chr: ", nrow(candidate_SNPs_chr), ", # chosen SNPs for this chr: ", nrow(chosen_SNPs_chr)))

            temp = 
              candidate_SNPs_chr %>%
              slice_max(LOG10P, n=1) %>%
              slice_head(n=1)
            
            chosen_SNPs_chr %<>% bind_rows(temp)
            
            candidate_SNPs_chr %<>%
              filter(
                
                #Remove the chosen SNP at the current step
                SNPID != temp$SNPID,
                
                #Remove the SNPs within the max_dist range
                !(CHR == temp$CHR & (abs(temp$POS - POS) < opt$maxdist))
                
              )
            
          }
          print(paste0("CHR: ", i, ", # remaining candidate SNPs for this chr: ", nrow(candidate_SNPs_chr), ", # chosen SNPs for this chr: ", nrow(chosen_SNPs_chr)))
          chosen_SNPs_chr
        },
        candidate_SNPs,
        chosen_SNPs
      )
    ) %>% 
      mutate(
        POS2 = POS
      ) %>% 
      select(CHR, POS, POS2, EA, OA, everything()) %>% 
      arrange(CHR, POS)
    
    print(paste0("I have finished selecting SNPs. #Chosen SNPs: ", nrow(res_chosen_SNPs)))
    
    cat("I am writing the results.\n\n")
    
    final_filename <- 
      if_else(
        !is.null(opt$pthreshold),
        paste0(opt$outdir,"/GWAS_independent_SNPs_", opt$out,"_", opt$pthreshold),
        paste0(opt$outdir,"/GWAS_independent_SNPs_", opt$out, "_all")
      )
    
    fwrite(
      res_chosen_SNPs,
      paste0(final_filename, ".txt"),
      sep="\t"
    )
    
    res_chosen_SNPs %>%
      select(CHR, POS, POS2) %>%
      #mutate(POS2 = POS) %>%
      fwrite(
        paste0(final_filename,".bed"),
        sep="\t",
        col.names = F
      )
    
  }
  
