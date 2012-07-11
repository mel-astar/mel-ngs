Steps for Trinity Mannual on axle server
-------------------------------------------
Pre-Inchworm:
--------------

After you ready with the reads fastq files.
Run perl pre_inchworm.pl

This script will form generate the lsf file and submit it to the axle
process done in this step are:

fastq->fasta conversion based on RF and FR strand-specific protocol
and they both are concatenated into a single both.fa file


Inchworm
-----------

filename: inchworm.lsf

change the filepaths in the iw.lsf file

Chrysalis
--------------
filename: *.chry.lsf

As the maximum running time for normal queue is 72 hrs(3days), mostly
chrysalis get halted in its last step(Quantify Graph)

So for the rest of the process, it shuld be runned manually

Steps for running rest of the chrysalis manually:
 
 1) Count the no of RawComps 
 2) in the program temp.pl, edit the for loop limit to total no of RawComps
    folder count 
    - Each of the RawComps can hold up to 20000 components (starting from 0)
 3) Run the prog temp.pl, gives the output of component range within each
    RawComps folder
 4) Now notedown at which component chrysalis had halted (look into the
    chrysalis.out file)
 5) Also in the butterfly_command file, not all the commands for all
    componenets will be filled up, so use man_butt.sh script to generate
    butterfly commands (remmber to store the parameters of butterfly from all
    aready generated butterfly_commands file)
    -Also if you want to print the final trinity_transcripts with FPKM values,
     need to use the trinity-r20110519 version 
 6) Now you can use of temp1.lsf and rest of the temp files to run chrysalis
    after editing them respectively
 
Butterfly
--------------
1) If you are making use of trinity-r20110519 donot edit the
dispatch_axle-New.pl , if you are using any other trinity latest packe, then
remove -compatile_path_ectension from $btfly_options variable(in the start of
program)

2) run butt1.lsf

3) after completeion of butt1.lsf job 
4) run 4.butt.lsf



