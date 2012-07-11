use strict;
use warnings;

use Cwd;
use Getopt::Long qw(:config no_ignore_case bundling);

my $usage = <<_EOUSAGE_;

#########################################################################################
# This program creats the lsf file and submit it to the server using the given parameters
#                       
#  --reads   Reads fasta file (Just the filename, No need of directory path)    
#  --iw      inchworm output fle (Def: inchwormK25L548.fa)
#  --out     Output directory (Def:./chrysalis);
#  --SS      if starnd-specific
#  --min     minimum sequence length(def=300)
#  --ncpu    No of cpus to use (def=10)
#  --insert  Insert-length of read-pair (def:350)
# 
# Optional 
#  --job_name       (Def:chrysalis_run)
#  --work_dir         directory where reads fasta is present (Def: ./)
#  --invoke_function  use only this to invoke the program parameters
#                    
########################################################################################

_EOUSAGE_

        ;
my $both_fa;
my $work_dir;
my $job_name;
my $invoke;
my $SS;
my $out;
my $iw;
my $min;
my $ncpu;
my $insert;

&GetOptions(          'iw=s' => \$iw,'SS' => \$SS,'out=s' => \$out,'min=i' =>\$min,'insert=i'=>\$insert,      
                      'reads=s' => \$both_fa,'ncpu=i'=>\$ncpu,
                      'work_dir=s' => \$work_dir,
                      'job_name=s' => \$job_name,
                      'invoke_function' => \$invoke,
                         );


unless ($both_fa||$invoke) {
        die $usage;
}

unless ($insert){
    $insert=350;
}

unless($min){
     $min=300;
}

unless($iw){
     $iw='inchwormK25L48.fa';
}

unless($ncpu){
    $ncpu=10;
}

unless ($work_dir) {
        $work_dir = cwd();
}
unless($out){ 
      $out=$work_dir.'/chrysalis';
}

unless ($job_name){
         $job_name='chrysalis_run';
}

my $prog='/scratch/scei/sceivam/softwares/trinityrnaseq_r2011-11-26/Chrysalis/Chrysalis';
my $butt_exec='/scratch/scei/sceivam/softwares/trinityrnaseq_r2011-11-26/Butterfly/Butterfly.jar';

if($invoke){
  system("$prog");
}

elsif(!$invoke){

   open(OUT,">$work_dir/$job_name".'.lsf');

   print "Generating lsf file \n";
           print OUT "#!/bin/bash\n";
           print OUT "#BSUB -n $ncpu\n";
           print OUT "#BSUB -R \"rusage[mem=30000]\"\n";
           print OUT "#BSUB -R \"span[hosts=1]\"\n";
           print OUT "#BSUB -W 72:00\n";
           print OUT "#BSUB -J \"$job_name\"\n";
           print OUT "#BSUB -o $job_name.job.out\n";
           print OUT "#BSUB -e $job_name.job.err\n";
           print OUT "\ndate\n";
         if($SS){
           print OUT "$prog -i $work_dir/$both_fa -iworm $work_dir/$iw -butterfly $butt_exec -o $out -strand 1 -dist $insert -min $min -cpu $ncpu -max_reads 20000000 >chrysalis.log 2>&1\n";
           }
         elsif(!$SS){
           print OUT "$prog -i $work_dir/$both_fa -iworm $work_dir/$iw -butterfly $butt_exec -o $out -strand 0  -dist $insert -min $min -cpu $ncpu -max_reads 20000000 >chrysalis.log 2>&1\n";
           }
           print OUT "echo END!\n";
         close OUT;
  print "Lsf file is created at $work_dir\nhave a check and submit it\n";
} 
  










