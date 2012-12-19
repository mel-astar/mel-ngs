for i in $(ls ./*.bam)
do
 echo $i;
 bamToBed -i $i >${i%.bam}_bamtobed.bed 
done

