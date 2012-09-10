# This is to run fastqc for quality statistics
# version used :10.0.1
# This fastqc can be directly used on bcltofastq output directory,
# as this can summarize all the files of same sample as one.

/path/to/fastqc -o ./ -f fastq --casava -t 4 --extract *.gz;

