#!/bin/bash
# module use /.mounts/labs/PDE/Modules/modulefiles
export MODULEPATH=/.mounts/labs/resit/modulator/modulefiles/data:/.mounts/labs/resit/modulator/modulefiles/Ubuntu18.04:/.mounts/labs/gsi/modulator/modulefiles/data:/.mounts/labs/gsi/modulator/modulefiles/Ubuntu18.04

module load samtools/1.9
module load python/3.6
module load picard/2.21.2
module load rstats/3.6
module load bwa/0.7.17
module load hg38-bwa-index/0.7.17
#
export PYTHONPATH=/u/prath/bin/py3:$PYTHONPATH

# module load python-gsi/3.6.4
# module load samtools/1.2
# module load bowtie/2.1.0
# module load picard/2.4.1
# module load R-gsi/3.5.1

OUTDIR=$1
# name=$2
R1=$2
R2=$3
#tool dirxwx
crunch="/.mounts/labs/TGL/gsi/tools/ConsensusCruncher/"

# needed stuff
bwa=`which bwa`
bwaref=$HG38_BWA_INDEX_ROOT/hg38_random.fa
cytoband=/.mounts/labs/gsiprojects/dicklab/MATS/tools/ConsensusCruncher/ConsensusCruncher/hg38_cytoBand.txt
samtools=`which samtools`
blist=/.mounts/labs/gsiprojects/dicklab/MATS/tools/ConsensusCruncher/kits/IDT_duplex_sequencing_barcodes.list
genome=hg38
cutoff=0.7
name=".R"
filename=$(basename $R1 | sed 's/.R1.*//')

# if consensuscruncher exists, remove it
if [[ -d $OUTDIR/5_consensuscruncher ]]; then rm -rf $OUTDIR/5_consensuscruncher; fi

cd $OUTDIR

mkdir -p 5_consensuscruncher

# step 5: run ConsensusCruncher
echo "running fastq2bam"
python3 $crunch/ConsensusCruncher.py fastq2bam \
        --fastq1 $R1 \
        --fastq2 $R2 \
        --output $OUTDIR/5_consensuscruncher \
        --name $name \
        --bwa $bwa \
        --ref $bwaref \
        --samtools $samtools \
    	  --skipcheck \
        --blist $blist

# consensus
echo "running consensus"
python3 $crunch/ConsensusCruncher.py consensus \
        --input $OUTDIR/5_consensuscruncher/bamfiles/$filename.sorted.bam \
        --output $OUTDIR/5_consensuscruncher/consensus \
        --samtools $samtools \
        --cutoff $cutoff \
        --genome $genome \
        --bedfile $cytoband \
        --bdelim '|'
