use strict;
use warnings;
use File::Basename;
use Getopt::Long;
use constant USAGE=><<END;

This program tabulates the expression values across all samples

USAGE : perl $0 <Directory Path Where Rsem Results are present for all samples>
	
	Options
	
	--level		: 	genes/isoforms (Def: genes)
	--coloumn	:	FPKM/TPKM/estimated_count (Def: FPKM)
	--output	: 	Output file basename (Def: rsem_genes_fpkm).
				Two output files will be generated with ("_rsem.tsv" and "_tab.tsv")

	Both Outputs are same, "*_rsem.tsv" is rsem like output and "_tab.tsv" is for user refined output
END

my $level;
my $col;
my $output;

&GetOptions('level=s' => \$level, 'coloumn=s'=>\$col, 'output=s'=>\$output) or die (USAGE."\n");

die ("Provide the Rsem Output directory Path\n".USAGE."\n") if($#ARGV<0);

my $dirpath = $ARGV[0];

unless($level){
	$level = 'genes';
}

unless($col){
	$col = 'FPKM';
}

unless($output){
	$output = 'rsem_genes_fpkm';
}

my $command = $dirpath.'/*'."$level.results";
print STDOUT "Search Command : $command\n";
my @files = `ls $command`;
my @f = map { chomp($_) } @files;

print "Total Number of files:".scalar(@files)."\n";
my $offsite;
if($col eq "FPKM") { $offsite = 6; }
elsif($col eq "TPKM"){ $offsite = 5; }
elsif($col eq "count") { $offsite = 4; }
else { die ("No $col is found\n".USAGE."\n"); }

my $n = scalar (@files);
my $M = -1;
my @matrix = ();
my @ids_arr = ();
&generate_matrix(@files);
@ids_arr = ("", @ids_arr);
@matrix = (\@ids_arr, @matrix);

open my $out, ">$output\_rsem.tsv" || die $!;
for (my $i = 0; $i <= $M; $i++) {
    for (my $j = 0; $j < $n; $j++) { print $out "$matrix[$j][$i]\t"; }
    print $out "$matrix[$n][$i]\n";
}
close($out);

open my $out2, ">$output\_tab.tsv" || die $!;
for(my $i=0; $i<=$M; $i++){
	for (my $j=0; $j < $n; $j++){
		if($j==0|| $i==0){
			my $name = parse_name($matrix[$j][$i]);
			print $out2 "$name\t";
		}
		else{
			print $out2 "$matrix[$j][$i]\t";
		}
	}
	if($i==0){
		my $name  = parse_name($matrix[$n][$i]);
		print $out2 "$name\n";
	}
	else{
		print $out2 "$matrix[$n][$i]\n";
	}
}
close($out2);

################## Subroutines   ####################################

sub generate_matrix {
	my (@files) = @_;
	for (my $i = 0; $i < scalar(@files); $i++) {
    		my (@ids, @ecs) = ();
    		&loadData($files[$i], \@ecs, \@ids);
		
   		if ($M < 0) {
        		 $M = scalar(@ids);
       			 @ids_arr = @ids;
    		}
    		elsif (!&check($M, \@ids_arr, \@ids)) {
        		print STDERR "Number of lines among samples are not equal!\n";
        		exit(-1);
    		}

    		my $colname;
    		if (substr($files[$i], 0, 2) eq "./") { $colname = substr($files[$i], 2); }
    		else { $colname = $files[$i]; }
    		$colname = "\"$colname\"";
    		@ecs = ($colname, @ecs);
    		push(@matrix, \@ecs);
	}
}

# 0, file_name; 1, reference of expected count array; 2, reference of transcript_id/gene_id array
sub loadData {
    open(INPUT, $_[0]);
    my $line = <INPUT>; # The first line contains only column names
    while ($line = <INPUT>) {
        chomp($line); 
        my @fields = split(/\t/, $line);
        push(@{$_[2]}, "\"$fields[0]\"");
        push(@{$_[1]}, $fields[$offsite]);
    }
    close(INPUT);

    if (scalar(@{$_[1]}) == 0) {
        print STDERR "Nothing is detected! $_[0] may not exist or is empty.\n";
        exit(-1);
    }
}

#0, M; 1, reference of @ids_arr; 2, reference of @ids
sub check {
    my $size = $_[0];
    for (my $i = 0; $i < $size; $i++) {
        if ($_[1]->[$i] ne $_[2]->[$i]) {
            return 0;
        }
    }
    return 1;
}


sub parse_name{
	my ($n) = @_;
	my $res;
	if($n eq ''){
		$res = "GeneIds" if($level eq "genes");
		$res = "TranscriptIds" if($level eq "isoforms");
	}
	else{
		$n =~ s/\"//g;
		$res = basename($n);
	}
	if($res =~ /\.results/){
		$res =~ /^(\S+)\.\w+\.results$/;
		$res = $1;
	}
	return($res);
}
