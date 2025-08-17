#!/bin/bash
#./step1_make_directory_and_file_integrity_checking.sh metainfo input_directory output_directory md5_ref
#
#2025-08-14
#Haojie Chen

meta_info=${1}
input_dir=${2}
output_dir=${3}
md5_ref=${4}

mkdir -m 775 -p $output_dir

#Step1 FastQC and cutting adapters
step1_dir="$output_dir/step1_fastqc_and_trim_galore/"
mkdir -m 775 -p $step1_dir
step1_fastqc_dir="$step1_dir/fastqc"
mkdir -m 775 -p $step1_fastqc_dir
step1_trim_galore_dir="$step1_dir/trim_galore"
mkdir -m 775 -p $step1_trim_galore_dir

#Step2 Reads mapping
step2_mapping_dir="$output_dir/step2_mapping"
mkdir -m 775 -p $step2_mapping_dir

#Step3 Reads counting
step3_reads_counting_dir="$output_dir/step3_reads_counting"
mkdir -m 775 -p $step3_reads_counting_dir

md5_check="$output_dir/md5check.txt"
input_files="$input_dir/*.fq.gz"
md5sum $input_files > $md5_check

file_integrity_checking_res="$output_dir/file_integrity_checking_res.txt"
python file_integrity_checking.py $meta_info $md5_ref $md5_check $file_integrity_checking_res

