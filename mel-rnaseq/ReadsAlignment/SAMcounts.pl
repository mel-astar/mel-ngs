use strict;
use warnings;

# This program is for calculating multimapped and uniquely mapped reads in sam file(without header)

die("\n\tUsage:$0 (<Samfile>|- FOR STDIN) output to STDOUT \n\n")if($#ARGV<0);

my $SAM_FILE=$ARGV[0];
my $fh;
if ($SAM_FILE eq "-") {
        $fh = \*STDIN;
}
else {
        open ($fh, $SAM_FILE) or die "Error, cannot open file $SAM_FILE";
}

my %PairUniq;  # uniquely mapped Paired end reads
my %SingleUniq;  # uniquely mapped Singletons
my %PairMulti; # Multi mapped paired end reads
my %SingleMulti; # Multi mapped singletonns 
my %reads;
my $nhmulti=0;
my $nhuniq=0;
my $totalign=0;

open(IN,"<$ARGV[0]")||die $!;
while(<IN>){
 chomp;
 if (/^\@/) { next; } # Skip Header
 my ($read,$flag,$chr,$pos,$mapq,$cigar)=split(/\t/,$_);
=head1
 my $pos1 = ($flag & 0x0040) ? 1 : 0; #Fisr in Pair
 my $pos2 = ($flag & 0x0080) ? 2 : 0; #Second in Pair
 my $name;
 $name = $read.'_'.$pos1 if($pos1>0);
 $name = $read.'_'.$pos2 if($pos2>0);
=cut 
 $totalign++;
 if(($totalign % 1000)==0){
   print STDERR "Processed $totalign no of lines\n";
 }
 next if($reads{$read});
 $_=~/NH:i:(\d+)/;
 my $nh=$1; # No of Times Query is Mapped
 my $single = ($flag & 0x0008) ? 0: 1; #Whether Mate is UnMapped??? (If mapped 1, else 0)
 if($nh>1){
   if($single>0){
     $nhmulti+=($nh*2);
     push @{$PairMulti{$read}},1;
     push @{$reads{$read}},1;
   }
   elsif($single==0){
     $nhmulti+=$nh;
     push @{$SingleMulti{$read}},1;
     push @{$reads{$read}},1;
   }
 }
 elsif($nh==1){
   if($single>0){
     $nhuniq+=($nh*2);
     push @{$PairUniq{$read}},1;
     push @{$reads{$read}},1;
   }
   elsif($single==0){
     $nhuniq+=$nh;
     push @{$SingleUniq{$read}},1;
     push @{$reads{$read}},1;
   }
 }
 else{
   warn("No Information on No of Times it Mapped for $read\n");
  }
}
my $PairedMulti = (scalar(keys %PairMulti)*2);
my $PairedUniq = (scalar(keys %PairUniq)*2);
my $singletonsMulti = scalar keys %SingleMulti;
my $singletonsUniq = scalar keys %SingleUniq;
my $singletons = $singletonsMulti + $singletonsUniq;
my $TotReads = $PairedMulti+$PairedUniq+$singletonsMulti+$singletonsUniq;

print STDOUT "Total No of alignments in SAM file are : $totalign\n";
print STDOUT "Toal No of Reads in SAM file are : $TotReads\n";
print STDOUT "Total No of Paired Readss : ".($PairedMulti+$PairedUniq)."\n";
print STDOUT "Total No of Multi Mapped Paired Reads : $PairedMulti\n";
print STDOUT "Total No of Uniqely Mapped Paired Reads : $PairedUniq\n";
print STDOUT "Total No of singleton Reads : $singletons\n";
print STDOUT "Total No of Multi Mapped singleton Reads : $singletonsMulti\n";
print STDOUT "Total No of Uniquely Mapped singleton Reads : $singletonsUniq\n";
print STDOUT "\nTotal No of Multi Mapped Reads : ".($PairedMulti+$singletonsMulti)."\n";
print STDOUT "Total No of Uniquely Mapped Reads : ".($PairedUniq+$singletonsUniq)."\n"; 
=head2
print STDOUT "\nSum of NH Multi : $nhmulti\n";
print STDOUT "\nSum of NH Uniq : $nhuniq\n";
print STDOUT "\nSum of all NH : ".($nhmulti+$nhuniq)."\n";
=cut
