# This is to run fastqc for quality statistics
# version used :10.0.1
# This fastqc can be directly used on bcltofastq output directory,
# as this can summarize all the files of same sample as one.

for i in $(ls -d ./Sample_lane*)
do
 echo $i
 cd $i
 echo fastqc \-o ./ \-f fastq \-\-casava \-t 4 \-\-extract *.gz;
 fastqc -o ./ -f fastq --casava -t 4 --extract *.gz;
 cd ../
done

