#!/bin/bash
#./step2_fastqc_and_cutting_adapter.sh metainfo input_directory output_directory cpu_number
#
#2025-08-14
#Haojie Chen

meta_info=${1}
input_dir=${2}
output_dir=${3}
cpun=${4}

file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
name=${file_info[0]};
read1_fq_gz="$input_dir/${file_info[1]}"
read2_fq_gz="$input_dir/${file_info[2]}"

temp_dir="$output_dir/step1_fastqc_and_trim_galore/fastqc/$name/"
mkdir -m 775 -p $temp_dir
read1_output_dir="$temp_dir/R1"
mkdir -m 775 -p $read1_output_dir
read2_output_dir="$temp_dir/R2"
mkdir -m 775 -p $read2_output_dir 

fastqc $read1_fq_gz --outdir $read1_output_dir -t $cpun;
fastqc $read2_fq_gz --outdir $read2_output_dir -t $cpun;

temp_dir="$output_dir/step1_fastqc_and_trim_galore/trim_galore/$name/"
mkdir -m 775 -p $temp_dir
trim_galore --dont_gzip --paired -o $temp_dir --fastqc $read1_fq_gz $read2_fq_gz


