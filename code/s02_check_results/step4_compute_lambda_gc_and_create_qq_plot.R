# This script compute lambda GC for each GWASes in the input folder
# run as `Rscript step4_compute_lambda_gc_and_create_qq_plot.R --indir input_dir --infileRegExpr regexprssion --outdir output_directory --out output prefix --method chisq --minMAF 0.0001`

options(stringsAsFactors=F)

# load R packages
require(optparse)
library(data.table)
suppressPackageStartupMessages(library(tidyverse))

# set list of command line arguments
option_list <- list(
  make_option("--indir", type="character",default="",
    help="Path to qc-ed regenie step2 output file directory, i.e. where all the significant snps are stored."),
  make_option("--infileRegExpr", type="character",default="",
    help="regular expression of input file name"),
  make_option("--method", type="character",default="chisq",
    help="Which method to use to compute lambda GC, either chisq or pvalue, default to chisq"),
  make_option("--minMAF", type="numeric",default="0.0001",
    help="mininum minor allele frequency to use for qq plot, default 0.0001"),
  make_option("--out", type="character",default="",
    help="output file prefix, default to NULL"),
  make_option("--outdir", type="character",default="",
    help="Path to output file folder, default to NULL"))

# list of options
parser <- OptionParser(usage="%prog [options]", option_list=option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

# Check options
if(!dir.exists(opt$outdir)){dir.create(opt$outdir)}
if(opt$method != "chisq" & opt$method != "pvalue"){
  stop("--method must be either chisq or pvalue")
}
if (!is.numeric(opt$minMAF)){stop("D'oh! minMAF is not numeric.")}

# Define functions
## Compute lambda GC
compute_lambda <- function(gwas_res, method){
  if(method == "pvalue"){
    lambda <- qchisq(median(as.numeric(gwas_res$P_VALUE),na.rm=T),1,lower.tail=FALSE)/qchisq(0.50,1,lower.tail=FALSE)
  }else if(method == "chisq"){
    lambda <- median(as.numeric(gwas_res$CHISQ),na.rm=T)/qchisq(0.50,1,lower.tail=FALSE)
  }
  lambda
}

## Make a pretty QQ plot of p-values
qq = function(pvector, ...) {
  if (!is.numeric(pvector)) stop("D'oh! P value vector is not numeric.")
  pvector <- pvector[!is.na(pvector) & pvector<1 & pvector>0]
  o = -log10(sort(pvector,decreasing=F))
	e = -log10( ppoints(length(pvector) ))
	plot(e,o,pch=19,cex=1, xlab=expression(Expected~~-log[10](italic(p))), ylab=expression(Observed~~-log[10](italic(p))), xlim=c(0,max(e)), ylim=c(0,max(o)), ...)
	abline(0,1,col="red")
}

# Get file list
list_gwas <- dir(opt$indir, opt$infileRegExpr)

# Use lapply to read each file into a data frame
chr_res_list <- lapply(list_gwas, function(file, input_folder) {
  as_tibble(fread(paste0(input_folder,"/",file)))%>%
  filter(between(EAF, opt$minMAF, 1-opt$minMAF)) %>%
  select(P_VALUE, LOG10P, CHISQ)
}, opt$indir) 
# Use bind_rows to combine all data frames into one tibble
input_res_all <- bind_rows(chr_res_list)

# Compute lambda GC
lambda_gc <- compute_lambda(input_res_all, opt$method)

# Plot QQ plot
png(paste0(opt$outdir,"/", opt$out, '_', opt$minMAF, '_QQ.png'),height=600,width=600,res=100)
qq(as.numeric(input_res_all$P_VALUE))
legend('topleft',legend=bquote("Median"~lambda == .(round(lambda_gc,2))),bg='white',bty='n',cex=1)
dev.off()






