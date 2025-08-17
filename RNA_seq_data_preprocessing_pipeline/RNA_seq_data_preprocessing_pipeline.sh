#!/bin/bash
#./RNA_seq_data_preprocessing_pipeline.sh metadata input_dir output_dir star_index_dir gene_ref rseqc_ref batch_size cpun md5sum_ref
#
#2025-08-15
#Haojie Chen

metadata=${1}
input_dir=${2}
output_dir=${3}
star_index_dir=${4}
gene_ref=${5}
rseqc_ref=${6}
batch_size=${7}
cpun=${8}
md5sum_ref=${9}

echo "Step1 making output directory and checking file integrity"
./step1_make_directory_and_file_integrity_checking.sh $metadata $input_dir $output_dir $md5sum_ref


echo "Step2 Reads quality control and cutting sequencing adapters"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step2_fastqc_and_cutting_adapter.sh $i $input_dir $output_dir $cpun &
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
  ./step3_reads_mapping_and_deduplicating.sh $i $input_dir $output_dir $star_index_dir $cpun &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi  
done
wait

echo "Step4 Reads counting"
count=0
for i in `tail -n +2 $metadata`;
do 
  echo $i;
  ./step4_reads_counting.sh $i $input_dir $output_dir $output_dir $cpun &
  ((count++))
  if ((count == batch_size)); then
    wait
    count=0
  fi    
done
wait

strand_specificity="$output_dir""/strand_specificity.txt"
python ./generating_count_matrix.py --indir="$output_dir""/step3_reads_counting" --metadata=$metadata --outdir="$output_dir""/step3_reads_counting" > $strand_specificity
python ./generating_TPM_matrix.py --indir="$output_dir""/step3_reads_counting"
python ./generating_statistics_report.py --indir=$output_dir --outdir=$output_dir --metadata=$metadata

a=''
for i in `ls $output_dir/step2_mapping/*/*deduped.bam`; do a=`echo $a,$i`;done
geneBody_coverage="$output_dir""/geneBody_coverage"
geneBody_coverage.py -i $a -f png -o $geneBody_coverage -r $rseqc_ref


