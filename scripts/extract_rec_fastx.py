#! /usr/bin/env python
#_*_ coding: utf-8 _*_

import os
import sys
import argparse as Arg
from Bio import SeqIO
from Bio.Seq import Seq

if __name__ == "__main__" :
   parser = Arg.ArgumentParser(description="Extracts specified no of records from provided fast(A/Q) file.")
   parser.add_argument("-file",dest="inp",help="Input fast(A/Q) file.",metavar="FILE")
   parser.add_argument("-fq",dest="fq",help="Set this if input is fastq.",action="store_true",default=False)
   parser.add_argument("-no",dest="number",help="No of fastq records to be extracted (def:50)",metavar="N",default=50,type=int)
   parser.add_argument("-out",dest="out",help="Output fast(A/Q) file name",metavar="FILE")
   if len(sys.argv)==1:
	parser.print_help()
	sys.exit(0)
   args = parser.parse_args()
   if args.inp is None:
	print "please provide the input file (-file)"
        parser.print_help()
	sys.exit(0)

   out_handle = open(args.out,"w")
   no=1
   if args.fq :
	filefor = "fastq"
   else:
 	filefor = "fasta"

   for rec in SeqIO.parse(args.inp,filefor):
       if no<=args.number :
           print no
           SeqIO.write(rec,out_handle,filefor)
           no += 1
       else:
	   break
   out_handle.close()
      	
