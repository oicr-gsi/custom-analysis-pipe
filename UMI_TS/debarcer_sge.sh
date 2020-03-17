#!/bin/bash
module use /.mounts/labs/PDE/Modules/modulefiles
module load python-gsi/3.6.4

BAM=$1
OUTDIR=$2
NAME=$3


REF=/.mounts/labs/resit/modulator/sw/data/hg38-p12/hg38_random.fa
# debarcer installation
DEBARCER=/.mounts/labs/gsiprojects/dicklab/MATS/tools/debarcer

# obtain bed
BED=${OUTDIR}/${NAME}.bed
if [[ ! -f ${BED} ]]; then
  python3 ${DEBARCER}/debarcer.py bed -b ${BAM} -bd ${BED} -io -mv 1
fi

#
# run debarcer
python3 ${DEBARCER}/debarcer.py run \
  -o ${OUTDIR} \
  -b ${BAM} \
  -rf $REF \
  -f "1,2,3,5,10" \
  -bd ${BED} \
  -ct 1 \
  -pt 50 \
  -p 10 \
  -d 1 \
  -rt 95 \
  -at 2 \
  -ft 10 \
  -ex png \
  -sp ${NAME} \
  -db ${DEBARCER}/debarcer.py
#
