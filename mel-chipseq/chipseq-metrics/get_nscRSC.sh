# This bash script runs run_spp.R from phantonpeaks package for all the bam files in current directory

for i in $(ls ./*.bam)
do
 echo $i
 Rscript /usr/local/share/bioinfo/spp_package/run_spp.R -c=$i -savp -out=${i%.bam}.spp.out
done
