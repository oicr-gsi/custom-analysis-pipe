#!/bin/bash
PROJ=$1
LIBTYPE="TS"
BASEDIR=/.mounts/labs/gsiprojects/dicklab/
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
OUTDIR=/scratch2/groups/gsi/bis/prath/MATS/bwa_align
# OUTDIR=
echo $OUTDIR
if [[ ! -d $OUTDIR ]]; then mkdir -p $OUTDIR; fi
SCRP=$OUTDIR/script; mkdir -p $SCRP
LOGD=$OUTDIR/logs; mkdir -p $LOGD

# DATADIR=$BASEDIR/$PROJ/data
DATADIR=/scratch2/groups/gsi/bis/prath/MATS/umiExtract
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
  R1=`ls $DATADIR/${ident_name}*.R1.umi.fastq.gz | tr " " ","`
  R2=`ls $DATADIR/${ident_name}*.R2.umi.fastq.gz | tr " " ","`

  # if [[ ! -f $R1 ]];then echo "$R1 non-exisitent"; fi
  # if [[ ! -f $R2 ]];then echo "$R2 non-exisitent"; fi

  # OUTBAM=$OUTDIR/${sample_name}.bam

  script=$SCRP/${ident_name}.bwa_align.sh
  #launch script
#   REF=/oicr/data/genomes/homo_sapiens_mc/UCSC/hg19_random/Genomic/bwa/0.7.12/hg19_random.fa
# CMD1="bwa mem $REF $R1 $R2 | samtools view -b > output.bam"
# qsub -cwd -b y -N jobname -e logs -o logs -l h_vmem=12g "module load bwa/0.7.12;module load samtools;$CMD1"
#
# CMD2="samtools sort output.bam > output.sorted.bam"
# qsub -cwd -b y -N jobname2 -hold_jid jobname -e logs -o logs -l h_vmem=12g "module load samtools;$CMD2"

  echo '#!/bin/bash' > ${script}
  echo "export MODULEPATH=/.mounts/labs/resit/modulator/modulefiles/data:/.mounts/labs/resit/modulator/modulefiles/Ubuntu18.04:/.mounts/labs/gsi/modulator/modulefiles/data:/.mounts/labs/gsi/modulator/modulefiles/Ubuntu18.04" >> ${script}
  echo "module load bwa/0.7.17" >> ${script}
  echo "module load samtools">> ${script}
  echo "module load hg38-bwa-index/0.7.17" >> ${script}
  echo "bwa mem \$HG38_BWA_INDEX_ROOT/hg38_random.fa $R1 $R2 | samtools view -b > $OUTDIR/${sample_name}.bam" >> ${script}
  echo "samtools sort $OUTDIR/${sample_name}.bam -o $OUTDIR/${sample_name}.sorted.bam" >> ${script}
  echo "samtools index $OUTDIR/${sample_name}.sorted.bam" >> ${script}
  echo "rm $OUTDIR/${sample_name}.bam" >> ${script}
  chmod +x ${script}
  if [[ ! -f $OUTDIR/${sample_name}.sorted.bam ]]; then
    qsub -P gsi -V -l h_vmem=${mem}G -N ${ident_name}_bwa -e ${LOGD} -o ${LOGD} ${script}
  fi
  # break
done
