use strict;
use warnings;

use Getopt::Long;
use Cwd;

my $usage = <<_EOUSAGE_;
##########################################################################################
#
# --wrkdir        		: directory where the quantifygraphs commands 
#				   are generated(Def: "./") (usually chrysalis folder)
# --c              		: Name of quantify coomands file
# --cutoff          		: No of commands you want to dispatch to one lsf file (Def: 200)
# --filebasename   	   	: basename of split files to be created (basename_1,basename_2....)
#				  (QG for QuantifyGraph and BF for Butterfly).
# --trin_dir			: path where trinity is installed
#
#    Bsub Options:
#
#   --CPU <int> 	        : number of CPUS to use (Def: 15)
#   --memory <int>      	: Memory required (Def:6000MB)
#   --single_span <flag>	: Use this if you need to submit job on one cluster (Def:No)
#   --run_time <int>		: No of hours you are intending to run this job (Def:24)
#
##########################################################################################

_EOUSAGE_
    ;
my $wrkdir;
my $c;
my $cutoff;
my $basename; my $trin_dir;
my ($CPU,$SPAN,$MEM,$W,$JOBNAME,$STDOUT,$STDERR,$lsffile);

&GetOptions( 'wrkdir=s'=>\$wrkdir,'c=s'=>\$c,'cutoff=i'=>\$cutoff,
			'filebasename=s'=>\$basename,
			"CPU=i"=>\$CPU,"trin_dir=s"=>\$trin_dir,
			"memory=i"=>\$MEM,
 			"single_span"=>\$SPAN,
 			"run_time=i"=>\$W,
     
);

unless($c && $basename && $trin_dir){  die "Some mandatory arguments are not defined\n\n$usage\n"; }

unless($wrkdir){ $wrkdir=cwd();}
unless($cutoff){ $cutoff=200; }
$CPU = defined($CPU) ? $CPU : 15;
$MEM = defined($MEM) ? $MEM : 6000;
$W = defined($W) ? $W : 24;

my @commands;
my $program="$trin_dir/Inchworm/bin/ParaFly";

open(IN,"$c") ||die $!;
while(<IN>)
{
 chomp;
 push(@commands,$_);
}

my $tot=scalar(@commands);
my $batches= $tot/$cutoff;

print "The total no of commands :$tot\n";
print "The No of rounded off batches:$batches\n";
my $b=int $batches;
my $start=0;
for(my $i=1; $i<=$b;$i++)
 {
     open(OUT, ">$wrkdir/$basename"."_$i")||die $!;
     open(JOB, ">$wrkdir/$basename"."_$i"."_lsfjob.lsf")||die $!;
     print OUT join("\n",@commands[$start..$start+($cutoff-1)]),"\n";
     close OUT;
     print STDOUT "Done $wrkdir/$basename"."_$i\n";
     print JOB "#!/bin/bash\n";
     print JOB "#BSUB -n $CPU\n";
     print JOB "#BSUB -R \"rusage[mem=$MEM]\"\n";
     print JOB "#BSUB -R \"span[hosts=1]\"\n" if(defined $SPAN);
     print JOB "#BSUB -W $W:00\n";
     print JOB "#BSUB -J \"Run$basename"."_$i\"\n";
     print JOB "#BSUB -o $wrkdir/../Run$basename"."_$i.jobrun.out\n";
     print JOB "#BSUB -e $wrkdir/../Run$basename"."_$i.jobrun.err\n";
     print JOB "date\n";
     print JOB "$program -c $wrkdir/$basename"."_$i -CPU $CPU -shuffle -failed_cmds $basename"."_$i.FailedCmds -v \n";
     print JOB "echo ENDS!!!!\n";
     $start=$start+$cutoff;   
 } 
     
if(($tot%$batches)!=0)
 { 
     open(OUT, ">$wrkdir/$basename"."_last");
     open(JOB, ">$wrkdir/$basename"."_last_lsfjob.lsf")||die $!;
     print OUT join("\n",@commands[$start..($tot-1)]),"\n";
     close OUT;
     print STDOUT  "Done $wrkdir/$basename"."_last\n";
     print JOB "#!/bin/bash\n";
     print JOB "#BSUB -n $CPU\n";
     print JOB "#BSUB -R \"rusage[mem=$MEM]\"\n";
     print JOB "#BSUB -R \"span[hosts=1]\"\n" if(defined $SPAN);
     print JOB "#BSUB -W $W:00\n";
     print JOB "#BSUB -J \"Run$basename"."_last\"\n";
     print JOB "#BSUB -o $wrkdir/../Run$basename"."_last.jobrun.out\n";
     print JOB "#BSUB -e $wrkdir/../Run$basename"."_last.jobrun.err\n";
     print JOB "date\n";
 	 print JOB "$program -c $wrkdir/$basename"."_last -CPU $CPU -shuffle -failed_cmds $basename"."_last.FailedCmds -v \n";
     print JOB "echo ENDS!!!!\n";
     print STDOUT "Splitting Commands file is successfully completed\n";
 }
 elsif(($tot%$batches)==0){
   print STDOUT "Splitting Commands file is successfully completed\n";
 }
