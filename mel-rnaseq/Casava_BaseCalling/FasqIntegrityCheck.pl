use strict;
use warnings;

use Bio::Perl;
use Bio::SeqIO;

die("\n\t This prog is to Check Fastq format and count no of reads\n\t \
          Make sure bioperl is installed\n\t \
          \t Usage $0 <inp fastq file> \n\n") if($#ARGV<0);


