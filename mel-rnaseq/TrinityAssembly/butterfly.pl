=head
perl /scratch/scei/sceivam/ES_Brain3Lanes/dispatch-axle_New.pl /scratch/scei/sceivam/ES_Brain3Lanes/chrysalis/butterfly_commands /scratch/scei/sceivam/ES_Brain3Lanes/chrysalis/;
=cut

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use Cwd;

my $usage = <<_EOUSAGE_ ;

#######################################################################
# --job_name    : name for the job to submit(Def:temp)
# --ncpu        : number of cpus needed(Def:15)
# --long        : if the job need to submit on long queue(def:no)
# --mem         : memory needed for job (Def:6000)
# --W           : wall time for job (Def:42:00)
# --filename    : filename for the lsf file(Def:prog_test)
# --wrkdir      : directory where to generate the lsf file (Def: ./)
# --ChryDir     : chrysalis directory
# --fbutt       : Name of the butterfly commands file.
#######################################################################

_EOUSAGE_
;

my $job_name;
my $ncpu;
my $long;
my $ChryDir;
my $fname;
my $wrkdir;
my $mem;
my $W;
my $fbutt;

&GetOptions('job_name=s' => \$job_name,'ChryDir=s'=>\$ChryDir,
             'ncpu=i' => \$ncpu,'mem=i' => \$mem,'W=i'=>\$W,
             'long' => \$long,'fbutt=s'=>\$fbutt,
             'filename=s'=>\$fname,'wrkdir=s'=>\$wrkdir,
            );

unless($fbutt && $ChryDir)
{
    die $usage;
}
unless($job_name)
{
 $job_name='temp';
}
unless($ncpu)
{
  $ncpu=15;
}
unless($mem)
{
    $mem=6000;
}
unless($W)
{
   $W=72;
}
unless($wrkdir)
{
   $wrkdir=cwd();
}
unless($fname)
{
   $fname='prog_test';
}

print "Generating lsf file..........\n";

open(OUT,">$wrkdir/$fname");

print OUT "#BSUB -n $ncpu\n";
print OUT "#BSUB -R \"rusage[mem=$mem]\"\n";
print OUT "#BSUB -R \"span[hosts=1]\"\n";
print OUT "#BSUB -W $W:00\n";
print OUT "#BSUB -J \"$job_name\"\n";
print OUT "#BSUB -o $job_name.run.out\n";
print OUT "#BSUB -e $job_name.run.err\n";
if($long)
{
 print OUT "#BSUB -q long\n";
}
print OUT "date\n";
print OUT "perl /scratch/scei/sceivam/ES_Brain3Lanes/dispatch-axle_New.pl $ChryDir/$fbutt $ChryDir\n";
print OUT "echo END!\n";
print "lsf file is sucessfully generated at $wrkdir, Have a check and submit it\n"

