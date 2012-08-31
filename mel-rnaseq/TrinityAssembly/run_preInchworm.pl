#!/usr/bin/env perl

use strict;
use warnings;
use threads;
no strict qw(subs refs);
use Cwd;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);

my ($seqType,$left,$right,$single,$SS_lib_type,$out_dir,$trin_dir);
my ($CPU,$SPAN,$MEM,$W,$JOBNAME,$STDOUT,$STDERR,$lsffile);

my $usage = <<_EOUSAGE_;

##########################################################################################
#   Required:
#
#     --seqType <string> 		: type of reads (fq/fa);
#     --trin_dir <string>		: path to where trinity is installed
#
#     If Paired reads:
#       --left <string> 		: left reads
#       --right <string>		: right reads
#	
#     If Unpaired:
#       --single <string>		: single reads
#
#   Optional:
#
#    --SS-lib_type <string>		: Strand-specific orientation of RNA-Seq reads
#				  	  If Paired : RF or FR (Def:FR)
#				  	  If Single : F or R (Def: F) 
#    --preInch_output_dir <string>	: output directory path (Def: "./PreInch_Output")
#   
#							  
#    Bsub Options:
#
#   --CPU <int>				: number of CPUS to use (Def: 15)
#   --memory <int> 			: Memory required (Def:6000MB)
#   --sing_span <flag>		  	: Use this if you need to submit job on one cluster (Def:No)
#   --run_time <int>			: No of hours you are intending to run this job (Def:24)
#   --job_name <string>			: job name for this job (Def: PreInch)
#   --stdout <string>			: stdout output filename (Def: PreInchRun.out)
#   --stderr <string>			: stderr output filename (Def: PreInchRun.err)
#   --filename <string>			: job file name (Def: "./PreInchRun.lsf")
#
###########################################################################################

_EOUSAGE_

    ;

&GetOptions(
 	"seqType=s" => \$seqType,
 	"left=s" =>\$left,
 	"right=s" =>\$right,
 	"single=s" =>\$single,
 	"SS_lib_type=s" =>\$SS_lib_type,
 	"output_dir=s" =>\$out_dir,
 	"trin_dir=s" =>\$trin_dir,
 	"CPU=i"=>\$CPU,
 	"preInch_output_dir=s"=>\$out_dir,
 	"memory=i"=>\$MEM,
 	"sing_span"=>\$SPAN,
 	"run_time=i"=>\$W,
 	"job_name=s"=>\$JOBNAME,
 	"stdout=s"=>\$STDOUT,
 	"stderr=s"=>\$STDERR,
 	"filename=s"=>\$lsffile,
 	);
 

unless((($left && $right)||$single) && $trin_dir  && $seqType){
  die "Some of Mandatory parameters are not defined\n$usage\n";
}

if(!$SS_lib_type){
   if($left && $right){
      $SS_lib_type="FR";
    }
   elsif($single){ $SS_lib_type="F"; }
}   

if ($SS_lib_type) {
    unless ($SS_lib_type =~ /^(R|F|RF|FR)$/) {
        die "Error, unrecognized SS_lib_type value of $SS_lib_type. Should be: F, R, RF, or FR\n";
    }
}

my $host;
$out_dir = defined($out_dir) ? $out_dir : "PreInch_Output";
$CPU = defined($CPU) ? $CPU: 15;
$MEM= defined($MEM) ? $MEM: 6000; 
$W = defined($W) ? $W : 24;
$JOBNAME = defined($JOBNAME) ? $JOBNAME : "PreInch";
$STDOUT = defined($STDOUT) ? $STDOUT : "PreInchRun.out";
$STDERR = defined($STDERR) ? $STDERR : "PreInchRun.err";
$host = defined($SPAN) ? 1 : 0;
$lsffile= defined($lsffile) ? $lsffile : "PreInchRun.lsf";

my $program = "$trin_dir"."/Trinity.pl";
my $command;
print STDOUT "Program Used : $program\n\n";
if($left && $right){
 $command = $program." --left $left --right $right";
}
else{ $command+="--single $single"; }

$command .=" --SS_lib_type $SS_lib_type --output $out_dir --prep";  

print STDOUT "Full Command to be Run is :\n\n\t$command\n\n";

open(OUT,">$lsffile") || die $!;
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
 print OUT "$command\n";
 print OUT "echo END\n";
close(OUT);        
