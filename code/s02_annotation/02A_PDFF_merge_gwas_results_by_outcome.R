library(data.table)
library(magrittr)
library(stringr)
library(tidyverse)

filter=dplyr::filter
select=dplyr::select
rename=dplyr::rename
slice=dplyr::slice

# Input and output --------------------------------------------------------

input_res_gwas_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/Liver_MRI/new_PDFF/REGENIE_TOPMED/result"
input_res_gwas_regexpr <- "\\.regenie$"
#input_res_gwas_regexpr <- "^UKBB_TOPMED_PDFF_overall_and_stratified_by_ancestry.*\\.regenie$"

output_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/IndivProj/Antonino/GOLDPP/results"
#output_filename <- "UKB_FIB4adjPLT_pheno_white_combined_QCed_LDSCinput.txt"
#output_complete_gwas_filename <- "UKB_FIB4adjPLT_pheno_white_combined_QCed.txt"

info_score_threshold <- .85

# Start of the script -----------------------------------------------------

list_gwas <- dir(input_res_gwas_folder, input_res_gwas_regexpr)

list_gwas_trait <- 
  tibble(
    file = paste0(input_res_gwas_folder,"/",list_gwas)
  ) %>% 
  mutate(
    trait = str_split_i(str_split_fixed(list_gwas, "[.]", n=2)[,1], "chr\\d+_", 2)
  ) %>% 
  arrange(trait, file)

traits <- unique(list_gwas_trait$trait)

lapply(
  traits,
  function(
    t,
    list_gwas_trait,
    info_score_threshold,
    output_folder,
    input_res_gwas_folder
  ){
    
    print(paste0("Analyzed trait: ", t))
    
    list_res_gwas_files <- 
      list_gwas_trait %>% 
      filter(
        trait %in% t
      ) %>% 
      pull(
        file
      )
    
    #if(t == "FIB4_PLT_residuals"){t <- "FIB4adjPLT"}
    
    res_gwas_compl <- 
      do.call(
        bind_rows,
        lapply(
          list_res_gwas_files,
          function(
            f,
            t,
            input_res_gwas_folder
          ){
            
            print(paste0("Trait: ", t, ", working with: ", f))
            
            temp_gwas <- 
              as_tibble(fread(f)) %>% 
              filter(
                INFO > info_score_threshold
              ) %>% 
              mutate(
                p.value = 10^(-LOG10P)
              ) %>% 
              relocate(p.value, .before=LOG10P)
            
          },
          t,
    input_res_gwas_folder
        )
      ) %>% 
      arrange(CHROM, GENPOS) %>% 
      select(CHR=CHROM, POS=GENPOS, SNPID=ID, EA=ALLELE1, OA=ALLELE0, EAF=A1FREQ, N, BETA, SE, CHISQ, p.value, LOG10P, INFO, TEST)
    
    fwrite(
      res_gwas_compl,
      paste0(output_folder,"/","GWAS_",t,"_QCed_results.txt"),
      sep = "\t"
    )
    
  },
  list_gwas_trait,
  info_score_threshold,
  output_folder,
  input_res_gwas_folder
)



# res_gwas <- 
#   res_gwas_compl %>% 
#   select(SNPID, CHR, POS, EA, OA, BETA, SE, p.value, N, EAF)
# 
# res_gwas_pos <- 
#   res_gwas %>% 
#   filter(BETA >= 0)
# 
# res_gwas_neg <- 
#   res_gwas %>% 
#   filter(BETA < 0) %>% 
#   mutate(
#     BETA = -BETA,
#     EAF = 1 - EAF,
#     temp = EA,
#     EA = OA,
#     EA = temp
#   ) %>% 
#   select(-temp)
# 
# res_gwas_mod <- 
#   bind_rows(res_gwas_pos, res_gwas_neg) %>%
#   mutate(
#     #SNPID = paste0(SNPID,"|",CHR,":",POS,":",EA,":",OA)
#     Z = BETA/SE
#   ) %>%
#   arrange(CHR, POS) %>% 
#   select(SNP = SNPID, N, A1=EA, A2=OA, BETA, SE, PVAL=p.value)
# 
# fwrite(
#   res_gwas_mod,
#   paste0(output_folder,"/",output_filename),
#   sep = "\t"
# )
