# This is to run fastqc for quality statistics
# version used :10.0.1
# This fastqc can be directly used on bcltofastq output directory,
# as this can summarize all the files of same sample as one.

/path/to/fastqc -o ./ -f fastq --casava -t 4 --extract *.gz;



##### bash script for running fastq in all the sample within a Project_FC folder


for s in $(ls -d Sample_*)
do
 echo "Working on $s";
 cd $s;
 echo fastqc \-f fastq \-\-casava \-t 4 \-\-extract *.fastq.gz;
 fastqc -f fastq --casava -t 4 --extract *.fastq.gz 
 cd ../
done

   
   #-t is the no of threads. 


