#!/bin/bash
#./step3_reads_mapping_and_removing_duplicates.sh metainfo input_directory output_directory reference_directory ATAC|ChIPPE|ChIPSE cpu_number
#
#2025-08-25
#Haojie Chen
meta_info=${1}
input_dir=${2}
output_dir=${3}
ref_dir=${4}
seq_type=${5}
cpun=${6}
MAPQ=${7}

trim_dir="$output_dir/step1_fastqc_and_trim_galore/trim_galore"
bowtie_index=$ref_dir

if [ "$seq_type" = "ATAC" ]
    then
        file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
        name=${file_info[0]}
        treatment_read1_name=(`echo ${file_info[1]}| tr '.' ' '`)
        treatment_read2_name=(`echo ${file_info[2]}| tr '.' ' '`)
        treatment_read1_fq_gz="$trim_dir/$name/${treatment_read1_name[0]}_val_1.fq.gz"
        treatment_read2_fq_gz="$trim_dir/$name/${treatment_read2_name[0]}_val_2.fq.gz"
        
        temp_dir="$output_dir/step2_mapping/$name"
        mkdir -m 775 -p $temp_dir

        mapstats="$temp_dir/$name.mapstats"
        aligned_sorted_bam="$temp_dir/$name""_aligned.sorted.bam"
        bowtie2 --very-sensitive --no-mixed --no-discordant --maxins 2000 -p $cpun -x $bowtie_index -1 $treatment_read1_fq_gz -2 $treatment_read2_fq_gz | samtools view -@ $cpun -bS -q ${MAPQ} - | samtools sort -@ $cpun -o $aligned_sorted_bam - > $mapstats 2>&1

        aligned_sorted_deduped_bam="$temp_dir/$name""_aligned.sorted.deduped.bam"
        dupstats="$temp_dir/$name.dupstats"
        picard MarkDuplicates I=$aligned_sorted_bam O=$aligned_sorted_deduped_bam M=$dupstats REMOVE_DUPLICATES=true ASSUME_SORTED=true
        
        
        bed="$temp_dir/$name"".bed"
        bedtools bamtobed -i $aligned_sorted_deduped_bam | sed 's/\/[12]//g' > $bed

elif [ "$seq_type" = "ChIPPE" ]
    then
        file_info=(`echo $meta_info |cut -d ',' -f 1,2,3,4,5 |tr ',' ' '`)
        name=${file_info[0]}
        treatment_read1_name=(`echo ${file_info[1]}| tr '.' ' '`)
        treatment_read2_name=(`echo ${file_info[2]}| tr '.' ' '`)
        control_read1_name=(`echo ${file_info[3]}| tr '.' ' '`)
        control_read2_name=(`echo ${file_info[4]}| tr '.' ' '`)
        treatment_read1_fq_gz="$trim_dir/$name/treatment/${treatment_read1_name[0]}_val_1.fq.gz"
        treatment_read2_fq_gz="$trim_dir/$name/treatment/${treatment_read2_name[0]}_val_2.fq.gz"
        control_read1_fq_gz="$trim_dir/$name/control/${control_read1_name[0]}_val_1.fq"
        control_read2_fq_gz="$trim_dir/$name/control/${control_read2_name[0]}_val_2.fq"
        
        temp_dir="$output_dir/step2_mapping/$name"
        mkdir -m 775 -p $temp_dir
        
        treatment_dir="$temp_dir/treatment"
        mkdir -m 775 -p $treatment_dir
        mapstats="$treatment_dir/$name""_treatment.mapstats"

        drm_bed="$treatment_dir/$name""_treatment_ss100_drm.bed"

        # treat control
        control_dir="$temp_dir/control"
        mkdir -m 775 -p $control_dir
        mapstats="$control_dir/$name""_control.mapstats"


        drm_bed="$control_dir/$name""_control_ss100_drm.bed"

elif [ "$seq_type" = "ChIPSE" ];
    then
        file_info=(`echo $meta_info |cut -d ',' -f 1,2,4|tr ',' ' '`)
        name=${file_info[0]};
        treatment_name=(`echo ${file_info[1]}| tr '.' ' '`)
        control_name=(`echo ${file_info[2]}| tr '.' ' '`)
        treatment_read_fq_gz="$trim_dir/$name/treatment/${treatment_name[0]}_trimmed.fq.gz"
        control_read_fq_gz="$trim_dir/$name/control/${control_name[0]}_trimmed.fq.gz"
        
        
        temp_dir="$output_dir/step2_mapping/$name"
        mkdir -m 775 -p $temp_dir
        treatment_dir="$temp_dir/treatment"
        mkdir -m 775 -p $treatment_dir
        mapstats="$treatment_dir/$name""_treatment.mapstats"

        drm_bed="$treatment_dir/$name""_treatment_ss100_drm.bed"

        # treat control
        control_dir="$temp_dir/control"
        mkdir -m 775 -p $control_dir
        mapstats="$control_dir/$name""_control.mapstats"

        drm_bed="$control_dir/$name""_control_ss100_drm.bed"

else
    echo "Unknown sequencing type"
    exit 1
fi
