#! /usr/bin/env python
#_*_ coding: utf-8 _*_

import os
import sys
import argparse as Arg
from Bio import SeqIO
from Bio.Seq import Seq

if __name__ == "__main__" :
   parser = Arg.ArgumentParser(description="Extracts user defined no of fastq records from given fastq file")
   parser.add_argument("-s",dest="inp",help="Input fastq file",metavar="FILE")
   parser.add_argument("-no",dest="number",help="No of fastq records to be extracted (def:50)",metavar="N",default=50,type=int)
   parser.add_argument("-out",dest="out",help="Output fastq file name",metavar="FILE")
   if len(sys.argv)==1:
	parser.print_help()
	sys.exit(0)
   args = parser.parse_args()
   out_handle = open(args.out,"w")
   no=1
   for rec in SeqIO.parse(args.inp,"fastq"):
       if no<=args.number :
           print no
           SeqIO.write(rec,out_handle,"fastq")
           no += 1
       else:
	   break
   out_handle.close()
      	
