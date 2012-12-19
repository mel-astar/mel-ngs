After Running run_chipseq.pl


Step1) Get Total No of Reads (Using Linux grep -c command or any other utility)


Step2) Calculate No of Uniquely Mapped reads:
 
        sh getMappedReads.sh

Step3) Calculate NRF (Non Redundant Fraction)
 
        a) Convet bam files to bed using bamtobed utility from bedtools 

	      sh run_bamtobed.sh

        b) Calculate NRF 

              perl CalbedNRF.pl

Step4) Report No of peaks identified by macs14.

       To get peaks for control samples, run macs14 usign control as treatment and then report no of peaks

Step5) Calculate NSC and RSC strand cross correlation

        sh get_nscRSC.sh 

Step6) Calculate FRiP (Fraction of Reads in peaks)

        a) get reads overlapping in peaks (atleast by 20%) using intersectbed from bedtools

            sample cmd: intersectBed -a /path/to/Sample_bamtobed.bed -b /path/to/macs/peaks.bed -c -f 0.20  >Output.intersectBed 
        
        b) summup reads mapped to peaks from Output.intersectBed output
 
            perl getCnt.pl 



All these metrics are tabulate with following coloumns

SampleName #NoOfReads #NoOfUniquelyMappedReads NRF NSC RSC FRiP IDR 
