#!/usr/bin/perl 

use strict;
use warnings;

use Getopt::Long qw(:config no_ignore_case bundling);
use Cwd;
my $usage = <<_EOUSAGE_;

#############################################################################################################################
# This program creats job script (.lsf) for pre processing steps before inchworm using the given parameters
#                       
#  --left_fq           left fragment fq file
#  --right_fq          right fragment fq file
#  --trin_dir	       Directory path of trinity installed (/PATH/to/TRINITY/).
#
# Optional (if strand-specific RNA-Seq):
#  --job_name         specify the job name (DEF :pre_inch)                      
#  --SS               RF or FR (Def: FR)
#                     (Reads from reverse strand will be reverse complimented based on this strand-specific protocol)
#  --work_dir         Directory where fastq reads are present
#  --invoke_function  Use this to check the trinity program used, also pas trin_dir along with this.
#                     (Use only invoke_function with trin_dir, no other arguments are used)
# 
##############################################################################################################################

_EOUSAGE_

        ;

my $left_fq;
my $right_fq;
my $SS;
my $work_dir;
my $job_name;
my $invoke_function;
my $trin_dir;

&GetOptions(          'left_fq=s' => \$left_fq,
                      'right_fq=s' => \$right_fq,
                      'SS=s' => \$SS,
                      'work_dir=s' => \$work_dir,
                      'job_name=s' => \$job_name,
                      'invoke_function' => \$invoke_function,'trin_dir=s'=>\$trin_dir,
            );


unless (($left_fq && $right_fq && $trin_dir)||($invoke_function && $trin_dir)) {
        die $usage;
}


unless ($work_dir) {
        $work_dir = cwd();
}

unless ($SS){
         $SS='FR'; 
}

unless ($job_name){
         $job_name='pre_inch';
}

my $fastq2fa=$trin_dir.'/util/fastQ_to_fastA.pl';

if($invoke_function){
  if($trin_dir){
    print "\n$fastq2fa\n";
    system("$fastq2fa");
    exit;
  }
  else{ die "Please Also provide the paramter trin_dir along with this\n"; }
}
elsif(!$invoke_function){

#$job_name=$job_name.'lsf';
open(OUT,">$work_dir/$job_name".'.lsf');

print "Generating lsf file \n";
           print OUT "#!/bin/bash\n";
           print OUT "#BSUB -n 15\n";
           print OUT "#BSUB -R \"rusage[mem=60000]\"\n";
           print OUT "#BSUB -R \"span[hosts=1]\"\n";
           print OUT "#BSUB -W 72:00\n";
           print OUT "#BSUB -J \"$job_name\"\n";
           print OUT "#BSUB -o $job_name.out\n";
           print OUT "#BSUB -e $job_name.err\n";
           print OUT "\ndate\n";
         if($SS eq 'FR'){
           print OUT "$fastq2fa -I $left_fq >$work_dir/left.fa \n";
           print OUT "$fastq2fa -I $right_fq --rev >$work_dir/right.fa \n";}
         else{
           print OUT "$fastq2fa -I $left_fq --rev >$work_dir/left.fa \n";
           print OUT "$fastq2fa -I $right_fq >$work_dir/right.fa \n";
           }
           print OUT "cat $work_dir/left.fa $work_dir/right.fa >$work_dir/both.fa \n";
           print OUT "touch pre_inchworm_v11.fininshed\n";
           print OUT "echo END!\n";
         close OUT;
print "$job_name.lsf file is created at $work_dir\nHave a check for your job requirements before submitting it using command bsub<$job_name.lsf\n";
}












