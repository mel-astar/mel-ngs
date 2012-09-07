#########################################################################################################################
# This prog is to check format of each record in FastQ file(s). And get the no of records in it.
# #######################################################################################################################

#!/usr/bin/perl -w 
use warnings;
use strict;

if(($#ARGV!=2)||($#ARGV!=1)){ die("\tNot enough Parameters Passed \n\tUsage: $0 <S/P (Single/Paired)> <Fastq file(s)>\n");}

my $count=0;

if($ARGV[0] eq "P"){

 open FILE1,"<","$ARGV[1]" or die $!;
 open FILE2,"<","$ARGV[2]" or die $!;

 my @read1;
 my @read2;
 my $clear=0;
 my $line1= <FILE1>;
 my $line2=<FILE2>;

 while ($line1 && $line2) {
     if(($line1=~ /^\@/)&&($line2=~/^\@/)){
        $count++;
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

       if ($seq1 =~/^[@+]/) {warn "Sequence '$seq1' looked like an id\n";}
       if ($seq2=~/^\[@+]/) {warn "Sequence '$seq2' looked like an id\n";}	
       if ($seq1 =~/^[@+]/) {warn "Sequence '$seq1' looked like an id\n" }
       if ($seq2=~/^\[@+]/) {warn "Sequence '$seq2' looked like an id\n";}
       if ($qual_head1 !~ /^\+/) {warn "Midline '$qual_head1' didn't start with a +\n";}	
       if ($qual_head2!~ /^\+/) {warn "Midline '$qual_head2' didn't start with a +\n";}
       if ($qual1 =~ /[GATCN]{20,}/) {warn "Quality '$qual1' looked like sequence\n";}
       if ($qual2 =~ /[GATCN]{20,}/) {warn "Quality '$qual2' looked like sequence\n";}
       if (length($seq1) != length($qual1)) {die "Seq $seq1 and Qual $qual1 weren't the same length\n";}
       if (length($seq2) != length($qual2)) { die "Seq $seq2 and Qual $qual2 weren't the same length\n";}
     } 
    elsif((($line1)&&(!$line2))||((!$line1)&&($line2))){ 
       die "No of records Vary in both paired end files\n";
    }
  }
 print "Total No of Paired reads are :$count\n";
}
elsif($ARGV[0] eq "S"){
 
 open FILE1,"<","$ARGV[1]" or die $!;

 my @read1;
 my $line1= <FILE1>;
 while ($line1) {
     if($line1=~ /^\@/){
        $count++;
        push(@read1,$line1);
        $line1=<FILE1>;
        for (1..3) {
          push (@read1, $line1);
          $line1 = <FILE1>;
       }
       my $record1_text = join("", @read1);
       my $read1 = shift @read1;
       my $seq1 = shift @read1;
       my $qual_head1 = shift @read1;
       my $qual1 = shift @read1;
       chomp $read1;
       chomp $seq1 if $seq1;
       chomp $qual_head1 if $qual_head1;
       chomp $qual1 if $qual1;

       if ($seq1 =~/^[@+]/) {warn "Sequence '$seq1' looked like an id\n";}
       if ($seq1 =~/^[@+]/) {warn "Sequence '$seq1' looked like an id\n" }
       if ($qual_head1 !~ /^\+/) {warn "Midline '$qual_head1' didn't start with a +\n";}
       if ($qual1 =~ /[GATCN]{20,}/) {warn "Quality '$qual1' looked like sequence\n";}
       if (length($seq1) != length($qual1)) {die "Seq $seq1 and Qual $qual1 weren't the same length\n";}
     }
  }
 print "Total no of Reads are :$count\n";
}
