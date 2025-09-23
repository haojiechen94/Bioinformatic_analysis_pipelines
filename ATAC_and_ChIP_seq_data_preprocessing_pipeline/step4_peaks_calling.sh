#!/bin/bash
#./step3_peaks_calling.sh metainfo input_directory output_directory ref_index ATAC|ChIPPE|ChIPSE
#
#2025-08-30
#Haojie Chen



meta_info=${1}
input_dir=${2}
output_dir=${3}
ref_idx=${4}
seq_type=${5}

file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
name=${file_info[0]}

if [ "$ref_idx" = "hg19" ] || [ "$ref_idx" = "hg38" ];
    then
        genome="hs"
elif [ "$ref_idx" = "mm9" ] || [ "$ref_idx" = "mm10" ] || [ "$ref_idx" = "mm38" ];
    then
        genome="mm"
else
    echo "Unknown genome"
    exit 1
fi

if [ "$seq_type" = "ATAC" ];
    then
        temp_dir="$output_dir/step3_peaks_calling/$name";
        mkdir -m 775 -p $temp_dir;
        bed="$output_dir/step2_mapping/$name/$name"".bed"
        macs2_output="$temp_dir/$name.macs2_output"

        cd $temp_dir && macs2 callpeak --gsize $genome --nomodel --shift -75 --extsize 150 --nolambda --keep-dup all -p 0.01 --call-summits -f BED -t $bed -n $name> $macs2_output 2>&1
elif [ "$seq_type" = "ChIPPE" ];
    then
        temp_dir="$output_dir/step3_peaks_calling/$name";
        mkdir -m 775 -p $temp_dir;
        treatment_bed="$output_dir/step2_mapping/$name/treatment/$name""_treatment.bed"
        control_bed="$output_dir/step2_mapping/$name/control/$name""_control.bed"
        macs2_output="$temp_dir/$name.macs2_output"
        cd $temp_dir && macs -t $treatment_bed -c $control_bed -n $name -f BED -g $genome --nomodel --shiftsize=100 --keep-dup=all > $macs2_output 2>&1
elif [ "$seq_type" = "ChIPSE" ];
    then
        temp_dir="$output_dir/step3_peaks_calling/$name";
        mkdir -m 775 -p $temp_dir;
        treatment_bed="$output_dir/step2_mapping/$name/treatment/$name""_treatment.bed"
        control_bed="$output_dir/step2_mapping/$name/control/$name""_control.bed"
        macs2_output="$temp_dir/$name.macs2_output"
        cd $temp_dir && macs -t $treatment_bed -c $control_bed -n $name -f BED -g $genome --nomodel --shiftsize=100 --keep-dup=all > $macs2_output 2>&1
else        
    echo "Unknown sequencing type"
    exit 1
fi


