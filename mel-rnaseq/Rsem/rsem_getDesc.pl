use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use constant USAGE=><<END;

This program get Descritpion for each gene/isoform from *_tab.tsv file (produced by rsem_consolidate.pl)

Usage: perl $0 
	
	Options:
		--id2desc		:	id-description file
						(EnsemblGeneId2Desc.txt for genes)
						(EnsemblTransId2Desc.txt for isoforms)
		--input			:	Input gene/isoform tabulated file.
		--output (Optional)	: 	Output filename (Def: %inputfilename%_desc.tsv)
END

my $input;
my $id2desc;
my $output;

&GetOptions( 'id2desc=s' => \$id2desc, 'input=s' => \$input, 'output=s' => \$output) || die $!;

unless($input || $id2desc){
	die("Some of the core parameters are missing\n".USAGE."\n");
}

unless($output){
	my $base = basename($input);
	$base =~ s/\.(\w+)$//;
	$output = $base."_desc.tsv";
}

my %DESC; my %TYPE;

open my $desc, $id2desc or die $!;
my $h1 = <$desc>;
chomp($h1);
while(my $descline = <$desc>){
	chomp($descline);
	my ($id, $type, $description) = split("\t", $descline);
	push @{$DESC{$id}}, $description unless($description eq '');
	push @{$TYPE{$id}}, $type if(($description eq '') && ($type ne ''));
}
close($desc);

open my $inp, $input or die $!;
open my $out, ">$output" or die $!;
my $h2 = <$inp>;
chomp($h2);
print $out "$h2\tDesc\n";
while(my $inpline = <$inp>){
	chomp($inpline);
	my ($id, @rec) = split("\t", $inpline);
	if($DESC{$id}){
		my $desc = $DESC{$id}->[0][0];
		print $out "$inpline\t$desc\n";
	}
	elsif($TYPE{$id}){
		my $type = $TYPE{$id}->[0];
		print $out "$inpline\t$type\n";
	}
	else{	print $out "$inpline\tNA\n";	}
}
close($inp);
close($out);
