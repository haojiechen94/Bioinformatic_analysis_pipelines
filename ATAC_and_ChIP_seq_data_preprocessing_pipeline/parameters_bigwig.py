# parameters_bigwig.py
# 2025-09-12
# Haojie Chen

"""
parameters_bigwig.py --peaks=pathname --summits=pathname --reads==pathname --black_list=path --metadata=path 
                     [--typical_bin_size=2000] [--outdir=current_directory]  [--keep_peaks=All]

--bins=<str>                      Peaks in BED format recording the genome windows.

--reads=<str>                     Mapped reads in BED format. Find all pathname matching this pattern. 
                                  Using relative pathname (e.g. /usr/src/*_drm.bed) to find any matching files in a 
                                  specified directory.

--metadata=<str>                  Metadata for the input samples, including sample names, input files and 
                                  clinical information.

[--outdir=<str>]                  Output directory for the parameters file.
                                  Default: current directory

[--sequencing_type=<str>]         ChIP or ATAC
                                  Default: ATAC

--help/-h                         print this page.                       

"""

from sys import argv, stderr, stdin, stdout
from getopt import getopt
import os
import glob
import pandas as pd

def get_peaks_file(pathname):
    peaks_dic={}
    for path in glob.glob(pathname):
        ID=path.split('/')[-1].split('_unique_peaks.bed')[0]
        peaks_dic[ID]=path
    return peaks_dic

def get_reads_file(pathname,sequencing_type):
    reads_dic={}
    if sequencing_type=='ATAC':
        for path in glob.glob(pathname):
            ID=path.split('/')[-1].split('.bed')[0]
            reads_dic[ID]=path
    elif sequencing_type=='ChIP':
         for path in glob.glob(pathname):
            ID=path.split('/')[-1].split('_treatment.bed')[0]
            reads_dic[ID]=path
    else:
        print(sequencing_type,'Unknown sequencing type')
        exit(1)

    return reads_dic

def create_parameters_file(metadata,peaks,bins,reads,out_dir,sequencing_type):
    shiftsize=0 if sequencing_type=='ATAC' else 100
    reads_dic=get_reads_file(reads,sequencing_type)
    peaks_dic=get_peaks_file(peaks)
    metadata_df=pd.read_csv(metadata,sep=',')
    parameters='labs='+','.join(metadata_df['sample_name'].tolist())+'\n'
    parameters=parameters+'peaks='+','.join([peaks_dic[i] for i in metadata_df['sample_name'].tolist()])+'\n'
    parameters=parameters+'bins=%s\n'%(bins)
    parameters=parameters+'reads='+','.join([reads_dic[i] for i in metadata_df['sample_name'].tolist()])+'\n'
    parameters=parameters+'keep-dup=all\n'
    parameters=parameters+'shiftsize=%s\n'%(shiftsize)

    with open(out_dir+'/parameters_bigwig.txt','w') as outfile:
        outfile.write(parameters)

def main():

    out_dir=False
    bins=''
    reads=''
    metadata=''
    peaks=''
    sequencing_type='ATAC'

    try:
        opts,args=getopt(argv[1:],'h',['peaks=','bins=','reads=','metadata=','outdir=','sequencing_type=','help'])
        for i,j in opts:   
            if i=="-h" or i=="--help":
                stdout.write(__doc__)
                exit(0)
            elif i=='--peaks':
                peaks=j                
            elif i=='--bins':
                bins=j
            elif i=='--reads':
                reads=j
            elif i=='--metadata':
                metadata=j
            elif i=='--outdir':
                out_dir=j
            elif i=='--sequencing_type':
                sequencing_type=j                                    
            else:
                raise Exception("Internal errors occur when parsing command line arguments.")
    except Exception as e:
        stderr.write("%s\n" % e)
        stderr.write("Type 'python parameters_bigwig.py --help' for more information.\n")
        exit(1)

    if not out_dir:
        out_dir=os.getcwd()

    create_parameters_file(metadata,peaks,bins,reads,out_dir,sequencing_type)

if __name__ == '__main__':
    main()

