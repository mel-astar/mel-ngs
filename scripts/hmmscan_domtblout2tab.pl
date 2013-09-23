###########################################################################################
#
#  This program is to transform hmmscan domtblout output
#  to tabular format 
#
#  perl hmmscan_domtblout2tab.pl <hmmscan.domtblout output> <tab-sep output filename>
#
############################################################################################

use strict;
use warnings;

die("\n\tUsage:\tperl $0 <hmmscan domtblout file> <tab sep output file>\n\n") if($#ARGV<1||$#ARGV>1);

my $header = "tname\ttaccession\ttlen\tqname\tqaccession\tqlen\teValtscore\tbias\t#domNo\t#TotDomains\tc-eVal\ti-eVal\tscore\tbias\thmm.from\thmm.to\tali.from\tali.to\tenv.from\tenv.to\tpost.prob\tdesc";

open(OUT,">$ARGV[1]")||die $!;
print OUT "$header\n";
open(IN,"$ARGV[0]")||die $!;
while(<IN>){
 chomp;
 next if($_=~/^#/);
 my @line = split(/\s/,$_);
 print OUT join("\t",@line)."\n";
}
