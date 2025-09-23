#file_integrity_checking.py
#2025-08-14
#Haojie Chen
'''
python file_integrity_checking.py metadata md5_reference_file md5_check_file md5_out_file
'''

import sys

print(sys.argv)
samples=[]
skip=True
with open(sys.argv[1],'r') as infile:
    for line in infile:
        if skip:
            skip=False
        else:
            temp=line.strip().split(',')
            samples.append(temp[1])
            samples.append(temp[2])

md5_reference={}
with open(sys.argv[2], 'r') as infile:
    for line in infile:
        temp=line.strip().split('  ')
        md5_reference[temp[1]]=temp[0]

md5_check={}
with open(sys.argv[3], 'r') as infile:
    for line in infile:
        temp=line.strip().split('  ')
        md5_check[temp[1].split('/')[-1]]=temp[0]

total=0
oks=0
nos=0
notexist=0
with open(sys.argv[4], 'w') as outfile:
    for i in samples:
        total+=1
        if i in md5_check and md5_check[i]==md5_reference[i]:
            oks+=1
            outfile.write('\t'.join([md5_reference[i],md5_check[i],i,'OK']) + '\n')
        elif i in md5_check and md5_check[i]!=md5_reference[i]:
            nos+=1
            outfile.write('\t'.join([md5_reference[i],md5_check[i],i,'NO']) + '\n')
        elif i not in md5_check:
            notexist+=1
            outfile.write('\t'.join([md5_reference[i],'NA',i,'Not exist']) + '\n')
    outfile.write('Total:%i; OK:%i; NO:%i; Not exist: %i'%(total,oks,nos,notexist))
