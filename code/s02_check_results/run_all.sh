#!/bin/bash
# This script runs all steps in s02_check_results folder
# runs like `./run_all.sh`

# Step 1: QC the regenie results
### All ancestry using PC_ALL
cd ${DATA_OUT}step2_by_ancestry
ancestry=("" "_EUR" "_AFR" "_AMR" "_EAS" "_WAS" "_CSA")
parallel --jobs 22 \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_ancestry \
    --infile mgi_nafld_by_ancestry_chr{1}_NAFLD{2}.regenie \
    --minMAF 0.001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD{2}_QC_results/' ::: $(seq 1 22) ::: "${ancestry[@]}"

### EUR ancestry using PC_EUR
cd ${DATA_OUT}step2_by_ancestry_eur
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_ancestry_eur \
    --infile mgi_nafld_by_ancestry_eur_chr{}_NAFLD_EUR.regenie \
    --minMAF 0.001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD_EUR_QC_results/' ::: $(seq 1 22)

### Sex stratified using PC_ALL
cd ${DATA_OUT}step2_by_sex
#strata=("_M" "_F" "_EUR_F" "_EUR_M" "_AFR_F" "_AFR_M" "_AMR_F" "_AMR_M" "_EAS_F" "_EAS_M" "_WAS_F" "_WAS_M" "_CSA_M" "_CSA_F")
strata=("_AFR_M" "WAS_M" "_CSA_M" "_CSA_F")
parallel --jobs 22 \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_sex \
    --infile mgi_nafld_by_sex_chr{1}_NAFLD{2}.regenie \
    --minMAF 0.001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD{2}_QC_results/' ::: $(seq 1 22) ::: "${strata[@]}"

### Sex stratifed EUR using PC_EUR
cd ${DATA_OUT}step2_by_sex_eur
strata=("_M" "_F")
parallel --jobs 22 \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_sex_eur \
    --infile mgi_nafld_by_sex_eur_chr{1}_NAFLD_EUR{2}.regenie \
    --minMAF 0.001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD_EUR{2}_QC_results/' ::: $(seq 1 22) ::: "${strata[@]}"

# Step 2: 