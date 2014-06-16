use strict;
use warnings;
use Getopt::Long;
use Bio::SeqIO;
use constant USAGE =><<END;

SYNOPSIS:
  antismash_genbank2gff.pl -in inputfile -out outputfile

DESCRIPTION:

This script converts the genbank file created by Antismash program into gff format
which can be used for Gbrowse2.

Some part of the code is modifed from reformat_old.pl script of Kasper Munch.

EXAMPLES:
  
  antismash_genbank2gff.pl --in input.gbk --out output.gff
  
AUTHOR:

Vamshidhar Gangu.

COPYRIGHT:

This program is free software. You may copy and redistribute it under 
the same terms as perl itself.

END

my $inputgbk = '';
my $outputfile = '';
my $help =0;
GetOptions("in=s" => \$inputgbk,
	    "out=s" => \$outputfile,
	    "help"=>\$help ) or die USAGE;
	    
$help and die USAGE;

unless($inputgbk && $outputfile){
  die USAGE;
}

my $in = Bio::SeqIO->newFh(-file=> "$inputgbk", -format=>'genbank') || die "$inputgbk $!\n";

open my $gffout, '>', $outputfile || die $!;

while(my $seq = <$in>){
  my @features = $seq->all_SeqFeatures();
  for my $f (@features){
      my $id = $seq->desc;
      my $gff = make_gff($f, $id, $seq);
      print $gffout "$gff\n";
      if(ref($f->location()) eq 'Bio::Location::Split' and $f->primary_tag() =~ /mRNA|CDS/i){
	my @sl = $f->location->sub_Location();
	 for(my $j=0;$j<@sl; $j++){
	    my $subid = $id . "_e". eval{$j + 1 };
	    my $subgff = makesubgff('exon', $sl[$j]->start(), $sl[$j]->end(), $id, $subid, $f);
	    print $gffout "$subgff\n";
	    unless($j==@sl-1){
	      my $subid = $id. "_i". eval{$j+1};
	      $subgff = makesubgff('intron', $sl[$j]->end()+1, $sl[$j+1]->start()-1, $id, $subid, $f);
	      print $gffout "$subgff\n";
	    }
	 }
      }
   }
 }

 
 sub make_gff {
  my ($feature, $id, $Seq) = @_;
  # FIGURE OUT WHETHER THE GROUP FIELD SHOULD HAVE A TARGET:, SEQUENCE:
  # OR OTHER TAG. FOR NOW WE CALL EVERYTHING FOR SEQUENCE.
  #my $type = 'Sequence';
  my $type = 'Name';
  my $gff = $feature->gff_string();
  if(!$feature->has_tag('sec_met')){
	  #$gff =~ s/^(\S+)(\t\S+\t\S+\t)(\S+)\t(\S+)(\t\S+\t\S+\t\S+\t)(.*)$/$Seq->accession() . $2 . $feature->start() . "\t" . $feature->end() . $5 . "$type:$id 1 " . eval{$feature->end() - $feature->start() + 1} . " ; " . $6/e;
	  $gff =~ s/^(\S+)(\t\S+\t\S+\t)(\S+)\t(\S+)(\t\S+\t\S+\t\S+\t)(.*)$/$Seq->desc() . $2 . $feature->start() . "\t" . $feature->end() . $5 . "$type=$id 1 " . eval{$feature->end() - $feature->start() + 1} . " ; " . $6/e;
  }
  else{
	$gff =~ m/^(\S+)(\t\S+\t\S+\t)(\S+)\t(\S+)(\t\S+\t\S+\t\S+\t)(.*)$/;
	my $last = $6;
	$last =~ s/sec_met/Name=/;
	$gff =~ s/^(\S+)(\t\S+\t\S+\t)(\S+)\t(\S+)(\t\S+\t\S+\t\S+\t)(.*)$/$Seq->desc() . $2 . $feature->start() . "\t" . $feature->end() . $5 . "ID=$id 1 " . eval{$feature->end() - $feature->start() + 1} . " ; " . $last/e;
	
  }
  return $gff;
}

sub makesubgff {
  my ($name, $start, $end, $id, $subid, $feature) = @_;
  # FIGURE OUT WHETHER THE GROUP FIELD SHOULD HAVE A TARGET:, SEQUENCE:
  # OR OTHER TAG. FOR NOW WE CALL EVERYTHING FOR SEQUENCE.
  my $type = 'Sequence';
  my $gff = sprintf "$id\tEMBL/GenBank/SwissProt\t$name\t$start\t$end\t.\t%s\t.\t$type:$subid 1 %d",
    eval{ $feature->strand() == 1 ? '+' : '-' }, eval{$end - $start + 1};
  return $gff;
}
