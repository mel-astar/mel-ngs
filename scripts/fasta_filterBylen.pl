use strict;
use warnings;
use Bio::SeqIO;
die("perl $0 <inp.fasta> <minLen> <output.fasta>\n") if($#ARGV<0);

my $in = Bio::SeqIO->new(-file=>"$ARGV[0]", -format=>"fasta");
my $out  = Bio::SeqIO->new(-file=>">$ARGV[2]", -format=>"fasta");

while(my $rec = $in->next_seq){
	my $len = $rec->length;
        $out->write_seq($rec)  if ($len >$ARGV[1]);
}
