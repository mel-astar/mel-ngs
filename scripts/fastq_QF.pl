#########################################################################################################################
# This program is to do the quality filter on two fastq files	 and  							#
# write the common ones into two diff corressponding outputs          							#
# The input is the illumina FASTQ file format and the also the output 							#
# is the same quality filtered fastq file                             							#
#							                               					#
# The syntax is perl fastq_qualty_filter.pl <input1.fq> <input2.fa> <output1.fq> <output2.fa>                           #
#								      							#
# For each read convert the Illumina score into phred quality score   							#
# if the median of phred scores of all the bases in a read is >=20    							#
# then it is accepted else filtered out                               							#
# #######################################################################################################################

#!/usr/bin/perl -w 
use warnings;
use strict;

open FILE1,"<","$ARGV[0]" or die("Couldn't find the file  $ARGV[0] \n");
open FILE2,"<","$ARGV[1]" or die("couldn't find the file $ARGV[1] \n");
open OUT1,">", "$ARGV[2]" ||die $!;
open OUT2,">","$ARGV[3]" ||die $!;

my @read1;
my @read2;
my $clear=0;

if($#ARGV<2){ die("Not enogh Parameters \n");}

my $line1= <FILE1>;
my $line2=<FILE2>;

while ($line1 && $line2) {

     if(($line1=~ /^\@/)&&($line2=~/^\@/)){
  
 		push(@read1,$line1);
  	  	push(@read2,$line2);
  		
  		$line1=<FILE1>;
  		$line2=<FILE2>;
  		for (1..3) {
                    push (@read1, $line1);
                    push (@read2, $line2);
                    $line1 = <FILE1>;
                    $line2 = <FILE2>;
                   }
  		my $record1_text = join("", @read1);
  		my $record2_text = join("", @read2);
  		my $read1 = shift @read1;
  		my $seq1 = shift @read1;
  		my $qual_head1 = shift @read1;
  		my $qual1 = shift @read1;
  		my $read2 = shift @read2;
  		my $seq2 = shift @read2;
  		my $qual_head2 = shift @read2;
  		my $qual2 = shift @read2;
  		chomp $read1;
  		chomp $read2;
  		chomp $seq1 if $seq1;
  		chomp $seq2 if $seq2;
  		chomp $qual_head1 if $qual_head1;
 		chomp $qual_head2 if $qual_head2;
  		chomp $qual1 if $qual1;
		chomp $qual2 if $qual2;

        	if ($seq1 =~/^[@+]/) {
   	        	 warn "Sequence '$seq1' looked like an id";
  			 }
  		if ($seq2=~/^\[@+]/) {
  			  warn "Sequence '$seq2' looked like an id";
  			 }	
 		if ($seq1 =~/^[@+]/) {
 			   warn "Sequence '$seq1' looked like an id";
  			 }
 		if ($seq2=~/^\[@+]/) {
 			   warn "Sequence '$seq2' looked like an id";
  			 }
  		if ($qual_head1 !~ /^\+/) {
  			  warn "Midline '$qual_head1' didn't start with a +";
  			}	
 		if ($qual_head2!~ /^\+/) {
    			warn "Midline '$qual_head2' didn't start with a +";
  			}

  		if ($qual1 =~ /[GATCN]{20,}/) {
    			warn "Quality '$qual1' looked like sequence";
   			}
 		if ($qual2 =~ /[GATCN]{20,}/) {
    			warn "Quality '$qual2' looked like sequence";
   			}
  		if (length($seq1) != length($qual1)) {
    			 warn "Seq $seq1 and Qual $qual1 weren't the same length";
   			}
 		if (length($seq2) != length($qual2)) {
    			 warn "Seq $seq2 and Qual $qual2 weren't the same length";
   			}
   		$read1=~/(\S+)\#/;
  	 	my $id1=$1;
   		$read2=~/(\S+)\#/;
   		my $id2 = $1;
   		if($id1 eq $id2){
  		    my @Qual1= split('',$qual1);
  		    my @Qual2=split('',$qual2);
  		    my @Q1=0;
  		    my @Q2=0;
  		    for(my $i=0;$i<length($qual1);$i++){
    		      	       #$Q1[$i] = 10 * log(1 + 10 ** ((ord($Qual1[$i])-64) / 10.0)) / log(10);
     	 		       #$Q2[$i] = 10 * log(1 + 10 ** ((ord($Qual2[$i])-64) / 10.0)) / log(10);
	    		       $Q1[$i]=ord($Qual1[$i])-64;
                               $Q2[$i]=ord($Qual2[$i])-64;
                             }

  	            my $QMed1 = median(@Q1);
  		    my $QMed2 = median(@Q2);

  		    if(($QMed1>=20) &&($QMed2>=20)){
    		      	 $clear=$clear+1;
    		    	 print OUT1 "$read1\n$seq1\n$qual_head1\n$qual1\n";
    	   	    	 print OUT2 "$read2\n$seq2\n$qual_head2\n$qual2\n";
   	   		}
		    else {
    		    	 print STDERR "/////////////////////////////////\n$read1\n$seq1\n$qual_head1\n$qual1\n";
    	   	    	 print STDERR "$read2\n$seq2\n$qual_head2\n$qual2\n";
		    }
                     }   
                @read1=();
		@read2=();
          }   
     else{
             $line1=<FILE1>;
             $line2=<FILE2>;
          }   
 } 
print "Total number of reads passed filtering is: '$clear' \n";

close(FILE1);
close(FILE2);
close(OUT1);
close(OUT2);


sub median {
    my @pole = @_;
    my $ret;
    @pole= sort {$a<=>$b} @pole;
    if( (@pole % 2) == 1 ) {
        $ret = $pole[((@pole+1) / 2)-1];
    } else {
        $ret = ($pole[(@pole / 2)-1] + $pole[@pole / 2]) / 2;
    }
    return $ret;
}
