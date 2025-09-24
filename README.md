# Bioinformatic analysis pipelines

## 1. RNA_seq_data_preprocessing_pipeline

Initilizing the runing enviroment according to this requirments file[https://github.com/haojiechen94/Bioinformatic_analysis_pipelines/blob/main/RNA_seq_data_preprocessing_pipeline/RNA_seq.yml]
```
conda env create -f RNA_seq.yml
```


Running commands:
```

./RNA_seq_data_preprocessing_pipeline.sh metadata input_dir output_dir star_index_dir gene_ref rseqc_ref batch_size cpun md5sum_ref

metadata: metadata file descripts the details of study design and sample information.

input_dir/output_dir: Directory for input data and output data.

star_index_dir: STAR index for reads alignment.

gene_ref: Gene annotation file (GTF format).

rseqc_ref: Gene body file (BED format).

batch_size: Maximun number of running tasks in each step.

cpun: Number of threads.

md5sum_ref: md5sum code for each input file.
```


## 1. ATAC_seq_data_preprocessing_pipeline

Initilizing the runing enviroment according to this requirments file[https://github.com/haojiechen94/Bioinformatic_analysis_pipelines/blob/main/ATAC_and_ChIP_seq_data_preprocessing_pipeline/ATAC_and_ChIP_seq.yml]
```
conda env create -f ATAC_and_ChIP_seq.yml
```

Using bedtools to create genome_bins bed file:
```
bedtools makewindows -g chrom.sizes -w 50 > genome_bins.bed 

bedtools sort -i genome_bins.bed > genome_bins.sorted.bed
```

Configuring default parameters:
```
MAPQ: Mapping quality score to filtering mapped reads, default: 30.

typical_bin_size: Typical bin size used for peak binning, default: 1000.

keep_peaks: The number of top-ranked peaks to keep, defualt: 25000.

black_list: e.g., mm10_blacklist.bed, blacklist bed file records those abnormal genomic regions.

genome_bins: e.g., mm10.genome_bins.sorted.bed, using for building bedGraph file.

homer_ref: e.g., /share/homer/data/genomes/mm10, using for TF motif enrichment analysis.

gene_ref: e.g., mm10.refGene.gtf using for peak annotation.

distance: Peaks to TSS distance to define proximal peaks (promoters), default: 2000.

interested_variable: One column in metadata file, e.g., tissue_type, using for differential/hypervairiable analysis.

adjusted_p_value_cutoff: Using this cutoff to define significant differential enriched peaks, defualt: 0.5.

chrom_sizes: chromosome sizes, e.g., mm10.chrom.sizes.

adjusted_p_value_cutoff_hypervariable_analysis: Using this cutoff to define significant hypervariable peaks, default: 0.1.
```

Running commands:
```

metadata=${1}
input_dir=${2}
output_dir=${3}
bowtie_index=${4}
library_type=${5}
genome_version=${6}
batch_size=${7}
cpun=${8}
md5sum_ref=${9}

```




