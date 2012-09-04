use strict;
use warnings;

use Getopt::Long;
use Cwd;

my $usage = <<_EOUSAGE_;

##########################################################################################
#
# --wrkdir        		: directory where the quantifygraphs commands 
#				   are generated(Def: "./") (usually chrysalis folder)
#
# --filebasename   	   	: basename of split files to be created (basename_1,basename_2....)
#				  (QG for QuantifyGraph and BF for Butterfly).
#
# --printonly			: Only print commmands that to be submitted; (Optional)
#
##########################################################################################

_EOUSAGE_
    ;

my $wrkdir;my $print;
my $basename; my $trin_dir;

&GetOptions( 'printonly'=>\$print,'wrkdir=s'=>\$wrkdir,'filebasename=s'=>\$basename,);

unless($basename){  die "\nSome mandatory arguments are not defined\n\n$usage\n"; }

unless($wrkdir){ $wrkdir=cwd();}

my @files = <$wrkdir/$basename*lsfjob.lsf>;

print "Total No of batch job files are :".scalar(@files)."\n";

if(defined $print){
 print "Only Printing commands\n";
 foreach my $f(@files){
    print "bsub < $f\n";
 }
}
else{
  print "Printing and Submitting Jobs\n";
  foreach my $f(@files){
   print "bsub < $f\n";
   system("bsub <$f");
  }
}
