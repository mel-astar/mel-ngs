use strict;
use warnings;
use Getopt::Long;
use Cwd;

my $usage=<<_EOUSAGE_;
###################################################################
#  --chr       :Full path to the chrysalis directory
#  --fout      :output file name (Def:Trin_fin_out.fa)
#  --job_name  :job_name for axle (Def:butt2_cat)
#  --outdir    :output directory (Def: chrysalisDirectory/../final_Trin)
##################################################################

_EOUSAGE_
          ;
my $chr;
my $fout;
my $out_dir;
my $job_name;

&GetOptions( 'job_name=s'=>\$job_name,'chr=s'=>\$chr,'fout=s'=>\$fout,'out_dir=s'=>\$out_dir, );

unless($chr)
{
  die $usage;
}

unless($fout)
{
 $fout='Trin_fin_out.fa';
}

unless($out_dir)
{
 $out_dir=$chr;
 $out_dir.='../final_Trin';
}

unless($job_name)
{
 $job_name='butt2_cat';
}

unless(-d $out_dir)
{
 mkdir $out_dir || die;
}

my $prog='/scratch/scei/sceivam/Trinity_Scripts/cat_probpathfasta2.pl';
my $dir=$chr.'/../';
 open OUT ,">$dir/$job_name.lsf";
 print OUT "#BSUB -n 15\n";
 print OUT "#BSUB -R \"rusage[mem=6000]\"\n";
 print OUT "#BSUB -R \"span[hosts=1]\"\n";
 print OUT "#BSUB -W 48:00\n";
 print OUT "#BSUB -J \"$job_name\"\n";
 print OUT "#BSUB -o $job_name.run.out\n";
 print OUT "#BSUB -e $job_name.run.err\n";
 print OUT "date\n";
 print OUT "perl $prog $chr $out_dir/$fout\n";
 print OUT "echo END!\n";
 print "lsf file is sucessfully generated at $dir, Have a check and submit it\n"


