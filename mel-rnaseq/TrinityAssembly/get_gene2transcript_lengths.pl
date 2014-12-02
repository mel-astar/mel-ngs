#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/../../PerlLib");
use Fasta_reader;


my $usage = "usage: $0 transcripts.fasta\n\n";

my $trans_fasta = $ARGV[0] or die $usage;

main: {
    
    my $fasta_reader = new Fasta_reader($trans_fasta);
    
    while (my $seq_obj = $fasta_reader->next()) {
	my $gene; my $trans;
        my $acc = $seq_obj->get_accession();
	if ($acc =~ /^(.*c\d+_g\d+)(_i\d+)/) {
            $gene = $1;
            $trans = $1 . $2;

            #print "$gene\t$trans\n";
        }
        elsif ($acc =~ /^(comp\d+_c\d+)/) {
            $gene = $1;
            $trans = $acc;
            #print "$gene\t$trans\n";
        }

        my $seq = $seq_obj->get_sequence();

        print join("\t", $gene, $trans, length($seq)) . "\n";
    }


    exit(0);
}



    
    
