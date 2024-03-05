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
    --minMAF 0.0001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD{2}_QC_results/' ::: $(seq 1 22) ::: "${ancestry[@]}"

### EUR ancestry using PC_EUR
cd ${DATA_OUT}step2_by_ancestry_eur
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_ancestry_eur \
    --infile mgi_nafld_by_ancestry_eur_chr{}_NAFLD_EUR.regenie \
    --minMAF 0.0001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD_EUR_QC_results/' ::: $(seq 1 22)

### Sex stratified using PC_ALL
cd ${DATA_OUT}step2_by_sex
strata=("_M" "_F" "_EUR_F" "_EUR_M" "_AFR_F" "_AFR_M" "_AMR_F" "_AMR_M" "_EAS_F" "_EAS_M" "_WAS_F" "_WAS_M" "_CSA_M" "_CSA_F")
#strata=("_AFR_M" "_WAS_M" "_CSA_M" "_CSA_F")
parallel --jobs 22 \
'Rscript ${PROJ_LOC}code/s02_check_results/step1_result_QC.R \
    --indir ${DATA_OUT}step2_by_sex \
    --infile mgi_nafld_by_sex_chr{1}_NAFLD{2}.regenie \
    --minMAF 0.0001 \
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
    --minMAF 0.0001 \
    --minINFO 0.85 \
    --out .qced \
    --outdir NAFLD_EUR{2}_QC_results/' ::: $(seq 1 22) ::: "${strata[@]}"

# Step 2: 
## All ancestry using PC_ALL
ancestry=("NAFLD" "NAFLD_EUR" "NAFLD_AFR" "NAFLD_AMR" "NAFLD_EAS" "NAFLD_WAS" "NAFLD_CSA")
parallel --jobs 3 \
'Rscript ${PROJ_LOC}code/s02_check_results/step2_select_distance_based_significant_snps.R \
    --indir ${DATA_OUT}step2_by_ancestry/{}_QC_results \
    --infileRegExpr regenie.qced \
    --pthreshold 5e-8 \
    --maxdist 500000 \
    --out {} \
    --outdir ${DATA_OUT}step2_by_ancestry' ::: "${ancestry[@]}"

## EUR ancestry using PC_EUR
Rscript ${PROJ_LOC}code/s02_check_results/step2_select_distance_based_significant_snps.R \
    --indir ${DATA_OUT}step2_by_ancestry_eur/NAFLD_EUR_QC_results \
    --infileRegExpr regenie.qced \
    --pthreshold 5e-8 \
    --maxdist 500000 \
    --out  NAFLD_EUR \
    --outdir ${DATA_OUT}step2_by_ancestry_eur

## All ancestry stratefied by sex using PC_ALL
strata=("NAFLD_M" "NAFLD_F" "NAFLD_EUR_F" "NAFLD_EUR_M" "NAFLD_AFR_F" "NAFLD_AFR_M" "NAFLD_AMR_F" "NAFLD_AMR_M" "NAFLD_EAS_F" "NAFLD_EAS_M" "NAFLD_WAS_F" "NAFLD_WAS_M" "NAFLD_CSA_M" "NAFLD_CSA_F")
parallel --jobs 6 \
'Rscript ${PROJ_LOC}code/s02_check_results/step2_select_distance_based_significant_snps.R \
    --indir ${DATA_OUT}step2_by_sex/{}_QC_results \
    --infileRegExpr regenie.qced \
    --pthreshold 5e-8 \
    --maxdist 500000 \
    --out {} \
    --outdir ${DATA_OUT}step2_by_sex' ::: "${strata[@]}"

## EUR ancestry stratefied by sex using PC_EUR
strata=("NAFLD_EUR_M" "NAFLD_EUR_F")
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step2_select_distance_based_significant_snps.R \
    --indir ${DATA_OUT}step2_by_sex_eur/{}_QC_results \
    --infileRegExpr regenie.qced \
    --pthreshold 5e-8 \
    --maxdist 500000 \
    --out {} \
    --outdir ${DATA_OUT}step2_by_sex_eur' ::: "${strata[@]}"

# Step 3: Annotation
folders=("step2_by_ancestry" "step2_by_ancestry_eur" "step2_by_sex" "step2_by_sex_eur")
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step3_annotate_variants_with_ANNOVAR.R \
    --indir ${DATA_OUT}{} \
    --infileRegExpr 5e-08.txt$ \
    --outdir ${DATA_OUT}{} \
    --dbtype refGene \
    --buildver hg38 \
    --humandb ${PROJ_LOC}code/s02_check_results/humandb/ > ${DATA_OUT}{}/annovar.{}.log' ::: "${folders[@]}"


# Step 4: Generate QQ plots with lambda GC
## All ancestry using PC_ALL
folders=("NAFLD" "NAFLD_EUR" "NAFLD_AFR" "NAFLD_AMR" "NAFLD_EAS" "NAFLD_WAS" "NAFLD_CSA")
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step4_compute_lambda_gc_and_create_qq_plot.R \
    --indir ${DATA_OUT}step2_by_ancestry/{}_QC_results \
    --infileRegExpr regenie.qced \
    --outdir ${DATA_OUT}step2_by_ancestry \
    --out {} \
    --method chisq \
    --minMAF 0.01' ::: "${folders[@]}"

## EUR ancestry using PC_EUR
Rscript ${PROJ_LOC}code/s02_check_results/step4_compute_lambda_gc_and_create_qq_plot.R \
    --indir ${DATA_OUT}step2_by_ancestry_eur/NAFLD_EUR_QC_results \
    --infileRegExpr regenie.qced \
    --method chisq \
    --minMAF 0.01 \
    --out  NAFLD_EUR \
    --outdir ${DATA_OUT}step2_by_ancestry_eur

## All ancestry stratified by sex
folders=("NAFLD_M" "NAFLD_F" "NAFLD_EUR_F" "NAFLD_EUR_M" "NAFLD_AFR_F" "NAFLD_AFR_M" "NAFLD_AMR_F" "NAFLD_AMR_M" "NAFLD_EAS_F" "NAFLD_EAS_M" "NAFLD_WAS_F" "NAFLD_WAS_M" "NAFLD_CSA_M" "NAFLD_CSA_F")
parallel --jobs 3 \
'Rscript ${PROJ_LOC}code/s02_check_results/step4_compute_lambda_gc_and_create_qq_plot.R \
    --indir ${DATA_OUT}step2_by_sex/{}_QC_results \
    --infileRegExpr regenie.qced \
    --outdir ${DATA_OUT}step2_by_sex \
    --out {} \
    --method chisq \
    --minMAF 0.01' ::: "${folders[@]}"

## EUR ancestry strafied by sex using PC_EUR
folders=("NAFLD_EUR_M" "NAFLD_EUR_F")
parallel \
'Rscript ${PROJ_LOC}code/s02_check_results/step4_compute_lambda_gc_and_create_qq_plot.R \
    --indir ${DATA_OUT}step2_by_sex_eur/{}_QC_results \
    --infileRegExpr regenie.qced \
    --outdir ${DATA_OUT}step2_by_sex_eur \
    --out {} \
    --method chisq \
    --minMAF 0.01' ::: "${folders[@]}"