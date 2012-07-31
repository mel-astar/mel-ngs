use strict;
use warnings;
use Bio::SeqIO;

die("\n\tThis script is for appending \"chr\" after > in fasta file\n\tMake sure to isntall BioPerl\n\t \
     \tUsage :$0 <input fasta> <output fasta> \n\n") if($#ARGV<1);

my $in=Bio::SeqIO->new(-file=>"<$ARGV[0]",-format=>"fasta");
my $out=Bio::SeqIO->new(-file=>">$ARGV[1]",-format=>"fasta");

while(my $entry=$in->next_seq){
 my $id = $entry->display_id;
 $id="chr$id";
 $entry->display_id($id);
 $out->write_seq($entry);
}
