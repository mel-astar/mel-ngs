#! /usr/bin/perl 

#This perl script takes in all intersectBed output files in current dir and calculates Total no of readscount for each file

use strict;
use warnings;

die("Usage: Run as: perl $0 \\*.intersectBed\n")if($#ARGV<0);

my $a = $ARGV[0];
my @files = <./$a>;
#print $_."\n" foreach(@files);
#exit;
foreach my $f(@files){
 print STDERR "Working on $f\n";
 open(IN,"<$f")|| die $!;
 my $cnt=0;
 while(<IN>){
  chomp;
  my @l=split("\t",$_);
  $cnt+=$l[-1];
 }
 print "$f:\t$cnt\n";
}
