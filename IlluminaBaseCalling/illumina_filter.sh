for s in $(ls -d Sample*)
do
 echo "Working for Sample $s\n"
 echo mkdir "$s/Filtered";
 mkdir "$s"/Filtered;
 cd  $s;
 for i in $(ls *fastq.gz)
 do
  echo gunzip \-c $i\|fastq_illumina_filter \-vvN\|gzip \> Filtered/$i ;
  gunzip -c $d/$i|fastq_illumina_filter -vvN|gzip > Filtered/$i; 
 done
 cd ../
done
