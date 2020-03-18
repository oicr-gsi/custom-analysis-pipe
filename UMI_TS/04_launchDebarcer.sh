#!/bin/bash
PROJ=$1
LIBTYPE="TS"
BASEDIR=/.mounts/labs/gsiprojects/dicklab/
DEBARCER_SCRP=/.mounts/labs/gsiprojects/dicklab/MATS/MATS_devel/debarcer_sge.sh
# PROV=/.mounts/labs/seqprodbio/private/backups/seqware_files_report_latest.tsv.gz
mem=64
# DATADIR=$BASEDIR/$PROJ/data

if [[ -z $PROJ ]]; then
  echo "Provide project name"
  exit
fi

# TSCC=$BASEDIR/$PROJ/MATS_devel/TGL_consensus_cruncher.sh
# WKFLDIR=$DATADIR/$LIBTYPE/CASAVA

# OUTDIR=$DATADIR/$LIBTYPE/umiExtract
OUTDIR=/scratch2/groups/gsi/bis/prath/MATS/debarcer_out
# OUTDIR=
echo $OUTDIR
if [[ ! -d $OUTDIR ]]; then mkdir -p $OUTDIR; fi
SCRP=$OUTDIR/script; mkdir -p $SCRP
LOGD=$OUTDIR/logs; mkdir -p $LOGD

# DATADIR=$BASEDIR/$PROJ/data
DATADIR=/scratch2/groups/gsi/bis/prath/MATS/bwa_align
libNames=`cat $BASEDIR/$PROJ/data/$PROJ.tmp | cut -d\| -f14 | sort | uniq`

for miso in $libNames; do
  # echo "cat $DATADIR/$PROJ.tmp | grep $miso | grep \"CASAVA\" | cut -d\| -f14,31,47 | tr \"|\" \"\\t\" | sort"
  R1=`cat $BASEDIR/$PROJ/data/$PROJ.tmp | grep $miso | grep "CASAVA" | cut -d\| -f14,18,19,31,47 | sort | head -1`
  R2=`cat $BASEDIR/$PROJ/data/$PROJ.tmp | grep $miso | grep "CASAVA" | cut -d\| -f14,18,19,31,47 | sort | tail -1`
  run_name=`echo $R1 | cut -d\| -f3`
  R1_file=`echo $R1 | cut -d\| -f5`
  R2_file=`echo $R2 | cut -d\| -f5`
  patient_name=`echo $R1 | cut -d\| -f2 | tr ";" "\n" | head -1 | sed 's/geo_external_name=//g'`
  sample_name=`echo $R1 | cut -d\| -f2 | tr ";" "\n" | tail -n +2 | head -1 | sed 's/geo_group_id=//g'`
  # echo ${miso},${run_name},${patient_name},${sample_name},${R1_file},${R2_file}
  # ident

  ident_name="${PROJ}_${patient_name}_${sample_name}_${miso}"
  OUT=$OUTDIR/${PROJ}_${patient_name}/${sample_name}
  if [[ ! -d $OUT ]];then
    mkdir -p $OUT
  fi

  BAM=$DATADIR/${sample_name}.sorted.bam

  if [[ ! -f $BAM ]];then
    echo "$BAM non-existent";
  else
    script=$SCRP/${sample_name}.debarcer_run.sh
    echo '#!/bin/bash' > ${script}
    echo "${DEBARCER_SCRP} ${BAM} ${OUT} ${sample_name}" >> ${script}
    chmod +x ${script}
    qsub -V -l h_vmem=${mem}G -N ${sample_name}_debarcer -e ${LOGD} -o ${LOGD} ${script}
  fi
  # break
done
