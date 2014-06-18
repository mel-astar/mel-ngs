#!/usr/bin/env perl
use warnings;
use strict;
use Statistics::Basic qw(:all);
use Getopt::Long qw(:config bundling);
use Cwd;
use Switch;
use constant USAGE=><<END;

SYNOPSIS:

  This program does the quality filtering on fastq paired end reads
  If average qulaity of paired reads is >= minQ (minimum required quality)
  then it retains them else filters them out.

USAGE: 
    
      perl fastq_QF.pl [OPTIONS] --fw forward_reads.fq --bw reverse_reads.fq 

	[OPTIONS]
	--casava			:  If the fastq files directory is a casava folder (Default : No).
	--outputbase			:  base name for the output files (Def: Illumina_QF).
	--minQ				:  Minimum medium Quality required  for filtering (Def: 20).
	--Qtype 			:  Quality encoding (def: sanger)
					   sanger (for sanger and Illumina 1.8+ formats)
					   solexa (for solexa and illumina 1.3+ formats)
	--zout				:  Output to be compressed (gzipped) format				  
    
	NOTE: --casava should not be used along with --fw and --bw options

AUTHOR: 
  
    Vamshidhar Gangu.	
END

my $casava;
my $minQ;
my $outbase;
my $fw;
my $bw;
my $Qtype;
our $ENCODING;
my $zout;

&GetOptions( 'casava' => \$casava,
	      'outputbase=s'=>\$outbase,
	      'minQ=i'=>\$minQ,
	      'fw=s'=>\$fw,
	      'bw=s'=>\$bw,
	      'Qtype=s'=>\$Qtype,
	      'zout'=>\$zout
	    );

die USAGE."\nERROR: No Input/ Arguments \n\n" unless(($fw && $bw)||$casava);

die USAGE."\nERROR: Choose either casava or input fq files\n\n" if(($fw && $bw) && $casava);

$minQ = 20 unless($minQ);
$outbase = "Illumina_QF" unless ($outbase);
$Qtype = "sanger" unless($Qtype);

switch($Qtype){
  case("sanger") { $ENCODING = 33; }
  case("solexa") { $ENCODING = 64; }
}

my ($out_fw, $out_bw);
if($zout){
 $out_fw = $outbase."_1_filt.fq.gz";
 $out_bw = $outbase."_2_filt.fq";

 open OUT1,">", "gzip $out_fw" ||die $!;
 open OUT2,">", "gzip $out_bw" ||die $!;
}
else{
 $out_fw = $outbase."_1_filt.fq";
 $out_bw = $outbase."_2_filt.fq";

 open OUT1,">", $out_fw ||die $!;
 open OUT2,">",$out_bw ||die $!;
}


if($casava){

  my @fwfiles = <./*R1*fastq.gz>;
  #my @bwfiles = <./*R2*fastq.gz>;
  print STDERR "Total Number of fastq paired files: ".scalar(@fwfiles)."\n";
  my $file=1;
  foreach my $f(@fwfiles){
      my $for = $f;
      my $rev = $for;
      $rev =~ s/'R1'/'R2'/;
      if((-e $for) && (-e $rev)){
	 my ($clear, $clearPercent) = parse_paired_files($for, $rev, $minQ);
	 print STDERR "$for:$rev\t $clear($clearPercent) reads filtered\n";
      }
      else{
	warn "No Paired file exists: $for $rev\n";
      }
     print STDERR "Finished $file/".scalar(@fwfiles)."\n";
     $file++;
  } 
}
elsif(!($casava) && ($fw && $bw)){
  my ($clear, $clearPercent) = parse_paired_files($fw, $bw, $minQ);
  print STDERR "$fw:$bw\t$clear($clearPercent) reads filtered\n"
}

close(OUT1);
close(OUT2);



sub parse_paired_files{
  my ($inp1, $inp2, $Q ) = @_;
  if($inp1 =~/\.gz$/){
      open FILE1 ,"-|", "/bin/gunzip -c $inp1"  or die "Cannot gunzip the stream of $inp1\n";
      #$FILE1 = gzopen($inp1, "rb") or die "Error reading $inp1: $gzerrno";
  }
  else{
    open FILE1, "<",$inp1 or die $!;
  }

  if($inp2 =~ /\.gz$/){
    open FILE2, "-|", "/bin/gunzip -c $inp2" || die $!;
    #$FILE2 = gzopen($inp2, "rb")  or die "Error reading $inp2: $gzerrno";
  }
  else{
    open FILE2,"<", $inp2 or die $!;
  }

  my @read1;
  my @read2;
  my $clear=0;
  my $totalreads=0;

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
   	        	 warn "Sequence '$seq1' looked like an id in $inp1";
  			 }
  		if ($seq2=~/^\[@+]/) {
  			  warn "Sequence '$seq2' looked like an id in $inp2";
  			 }	
 		if ($seq1 =~/^[@+]/) {
 			   warn "Sequence '$seq1' looked like an id in $inp1";
  			 }
 		if ($seq2=~/^\[@+]/) {
 			   warn "Sequence '$seq2' looked like an id in $inp2";
  			 }
  		if ($qual_head1 !~ /^\+/) {
  			  warn "Midline '$qual_head1' didn't start with a + in $inp1";
  			}	
 		if ($qual_head2!~ /^\+/) {
    			warn "Midline '$qual_head2' didn't start with a + in $inp2";
  			}

  		if ($qual1 =~ /[GATCN]{60,}/) {
    			warn "Quality '$qual1' looked like sequence in $inp1";
   			}
 		if ($qual2 =~ /[GATCN]{60,}/) {
    			warn "Quality '$qual2' looked like sequence in $inp2";
   			}
  		if (length($seq1) != length($qual1)) {
    			 warn "Seq $seq1 and Qual $qual1 weren't the same length in $inp1";
   			}
 		if (length($seq2) != length($qual2)) {
    			 warn "Seq $seq2 and Qual $qual2 weren't the same length in $inp2";
   			}
   		$read1=~/(\S+)\#*/;
  	 	my $id1=$1;
   		$read2=~/(\S+)\#*/;
   		my $id2 = $1;
   		if($id1 eq $id2){
		    $totalreads++;
  		    my @Qual1 = split('',$qual1);
  		    my @Qual2 = split('',$qual2);
  		    my @Q1 = map { ord($_) - $ENCODING } @Qual1;
  		    my @Q2 = map { ord($_) - $ENCODING } @Qual2;
  	            my $QMed1 = mean(@Q1);
  		    my $QMed2 = mean(@Q2);

  		    if(($QMed1>=$Q) &&($QMed2>=$Q)){
    		      	 $clear=$clear+1;
    		    	 print OUT1 "$read1\n$seq1\n$qual_head1\n$qual1\n";
    	   	    	 print OUT2 "$read2\n$seq2\n$qual_head2\n$qual2\n";
   	   		}
		    #else {
    		    #	 print STDERR "/////////////////////////////////\n$read1\n$seq1\n$qual_head1\n$qual1\n";
    	   	    #	 print STDERR "$read2\n$seq2\n$qual_head2\n$qual2\n";
		    #}
                }   
		@read1=();
		@read2=();
     }   
     else{
             $line1=<FILE1>;
             $line2=<FILE2>;
          }   
  }
  my $percent = ($clear/$totalreads)*100;
  #print STDERR "Total number of reads passed filtering is: $clear ($percent)\n";
  close(FILE1);
  close(FILE2);
  return($clear, $percent);
}
