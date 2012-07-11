use strict;
use warnings;

use Cwd;
use Getopt::Long qw(:config no_ignore_case bundling);

my $usage = <<_EOUSAGE_;

#########################################################################################
# This program creats the lsf file and submit it to the server using the given parameters
#                       
#  --reads     Concatenated Reads fasta file (Just the filename, No need of directory path).    
#  --trin_dir  dir path where trinity installed.
# Optional 
#  --job_name           (Def:inchworm_run)
#  --NOMERYL   Flag not to use merly (Def:Yes)
#  --work_dir           directory where reads fasta is present (Def: ./)
#  --min_kmer_coverage  (Def: 1)
#  --invoke_function    use only this without any other to  invoke the program parameters
########################################################################################

_EOUSAGE_

        ;
my $both_fa;
my $work_dir;
my $job_name;
my $invoke;
my $NOMERYL;
my $min_kmer_coverage;
my $trin_dir;

&GetOptions(          'NOMERYL' => \$NOMERYL,'min_kmer_coverage=i'=>\$min_kmer_coverage,
                      'reads=s' => \$both_fa,
                      'work_dir=s' => \$work_dir,
                      'job_name=s' => \$job_name,
                      'invoke_function' => \$invoke,'trin_dir=s'=>\$trin_dir,
                         );


unless (($both_fa && $trin_dir)||($invoke && $trin_dir)) {
        die $usage;
}

unless ($work_dir) {
        $work_dir = cwd();
}

unless ($job_name){
         $job_name='inchworm_run';
}

unless($min_kmer_coverage)
{
   $min_kmer_coverage=1;
}

my $inch=$trin_dir.'/Inchworm/bin/inchworm';

if($invoke && $trin_dir){
    print "\n$inch\n";
    system("$inch");
    exit;
}
elsif(!$invoke){
   if($NOMERYL){
   open(OUT,">$work_dir/$job_name".'.lsf');

   print "Generating lsf file \n";
           print OUT "#!/bin/bash\n";
           print OUT "#BSUB -n 20\n";
           print OUT "#BSUB -R \"rusage[mem=9000]\"\n";
           print OUT "#BSUB -R \"span[hosts=1]\"\n";
           print OUT "#BSUB -W 72:00\n";
           print OUT "#BSUB -J \"$job_name\"\n";
           print OUT "#BSUB -o $job_name.run.out\n";
           print OUT "#BSUB -e $job_name.run.err\n";
           print OUT "\ndate\n";
           print OUT "$inch --reads $work_dir/$both_fa --coverage_outfile $work_dir/kmer2iwContig.coverage --run_inchworm --monitor 1 2>$work_dir/monitor.out  >$work_dir/inchworm.K25L48.fa.tmp && mv $work_dir/inchworm.K25L48.fa.tmp $work_dir/inchworm.K25L48.fa\n";
           print OUT "touch inchworm.fininshed\n";
           print OUT "echo END!\n";
     close OUT;
  }
 else{
  open(OUT,">$work_dir/$job_name".'.lsf');

   print "Generating lsf file \n";
           print OUT "#!/bin/bash\n";
           print OUT "#BSUB -n 20\n";
           print OUT "#BSUB -R \"rusage[mem=9000]\"\n";
           print OUT "#BSUB -R \"span[hosts=1]\"\n";
           print OUT "#BSUB -W 72:00\n";
           print OUT "#BSUB -J \"$job_name\"\n";
           print OUT "#BSUB -o $job_name.run.out\n";
           print OUT "#BSUB -e $job_name.run.err\n";
           print OUT "\ndate\n";
           print OUT "perl /scratch/scei/sceivam/Trinity_Scripts/kmeryl.pl --reads $both_fa --work_dir $work_dir --trin_dir $trin_dir\n";
           print OUT "$inch --kmers $work_dir/meryl.kmers.min${min_kmer_coverage}.fa --coverage_outfile $work_dir/kmer2iwContig.coverage --run_inchworm --monitor 1 2>$work_dir/monitor.out  >$work_dir/inchworm.K25L48.fa.tmp && mv $work_dir/inchworm.K25L48.fa.tmp $work_dir/inchworm.K25L48.fa \n";
           print OUT "touch inchworm.finished\n";
           print OUT "echo END!\n";
     close OUT;
  }
print "Lsf file is created at $work_dir\nHave a look and submit it\n";
  
}
  










