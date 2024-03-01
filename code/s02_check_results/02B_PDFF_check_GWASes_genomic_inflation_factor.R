library(data.table)
library(magrittr)
library(stringr)
library(tidyverse)

filter=dplyr::filter
select=dplyr::select
rename=dplyr::rename
slice=dplyr::slice

# Input and output --------------------------------------------------------

input_res_gwas_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/IndivProj/Antonino/GOLDPP/results"
input_res_gwas_regexpr <- "^GWAS_pdff"

output_folder <- "/nfs/corenfs/INTMED-Speliotes-data/Projects/UK_ATLAS/IndivProj/Antonino/GOLDPP/results"
output_filename <- "list_genomic_inflation_factor_PDFF_by_GWAS.txt"



# Start of the script -----------------------------------------------------

if(!dir.exists(output_folder)){dir.create(output_folder)}

list_gwas <- dir(input_res_gwas_folder, input_res_gwas_regexpr)

lambda_list <-
  do.call(
    bind_rows,
    lapply(
      list_gwas,
      function(
        file,
        input_res_gwas_folder
      ){
          print(paste0("Working with: ", file))
          trait <- str_split_i(str_split_i(file, "_QCed", 1),"GWAS_",2)
          temp <- as_tibble(fread(paste0(input_res_gwas_folder,"/",file)))

          lambda <- qchisq(median(as.numeric(temp$p.value),na.rm=T),1,lower.tail=FALSE)/qchisq(0.50,1,lower.tail=FALSE)

          tibble(
            trait = trait,
            lambda = lambda
          )
      },
        input_res_gwas_folder
    )
  )

fwrite(
  lambda_list,
  paste0(output_folder,"/",output_filename),
  sep = "\t",
  na = "NA",
  quote = F
)

