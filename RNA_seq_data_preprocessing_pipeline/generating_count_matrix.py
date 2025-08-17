# generating_count_matrix.py
# 2025-08-16
# Haojie Chen
'''
python generating_count_matrix.py
--indir=path_to_read_counts_files   Directory of read counting result of featureCounts.
--outdir=ouput_directory            Output directory.          
--metadata=metadata_path            Path to metadata file.           

--help/-h                      print this page.
'''

import sys
from sys import argv, stderr, stdin, stdout
from getopt import getopt
import glob
import os
import time
import numpy as np


def detect_strand_specificity(indir):
    count_dic={}
    for path in glob.glob('%s/*/*counts.summary'%(indir)):
        name=path.split('/')[-2]
        ID='_'.join(path.split('\\')[-1].split('.counts.summary')[0].split('.')[1:])
        with open(path) as infile:
            for line in infile:
                temp=line.strip().split('\t')
                if temp[0]=='Assigned':
                    if name in count_dic:
                        count_dic[name][ID]=int(temp[1])
                    else:
                        count_dic[name]={}
                        count_dic[name][ID]=int(temp[1])
    ratios=[]
    for name in count_dic:
        ratios.append(count_dic[name]['stranded']*1.0/count_dic[name]['reversely_stranded'])

    if np.median(ratios)<1.1 and np.median(ratios)>0.9:
        return('unstranded')
    elif np.median(ratios)<=0.9:
        return('reversely.stranded')
    elif np.median(ratios)>=1.1:
        return('stranded')

def merge_results(metadata,indir,outdir,strand_specificity):
    gene_list=[]
    count_dic={}
    for path in glob.glob('%s/*/*%s.counts'%(indir,strand_specificity)):
        ID=path.split('/')[-2]
        temp_dic={}
        if gene_list:
            with open(path) as infile:
                for line in infile:
                    if '#' in line or 'Geneid' in line:
                        continue
                    else:
                        temp=line.strip().split('\t')
                        temp_dic[temp[0]]=temp[-1]
            count_dic[ID]=temp_dic
        else:
            with open(path) as infile:
                for line in infile:
                    if '#' in line or 'Geneid' in line:
                        continue
                    else:
                        temp=line.strip().split('\t')
                        temp_dic[temp[0]]=temp[-1]
                        gene_list.append(temp[0])
            count_dic[ID]=temp_dic
    IDs=[]
    skip=True
    with open(metadata) as infile:
        for line in infile:
            if skip:
                skip=False
                continue
            else:
                IDs.append(line.strip().split(',')[0])

    with open('%s/gene_expression_matrix.txt'%(outdir),'w') as outfile:
        outfile.write('\t'.join(IDs)+'\n')
        for gene in gene_list:
            temp=[gene]
            for ID in IDs:
                temp.append(count_dic[ID][gene])
            outfile.write('\t'.join(temp)+'\n')

def main():
    try:
        opts,args=getopt(argv[1:],'h',['metadata=','indir=','outdir=','help'])
        for i,j in opts:   
            if i=="-h" or i=="--help":
                stdout.write(__doc__)
                exit(0)
            elif i=='--indir':
                indir=j
            elif i=='--metadata':
                metadata=j                
            elif i=='--outdir':
                outdir=j
            else:
                raise Exception("Internal errors occur when parsing command line arguments.")
    except Exception as e:
        stderr.write("%s\n" % e)
        stderr.write("Type 'python generating_count_matrix.py --help' for more information.\n")
        exit(1)

    strand_specificity=detect_strand_specificity(indir)
    print(strand_specificity)
    merge_results(metadata,indir,outdir,strand_specificity)


if __name__ == '__main__':
    main()
