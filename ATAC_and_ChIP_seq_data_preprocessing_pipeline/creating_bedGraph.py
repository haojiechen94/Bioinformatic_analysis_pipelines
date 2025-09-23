# creating_bedGraph.py
# 2025-09-12
# Haojie Chen

"""
creating_bedGraph.py --counts=pathname --normalization_coefficient=pathname [--outdir=current_directory]

--counts=<str>                        Read count matrix from outputs of MAnorm2-utils profile_bins.

--normalization_coefficient=<str>     Normalization coefficients 

[--outdir=<str>]                      Output directory for the parameters file.
                                      Default: current directory

--help/-h                             print this page.                       

"""

from sys import argv, stderr, stdin, stdout
from getopt import getopt
import os
import glob
import pandas as pd
import numpy as np

def covert_counts_to_bedGraph(counts,normalization_coefficient,outdir):

    counts_df=pd.read_csv(counts,sep='\t')
    normalization_coefficient_df=pd.read_csv(normalization_coefficient,sep='\t')
    columns=[i for i in counts_df.columns if '.read_cnt' in i]
    for i in columns:
        counts_df[i]=2**(np.log2(counts_df[i]/(50/1000)+1)*normalization_coefficient_df.loc[i,'slope']+normalization_coefficient_df.loc[i,'intercept'])

    for i in columns:
        counts_df.loc[:,['chrom','start','end',i]].to_csv('%s/%s.bedGraph'%(outdir,i),sep='\t',header=False,index=False)






def main():

    out_dir=False
    counts=''
    normalization_coefficient=''

    try:
        opts,args=getopt(argv[1:],'h',['counts=','normalization_coefficient=','outdir=','help'])
        for i,j in opts:   
            if i=="-h" or i=="--help":
                stdout.write(__doc__)
                exit(0)
            elif i=='--counts':
                counts=j                
            elif i=='--normalization_coefficient':
                normalization_coefficient=j
            elif i=='--outdir':
                out_dir=j                                    
            else:
                raise Exception("Internal errors occur when parsing command line arguments.")
    except Exception as e:
        stderr.write("%s\n" % e)
        stderr.write("Type 'python creating_bedGraph.py --help' for more information.\n")
        exit(1)

    if not out_dir:
        out_dir=os.getcwd()

    covert_counts_to_bedGraph(counts,normalization_coefficient,out_dir)

if __name__ == '__main__':
    main()


