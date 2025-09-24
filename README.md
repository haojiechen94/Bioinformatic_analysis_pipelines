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
MAPQ: Mapping quality score threshold for filtering mapped reads. Default: 30

typical_bin_size: Typical bin size used for peak binning. Default: 1000

keep_peaks: Number of top-ranked peaks to retain. Default: 25,000

black_list: Blacklist BED file recording abnormal genomic regions (e.g., mm10_blacklist.bed).

genome_bins: BED file used for building bedGraph files (e.g., mm10.genome_bins.sorted.bed).

homer_ref: Reference path for HOMER genome data, used in TF motif enrichment analysis (e.g., /share/homer/data/genomes/mm10).

gene_ref: Gene annotation file in GTF format for peak annotation (e.g., mm10.refGene.gtf).

distance: Distance from peak to TSS for defining proximal peaks (promoters). Default: 2000

interested_variable: A column in the metadata file (e.g., tissue_type), used for differential or hypervariable analysis.

adjusted_p_value_cutoff: Threshold for defining significantly differentially enriched peaks. Default: 0.5

chrom_sizes: Chromosome sizes file (e.g., mm10.chrom.sizes).

adjusted_p_value_cutoff_hypervariable_analysis: Threshold for defining significantly hypervariable peaks. Default: 0.1
```

Running commands:
```

metadata: metadata file descripts the details of study design and sample information.

input_dir/output_dir: Directory for input data and output data.

bowtie_index: bowtie2 index for reads alignment.

library_type: ATAC or CHIPSE or CHIPPE

genome_version: mm9/mm10/mm39/hg19/hg38

batch_size: Maximun number of running tasks in each step.

cpun: Number of threads.

md5sum_ref: md5sum code for each input file.

```






