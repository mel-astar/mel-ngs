use strict;
use warnings;
use POSIX;

die ("\n\tperl $0 <input file> <TotalNoOfLines (use wc -l file) > <Total no of files to split> <output base name>\n\n") if($#ARGV<0);

my $inp = $ARGV[0];
my $LINES = $ARGV[1];
my $noFiles = $ARGV[2];
my $outbase  = $ARGV[3];

my $const = floor($LINES/$noFiles);

my @file;
open(IN,"<$inp") or die $!;
while(<IN>){
	chomp;
	push @file,$_;	
}
close(IN);

my @int;
my $res =0;
for(my $i=0;$i<$noFiles-1;$i++){
	$res += $const;
	push @int,$res;
}
push @int,$LINES-1;
my $start=0;
for(my $i=0;$i<$noFiles;$i++){
	my $end = $int[$i];
	my $outfile = $outbase."_split".($i+1).".txt";
	open(OUT,">$outfile") || die $!;
	print OUT join("\n",@file[$start..$end])."\n";
	$start = $end +1;
}
