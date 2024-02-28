#!/bin/bash
# This scripts remove snps MAF< 0.01 using plink
# runs as `./step2_prepare_step1_input.sh`

plink2 --bfile ${GENO_IN}Freeze5_TOPMED_CoreExome_GSA \
       --maf 0.01 --make-bed --out ${GENO_STEP1}Freeze5_TOPMED_CoreExome_GSA_MAF_0.01

# Example in Regenie documentation
# If regenie still returns error after MAF 0.01 filter, run following code
# plink2 \
#   --bfile ukb_cal_allChrs \
#   --maf 0.01 --mac 100 --geno 0.1 --hwe 1e-15 \
#   --mind 0.1 \
#   --write-snplist --write-samples --no-id-header \
#   --out qc_pass

