# generating_count_matrix.py
# 2023-11-20
# Haojie Chen
'''
python generating_statistics_report.py
--indir=path_to_analysis_results    Directory of output from this pipeline.
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

def get_mapping_res(indir):
    mapping_res={}
    for path in glob.glob('%s/step2_mapping/*/*Log.final.out'%indir):
        sample_id=path.split('/')[-2]
        mapping_res[sample_id]={}
        with open(path) as infile:
            for line in infile:
                if 'Number of input reads' in line:
                    mapping_res[sample_id]['Number_of_input_reads']=int(line.strip().split('\t')[-1])
                elif 'Uniquely mapped reads number' in line:
                    mapping_res[sample_id]['Uniquely_mapped_reads_number']=int(line.strip().split('\t')[-1])

    for path in glob.glob('%s/step2_mapping/*/*dup_metrics.txt'%indir):
        sample_id=path.split('/')[-2]
        with open(path) as infile:
            for line in infile:
                if 'Unknown Library' in line:
                    mapping_res[sample_id]['Duplicated_reads_number']=int(line.strip().split('\t')[-4])
    return mapping_res

def get_strand_specificity(indir):
    specificity=''
    with open('%s/strand_specificity.txt'%indir) as infile:
        for line in infile:
            specificity=line.strip()
    return specificity

def get_counting_res(indir,strand_specificity):
    counting_res={}
    for path in glob.glob('%s/step3_reads_counting/*/*.%s.counts.summary'%(indir,strand_specificity)):
        sample_id=path.split('/')[-2]
        counting_res[sample_id]={}
        with open(path) as infile:
            for line in infile:
                if 'Assigned' in line:
                    counting_res[sample_id]['Assigned_reads_number']=int(line.strip().split('\t')[-1])
    return counting_res

def get_sample_ids(metadata):
    IDs=[]
    skip=True
    with open(metadata) as infile:
        for line in infile:
            if skip:
                skip=False
                continue
            else:
                IDs.append(line.strip().split(',')[0])  
    return IDs

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
        stderr.write("Type 'python generating_statistics_report.py --help' for more information.\n")
        exit(1)

    strand_specificity=get_strand_specificity(indir)
    mapping_res=get_mapping_res(indir)
    counting_res=get_counting_res(indir,strand_specificity)
    IDs=get_sample_ids(metadata)
    with open('%s/statistics.txt'%outdir,'w') as outfile:
        outfile.write('\t'.join(['Sample_id','Sequencing_depth','Uniquely_mapped_reads_number(%)','Duplicated_reads_number(%)','Assigned_reads_number(%)'])+'\n')
        for ID in IDs:
            outfile.write('\t'.join([ID,
                                     str(mapping_res[ID]['Number_of_input_reads']),
                                     '%d(%.1f%%)'%(mapping_res[ID]['Uniquely_mapped_reads_number'],
                                                    (mapping_res[ID]['Uniquely_mapped_reads_number']/mapping_res[ID]['Number_of_input_reads'])*100),
                                     '%d(%.1f%%)'%(mapping_res[ID]['Uniquely_mapped_reads_number']-mapping_res[ID]['Duplicated_reads_number'],
                                                    ((mapping_res[ID]['Uniquely_mapped_reads_number']-mapping_res[ID]['Duplicated_reads_number'])/mapping_res[ID]['Number_of_input_reads'])*100),
                                     '%d(%.1f%%)'%(counting_res[ID]['Assigned_reads_number'],
                                                    (counting_res[ID]['Assigned_reads_number']/mapping_res[ID]['Number_of_input_reads'])*100)])+'\n')



    get_sample_ids(metadata)




if __name__ == '__main__':
    main()



