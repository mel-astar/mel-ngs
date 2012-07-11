#!/usr/bin/perl -w
#
# use this for fuji
# to check with yy on editted script
# for new trinity_Run (24042011) & -r20110519
# NOTE: to indicate edge threshold value (tuning); 
# default set as 0.05 (hard-coded)
#######################################################################################

use strict;


open(Command, $ARGV[0]);
my $count = 0;
my @list;
my $dir;

while(my $command = <Command>){
	if($count > 2000){
		$count = 0;
			open(OUT, ">quantifyGraph\\Run_$count");
			print OUT "#!/bin/bash\n";
			print OUT "#BSUB -n 15\n";
			print OUT "#BSUB -R \"rusage[mem=60000]\"\n";
			print OUT "#BSUB -R \"span[hosts=1]\"\n";
			print OUT "#BSUB -W 72:00\n";
			print OUT "#BSUB -J \"$r\_$count\"\n";
			print OUT "#BSUB -o quantifyGraph\\Run$count.out\n";
			print OUT "\ndate\n";
			print OUT join("\n",@list),"\n";
			print OUT "date\n";
			close OUT;
			print "bsub <Run_$dir\_$count\n";
		last;
#			system("bsub <Run_$dir\_$count");

		
		#start next batch
		@list = ();
		push @list,$command;
	}
	else {
		push @list,$command;
		$count++;
	}
	
}
