#!/bin/bash
#./step5_motif_enrichment.sh metainfo input_directory output_directory homer_ref
#
#2025-09-10
#Haojie Chen

meta_info=${1}
input_dir=${2}
output_dir=${3}
homer_ref=${4}


file_info=(`echo $meta_info |cut -d ',' -f 1,2,3 |tr ',' ' '`)
name=${file_info[0]};
step4_motif_enrichment_dir="$output_dir/step4_motif_enrichment"
echo $step4_motif_enrichment_dir
mkdir -m 775 -p "$step4_motif_enrichment_dir/$name"
peaks_bed="$input_dir/step3_peaks_calling/$name/$name""_top10k_peaks.bed"
findMotifsGenome.pl $peaks_bed $homer_ref "$step4_motif_enrichment_dir/$name"



