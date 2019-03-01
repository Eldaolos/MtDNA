#!/bin/bash/
#Paths
declare -A REF=(
  [hg19]='/mnt/data/ref/hg19.fa'
  [RCRS]='/mnt/data/references/RCRS.fa'
  [RSRS]='/mnt/data/references/RSRS.fa')

declare -a path=(
  [fb]='/PIPELINE/SOFTWARE/freebayes/bin/freebayes'
  [pc]='/mnt/data/picard/build/libs/picard.jar'
  [gatk]='/mnt/data/gatk/gatk' 
  [snpeff]='/mnt/data/snpEff/snpEff.jar'
)

