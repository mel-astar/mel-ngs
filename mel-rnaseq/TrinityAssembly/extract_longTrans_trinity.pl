#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/../../PerlLib");
use Fasta_reader;

use constant USAGE=><<END;
\n\tSynopsis: Prints out Gene Trans Length information for Trinity.fasta and extracts longest transcript for each component

	USAGE:  perl $0 transcripts.fasta\n\n
	OUTPUT: {transcripts.fasta}.gene2trans.len and {transcripts}_maxTrans.fasta
END

my $trans_fasta = $ARGV[0] or die USAGE."\n";
my $length_output = $ARGV[0].".gene2trans.len";
$trans_fasta =~ m/^(\S+)\.fasta$/;
my $fasta_output = $1."_maxTrans.fasta";
open my $lenstat ,">$length_output" or die "cannot create output file $length_output\n";
main: {
    my %COMPLEN; my %COMPMAX;
    my $fasta_reader = new Fasta_reader($trans_fasta);
    
    while (my $seq_obj = $fasta_reader->next()) {
	my $gene; my $trans;
        my $acc = $seq_obj->get_accession();
	if ($acc =~ /^(.*c\d+_g\d+)(_i\d+)/) {
            $gene = $1;
            $trans = $1 . $2;
        }
        elsif ($acc =~ /^(comp\d+_c\d+)/) {
            $gene = $1;
            $trans = $acc;
        }

        my $seq = $seq_obj->get_sequence();
	my $len = length($seq);
        print $lenstat join("\t", $gene, $trans, $len) . "\n";

	if(!$COMPLEN{$gene} || $COMPLEN{$gene} < $len){
		$COMPLEN{$gene} = $len;
		$COMPMAX{$gene} = $trans;
    	}
       }
       $fasta_reader->finish();
       close($lenstat);
       print STDERR "Writing Longest transcript seq records\n";
	
	#Writing out the longest transcript
	open my $maxtrans, ">$fasta_output" or die "Cannot create $length_output file!!\n";
	my $fasta_reader2 = new Fasta_reader($trans_fasta);
	while(my $seq_obj = $fasta_reader2->next()){
		my $gene; my $trans;
        	my $acc = $seq_obj->get_accession();
        	if ($acc =~ /^(.*c\d+_g\d+)(_i\d+)/) {
            		$gene = $1;
            		$trans = $1 . $2;
        	}
        	elsif ($acc =~ /^(comp\d+_c\d+)/) {
            		$gene = $1;
            		$trans = $acc;
        	}
		die ("No Long Transcript for $gene\n") if($COMPMAX{$gene});
		next unless($trans eq $COMPMAX{$gene});
		my $fasta_entry = $seq_obj->get_FASTA_format();
		print $maxtrans $fasta_entry;	
	}	
 	
    exit(0);
}



    
    
