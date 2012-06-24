use Config::General;
my $CONFIG_FILE = $ARGV[0] || "Config.txt";
my $conf = Config::General->new(-ConfigFile=>"Config.txt");
my %config = $conf->getall;

my $INPUT = $config{'INPUTFASTQ'};
my $TREAT = $config{'TREATMENTFASTQ'};
my $PROJ = $config{'PROJECTNAME'};
my $OUTDIR = $config{'OUTPUTDIR'};
my $OUTDIR_PROJ = "$OUTDIR/$PROJ"."_dir";
my $BOWTIE_DIR = "$OUTDIR_PROJ/bowtie";
my $MACS_DIR = "$OUTDIR_PROJ/macs";
my $MOTIF_DIR = "$OUTDIR_PROJ/motif";
my $GENOME = $config{'GENOME'};
$GENOME=~/^(\w{2})/;
my $MACS_GENOME = $1 || die "can't determine MACs genome";
my $BOWTIE_PARAMS = $config{'BOWTIE_PARAMS'} || "-m 1 --chunkmbs 256 --best -p 7";
my $MACS_PARAMS = $config{'MACS_PARAMS'} || "-p 1e-5";

if(! -d $OUTDIR){
	die ("$OUTDIR does not exist");
}
unless (-d $OUTDIR_PROJ) {
	mkdir $OUTDIR_PROJ;
}
mkdir "$OUTDIR/$PROJ"."_dir"."/bowtie";
mkdir "$OUTDIR/$PROJ"."_dir"."/macs";
mkdir "$OUTDIR/$PROJ"."_dir"."/motif";

#run bowtie
print STDERR "mel-chipseq: Running bowtie\n\n";
chdir  $BOWTIE_DIR;
my $BOWTIE_IN_OUTFILE = $PROJ."_INPUT";
my $BOWTIE_TREAT_OUTFILE = $PROJ."_TREAT";
my $bowtie_IN_cmd = "(bowtie $BOWTIE_PARAMS -S $GENOME $INPUT |samtools view -ut -bS - | samtools sort - $BOWTIE_IN_OUTFILE) 2> $OUTDIR_PROJ/log.txt";
my $bowtie_TREAT_cmd = "(bowtie $BOWTIE_PARAMS -S $GENOME $TREAT |samtools view -ut -bS - | samtools sort - $BOWTIE_TREAT_OUTFILE) 2>> $OUTDIR_PROJ/log.txt";

system("$bowtie_IN_cmd");
# || die ("problems running $bowtie_IN_cmd");
system("$bowtie_TREAT_cmd");
# || die ("problems running $bowtie_TREAT_cmd");
print STDERR "mel-chipseq: "."$bowtie_IN_cmd\n";
print STDERR "mel-chipseq: "."$bowtie_TREAT_cmd\n";

#run MACS
print STDERR "mel-chipseq: Running MACS\n\n";
chdir "$MACS_DIR";
my $macs_cmd = "macs14 $MACS_PARAMS -c $BOWTIE_DIR/$BOWTIE_IN_OUTFILE.bam -t $BOWTIE_DIR/$BOWTIE_TREAT_OUTFILE.bam -f BAM -g $MACS_GENOME -n $PROJ 2>> $OUTDIR_PROJ/log.txt";
print STDERR "mel-chipseq: ".$macs_cmd."\n";
system($macs_cmd);
# || die ("problems running $macs_cmd");


#run findmotifs
chdir "$MOTIF_DIR";  
print STDERR "mel-chipseq: Running findMotifsGenome.pl\n\n";

my $motif_cmd = "findMotifsGenome.pl $MACS_DIR/$PROJ"."_peaks.bed $GENOME $MOTIF_DIR -mask 2>> $OUTDIR_PROJ/log.txt";
print STDERR "mel-chipseq: ".$motif_cmd."\n";
system($motif_cmd) ;
#|| die("problems running $motif_cmd");


print STDERR "mel-chipseq: Analysis Completed\n";



