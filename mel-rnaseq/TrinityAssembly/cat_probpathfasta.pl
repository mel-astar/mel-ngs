use strict;
use warnings;


my $dir = $ARGV[0];
print "ls $dir/*|grep ^RawComps";
my @raw_dir = `ls $dir/|grep ^RawComps`;

foreach my $r( sort @raw_dir){
	chomp($r);
	$r=~s/://g;
	my $str = "cat $dir/$r/*allProbPaths.fasta >> ".$ARGV[1];
	print STDERR $str."\n";
	system($str);

}

