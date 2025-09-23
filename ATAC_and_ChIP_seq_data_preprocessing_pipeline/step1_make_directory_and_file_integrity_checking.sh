#!/bin/bash
#./step1_make_directory_and_file_integrity_checking.sh metainfo input_directory output_directory md5_ref 
#
#2025-08-21
#Haojie Chen

meta_info=${1}
input_dir=${2}
output_dir=${3}
md5_ref=${4}

mkdir -m 775 -p $output_dir

# Step1 FastQC and cutting adapters
step1_dir="$output_dir/step1_fastqc_and_trim_galore/"
mkdir -m 775 -p $step1_dir
step1_fastqc_dir="$step1_dir/fastqc"
mkdir -m 775 -p $step1_fastqc_dir
step1_trim_galore_dir="$step1_dir/trim_galore"
mkdir -m 775 -p $step1_trim_galore_dir

# Step2 Reads mapping and removing duplicates
step2_mapping_dir="$output_dir/step2_mapping"
mkdir -m 775 -p $step2_mapping_dir

# Step3 Peaks calling
step3_peaks_calling_dir="$output_dir/step3_peaks_calling"
mkdir -m 775 -p $step3_peaks_calling_dir

# Step4 Motif enrichment
step4_motif_enrichment_dir="$output_dir/step4_motif_enrichment"
mkdir -m 775 -p $step4_motif_enrichment_dir

# Step5 Peaks annotation
step5_peaks_annotation_dir="$output_dir/step5_peaks_annotations"
mkdir -m 775 -p $step5_peaks_annotation_dir
step5_link_peaks_to_genes_dir="$step5_peaks_annotation_dir/link_peaks_to_genes"
mkdir -m 775 -p $step5_link_peaks_to_genes_dir
step5_peaks_annotation_dir1="$step5_peaks_annotation_dir/peaks_annotation"
mkdir -m 775 -p $step5_peaks_annotation_dir1

#Step6 Reads counting
step6_reads_counting_dir="$output_dir/step6_reads_counting"
mkdir -m 775 -p $step6_reads_counting_dir

# Step7 Differential analysis
step7_differential_analysis_dir="$output_dir/step7_differential_analysis"
mkdir -m 775 -p $step7_differential_analysis_dir

# Step8 Functional enrichment
step8_functional_enrichment_dir="$output_dir/step8_functional_enrichment"
mkdir -m 775 -p $step8_functional_enrichment_dir

md5_check="$output_dir/md5check.txt"
input_files="$input_dir/*.fq.gz"
md5sum $input_files > $md5_check

file_integrity_checking_res="$output_dir/file_integrity_checking_res.txt"
python file_integrity_checking.py $meta_info $md5_ref $md5_check $file_integrity_checking_res

