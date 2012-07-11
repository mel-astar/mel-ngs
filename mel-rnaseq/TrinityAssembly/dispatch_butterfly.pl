use strict;
use warnings;

use Getopt::Long;
use Cwd;

my $usage = <<_EOUSAGE_;
####################################################################################
# --wrkdir        : directory where the quantifygraphs commands are generated(Def: "./")
#  --c               : Name of quantify coomands file
# --cutoff          : No of commands you want to dispatch to one lsf file (Def: 200)
# 
###############################################################################

_EOUSAGE_
    ;
my $wrkdir;
my $c;
my $cutoff;

&GetOptions( 'wrkdir=s'=>\$wrkdir,'c=s'=>\$c,'cutoff=i'=>\$cutoff, );

unless($c && $cutoff)
{    
       die $usage;
}

unless($wrkdir)
{
     $wrkdir=cwd;
}

unless($cutoff)
{
    $cutoff=200;
}


open(IN,"$wrkdir/$c");

my @commands;

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
     open(OUT, ">$wrkdir/QG_$i");
     print OUT "#!/bin/bash\n";
     print OUT "#BSUB -n 15\n";
     print OUT "#BSUB -R \"rusage[mem=9000]\"\n";
     print OUT "#BSUB -R \"span[hosts=1]\"\n";
     print OUT "#BSUB -W 72:00\n";
     print OUT "#BSUB -J \"RunQG_$i\"\n";
     print OUT "#BSUB -o $wrkdir/RunQG_$i.job.out\n";
     print OUT "#BSUB -e $wrkdir/RunQG_$i.job.err\n";
     print OUT "\ndate\n";
     print OUT join("\n",@commands[$start..$start+($cutoff-1)]),"\n";
     print OUT "date\n";
     close OUT;
     print "bsub <$wrkdir/QG_$i\n";
   
     #ast;
   
    $start=$start+$cutoff;   
 } 
     
if(($tot%$batches)!=0)
 { 
     open(OUT, ">$wrkdir/QG_last");
     print OUT "#!/bin/bash\n";
     print OUT "#BSUB -n 15\n";
     print OUT "#BSUB -R \"rusage[mem=9000]\"\n";
     print OUT "#BSUB -R \"span[hosts=1]\"\n";
     print OUT "#BSUB -W 72:00\n";
     print OUT "#BSUB -J \"RunQG_last\"\n";
     print OUT "#BSUB -o $wrkdir/RunQG_last.job.out\n";
     print OUT "#BSUB -e $wrkdir/RunQG_last.job.err\n";
     print OUT "\ndate\n";
     print OUT join("\n",@commands[$start..($tot-1)]),"\n";
     print OUT "date\n";
     close OUT;
     print "bsub <$wrkdir/QG_last\n";
     print "Dispatching QunatifyGraphs is successfully completed\n";
 }
 elsif(($tot%$batches)==0){
   print "Dispatching QuantifyGraphs is successfully completed\n";
 }
