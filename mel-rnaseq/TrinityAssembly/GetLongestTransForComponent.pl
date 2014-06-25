#! /usr/bin/env perl 
use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use List::MoreUtils ':all';
use List::Util qw{first max maxstr min minstr };

use constant USAGE=><<END;

This program is used to get the longest transcript for each Trinity component

USAGE: perl $0 <Trinity.fasta> <output.fasta>

END

die USAGE."\n ERROR: No / More Parameters passes\n" if($#ARGV<0||$#ARGV>1);

die USAGE."\n ERROR: Some Parameters are missing \n" if($#ARGV==0);

my %COMP;
my %LEN;

my ($trinity_file, $output_file) = @ARGV;

my $inp = Bio::SeqIO->new(-file=>$trinity_file, -format=>'fasta');

=fastaId sample
>comp10001_c0_seq1 len=1297 ~FPKM=4.2 path=[0, 1680]
>comp10001_c0_seq2 len=1632 ~FPKM=6 path=[0, 1231]
=cut
my $total=0;
while(my $comp = $inp->next_seq){
	$total++;
	my $name = $comp->id;
	$name =~ m/^(\S+\_\S+)\_\S+$/;
	my $component = $1;
	my $len = $comp->length;
	push @{$COMP{$component}}, $name;
	push @{$LEN{$name}}, $len;
}

my %LONG;

print STDERR "Reading Input is finished: Total Fasta records: $total  Total Components:".scalar(keys %COMP)."\n";

foreach my $c(sort keys %COMP){
	my @trans = @{$COMP{$c}};
	my @lengths = map { $LEN{$_}->[0] } @trans;
	die "Trans and Lengths are different for $c\n" unless(scalar(@trans)==scalar(@lengths));
	my $max_length = max @lengths;
	my $max_index = firstidx {$_ == $max_length} @lengths;
	my $max_seqid = $trans[$max_index];
	$LONG{$max_seqid}++;
}

$inp = Bio::SeqIO->new(-file=>"$trinity_file", -format=>'fasta');
my $out = Bio::SeqIO->new(-file=>">$output_file", -format=>'fasta');
while(my $rec = $inp->next_seq){
	my $id = $rec->id;
	$out->write_seq($rec) if($LONG{$id});
}
print STDERR "Program $0 finished  See Output :$output_file\n\n";
