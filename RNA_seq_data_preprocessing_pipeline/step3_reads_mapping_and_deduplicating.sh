#!/bin/bash
#step2_reads_mapping.sh metainfo input_directory output_directory reference_directory cpu_number
#
#2025-08-14
#Haojie Chen

meta_info=${1}
input_dir=${2}
output_dir=${3}
star_index=${4}
cpun=${5}



file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
name=${file_info[0]};
read1_name=(`echo ${file_info[1]}| tr '.' ' '`)
read2_name=(`echo ${file_info[2]}| tr '.' ' '`)
read1_fq_gz="$output_dir/step1_fastqc_and_trim_galore/trim_galore/$name/${read1_name[0]}_val_1.fq"
read2_fq_gz="$output_dir/step1_fastqc_and_trim_galore/trim_galore/$name/${read2_name[0]}_val_2.fq"

temp_dir="$output_dir/step2_mapping/$name"
mkdir -m 775 -p $temp_dir

output_sam="$temp_dir/$name"
star_mapping_log="$temp_dir/$name"".star.mapping.log"

STAR --runMode alignReads --runThreadN ${cpun} --outSAMtype BAM SortedByCoordinate --outSAMmultNmax 1 --genomeDir $star_index --readFilesIn $read1_fq_gz $read2_fq_gz  --outFileNamePrefix $output_sam > $star_mapping_log 2>&1;
input_bam="$temp_dir/$name""Aligned.sortedByCoord.out.bam"

unique_bam="$temp_dir/$name""unique.bam"
samtools view -h -q 255 $input_bam | samtools view -b -o $unique_bam
 
sorted_bam="$temp_dir/$name""sorted.bam"
samtools sort -@ 8 -o $sorted_bam $unique_bam

marked_dups_bam="$temp_dir/$name""marked_dups.bam"
dup_metrics="$temp_dir/$name""dup_metrics.txt"
picard MarkDuplicates I=$sorted_bam O=$marked_dups_bam M=$dup_metrics REMOVE_DUPLICATES=false

deduped_bam="$temp_dir/$name""deduped.bam"
samtools view -b -F 1024 $marked_dups_bam > $deduped_bam
samtools index $deduped_bam