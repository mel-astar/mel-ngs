use strict;
use warnings;
use Getopt::Long;
use Cwd;
 
my $usage= <<_EOUSAGE_;
##########################################################
# --reads  reads fasta file
# --DS if Double-stranded (default: SS, Strand specific)
# --min_kmer_coverage min count for K-mers to be assembled by Inchworm (default: 1)
# --work_dir : dir where reads fasta file is located
################################################################


_EOUSAGE_
;
my $reads;
my $SS;
my $DS;
my $min_kmer_coverage;
my $work_dir;

&GetOptions( 'reads=s'=>\$reads,'work_dir=s'=>\$work_dir, 'DS'=>\$DS,'min_kmer_coverage=i'=>\$min_kmer_coverage,);


unless($reads)
{
 die $usage;
}

unless($work_dir){
  $work_dir=getcwd();
}

unless($min_kmer_coverage)
{
  $min_kmer_coverage=1;
}


my $MERYL_DIR='/scratch/scei/sceivam/softwares/trinityrnaseq_r2011-11-26/trinity-plugins/kmer/meryl/meryl';

my $cmd = "sed  \'s/^\>.*/\>/\' $work_dir/$reads > $work_dir/${reads}.headless";
    system("$cmd") unless (-s "$work_dir/${reads}.headless");	

$cmd = "$MERYL_DIR -v -B -m 25 -s $work_dir/${reads}.headless -o $work_dir/meryl_kmer_db";

if (!$DS) {
      $cmd .= " -f"; # forward strand k-mers only
 }
else {
      $cmd .= " -C"; # canonical (one or other of the potential DS k-mer)
    }
system("$cmd");

my $meryl_kmer_file = "meryl.kmers.min${min_kmer_coverage}.fa";

## output k-mers

$cmd = "$MERYL_DIR -Dt -n $min_kmer_coverage -s $work_dir/meryl_kmer_db >$work_dir/$meryl_kmer_file";
system("$cmd") unless (-s "$work_dir.'/'.$meryl_kmer_file");

unlink("$work_dir/${reads}.headless", "$work_dir/${reads}.headless.fastaidx", "$work_dir/meryl_kmer_db.mcdat", "$work_dir/meryl_kmer_db.mcidx");

