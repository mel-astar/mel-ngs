#!/usr/bin/env perl

use strict;
use warnings;
use threads;
no strict qw(subs refs);
use Cwd;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);

my ($input,$SS_lib_type,$work_dir,$trin_dir,$paired);
my $iworm;
my ($CPU,$SPAN,$MEM,$W,$JOBNAME,$STDOUT,$STDERR,$lsffile);

my $usage = <<_EOUSAGE_;

##########################################################################################
#   Required:
#
#     --input <string>  	: input file name ("Usually it is ./both.fa")
#     --iworm <string>  	: inchworm output file (inchworm.K25.L26.fa)
#     --trin_dir <string>	: path to where trinity is installed
#
#   Optional:
#
#    --SS-lib_type <flag>	: if reads are strand-specific.
#    --paired <flag>	        : if reads are paired.
#    --work_dir <string>  	: working directory path (Def: "./")
#   
#	 Outputs will be stored in folder called "chrysalis_output" under work dir.
#					  
#    Bsub Options:
#
#   --CPU <int> 	        : number of CPUS to use (Def: 15)
#   --memory <int>      	: Memory required (Def:6000MB)
#   --single_span <flag>	: Use this if you need to submit job on one cluster (Def:No)
#   --run_time <int>		: No of hours you are intending to run this job (Def:24)
#   --job_name <string>		: job name for this job (Def: Chry)
#   --stdout <string>		: stdout output filename (Def: ChryRun.out)
#   --stderr <string>		: stderr output filename (Def: ChryRun.err)
#   --filename <string>		: job file name (Def: "./ChryRun.lsf")
#
###########################################################################################

_EOUSAGE_

    ;

&GetOptions(
 	"input=s" =>\$input,"iworm=s"=>\$iworm,
 	"SS_lib_type" =>\$SS_lib_type,"paired"=>\$paired,
 	"trin_dir=s" =>\$trin_dir,
 	"CPU=i"=>\$CPU,
 	"work_dir=s"=>\$work_dir,
 	"memory=i"=>\$MEM,
 	"single_span"=>\$SPAN,
 	"run_time=i"=>\$W,
 	"job_name=s"=>\$JOBNAME,
 	"stdout=s"=>\$STDOUT,
 	"stderr=s"=>\$STDERR,
 	"filename=s"=>\$lsffile,
 	);
 

unless($input && $trin_dir & $iworm){
  die "Some of Mandatory parameters are not defined\n$usage\n";
}


my $host;
$work_dir = defined($work_dir) ? $work_dir : "./";
$CPU = defined($CPU) ? $CPU: 15;
$MEM= defined($MEM) ? $MEM: 6000; 
$W = defined($W) ? $W : 24;
$JOBNAME = defined($JOBNAME) ? $JOBNAME : "Chry";
$STDOUT = defined($STDOUT) ? $STDOUT : "ChryRun.out";
$STDERR = defined($STDERR) ? $STDERR : "ChryRun.err";
$host = defined($SPAN) ? 1 : 0;
$lsffile= defined($lsffile) ? $lsffile : "ChryRun.lsf";

my $program = "$trin_dir/Chrysalis/Chrysalis";
my $butt_path = "$trin_dir/Butterfly/Butterfly.jar";

my $command = "$program -i $input -iworm $iworm -o $work_dir/chrysalis_output -cpu $CPU -min 200 -dist 500 -max_reads 20000000 -max_mem_reads 1000000 -butterfly $butt_path ";

$command .= " --strand 1" if(defined $SS_lib_type);
$command .= " --paired" if(defined $paired);

$command .= " 2>&1\\n\;\n";

print STDOUT "Full Command to be Run is :\n\n\t$command\n\n";

open(OUT,">$work_dir/$lsffile") || die $!;
 print "Generating lsf file \n";
 print OUT "#!/bin/bash\n";
 print OUT "#BSUB -n $CPU\n";
 print OUT "#BSUB -R \"rusage[mem=$MEM]\"\n";
 print OUT "#BSUB -R \"span[hosts=1]\"\n" if($host>0);
 print OUT "#BSUB -W $W:00\n";
 print OUT "#BSUB -J \"$JOBNAME\"\n";
 print OUT "#BSUB -o $STDOUT\n";
 print OUT "#BSUB -e $STDERR\n";
 print OUT "\ndate\n";   
 print OUT "$command\n\n";
 print OUT "echo END\n";

close(OUT);        

print STDOUT "job submission lsf file is generated at $work_dir.\nPlease have a look and submit to cluster\n";     
