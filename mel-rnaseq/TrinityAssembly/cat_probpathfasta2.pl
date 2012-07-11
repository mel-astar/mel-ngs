#!/usr/bin/perl

use strict;
use warnings;

if($#ARGV<1){die "Usage: $0 <chrysalis_directory> <outputfile> \n"};

my $dir = $ARGV[0];
my @chry_dir_files;
#print "ls $dir/*|grep ^RawComps";
#my @raw_dir_cnt = `ls $dir/|grep ^RawComps|wc -l`;
opendir(DIR,$dir)||die("cannot openn the chrysalis directory $dir\n");
@chry_dir_files=readdir(DIR);
closedir(DIR);

my @rawcomps_dir;
foreach my $v(@chry_dir_files){
  if($v=~/^RawComps/)
   {
      push(@rawcomps_dir,$v);
   }
}

foreach my $r(@rawcomps_dir){
        
	chomp($r);
        my @allProbs_files;
        my @rawcomps_dir_files;
	$r=~s/://g;
        my $path=$dir.'/'.$r;
      #Reading all the files in RawComps directory
	opendir(RAW,$path)||die("Couldn't open the RawComps folder $path\n");
        @rawcomps_dir_files=readdir(RAW);
        closedir(RAW);
       #Gathering all  *allprobPaths.fasta files into one array
        foreach my $x(@rawcomps_dir_files)
        {
          if($x=~ m/allProbPaths.fasta/){
            push(@allProbs_files,$x);
           }
        }
       #Concatenating all the *allProbPaths.fasta file in to one output
        foreach my $v(@allProbs_files){
          my $file=$dir.'/'.$r.'/'.$v;
          my $str ="cat $file >>".$ARGV[1];        
	  print STDOUT $str."\n";
	  system($str);
        }

}
