#!/bin/bash
#./step4_reads_counting.sh metainfo input_directory output_directory reference_path cpu_number
#
#2025-08-14
#Haojie Chen/Zhijie Guo

meta_info=${1}
input_dir=${2}
output_dir=${3}
ref=${4}
cpun=${5}


file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
name=${file_info[0]};

temp_dir="$output_dir/step3_reads_counting/$name"
mkdir -m 775 -p $temp_dir

deduped_bam="$output_dir/step2_mapping/$name/$name""deduped.bam"

featureCounts -a $ref $deduped_bam -o "$temp_dir/$name"".unstranded.counts" -F GTF -t exon -g gene_name -p -T $cpun -s 0
featureCounts -a $ref $deduped_bam -o "$temp_dir/$name"".stranded.counts" -F GTF -t exon -g gene_name -p -T $cpun -s 1
featureCounts -a $ref $deduped_bam -o "$temp_dir/$name"".reversely.stranded.counts" -F GTF -t exon -g gene_name -p -T $cpun -s 2


