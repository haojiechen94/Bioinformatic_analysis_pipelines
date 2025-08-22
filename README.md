# Bioinformatic analysis pipelines

## 1. RNA_seq_data_preprocessing_pipeline

Initilizing the runing enviroment according to this requirments file[https://github.com/haojiechen94/Bioinformatic_analysis_pipelines/blob/main/RNA_seq_data_preprocessing_pipeline/requirements.txt]

Running commands:

./RNA_seq_data_preprocessing_pipeline.sh metadata input_dir output_dir star_index_dir gene_ref rseqc_ref batch_size cpun md5sum_ref

metadata: metadata file descripts the details of study design and sample information.

input_dir/output_dir: Directory for input data and output data.

star_index_dir: STAR index for reads alignment.

gene_ref: Gene annotation file (GTF format).

rseqc_ref: Gene body file (BED format).

batch_size: Maximun number of running tasks in each step.

cpun: Number of threads.

md5sum_ref: md5sum code for each input file.


