#usage:  sh bamToBigWig.sh bam_file genome_chrom_info_file
#e.g. sh ~/data/JLoh_Chip-SEQ/02_bowtie_align/Jloh-INPUT_NoIndex_L004_R1.bam mm9.chrom.sizes
bamToBed -i $1  > $1.bed
genomeCoverageBed -i $1.bed -bg -g $2 > sample.cov
bedGraphToBigWig  sample.cov  $2 $1.bw
