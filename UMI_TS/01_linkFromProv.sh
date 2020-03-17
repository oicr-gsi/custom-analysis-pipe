#!/bin/bash
PROV=/.mounts/labs/seqprodbio/private/backups/seqware_files_report_latest.tsv.gz

PROJ=$1 # enter project name
LIBTYPE="TS"
BASEDIR=/.mounts/labs/gsiprojects/dicklab/

if [[ -z $PROJ ]]; then
  echo "please enter your project name to link all files"
else
  DATADIR=$BASEDIR/$PROJ/data
  if [[ ! -d $DATADIR ]]; then
    mkdir -p $DATADIR
  fi
  # first create a project prov record
  zgrep -w $PROJ $PROV | grep -w "$LIBTYPE"| tr "\t" "|" > $DATADIR/$PROJ.tmp
  # run name
  runName=`cat $DATADIR/$PROJ.tmp | cut -d\| -f19 | sort | uniq | grep -v "_M0"` # exclude all MiSeq runs
  # echo $runName
  for run in $runName; do
    cat $DATADIR/$PROJ.tmp | grep $run > tmp_$run.txt
    # for each run
  done
  cat tmp_*.txt > $DATADIR/$PROJ.tmp
  rm tmp_*.txt
  # check the workflows run so far
  workflowNames=`cat $DATADIR/$PROJ.tmp | cut -d\| -f31 | sort | uniq`
  # echo $workflowNames

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
    WKFLDIR=$DATADIR/$LIBTYPE/CASAVA
    if [[ ! -d WKFLDIR ]]; then mkdir -p $WKFLDIR; fi
    if [[ ! -f $WKFLDIR/${ident_name}.R1.fastq.gz ]]; then
      ln -sf ${R1_file} $WKFLDIR/${ident_name}.R1.fastq.gz
    fi
    if [[ ! -f $WKFLDIR/${ident_name}.R2.fastq.gz ]]; then
      ln -sf ${R2_file} $WKFLDIR/${ident_name}.R2.fastq.gz
    fi
    # bwamem
    bam=`cat $DATADIR/$PROJ.tmp | grep $miso | grep "BwaMem" | cut -d\| -f14,18,19,31,47 | grep "sorted.filter.deduped.realign.recal.bam" | grep -v "bai" | cut -d\| -f5`
    bam=`cat $DATADIR/$PROJ.tmp | grep $miso | grep "BwaMem" | cut -d\| -f14,18,19,31,47 | grep bai | cut -d\| -f5`
    echo $bam
    break
  done

  # for wkfl in $workflowNames; do
  #   if [[ $wkfl != "CASAVA" ]]; then
  #     continue
  #   fi
  #   WKFLDIR=$DATADIR/$wkfl
  #   if [[ ! -d WKFLDIR ]]; then mkdir -p $WKFLDIR; fi
  #   for miso in $libNames; do
  #     smp=`zgrep $miso $DATADIR/$PROJ.tmp | grep $wkfl | cut -d\| -f2,14,18,47 | sort | uniq`
  #     echo $smp
  #     deet=`echo $smp | cut -d\| -f3`
  #     # echo $deet
  #     patientName=`echo $deet | tr ";" "\n" | head -1 | sed 's/geo_external_name=//g'`
  #     sampleName=`echo $deet | tr ";" "\n" | tail -1 | sed 's/geo_tube_id=//g'`
  #     F1=`echo $smp | cut -d\| -f4 | grep "R1"`
  #     F2=`echo $smp | cut -d\| -f4 | grep "R2"`
  #     echo $miso,$patientName,$sampleName,$wkfl,$F1,$F2
  #     break
  #   done
  #   break
  # done



  # sample name
  # run name
  # Seqware/Niassa workflow
  # version of this workflow
  # File name

fi
