# simplifying_MASC2_res.py
# 2025-08-31
# Haojie Chen
'''
python simplifying_MASC2_res.py --indir=input_directory --outdir=ouput_directory --metadata=metadata_path
--indir=input_directory             Directory of peaks calling result of MACS2.
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
import re

def get_peaks_bed(path):
    peaks_dic={}
    with open(path) as infile:
        for line in infile:
            temp=line.strip().split('\t')
            peaks_dic[temp[3]]=[temp[0],temp[1],temp[2],temp[4],temp[5]]
    return peaks_dic


def get_summits_bed(path):
    summits_dic={}
    group_dic={}
    with open(path) as infile:
        for line in infile:
            temp=line.strip().split('\t')
            summits_dic[temp[3]]=[temp[0],temp[1],temp[2],temp[4]]
            summit_ID=temp[3].split('_')
            if re.search(r'\d+',summit_ID[-1])==None:
                if temp[3] in group_dic:
                    group_dic[temp[3]].append([temp[3],float(temp[4])])
                else:
                    group_dic[temp[3]]=[[temp[3],float(temp[4])]]
            else:
                summit_ID='_'.join(summit_ID[:-1])+'_'+re.search(r'\d+',summit_ID[-1]).group()
                if summit_ID in group_dic:
                    group_dic[summit_ID].append([temp[3],float(temp[4])])
                else:
                    group_dic[summit_ID]=[[temp[3],float(temp[4])]]

    return summits_dic,group_dic


def get_sample_IDs(path):
    IDs=[]
    skip=True
    with open(path) as infile:
        for line in infile:
            if skip:
                skip=False
                continue
            else:
                IDs.append(line.strip().split(',')[0])
    return IDs



def coverting_result(IDs,indir,outdir):
    for ID in IDs:
        peaks_dic=get_peaks_bed('%s/%s/%s_peaks.narrowPeak'%(indir,ID,ID))
        summits_dic,group_dic=get_summits_bed('%s/%s/%s_summits.bed'%(indir,ID,ID))
        with open('%s/%s/%s_unique_peaks.bed'%(outdir,ID,ID),'w') as outfile1:
            with open('%s/%s/%s_unique_summits.bed'%(outdir,ID,ID),'w') as outfile2:  
                for summit_ID in group_dic:
                    temp=sorted(group_dic[summit_ID],key=lambda x:x[1],reverse=True)
                    peak=peaks_dic[temp[0][0]]
                    summit=summits_dic[temp[0][0]]
                    outfile1.write('\t'.join([peak[0],peak[1],peak[2],temp[0][0],peak[3],peak[4]])+'\n')
                    outfile2.write('\t'.join([summit[0],summit[1],summit[2],temp[0][0],summit[3]])+'\n')
        peaks=[]
        with open('%s/%s/%s_unique_peaks.bed'%(outdir,ID,ID)) as infile:
            for line in infile:
                temp=line.strip().split('\t')
                peaks.append([temp[0],temp[1],temp[2],temp[3],int(temp[4]),temp[5]])

        with open('%s/%s/%s_top10k_peaks.bed'%(outdir,ID,ID),'w') as outfile:
            for i in sorted(peaks,key=lambda x:x[4],reverse=True)[:10000]:
                outfile.write('\t'.join([i[0],i[1],i[2],i[3],str(i[4]),i[5]])+'\n')

                

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
        stderr.write("Type 'python simplifying_MASC2_res.py --help' for more information.\n")
        exit(1)

    IDs=get_sample_IDs(metadata)
    coverting_result(IDs,indir,outdir)


if __name__ == '__main__':
    main()
