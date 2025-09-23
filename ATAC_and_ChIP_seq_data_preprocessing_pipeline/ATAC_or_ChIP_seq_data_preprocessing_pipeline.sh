#!/bin/bash
#./ATAC_or_ChIP_seq_data_preprocessing_pipeline.sh metadata input_dir output_dir bowtie_index library_type genome_version batch_size cpun md5sum_ref
#
#2025-09-15
#Haojie Chen

metadata=${1}
input_dir=${2}
output_dir=${3}
bowtie_index=${4}
library_type=${5}
genome_version=${6}
batch_size=${7}
cpun=${8}
md5sum_ref=${9}

MAPQ=30
typical_bin_size=1000
keep_peaks=25000
black_list='/hwdata/home/chenhaojie/ATAC_or_ChIP_seq_data_preprocessing_pipeline/black_lists/mm10_blacklist.bed'
genome_bins='/hwdata/home/chenhaojie/ATAC_or_ChIP_seq_data_preprocessing_pipeline/mm10.genome_bins.sorted.bed'
homer_ref='/hwdata/home/chenhaojie/anaconda3/envs/ATAC_and_ChIP_seq/share/homer/data/genomes/mm10'
gene_ref='/hwdata/home/chenhaojie/ATAC_or_ChIP_seq_data_preprocessing_pipeline/mm10.refGene.gtf'
distance=2000
interested_variable='tissue_type'
adjusted_p_value_cutoff='0.5'
chrom_sizes='/hwdata/home/chenhaojie/ATAC_or_ChIP_seq_data_preprocessing_pipeline/mm10.chrom.sizes'
adjusted_p_value_cutoff_hypervariable_analysis='0.1'

echo "Step1 making output directory and checking file integrity"
./step1_make_directory_and_file_integrity_checking.sh $metadata $input_dir $output_dir $md5sum_ref


echo "Step2 Reads quality control and cutting sequencing adapters"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step2_fastqc_and_trim_galore.sh $i $input_dir $output_dir $library_type $cpun &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi  
done
wait


echo "Step3 Reads mapping and deduplicating"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step3_reads_mapping_and_removing_duplicates.sh $i $input_dir $output_dir $bowtie_index $library_type $cpun $MAPQ &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi  
done
wait


echo "Step4 Peaks calling"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step4_peaks_calling.sh $i $input_dir $output_dir $genome_version $library_type &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi    
done
wait

python simplifying_MASC2_res.py --indir="$output_dir""/step3_peaks_calling/"  --outdir="$output_dir""/step3_peaks_calling/" --metadata=$metadata


echo "Step5 Motif enrichment"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step5_motif_enrichment.sh $i $output_dir $output_dir $homer_ref &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi    
done
wait

echo "Step6 Peaks annotations"

unique_peaks_bed="$output_dir""/step3_peaks_calling/*/*_unique_peaks.bed"
link_peaks_to_genes="$output_dir""/step5_peaks_annotations/link_peaks_to_genes/"
python link_peaks_to_genes.py --pathname=$unique_peaks_bed --ref=$gene_ref --outdir=$link_peaks_to_genes

peaks_annotation="$output_dir""/step5_peaks_annotations/peaks_annotation/"
python peaks_annotation.py --pathname=$unique_peaks_bed --ref=$gene_ref --name=peak_annotation --outdir=$peaks_annotation

echo "Step7 Reads counting"


unique_summits_bed="$output_dir""/step3_peaks_calling/*/*_unique_summits.bed"
reads_bed="$output_dir""/step2_mapping/*/*.bed"
temp_outdir="$output_dir""/step6_reads_counting/"

cd $temp_outdir
python parameters.py --peaks=$unique_peaks_bed --summits=$unique_summits_bed --reads=$reads_bed --black_list=$black_list --metadata=$metadata --typical_bin_size=$typical_bin_size --outdir=$temp_outdir --keep_peaks=$keep_peaks --sequencing_type=$library_type

parameters="$temp_outdir""/parameters.txt"
profile_bins --parameters=$parameters -n raw_reads_count

raw_reads_count="$temp_outdir""/raw_reads_count_profile_bins.xls"
python separate_proximal_and_distal_peak_regions.py --input=$raw_reads_count --outdir=$temp_outdir --ref=$gene_ref --distance=$distance

python parameters_bigwig.py --bins=$genome_bins --reads=$reads_bed --metadata=$metadata --outdir=$temp_outdir --peaks=$unique_peaks_bed

parameters="$temp_outdir""/parameters_bigwig.txt"
profile_bins --parameters=$parameters -n raw_reads_count_bigwig

echo "Step8 Differential analysis"

temp_outdir1="$output_dir""/step7_differential_analysis/"
inputs="$temp_outdir""/proximal_peak_regions_2000bp.txt,""$temp_outdir""/distal_peak_regions_2000bp.txt"
Rscript Hypervariable_analysis.R --input=$inputs --metadata=$metadata --categorical_variable=$interested_variable --outdir=$temp_outdir1 --adjusted_p_value_cutoff=$adjusted_p_value_cutoff_hypervariable_analysis


Rscript Pairwise_differential_analysis.R --input=$raw_reads_count --metadata=$metadata --interested_variable=$interested_variable --outdir=$temp_outdir1 --adjusted_p_value_cutoff=$adjusted_p_value_cutoff

echo "Step9 Building bigwig files"

raw_reads_count_bigwig="$temp_outdir""/raw_reads_count_bigwig_profile_bins.xls"
normalization_coefficient="$temp_outdir1""/normalization_coefficiences.txt"
python creating_bedGraph.py --counts=$raw_reads_count_bigwig --normalization_coefficient=$normalization_coefficient --outdir=$temp_outdir1

count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  file_info=(`echo $i |cut -d ',' -f 1,2,3 |tr ',' ' '`)
  name=${file_info[0]}
  bedGraph="$temp_outdir1""/""$name"".read_cnt.bedGraph"
  bw="$temp_outdir1""/""$name"".bw"
  bedGraphToBigWig $bedGraph $chrom_sizes $bw &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi    
done
wait

