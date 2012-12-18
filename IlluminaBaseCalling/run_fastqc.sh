# This is to run fastqc for quality statistics
# version used :10.0.1
# This fastqc can be directly used on bcltofastq output directory,
# as this can summarize all the files of same sample as one.

for i in $(ls -d ./Sample_*)
do
 echo $i
 cd $i
 echo /usr/local/share/bioinfo/FastQC/fastqc \-o ./ \-f fastq \-\-nogroup \-\-casava \-t 4 \-\-extract *.gz;
 /usr/loacl/share/bioinfo/FastQC/fastqc -o ./ -f fastq --casava -t 4 --extract --nogroup *.gz;
 cd ../
done

