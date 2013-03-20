#! /usr/bin/perl -w
use strict;
use warnings;
die "\nThis prog is for comparing two files line by line\n\tProvide two files for comparison\n\tperl $0 file1 file2\n\n" if($#ARGV<1);
my %ab; my %a; my %b;
open(IN1,$ARGV[0]);
while(<IN1>){
 chomp;
 $ab{$_}++;
 $a{$_}++;
}
open(IN2,$ARGV[1]);
my $ua=0; my $ub=0; my $ab=0;
while(<IN2>){
 chomp;
 $ab{$_}++;
 $b{$_}++;
}
foreach(keys %ab){
 if(($a{$_}) && ($b{$_})){
   print "NA\tNA\t$_\n";
   $ab++;
 }
 elsif(($a{$_}) && (!$b{$_})){
   print "$_\tNA\tNA\n";
   $ua++;
 }
 elsif((!$a{$_}) && ($b{$_})){
   print "NA\t$_\tNA\n";  
   $ub++;
 }
 else { die "Some Error\n"; }
}
print STDERR "Total No of Records in $ARGV[0]: ".scalar(keys %a)."\n";
print STDERR "Total No of Records in $ARGV[1]: ".scalar(keys %b)."\n";
print STDERR "Total No of common records in both :$ab\n";
print STDERR "Total No of Unique records in $ARGV[0]: $ua\n";
print STDERR "Total No of Unique records in $ARGV[1]: $ub\n";
