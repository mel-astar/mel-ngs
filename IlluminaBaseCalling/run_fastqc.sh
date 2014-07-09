# This is to run fastqc for quality statistics
# version used :10.0.1
# This fastqc can be directly used on bcltofastq output directory,
# as this can summarize all the files of same sample as one.

dir=`pwd`;
for i in `find ./ -name "Sample_*" -type d |grep -v "Undetermined"|grep -v "Temp"`
do
 echo $i
 cd $i
 echo /usr/local/share/bioinfo/FastQC/fastqc \-o ./ \-f fastq \-\-nogroup \-\-casava \-t 4 \-\-extract *.gz;
 /usr/local/share/bioinfo/FastQC/fastqc -o ./ -f fastq --casava -t 4 --extract --nogroup *.gz;
 cd $dir
done

