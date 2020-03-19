#!/bin/bash
module use /.mounts/labs/PDE/Modules/modulefiles
module load python-gsi/3.6.4

BAM=$1
OUTDIR=$2
# NAME=$3

REF=/.mounts/labs/resit/modulator/sw/data/hg38-p12/hg38_random.fa
# debarcer installation
DEBARCER=/.mounts/labs/gsiprojects/dicklab/MATS/tools/debarcer/debarcer
# obtain bed
BED=/.mounts/labs/gsiprojects/dicklab/MATS/MATS_devel/interval.bed

for region in `cat $BED | tr "\t" ","`; do
  chrom=`echo $region | cut -d, -f1`
  spos=`echo $region | cut -d, -f2`
  epos=`echo $region | cut -d, -f3`
  REG="$chrom:$spos-$epos"

  python3 ${DEBARCER}/debarcer.py group \
    -o $OUTDIR \
    -b $BAM \
    -r "$REG" \
    -p 10 \
    -d 1 \
    -i False \
    -t False

  python3 ${DEBARCER}/debarcer.py collapse \
    -o $OUTDIR \
    -b $BAM \
    -r "$REG" \
    -u $OUTDIR/Umifiles/$REG.json \
    -f "1,2,3,5,10" \
    -ct 1 \
    -pt 50 \
    -p 10 \
    -m 1000000 \
    -t False \
    -i False \
    -stp nofilter

  break
done

# #
# # run debarcer
# python3 ${DEBARCER}/debarcer.py run \
#   -o ${OUTDIR} \
#   -b ${BAM} \
#   -rf ${REF} \
#   -f "1,2,3,5,10" \
#   -bd ${BED} \
#   -ct 1 \
#   -pt 50 \
#   -p 10 \
#   -d 1 \
#   -rt 95 \
#   -at 2 \
#   -ft 10 \
#   -ex png \
#   -sp ${NAME} \
#   -db ${DEBARCER}/debarcer.py
#
