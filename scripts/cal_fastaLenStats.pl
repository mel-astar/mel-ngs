#! /usr/bin/env perl 
use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;

my $usage = <<"HELP";

usage  : perl $0 -f/-fq -i inputfile
		(-f: fasta, -fq: fastq)
HELP

my $f=''; my $fq='';
my $input='';
GetOptions("f"=>\$f, "fq"=>\$fq, "i=s"=>\$input );

unless($f||$fq||$input) { die "$usage\n"; }
unless($f||$fq){ die "Error: Choose -f/-fq option\n $usage\n\n" ;}
unless($input){ die "Provide input file \n$usage\n"; }

my $inp;
if($f){
	$inp = Bio::SeqIO->new(-file=>"$input", -format=>'fasta');
}
elsif($fq){
	$inp = Bio::SeqIO->new(-file=>"$input", -format=>'fastq');
}


my $TLEN=0;
my @len;
while(my $rec = $inp->next_seq){
 my $l = $rec->length();
 $TLEN += $l;
 push(@len,$l);
}
my @slen = sort {$a<=>$b} @len;
print STDOUT "\n\tInput fasta file : \"$input\"\n";
print STDOUT "\tTotal fasta records : ".($#len+1)."\n";
print STDOUT "\tTotal Genome Length of all sequences: $TLEN\n";
print STDOUT "\tMin sequence length : $slen[0]\n";
print STDOUT "\tMax sequence length : $slen[-1]\n\n";
