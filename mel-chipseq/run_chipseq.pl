use Config::General;
my $CONFIG_FILE = $ARGV[0] || "Config.txt";
my $conf = Config::General->new(-ConfigFile=>$CONFIG_FILE);
my %config = $conf->getall;
my $ONLYTREAT = $config{'ONLYTREAT'};
my $INPUT = $config{'INPUTFASTQ'};
my $TREAT = $config{'TREATMENTFASTQ'};
my $PROJ = $config{'PROJECTNAME'};
my $OUTDIR = $config{'OUTPUTDIR'};
my $INPUTBAM = $config{'INPUTBAM'};
my $OUTDIR_PROJ = "$OUTDIR/$PROJ"."_dir";
my $BOWTIE_DIR = "$OUTDIR_PROJ/bowtie";
my $MACS_DIR = "$OUTDIR_PROJ/macs";
my $MOTIF_DIR = "$OUTDIR_PROJ/motif";
my $ANNOTATEPEAKS_DIR = "$OUTDIR_PROJ/annotated_peaks";
my $GENOME = $config{'GENOME'};
$GENOME=~/^(\w{2})/;
my $MACS_GENOME = $1 || die "can't determine MACs genome";
if($MACS_GENOME eq 'hg'){
	$MACS_GENOME = 'hs';
}
my $BOWTIE_PARAMS = $config{'BOWTIE_PARAMS'} || "-m 1 --chunkmbs 256 --best -p 7";
my $MACS_PARAMS = $config{'MACS_PARAMS'} || "-p 1e-5";

if(! -d $OUTDIR){
	die ("$OUTDIR does not exist");
}
unless (-d $OUTDIR_PROJ) {
	mkdir $OUTDIR_PROJ;
}
mkdir "$OUTDIR/$PROJ"."_dir"."/bowtie";
mkdir "$OUTDIR/$PROJ"."_dir"."/annotated_peaks";
mkdir "$OUTDIR/$PROJ"."_dir"."/macs";
mkdir "$OUTDIR/$PROJ"."_dir"."/motif";

#run bowtie
print STDERR "mel-chipseq: Running bowtie\n\n";
chdir  $BOWTIE_DIR;
my $BOWTIE_IN_OUTFILE = $PROJ."_INPUT";
my $BOWTIE_TREAT_OUTFILE = $PROJ."_TREAT";
my $bowtie_IN_cmd = "(bowtie $BOWTIE_PARAMS -S $GENOME $INPUT |samtools view -ut -bS - | samtools sort - $BOWTIE_IN_OUTFILE) 2> $OUTDIR_PROJ/log.txt";
my $bowtie_TREAT_cmd = "(bowtie $BOWTIE_PARAMS -S $GENOME $TREAT |samtools view -ut -bS - | samtools sort - $BOWTIE_TREAT_OUTFILE) 2>> $OUTDIR_PROJ/log.txt";

if($ONLYTREAT<1){
  print STDERR "mel-chipseq: "."$bowtie_IN_cmd\n";
  system("$bowtie_IN_cmd") unless $INPUTBAM; 
  $INPUTBAM = $INPUTBAM || "$BOWTIE_DIR/$BOWTIE_IN_OUTFILE.bam";
}
print STDERR "mel-chipseq: "."$bowtie_TREAT_cmd\n";
system("$bowtie_TREAT_cmd") || die ("problems running $bowtie_TREAT_cmd");

#run MACS
print STDERR "mel-chipseq: Running MACS\n\n";
chdir "$MACS_DIR";
if($ONLYTREAT<1){
 my $macs_cmd = "macs14 $MACS_PARAMS -c $INPUTBAM -t $BOWTIE_DIR/$BOWTIE_TREAT_OUTFILE.bam -f BAM -g $MACS_GENOME -n $PROJ 2>> $OUTDIR_PROJ/log.txt";
}
else{
 my $macs_cmd = "macs14 $MACS_PARAMS -t $BOWTIE_DIR/$BOWTIE_TREAT_OUTFILE.bam -f BAM -g $MACS_GENOME -n $PROJ 2>> $OUTDIR_PROJ/log.txt";
} 
print STDERR "mel-chipseq: ".$macs_cmd."\n";
system($macs_cmd) || die ("problems running $macs_cmd");

#run annotated peaks
chdir "$ANNOTATEPEAKS_DIR";
print STDERR "mel-chipseq: Running annotatePeaks.pl\n\n";
my $annotate_cmd = "annotatePeaks.pl $MACS_DIR/$PROJ"."_peaks.bed $GENOME > $PROJ"."_annotated_peaks.txt";
system($annotate_cmd);


#run findmotifs
chdir "$MOTIF_DIR";  
print STDERR "mel-chipseq: Running findMotifsGenome.pl\n\n";

my $motif_cmd = "findMotifsGenome.pl $MACS_DIR/$PROJ"."_peaks.bed $GENOME $MOTIF_DIR -mask 2>> $OUTDIR_PROJ/log.txt";
print STDERR "mel-chipseq: ".$motif_cmd."\n";
system($motif_cmd) || die("problems running $motif_cmd");


print STDERR "mel-chipseq: Analysis Completed\n";



