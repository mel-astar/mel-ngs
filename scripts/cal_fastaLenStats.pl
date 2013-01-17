#! /usr/bin/env perl 
use strict;
use warnings;
use Bio::SeqIO;
die("\n\tUsage perl $0 input.fasta\n\n") if($#ARGV<0);
my $inp = Bio::SeqIO->new(-file=>"$ARGV[0]", -format=>'fasta');
my $TLEN=0;
my @len;
while(my $rec = $inp->next_seq){
 my $l = $rec->length();
 $TLEN += $l;
 push(@len,$l);
}
my @slen = sort {$a<=>$b} @len;
print STDOUT "\n\tInput fasta file : \"$ARGV[0]\"\n";
print STDOUT "\tTotal fasta records : ".($#len+1)."\n";
print STDOUT "\tTotal Genome Length of all sequences: $TLEN\n";
print STDOUT "\tMin sequence length : $slen[0]\n";
print STDOUT "\tMax sequence length : $slen[-1]\n\n";
