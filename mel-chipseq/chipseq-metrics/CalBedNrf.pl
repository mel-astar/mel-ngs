# This perl scripts takes in all bamtobed.bed files in current dir and calculates NRF 
# If you want to run for specific files denote those file as regex in first argument

#! /usr/bin/perl -w

use strict;
use warnings;

die("\t Usage $0 <\\*bamtobed.bed>\n") if($#ARGV<0);

my $a = $ARGV[0];
my @files = <./$a>;
foreach my $f(@files){
 print STDERR "Working on file $f\n";
 open(IN,"<$f")||die $!;
 my $Tcnt=0;
 my $prev="NA";
 my $lcnt=0;
 while(<IN>){
  chomp;
  my @line=split("\t",$_);
  $lcnt++;
  my $t = join("_",@line[0..2]);
  $Tcnt++ unless($t eq $prev);
  $prev=$t;
 }
 print "$f\t$Tcnt\t$lcnt\t".($Tcnt/$lcnt)."\n";
 close(IN);
}
