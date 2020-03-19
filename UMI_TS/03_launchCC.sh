#!/bin/bash
PROJ=$1
LIBTYPE="TS"
BASEDIR=/.mounts/labs/gsiprojects/dicklab/
PROV=/.mounts/labs/seqprodbio/private/backups/seqware_files_report_latest.tsv.gz
mem=80
DATADIR=$BASEDIR/$PROJ/data

if [[ -z $PROJ ]]; then
  echo "Provide project name"
  exit
fi

TSCC=$BASEDIR/$PROJ/MATS_devel/TGL_consensus_cruncher.sh
WKFLDIR=$DATADIR/$LIBTYPE/CASAVA

# OUTDIR=$DATADIR/$LIBTYPE/ConsensusCruncher
# use a temp scratch space for this sicne GSI advisory quota is exceeding now
OUTDIR=/scratch2/groups/gsi/bis/prath/MATS/ConsensusCruncher
echo $OUTDIR
if [[ ! -d $OUTDIR ]]; then mkdir -p $OUTDIR; fi
SCRP=$OUTDIR/script; mkdir -p $SCRP
LOGD=$OUTDIR/logs; mkdir -p $LOGD

DATADIR=$BASEDIR/$PROJ/data
libNames=`cat $DATADIR/$PROJ.tmp | cut -d\| -f14 | sort | uniq`

for miso in $libNames; do
  # echo "cat $DATADIR/$PROJ.tmp | grep $miso | grep \"CASAVA\" | cut -d\| -f14,31,47 | tr \"|\" \"\\t\" | sort"
  R1=`cat $DATADIR/$PROJ.tmp | grep $miso | grep "CASAVA" | cut -d\| -f14,18,19,31,47 | sort | head -1`
  R2=`cat $DATADIR/$PROJ.tmp | grep $miso | grep "CASAVA" | cut -d\| -f14,18,19,31,47 | sort | tail -1`
  run_name=`echo $R1 | cut -d\| -f3`
  R1_file=`echo $R1 | cut -d\| -f5`
  R2_file=`echo $R2 | cut -d\| -f5`
  patient_name=`echo $R1 | cut -d\| -f2 | tr ";" "\n" | head -1 | sed 's/geo_external_name=//g'`
  sample_name=`echo $R1 | cut -d\| -f2 | tr ";" "\n" | tail -n +2 | head -1 | sed 's/geo_group_id=//g'`
  # echo ${miso},${run_name},${patient_name},${sample_name},${R1_file},${R2_file}
  # ident

  ident_name="${PROJ}_${patient_name}_${sample_name}_${miso}_${run_name}"
  R1=$WKFLDIR/${ident_name}.R1.fastq.gz
  R2=$WKFLDIR/${ident_name}.R2.fastq.gz

  if [[ ! -f $R1 ]];then echo "$R1 non-exisitent"; fi
  if [[ ! -f $R2 ]];then echo "$R2 non-exisitent"; fi

  script=$SCRP/${ident_name}.CC.sh

  OUT=$OUTDIR/${sample_name}
  mkdir -p $OUT
  #launch script
  echo '#!/bin/bash' > ${script}
  echo "$TSCC $OUT $R1 $R2" >> ${script}
  chmod +x $script
  qsub -P gsi -V -l h_vmem=${mem}G -N ${ident_name}_CC -e ${LOGD} -o ${LOGD} ${script}
  # break
done
