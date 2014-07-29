use strict;
use warnings;
use Config::Simple;

use constant USAGE=><<END;
Synopsis:

  This program runs rsem on the input fastq reads, Align them to reference
  
Usage:
	 perl $0  <align.cfg> (See algn.cfg to set Input Parameters)

END

die ("Provide Config file along the program\n".USAGE."\n") if($#ARGV<0);

my $cfg = new Config::Simple("$ARGV[0]");

my %values = $cfg->vars();

my $paired = (defined $values{'default.PAIRED'}) ? $values{'default.PAIRED'} : 0 ;


my @inpR1 = @{$values{'default.INPUT_R1'}} if(defined $values{'default.INPUT_R1'});
my @inpR2 = @{$values{'default.INPUT_R2'}} if(defined $values{'default.INPUT_R2'});
my $alignment_file = $values{'default.ALIGN_FILE'} if(defined $values{'default.ALIGN_FILE'});

my $rsem_genome = $values{'default.RSEM_GENOME'};

unless($rsem_genome){
	die("No Reference Genome is provided.. check $ARGV[0] file!!!!\n");
}

if($paired == 0 && (defined $inpR2[0])){
	die("For Single Reads, INPUT_R2 reads also given .. Please check $ARGV[0]\n");
}
elsif($paired ==0 && !(defined $inpR1[0])){
	die("For Single Reads, No INPUT_R1 reads are provided.. Please check $ARGV[0]\n");
}
elsif($paired==1 && (!(defined $inpR2[0]) || !(defined $inpR1[0])) && !(defined $alignment_file)){
	die("For Paired Reads, Either INPUT_R1 or INPUT_R2  or Alignment file are missing,.. Please check $ARGV[0]\n");
} 

if((defined $inpR1[0] || defined $inpR2[0]) && (defined $alignment_file)){
	die("Both sam/bam file and input fastq reads are provided!! Provide any one of them!!... Please check $ARGV[0]\n");
}

my $rsem_path = (defined $values{'default.RSEM_PATH'})? $values{'default.RSEM_PATH'}: `which rsem-calculate-expression`;

unless($rsem_path){
	die "RSEM is not found in your system, Please provide correct rsem path in $ARGV[0]\n";
}

my $SS = (defined $values{'default.SS'})? $values{'default.SS'} : 0; # Strand specific
my $cpu = (defined $values{'default.CPU'})? $values{'default.CPU'}: 2 ;
my $output_sample_name = (defined $values{'default.SAMPLE_NAME'}) ? $values{'default.SAMPLE_NAME'} : "rsem_test";


my $rsem_prog = $rsem_path.'/rsem-calculate-expression'." -p $cpu --output-genome-bam";

$rsem_prog .= " --strand-specific" if($SS==1);
$rsem_prog .= " --paired-end" if($paired == 1);

if(!defined $alignment_file){
	my $bowtieVer = ($values{'default.BOWTIE'}>1) ? 'bowtie2' : 'bowtie';
	my $bowtiePath = (defined $values{'default.BOWTIE_PATH'}) ? $values{'default.BOWTIE_PATH'} : `which $bowtieVer`;
	unless($bowtiePath){
		die("Error in finding $bowtieVer... Please provide correct $bowtieVer Path in $ARGV[0]\n");
	}
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
}
else{
	$alignment_file =~ m/\.(\w{3})$/;
	my $type = $1;	
	if($type eq "sam"){
		$rsem_prog .= " --sam";
	}
	elsif($type eq "bam"){
		$rsem_prog .= " --bam";
	}
	else{
		die ("Cannot determine whether sam/bam .. check $ARGV[0] file!!!\n");
	}
	$rsem_prog .= " $alignment_file";
}
			

$rsem_prog .= " $rsem_genome $output_sample_name";

print STDOUT "$rsem_prog\n";
