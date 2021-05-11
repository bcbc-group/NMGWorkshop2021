#!/bin/sh
###############################################################
# pipeline for running hisat2 on paired end files   #
#                                                             #
# usage:                                                      #
#                                                             #
#      hisat_pe_annot.sh $base_dir $CPU                       #
#                                                             #
###############################################################

cd $1
CPU=$2

#make a dir for your output and symlink some files there
mkdir /scratch/annotation_output
cd /scratch/annotation_output
cp /scratch/Botany2020NMGWorkshop/annotation/2transfer/contig_15.fasta .
ln -s /scratch/Botany2020NMGWorkshop/annotation/2transfer/*.fastq .

#index reference fasta file; We will use only contig_15 for demo purposes
 /opt/hisat-genotype-top/hisat2-build contig_15.fasta contig_15

#map RNA-seq reads to reference genome fasta file
for file in `dir -d *_1.fastq` ; do

    samfile=`echo "$file" | sed 's/_1.fastq/.sam/'`
    file2=`echo "$file" | sed 's/_1.fastq/_2.fastq/'`

     /opt/hisat-genotype-top/hisat2 --max-intronlen 100000 --dta -p $CPU -x contig_15 -1 $file -2 $file2 -S $samfile

done

ls *.sam |parallel --gnu -j $CPU samtools view -Sb -o {.}.bam {}
ls *.bam |parallel --gnu -j $CPU samtools sort -o {.}.sort.bam {}

#run stringtie to get gtf files of transcript annotations
for file in `dir -d *sort.bam` ; do

    outdir=`echo "$file" |sed 's/.bam/.gtf/'`

    /opt/stringtie/stringtie --rf -p $CPU -o $outdir $file

done
