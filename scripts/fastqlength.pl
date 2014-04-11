#! /usr/bin/perl 
use strict;
use warnings;
use Bio::SeqIO;

die("\t perl $0 <fastq file>") if($#ARGV<0);

my $in = Bio::SeqIO->new(-file=>"$ARGV[0]", -format=>'fastq');
while(my $rec = $in->next_seq){
	my $len  = $rec->length;
	my $name = $rec->id;
	print "$name\tlen\n";
}
