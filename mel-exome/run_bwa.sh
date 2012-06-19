#run bwa alignment, sort with sam tools and use picard to remove PCR duplicates.

#ALIGNMENT
#bwa aln -q 30 -t 7 /MEL/shared/GenomeFasta/hg19/hg19.fa  s_5_6_1_sequence.txt >  SRR309293_1.sai  
#bwa aln -q 30 -t 7 /MEL/shared/GenomeFasta/hg19/hg19.fa  s_5_6_2_sequence.txt  >  SRR309293_2.sai  

#TRANSFORM OUTPUT
#bwa sampe /MEL/shared/GenomeFasta/hg19/hg19.fa SRR309293_1.sai SRR309293_2.sai s_5_6_1_sequence.txt s_5_6_2_sequence.txt |gzip > SRR309293_bwa.sam.gz 
#bwa sampe -f SRR309293_bwa.sam -r "@RG\tID:EXOME1\tLB:EXOME1\tSM:EXOME1\tPL:ILLUMINA" /MEL/shared/GenomeFasta/hg19/hg19.fa SRR309293_1.sai SRR309293_2.sai s_5_6_1_sequence.txt s_5_6_2_sequence.txt

#SAM to BAM CONVERSIOn
#java -Xmx4g -Djava.io.tmpdir=/MEL/shared/tmp \
#-jar /MEL/bin/picard-tools-1.56/SortSam.jar \
#SO=coordinate \
#INPUT=SRR309293_bwa.sam \
#OUTPUT=SRR309293_bwa.bam \
#VALIDATION_STRINGENCY=LENIENT \
#CREATE_INDEX=true

#MARKING PCR DUPLICATES

#java -Xmx4g -Djava.io.tmpdir=/MEL/shared/tmp \
#-jar  /MEL/bin/picard-tools-1.56/MarkDuplicates.jar \
#INPUT=SRR309293_bwa.bam \
#OUTPUT=SRR309293_bwa.marked.bam \
#METRICS_FILE=metrics \
#CREATE_INDEX=true \
#VALIDATION_STRINGENCY=LENIENT


#LOCAL REALIGNMENT AROUND INDELS


#java -Xmx4g -jar  /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
#-T RealignerTargetCreator \
#-R /MEL/shared/GenomeFasta/hg19/hg19.fa \
#-o SRR309293_bwa.marked.bam.list \
#-I SRR309293_bwa.marked.bam

#java -Xmx4g -Djava.io.tmpdir=/MEL/shared/tmp \
#-jar  /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
#-I SRR309293_bwa.marked.bam \
#-R /MEL/shared/GenomeFasta/hg19/hg19.fa \
#-T IndelRealigner \
#-targetIntervals SRR309293_bwa.marked.bam.list \
#-o SRR309293_bwa.marked.realigned.bam

#java -Xmx4g -Djava.io.tmpdir=/MEL/shared/tmp \
#-jar /MEL/bin/picard-tools-1.56/FixMateInformation.jar \
#INPUT=SRR309293_bwa.marked.realigned.bam \
#OUTPUT=SRR309293_bwa_bam.marked.realigned.fixed.bam \
#SO=coordinate \
#VALIDATION_STRINGENCY=LENIENT \
#CREATE_INDEX=true

#QUALITY SCORE RECALIBRATION

#java -Xmx4g -jar  /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
#-l INFO \
#-R /MEL/shared/GenomeFasta/hg19/hg19.fa \
#--knownSites /MEL/hoonss/Projects/Exome/dbsnp/00-All_fixed.vcf \
#-I SRR309293_bwa_bam.marked.realigned.fixed.bam \
#-T CountCovariates \
#-cov ReadGroupCovariate \
#-cov QualityScoreCovariate \
#-cov CycleCovariate \
#-cov DinucCovariate \
#-recalFile input.recal_data.csv

#java -Xmx4g -jar  /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
#-l INFO \
#-R  /MEL/shared/GenomeFasta/hg19/hg19.fa \
#-I SRR309293_bwa_bam.marked.realigned.fixed.bam \
#-T TableRecalibration \
#--out SRR309293_bwa_bam.marked.realigned.fixed.recal.bam \
#-recalFile input.recal_data.csv



#SNP CALLING

java -Xmx4g -jar /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
-glm BOTH \
-R  /MEL/shared/GenomeFasta/hg19/hg19.fa \
-T UnifiedGenotyper \
-I SRR309293_bwa_bam.marked.realigned.fixed.recal.bam \
--dbsnp /MEL/hoonss/Projects/Exome/dbsnp/00-All_fixed.vcf \
-o snps.vcf \
-metrics snps.metrics \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-A DepthOfCoverage \
-A AlleleBalance \
-L /MEL/hoonss/Projects/Exome/dbsnp/exome.interval_list

#FILTER SNPS
java -Xmx4g -jar  /MEL/bin/GenomeAnalysisTK-1.3-17-gc62082b/GenomeAnalysisTK.jar \
-R /MEL/shared/GenomeFasta/hg19/hg19.fa \
--variant snps.vcf \
-T VariantFiltration \
-o snp.recalibrated.filtered.vcf \
--clusterWindowSize 10 \
--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
--filterName "HARD_TO_VALIDATE" \
--filterExpression "DP < 5 " \
--filterName "LowCoverage" \
--filterExpression "QUAL < 30.0 " \
--filterName "VeryLowQual" \
--filterExpression "QUAL > 30.0 && QUAL < 50.0 " \
--filterName "LowQual" \
--filterExpression "QD < 1.5 " \
--filterName "LowQD" \
--filterExpression "FS > 150 " \
--filterName "StrandBias"

#convert to vcf to annovar file format
perl /MEL/bin/annovar/convert2annovar.pl --format vcf4 --includeinfo snp.recalibrated.filtered.vcf > snp.annovar
#annotate
perl /MEL/bin/annovar/summarize_annovar.pl --verdbsnp 132 --buildver hg19 snp.annovar /MEL/bin/annovar/humandb -outfile snps



#samtools view -bS SRR309293_bwa.sam.gz | samtools sort - SRR309293_bwa_sorted
#java -jar /MEL/bin/picard-tools-1.56/MarkDuplicates.jar INPUT=SRR309293_bwa_sorted.bam OUTPUT=SRR309293_bwa_sorted.bam_rmdup.bam METRICS_FILE=PCR_duplicates REMOVE_DUPLICATES=true AS=true VALIDATION_STRINGENCY=LENIENT
