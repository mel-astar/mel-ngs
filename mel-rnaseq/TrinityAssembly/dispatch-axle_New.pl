#!/usr/bin/perl -w
#
# use this for fuji
# to check with yy on editted script
# for new trinity_Run (24042011) & -r20110519
# NOTE: to indicate edge threshold value (tuning); 
# default set as 0.05 (hard-coded)
#######################################################################################

use strict;

my %hash;
my $bfly_opts= "--compatible_path_extension --stderr --edge-thr=0.05";  #butterfly_options to set


print "Hashing butterfly commands...\n";
open(Command, $ARGV[0]);

while(my $c = <Command>){
    chomp $c;
    my @com = split(/\s+/,$c); 
    my @comp = split(/\//,$com[-1]);
  # $hash{$comp[-1]} = "$c"." $bfly_opts";
  # $hash{$comp[-1]} = "$c";
  # $hash{$comp[-1]} = "/apps/JAVA_Collection/jre1.6.0_16/bin/"."$c";  #to use this for axle
    $hash{$comp[-1]} = "/apps/JAVA_Collection/jre1.6.0_16/bin/"."$c"." $bfly_opts";  #to use this for axle
}


my @dir_contents;
my $dir_to_open = "$ARGV[1]";

opendir(DIR,$dir_to_open) || die("Cannot open directory $dir_to_open!\n");
@dir_contents= readdir(DIR);
closedir(DIR);

foreach my $dir (@dir_contents){
    if(!(($dir eq ".") || ($dir eq ".."))){
	next unless($dir =~ /RawComps/);
	print "Reading $dir\n";
	my @dir_rawcomps;
	my $dir_to_read = "$dir_to_open/$dir";
	#print $dir_to_read,"\n";
	opendir(RAW,$dir_to_read) || die("Cannot open directory $dir_to_read!\n");
	@dir_rawcomps = readdir(RAW);
	closedir(RAW);

	# Initialise variables
	my ($flag, $count_reads, $file_num, $count, @array);
	$flag= $count_reads= 0;
	$file_num= $count= 1;

        foreach my $file (@dir_rawcomps){
            if(!(($file eq ".") || ($file eq ".."))){
                next unless($file =~ /reads$/);
		$count_reads++;
	    }
	}
	
	print "Dispatching jobs...\n";
	foreach my $file (@dir_rawcomps){
	    if(!(($file eq ".") || ($file eq ".."))){
		next unless($file =~ /reads$/);
		my $line_count = `grep -c ">" $dir_to_read/$file`;

               #changed to 10 million reads; michelle 3/5/2011
		if($line_count < 10000000){
		    START:
		    if($file_num <= 2000 && $count_reads > 0){
			$file_num++;
			$file =~ s/\.reads//;
			push(@array, $hash{$file});

			$count_reads--;
			if($count_reads == 0){ $flag = 1; goto PRINT;}

		    }else{
			PRINT:
			open(OUT, ">Run_".$dir."_$count");
			print OUT "#!/bin/bash\n";
			print OUT "#BSUB -n 15\n";
			print OUT "#BSUB -R \"rusage[mem=6000]\"\n";
			print OUT "#BSUB -R \"span[hosts=1]\"\n";
			print OUT "#BSUB -W 72:00\n";
			print OUT "#BSUB -J \"$dir\_$count\"\n";
			print OUT "#BSUB -o Run_$dir\_$count.out\n";
			print OUT "\ndate\n";
			print OUT join("\n",@array),"\n";
		#	print OUT "mkdir $dir_to_read/butterfly;";
		#	print OUT "mv $dir_to_read/*_finalCompsWOloops.dot $dir_to_read/*_allProbPaths.fasta $dir_to_read/*.err $dir_to_read/butterfly;\n";
			print OUT "date\n";
			close OUT;
			print "bsub <Run_$dir\_$count\n";
	#		system("bsub <Run_$dir\_$count");

			if($flag == 1){
			    last;
			}
		
			# Re-initialise variables
			$count++;
			$file_num = 1;
			@array = ();
			goto START;
		    }    
		}else{
		    print "ERROR: File too large $dir_to_read/$file\t$line_count reads\n";
                    $count_reads--; #added so that problematic RawComps# not missed; michelle; 8/5/2011
		}
	    }
	}
    }
}

close(OUT);

