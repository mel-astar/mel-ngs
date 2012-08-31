#!/usr/bin/env perl

use strict;
use warnings;
use threads;
no strict qw(subs refs);
use Cwd;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);

my ($input,$SS_lib_type,$work_dir,$trin_dir);
my $JM;
my ($CPU,$SPAN,$MEM,$W,$JOBNAME,$STDOUT,$STDERR,$lsffile);

my $usage = <<_EOUSAGE_;

##########################################################################################
#   Required:
#
#     --input <string>  		: input file name ("Usually it is ./both.fa")
#     --trin_dir <string>		: path to where trinity is installed
#
#     --JM <int>                : Memory needed to run Jelly fish in GB (like 50G)
#
#   Optional:
#
#    --SS-lib_type <string>		: if reads are strand-specific.
#				  	  
#    --work_dir <string>        : working directory path (Def: "./")
#   
#							  
#    Bsub Options:
#
#   --CPU <int>				: number of CPUS to use (Def: 15)
#   --memory <int> 			: Memory required (Def:6000MB)
#   --single_span <flag>	: Use this if you need to submit job on one cluster (Def:No)
#   --run_time <int>		: No of hours you are intending to run this job (Def:24)
#   --job_name <string>		: job name for this job (Def: Inch)
#   --stdout <string>		: stdout output filename (Def: InchRun.out)
#   --stderr <string>		: stderr output filename (Def: InchRun.err)
#   --filename <string>		: job file name (Def: "./InchRun.lsf")
#
###########################################################################################

_EOUSAGE_

    ;

&GetOptions(
 	"input=s" =>\$input,
 	"SS_lib_type" =>\$SS_lib_type,
 	"trin_dir=s" =>\$trin_dir,
 	"CPU=i"=>\$CPU,
 	"work_dir=s"=>\$work_dir,
    "JM=s"=>\$JM,
 	"memory=i"=>\$MEM,
 	"single_span"=>\$SPAN,
 	"run_time=i"=>\$W,
 	"job_name=s"=>\$JOBNAME,
 	"stdout=s"=>\$STDOUT,
 	"stderr=s"=>\$STDERR,
 	"filename=s"=>\$lsffile,
 	);
 

unless($input && $trin_dir & $JM){
  die "Some of Mandatory parameters are not defined\n$usage\n";
}

if($JM){
    $JM =~/^([\d\.]+)G$/ or die "Error, cannot parse jelly fish memory value of $JM.  Set it to 'xG' where x is a numerical value\n";
    $JM=$1;
    $JM *= 1024*3; #Convertion from Gb to Bytes
    print STDOUT "Value of JM in Bytes: $JM\n";
}
my $inchworm_out_file= "inchworm.K25.L25";
unless($SS_lib_type){
     $inchworm_out_file .= ".DS";
}
$inchworm_out_file .= ".fa";

my $host;
$work_dir = defined($work_dir) ? $work_dir : "./";
$CPU = defined($CPU) ? $CPU: 15;
$MEM= defined($MEM) ? $MEM: 6000; 
$W = defined($W) ? $W : 24;
$JOBNAME = defined($JOBNAME) ? $JOBNAME : "Inch";
$STDOUT = defined($STDOUT) ? $STDOUT : "InchRun.out";
$STDERR = defined($STDERR) ? $STDERR : "InchRun.err";
$host = defined($SPAN) ? 1 : 0;
$lsffile= defined($lsffile) ? $lsffile : "InchRun.lsf";

my $reads_size = -s $input;
print STDOUT "Size of $input is $reads_size\n";
my $jelly_hash_size = int(($JM - $reads_size)/7);
if($jelly_hash_size <100e6){
    $jelly_hash_size=100e6;
}
my $program = "$trin_dir/trinity-plugins/jellyfish/bin/jellyfish";
my $inch_prog = "$trin_dir/Inchworm/bin/inchworm";
my $command = "$program count -t $CPU -m 25 -s $jelly_hash_size ";
my $jelly_kmer_fa_file = "jellyfish.kmers.fa";
my $jelly_kmer_check = "jellyfish.finished";
print STDOUT "Program Used : $program\n\n";

unless($SS_lib_type){
 $command .=" --both-strands";
}

$command .= " $input";  

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
 print OUT "$command\n\n";
 print OUT "foreach my \$file(\<$work_dir/mer_counts_*\>){\n\t\t$program dump -L 1 \$file >> $jelly_kmer_fa_file \;\n\t}\n";
 print OUT "touch $jelly_kmer_check\n\n";
 my $inchworm_command = "$inch_prog --kmers $jelly_kmer_fa_file --run_inchworm -K 25 -L 25 --monitor 1";
 unless ($SS_lib_type){
  $inchworm_command .= " --DS";
 }
 $inchworm_command .= " > $inchworm_out_file.tmp";
 print OUT "eval { $inchworm_command; }\n";
 print OUT "if(\$\@){ print STDERR \"$@\\n\";\n\tprint STDERR \"Inchworm failes if indicated badalloc(), then it ran out of memory\\n\"\;\n";
 print OUT "\nrename($inchworm_out_file.tmp, $inchworm_out_file)\n";
 print OUT "echo END\n";

close(OUT);        

     
