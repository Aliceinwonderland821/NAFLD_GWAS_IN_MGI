library(data.table)
library(magrittr)
library(stringr)
library(tidyverse)

# Input and output --------------------------------------------------------

input_file_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/IndivProj/Antonino/GOLDPP/results/independent_SNPs"
input_file_expr <- "pdff.*\\.txt$"

annovar_path <- "/nfs/corenfs/INTMED-Speliotes-data/Software/ANNOVAR/annovar_new/annovar"

output_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/IndivProj/Antonino/GOLDPPresults/independent_SNPs/"

# Start of the script -----------------------------------------------------

list_files <- dir(input_file_folder, input_file_expr)

old_wd <- getwd()

setwd(annovar_path)

lapply(
  list_files,
  function(
    file,
    input_file_folder,
    output_folder
  ){
    
    print(paste0("Working with the file: ", file))
    
    temp <- as_tibble(fread(paste0(input_file_folder,"/",file)))
    
    system(sprintf(
      "perl annotate_variation.pl -geneanno -dbtype refGene -buildver hg38 %s humandb/",
      paste0(input_file_folder,"/",file)
    ))
    
    temp2 <- 
      as_tibble(fread(paste0(input_file_folder,"/",file,".variant_function"))) %>% 
      set_colnames(c("location","Gene",colnames(temp)))
    
    exonic <- 
      temp2 %>% 
      filter(
        location %in% c("exonic")
      )
    
    if(nrow(exonic)>0){
      
      temp_exonic <- 
        as_tibble(fread(paste0(input_file_folder,"/",file,".exonic_variant_function"))) %>% 
        set_colnames(c("line", "exonic_location", "change", colnames(temp)))
      
      temp2 %<>% 
        left_join(select(temp_exonic, SNPID, exonic_location, change), by=c("SNPID")) %>% 
        mutate(
          location = if_else(!is.na(exonic_location), exonic_location, location)
        ) %>% 
        select(-exonic_location)
      
    }
    
    fwrite(
      temp2,
      paste0(input_file_folder,"/",file,".variant_function"),
      sep = "\t",
      na = "NA"
    )
    
    file.remove(paste0(input_file_folder,"/",file,".invalid_input"))
    
  },
  input_file_folder,
  output_folder
)

setwd(old_wd)
