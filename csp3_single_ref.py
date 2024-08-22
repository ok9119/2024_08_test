#!/usr/bin/python

'''
This script checks which alleles listed in the preproccessed GRAF output file are reference. 
In order to proceed, specift the arguments:
-r / --reference - Reference genome (single file)
-i / --input - a preprocessed input file (#CHROM, POS, ID, allele1, allele2),
-o / --output - an output file
'''

import numpy as np
import pandas as pd

import pysam

import time
from datetime import datetime

#import glob
from pathlib import Path

import argparse

#Параметр required=True не задан, чтобы была возможность запросить справку, но после этого шага наличие файлов и папок проверяется
parser = argparse.ArgumentParser(description='This script checks which alleles listed in the preprocessed GRAF output file are reference. \
                                              In order to proceed, specify the arguments:')
parser.add_argument('-r', '--reference', help='Reference genome (single file)')
parser.add_argument('-i', '--input', help='Input file')
parser.add_argument('-o', '--output', help='Output folder')
args = parser.parse_args()


if Path(args.input).is_file():
    processed_input = pd.read_csv(args.input, sep = '\t').drop(columns='Unnamed: 0')
else:
    raise Exception ('Input file does not exist')


if Path(args.output).is_dir():
    pass
else:
    raise Exception ('Specified output directory does not exist')


if Path(args.reference).is_file():
    pass
else:
    raise Exception ('Reference genome not found')


def check_reference(df):
    start_time = time.time()
    print('Starting input format check at', datetime.fromtimestamp(start_time))
# Проверка соответствия названий колонок во входящем файле нужному формату
    table_columns = df.columns
    column_names = ['#CHROM', 'POS', 'ID', 'allele1', 'allele2']
    diff = {}
    for i, j, k in zip(range(0,5), table_columns, column_names):
        if j == k:
            pass
        else:
            diff[i]={j,k}
    if diff:
        raise Exception ('Input error: check column names', diff)
    else:
        print('Input format check elapsed in %.4f s. Proceeding to reference allele check' % (time.time() - start_time))

# Проверяем, какой вариант для заданной позиции референсный
    start_time2 = time.time()
    print('Starting reference allele check at', datetime.fromtimestamp(start_time2))
    genome = pysam.FastaFile(args.reference)
    df['REF'] = [genome.fetch(chrom, start, end)
                        for chrom, start, end in
                               zip(df['#CHROM'],
                                   df['POS']-1,
                                   df['POS'])]
# Поскольку часть нуклеотидов референса относится к маскированным участкам и записана в нижнем регистре,
# переводим значения в df_slice['REF'] в верхний для корректного сравнения со значениями в ['allele1'] и ['allele2']
    df['REF'] = df['REF'].str.upper()
    df['ALT'] = df['allele1'].where(df['allele1'] != df['REF'], df['allele2'])
    df.drop(columns = ['allele1', 'allele2'], inplace = True)
    print('Reference allele check elapsed in %.4f s' % (time.time() - start_time2))
    return df

output = check_reference(processed_input)

out_path = Path(args.output, 'FP_SNPs_10k_GB38_REF_ALT_res.tsv')

output.to_csv(out_path, sep = '\t')