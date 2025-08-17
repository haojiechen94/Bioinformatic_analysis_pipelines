# generating_count_matrix.py
# 2025-08-16
# Haojie Chen
'''
python generating_TPM_matrix.py
--indir=path_to_read_counts_files   Directory of read counting result of featureCounts.                   

--help/-h                      print this page.
'''

import sys
from sys import argv, stderr, stdin, stdout
from getopt import getopt
import glob
import os
import time
import numpy as np
import pandas as pd


def get_strand_specificity(indir):
    specificity=''
    with open('%s/strand_specificity.txt'%indir) as infile:
        for line in infile:
            specificity=line.strip()
    return specificity

def get_gene_length(indir,specificity):
    gene_length_dic={}
    with open(glob.glob('%s/*/*.%s.counts'%(indir,specificity))[0]) as infile:
        for line in infile:
            if '#' in line or 'Geneid' in line:
                continue
            else:
                temp=line.strip().split('\t')
                gene_length_dic[temp[0]]=float(temp[-2])/1000
    return gene_length_dic

def count_to_TPM(indir,gene_length_dic):
    count_matrix=pd.read_csv('%s/gene_expression_matrix.txt'%indir,sep='\t')
    length_kb=[gene_length_dic[i] for i in count_matrix.index]
    rpk=count_matrix.div(length_kb, axis=0)
    scale_factor=rpk.sum(axis=0)/1000000
    tpm=rpk.div(scale_factor,axis=1)
    return tpm

def main():
    try:
        opts,args=getopt(argv[1:],'h',['indir=','outdir=','help'])
        for i,j in opts:   
            if i=="-h" or i=="--help":
                stdout.write(__doc__)
                exit(0)
            elif i=='--indir':
                indir=j
            else:
                raise Exception("Internal errors occur when parsing command line arguments.")
    except Exception as e:
        stderr.write("%s\n" % e)
        stderr.write("Type 'generating_TPM_matrix.py --help' for more information.\n")
        exit(1)

    strand_specificity=get_strand_specificity('/'.join(indir.split('/')[:-1]))
    gene_length_dic=get_gene_length(indir,strand_specificity)
    tpm=count_to_TPM(indir,gene_length_dic)
    tpm.to_csv('%s/gene_expression_matrix_TPM.txt'%indir,sep='\t')

if __name__ == '__main__':
    main()