use strict;
use warnings;
use Config::Simple;

use constant USAGE=><<END;
Synopsis:

  This program runs rsem on the input fastq reads, Align them to reference
  
Usage:
	 perl $0  (See algn.cfg to set Parameters)

END

my $cfg = new Config::Simple("align.cfg");

my %values = $cfg->vars();

my $paired = (defined $values{'default.PAIRED'}) ? $values{'default.PAIRED'} : 0 ;

my @inpR1 = @{$values{'default.INPUT_R1'}};
my @inpR2 = @{$values{'default.INPUT_R2'}};

my $rsem_genome = $values{'default.RSEM_GENOME'};

unless($rsem_genome){
	die("No Reference Genome is provided.. check align.cfg file!!!!\n");
}

if($paired == 0 && (defined $inpR2[0])){
	die("For Single Reads, INPUT_R2 reads also given .. Please check align.cgf\n");
}
elsif($paired ==0 && !(defined $inpR1[0])){
	die("For Single Reads, No INPUT_R1 reads are provided.. Please check align.cfg\n");
}
elsif($paired==1 && (!(defined $inpR2[0]) || !(defined $inpR1[0]))){
	die("For Paired Reads, Either INPUT_R1 or INPUT_R2 are missing,.. Please check align.cfg\n");
} 


my $rsem_path = (defined $values{'default.RSEM_PATH'})? $values{'default.RSEM_PATH'}: `which rsem-calculate-expression`;

unless($rsem_path){
	die "RSEM is not found in your system, Please provide correct rsem path in align.cfg\n";
}


my $SS = (defined $values{'default.SS'})? $values{'default.SS'} : 0; # Strand specific
my $cpu = (defined $values{'default.CPU'})? $values{'default.CPU'}: 2 ;
my $output_sample_name = (defined $values{'default.SAMPLE_NAME'}) ? $values{'default.SAMPLE_NAME'} : "rsem_test";

my $bowtieVer = ($values{'default.BOWTIE'}>1) ? 'bowtie2' : 'bowtie';
my $bowtiePath = (defined $values{'default.BOWTIE_PATH'}) ? $values{'default.BOWTIE_PATH'} : `which $bowtieVer`;

unless($bowtiePath){
	die("Error in finding $bowtieVer... Please provide correct $bowtieVer Path in align.cfg\n");
}

my $rsem_prog = $rsem_path.'/rsem-calculate-expression'." -p $cpu --output-genome-bam";

$rsem_prog .= " --strand-specific" if($SS==1);
$rsem_prog .= " --paired-end" if($paired == 1);

if(defined $values{'default.BOWTIE_PATH'}){
	if($bowtieVer eq "bowtie2"){
		$rsem_prog .= " --bowtie2 --bowtie2-path ".$values{"default.BOWTIE_PATH"};
	}
	elsif($bowtieVer eq "bowtie"){
		$rsem_prog .= " --bowtie-path ".$cfg->param("default.BOWTIE_PATH");
	}
}
else{
	if($bowtieVer eq "bowtie2"){
		$rsem_prog .= " --bowtie2";
	}
}

$rsem_prog .= " ".join(",", @inpR1);
$rsem_prog .= " ".join(",", @inpR2) if($paired ==1 );
$rsem_prog .= " $rsem_genome $output_sample_name";

print STDOUT "$rsem_prog\n";





