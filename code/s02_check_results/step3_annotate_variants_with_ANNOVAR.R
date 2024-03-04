# This script annotate variants with ANNOVAR
# run as `Rscript step3_annotate_variants_with_ANNOVAR.R --indir input_dir --infileRegExpr regexprssion --outdir output_directory --dbtype refGene --buildver hg38 --humandb humandb_folder`

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
    help="Path to regenie step3 input file directory, i.e. where all the significant snps are stored."),
  make_option("--infileRegExpr", type="character",default="",
    help="regular expression of input file name"),
  make_option("--dbtype", type="character",default="refGene",
    help="database type, default to refGene"),
  make_option("--buildver", type="character",default="hg38",
    help="genome build version, default to hg38"),
  make_option("--humandb", type="character",default="",
    help="location of humandb folder, default to NULL"),
  make_option("--outdir", type="character",default="",
    help="Path to output file folder, default to NULL"))

# list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

# Get file list
list_files <- dir(opt$indir, opt$infileRegExpr)

lapply(
  list_files,
  function(
    file,
    input_file_folder,
    output_folder,
    dbtype,
    buildver,
    humandb
  ){
    
    print(paste0("Working with the file: ", file))
    
    temp <- as_tibble(fread(paste0(input_file_folder,"/",file)))
    
    system(paste(
      "annotate_variation.pl -geneanno -dbtype", dbtype, "-buildver", buildver, "-out", paste0(output_folder,"/",file), 
      paste0(input_file_folder,"/",file), humandb, sep = " "
    ))
    
    temp2 <- 
      as_tibble(fread(paste0(output_folder,"/",file,".variant_function"))) %>% 
      set_colnames(c("location","Gene",colnames(temp)))
    
    exonic <- 
      temp2 %>% 
      filter(
        location %in% c("exonic")
      )
    
    if(nrow(exonic)>0){
      
      temp_exonic <- 
        as_tibble(fread(paste0(output_folder,"/",file,".exonic_variant_function"))) %>% 
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
      paste0(output_folder,"/",file,".variant_function"),
      sep = "\t",
      na = "NA",
      quote = F
    )
    
    file.remove(paste0(output_folder,"/",file,".invalid_input"))
    
  },
  opt$indir,
  opt$outdir,
  opt$dbtype,
  opt$buildver,
  opt$humandb
)

# "GWAS.*\\.txt$"