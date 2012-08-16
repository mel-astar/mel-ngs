# This program reads in the sam file and prinout the below stats
# 	Total no of read entries in a given sam file
# 	Total no of reads 
#	Total no of uniquely mapped reads
#	Total no of Multi-mapped reads
#	Read distribution for each chr
#
# This program works for sam file where both the paired end reads are identified with same name in alignment file(sam).


use strict;
use warnings;

=head
HWUSI-EAS623:3:1:1171:17219#0   137     chr17   16344928        50      40M     *       0       0       NCCAGGCTGGAGTGTGGTGGCACAATCACAGCTCATTGNA        BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        AS:i:-2 XN:i:0  XM:i:2  XO:i:0  XG:i:0  NM:i:2  MD:Z:0C37C1     YT:Z:UU XS:A:+  NH:i:1
HWUSI-EAS623:3:1:1173:12474#0   153     chr19   4555148 50      40M     *       0       0       CGCAGAGGCCAGGGGCTGGGTGGGTCGAAACTCGATTTTN        BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        AS:i:-1 XN:i:0  XM:i:1  XO:i:0  XG:i:0  NM:i:1  MD:Z:39C0       YT:Z:UU NH:i:1
HWUSI-EAS623:3:1:1173:15345#0   153     chr10   1392660 3       40M     *       0       0       CCTCCCCTCCTCACACCTGGTCTGACTTACAGTTTCGTTN        BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        AS:i:-1 XN:i:0  XM:i:1  XO:i:0  XG:i:0  NM:i:1  MD:Z:39C0       YT:Z:UU NH:i:2  CC:Z:chr3       CP:i:112140347  HI:i:0
=cut

die("\n\tUsage: $0 <samfile> <readlength> <outputName>\n\n")if($#ARGV<2);

my $readlen=$ARGV[1];
my $out=$ARGV[2];
my $perfcigar=$readlen."M";

my %multi;
my %uniq;
my %unmapped;
my %perfect;
my %gapless;
my %Chr;

my $totrecords=0;
my $totreads=0;
my $totuniqreads=0;
my $totuniqreadspair=0;
my $totmultireads=0;
my $totmultireadspair=0;
my $totunmappedreads=0;

open(IN,"<$ARGV[0]")||die $!;
while(<IN>){
 chomp;
 $totrecords++;
 my ($read,$flag,$chr,$pos,$mapq,$cigar)=split(/\t/,$_);
 $_=~/NH:i:(\d+)/;
 my $nh=$1;
 $_=~/NM:i:(\d+)/;
 my $nm=$1;
 my $hi;
 if($nh>1){
  $_=~/HI:i:(\d+)/;
  $hi=$1;
 }  
 push @{$Chr{$chr}},[$read];
 push @{$unmapped{$read}},1 if($mapq==255);
 
 push @{$gapless{$read}},1 if($cigar eq $perfcigar);
 push @{$perfect{$read}},1 if(($cigar eq $perfcigar)&&($nm==0));
 if($nh==1){
  push @{$uniq{$read}},[$nh];
 }
 elsif($nh>1){
  push @{$multi{$read}},[$nh,$hi];
 }
 #print "$read\t$flag\t$chr\t$pos\t$mapq\t$cigar\t$READ\n";
}

print STDERR "Finished reading SAM file\n";

foreach my $r(keys %uniq){
   my $siz= scalar @{$uniq{$r}};
   $totuniqreads+=$siz;
   $totreads+=$siz;
   $totuniqreadspair++ if($siz==2);
}

foreach my $r(keys %multi){
   my $rec=$multi{$r}->[0][0];
   my $siz= scalar @{$multi{$r}};
   if($siz==$rec){
     $totreads++;
     $totmultireads++;
    }
   elsif($siz==($rec*2)){ 
    $totreads+=2;
    $totmultireads+=2;
    $totmultireadspair++;
   }
}

$totunmappedreads=scalar keys %unmapped;

open(SUM,">$out.summary")||die $!;
print SUM "Total No of Records in SAM : $totrecords\n";
print SUM "Total No of Mapped reads in SAM : $totreads\n";
print SUM "Total No of Uniquely mapped reads in SAM : $totuniqreads\n";
print SUM "Total No of Uniquely mapped readpairs in SAM : $totuniqreadspair\n";
print SUM "Total No of Multi-mapped reads in SAM : $totmultireads\n";
print SUM "Total No of Multi-mapped readpairs in SAM : $totmultireadspair\n";
print SUM "Total No of Unmapped reads in SAM : $totunmappedreads\n";
print SUM "Total No of gapless aligned reads in SAM : ".scalar(keys %gapless)."\n";
print SUM "Total No of Perfect aligned reads in SAM : ".scalar(keys %perfect)."\n\n";
print SUM "===========================================================================\n";
print SUM "\n\t\tREAD DISTRIBUTION ACROSS EACH CHROMOSOME\t\t\n";

foreach my $c(keys %Chr){
  print SUM "\t$c\t: ".scalar(@{$Chr{$c}})."\n";
}


