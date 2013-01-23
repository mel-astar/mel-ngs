# Converiting BED files into bigWig format
-------------------------------------------

Step 1) convert bam/bed To bedGraph (Bedtools)

 	genomeCoverageBed -ibam <bamFile> -g <user.genome> -bg >Output.bedGraph

Step 2) convert bedGraph to bigWig (UCSC executables)

       bedGraphToBigWig <bedGraph file> <chrom.sizes> <bigWig output> 

       if no chrom.sizes, run fetchChromSizes (UCSC exec) to get sizes.

# Converting bam files into Wiggle files
-----------------------------------------

Using igvtools sample command:

	igvtools count -e 100 -w 25 input.bam output.cov.tdf,output.cov.wig  hg19
 
      Input bam file should ne indexed.
