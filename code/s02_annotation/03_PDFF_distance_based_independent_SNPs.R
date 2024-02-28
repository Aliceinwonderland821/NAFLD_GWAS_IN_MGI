library(data.table)
library(magrittr)
library(stringr)
library(tidyverse)
#library(parallel)


# Define the input and output parameters --------------------------------------

input_folder <- "results"
input_file_format <- "^GWAS_pdff"

output_folder <- "results/independent_SNPs"

max_dist <- 500000

threshold <- 5e-08
MAC_threshold <- 10


# My functions ------------------------------------------------------------

orient_alleles <- 
  function(
    data
  ){
    
    data_pos <- 
      data %>% 
      filter(
        BETA >= 0
      )
    
    data_neg <- 
      data %>% 
      filter(
        BETA < 0
      ) %>% 
      mutate(
        BETA = -BETA,
        EAF = 1 - EAF,
        temp = OA,
        OA = EA,
        EA = temp
      ) %>% 
      select(
        -temp
      )
    
    res_data <- 
      bind_rows(data_pos, data_neg) %>% 
      arrange(CHR, POS)
    
    res_data
    
  }

# Start of the script ------------------------------------------------------------

if(!dir.exists(output_folder)){dir.create(output_folder)}

#setwd(input_folder)
list_gwas = dir(input_folder, input_file_format)

lapply(list_gwas, function(file,
                                input_folder,
                                threshold,
                                MAC_threshold,
                                output_folder
                                ){
  
  #Read the file
  
  print(paste0("Reading ", file, "..."))
  
  input_res_all = as_tibble(fread(paste0(input_folder,"/",file)))
  
  input_res <- 
    input_res_all %>% 
    filter(
      if(!is.null(threshold)){p.value < threshold} else {p.value < 1}
    ) %>% 
    mutate(
      MAC = 2 * N * EAF
    ) %>% 
    filter(
      (
        OA %in% c("A","T","C","G") & EA %in% c("A","T","C","G")),
      # !(
      #   (
      #     (OA=="A" & EA=="T") | 
      #     (OA=="T" & EA=="A") |
      #     (OA=="C" & EA=="G") |
      #     (OA=="G" & EA=="C") 
      #   ) & between(EAF, .3, .7)
      # ),
      between(MAC, MAC_threshold + 1, 2 * N - MAC_threshold - 1)
    )
  
  filename <- str_split_i(str_split_i(file, "_QCed", 1),"GWAS_",2)
  
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
            chosen_SNPs,
            file
            
        ){
          
          candidate_SNPs_chr <- 
            candidate_SNPs %>% 
            filter(
              CHR == i
            ) 
          
          chosen_SNPs_chr <- chosen_SNPs
          
          while(nrow(candidate_SNPs_chr)>0){
            
            print(paste0("File: ", file,", CHR: ", i, ", # remaining candidate SNPs for this chr: ", nrow(candidate_SNPs_chr), ", # chosen SNPs for this chr: ", nrow(chosen_SNPs_chr)))

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
                !(CHR == temp$CHR & (abs(temp$POS - POS) < max_dist))
                
              )
            
          }
          print(paste0("File: ", file,", CHR: ", i, ", # remaining candidate SNPs for this chr: ", nrow(candidate_SNPs_chr), ", # chosen SNPs for this chr: ", nrow(chosen_SNPs_chr)))
          chosen_SNPs_chr
        },
        candidate_SNPs,
        chosen_SNPs,
        file
      )
    ) %>% 
      mutate(
        POS2 = POS
      ) %>% 
      select(CHR, POS, POS2, EA, OA, everything()) %>% 
      arrange(CHR, POS)
    
    print(paste0("I have finished selecting SNPs from ", file, ". #Chosen SNPs: ", nrow(res_chosen_SNPs)))
    
    cat("I am writing the results.\n\n")
    
    final_filename <- 
      if_else(
        !is.null(threshold),
        paste0(output_folder,"/independent_SNPs_", filename,"_",threshold),
        paste0(output_folder,"/independent_SNPs_", filename,"_all")
      )
    
    
    fwrite(
      res_chosen_SNPs,
      paste0(final_filename,".txt"),
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
  
}, 
input_folder,
threshold,
MAC_threshold,
output_folder
)



