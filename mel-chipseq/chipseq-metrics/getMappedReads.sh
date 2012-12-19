# This prog finds all bam files in current dir and sub directories and run bamtools filter to get onlu mapped reads.
# Before running this script, make sure you create a dir named MappedBams in current path or change output dir path at bamtools line

for i in $(find ./ -name "*.bam")
do
 x=$(basename $i)
 echo "Running bamtoold filter on $x";
 bamtools filter \-in $i -out ./MappedBams/${x%.bam}_Mapped.bam -isMapped true;
done
