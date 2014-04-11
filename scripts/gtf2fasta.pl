#! /usr/bin/perl 
use strict;
use warnings;
use Bio::SeqIO;
use Bio::DB::Fasta;
use List::Util qw(max min);
use List::MoreUtils qw(uniq minmax) ;

die ("\tThis program is for extracting gene fasta sequences from genome provided its gtf(with exon no information) and genome fasta, \n\t
	Usage :  perl $0 <eshark_genes.gtf> <genome fasta (scaffolds.fa)> <output_file(fasta)>\n\n") if($#ARGV<2);

my $inpfasta = Bio::DB::Fasta->new($ARGV[1]);
my $out = Bio::SeqIO->new(-file=>">$ARGV[2]",-format=>"fasta");
open(GTF,"<$ARGV[0]")||die $!;
# scaffold_21126  protein_coding  exon    81      416     .       +       .        gene_id "SINCAMG00000017008"; transcript_id "SINCAMT00000026356"; exon_number "1";
my %GENES;
while(<GTF>){
	 chomp;
	 my ($scaff,$type,$region,$start,$stop,$tmp,$strand,$tmp1,$annot) = split("\t",$_);
	 next unless($region eq "CDS");
	 my ($gene_id,$trans_id,$exon_no,@group) = split(";", $annot);
	 $gene_id=~s/[\s|gene_id|\"]//g;
	 $trans_id=~s/[\s|transcript_id|\"]//g;
	 $exon_no=~s/[\s|exon_number\s|\"]//g;
	 push @{$GENES{$gene_id}},[$start, $stop, $strand, $scaff];
}

foreach my $G(sort keys %GENES){
	 my @start = uniq(map {$_->[0] } @{$GENES{$G}});
         my @end  = uniq(map {$_->[1]} @{$GENES{$G}});
	 my $strand = $GENES{$G}->[0][2];
	 my $scaff = $GENES{$G}->[0][3];
	 my $st = min @start;
	 my $stp = max @end;
	 my $gene_seq = $inpfasta->seq("$scaff:$st-$stp");
 	 my $rec = Bio::Seq->new(-seq => $gene_seq, -id => $G);
 	 if($strand eq "+"){
   		$out->write_seq($rec);
 	 }
	 else{
	   	my $rec2 = $rec->revcom();
   		$out->write_seq($rec2);
 	 }
}
 
