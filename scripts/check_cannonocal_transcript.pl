#!/usr/bin/env perl

# Check EnsEMBL Transcripts
# Coded by Steve Moss (gawbul [at] gmail [dot] com)
# http://about.me/gawbul

# make things easier
use strict;
use warnings;

# import modules
use Bio::EnsEMBL::Registry;
use Data::Dumper;

# setup registry
my $registry = 'Bio::EnsEMBL::Registry';

# connect to EnsEMBL
$registry->load_registry_from_db(-host => "ensembldb.ensembl.org",
                -user => "anonymous");

# get gene adaptor object from registry for human core
my $gene_adaptor = $registry->get_adaptor("Human", "Core", "Gene");

# get list of gene stable IDs
my $gene_ids = $gene_adaptor->list_stable_ids();

# traverse gene IDs
my $count = 0;
my $defined_count = 0;
my $undefined_count = 0;
print "Processing " . scalar(@{$gene_ids}) . " gene IDs...\n";
while (my $gene_id = shift(@{$gene_ids})) {
    # let user know count
    local $| = 1;
    print "[$count/" . scalar(@{$gene_ids}) . "]\r";

    # get gene object
    my $gene = $gene_adaptor->fetch_by_stable_id($gene_id);

    # get canonical transcript
    my $canonical_transcript = $gene->canonical_transcript();

    # check defined
    if (defined $canonical_transcript) {
        $defined_count++;
    }
    else {
        $undefined_count++;
    }
    $count++;

    # undef the transcript
    $canonical_transcript = undef;
}

# let the user know
print "$defined_count defined \& $undefined_count undefined in $count.\n";
print "...done!\n";
