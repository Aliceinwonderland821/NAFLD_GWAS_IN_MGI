#!/bin/bash
# This script correct bgen sample file for regenie
# what it really change is make ID_1 = ID_2
# runs as `./step3_correct_bgen_sample_file.sh`

parallel 'Rscript correct_bgen_sample_file.R ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample ${MGI_REGENIE_STEP2}Freeze6_TOPMed.UNFILTERED.xwalk.broad_sharable.chr{}.no_phase_new.sample.identical.id1.id2' ::: $(seq 1 22)