#!/bin/bash
# variant calling 


help=$(cat << EOF

Usage: ./`basename $0` id ref
        id: sample ID, which is the prefix of input (prefix.bam) and 
            output files (prefix.vcf). 
        ref: reference ID (hg19, RCRS, RSRS, default: hg19). 

EOF
)

# Check input
if [ -z $1 ] ; then
  echo "Sample ID is required! $help" && exit 1;
fi

# Initiate
id=$1
refid=${2:-hg19}

if [[  $refid !=  @(hg19|RCRS|RSRS)  ]] ; then
  echo "Unknown reference ID. $help" && exit 1;
fi

declare -A REF=(
  [hg19]='/mnt/data/ref/hg19.fa'
  [RCRS]='/mnt/data/references/RCRS.fa'
  [RSRS]='/mnt/data/references/RSRS.fa')

declare -a path=(
  [fb]='/PIPELINE/SOFTWARE/freebayes/bin/freebayes'
  [pc]='/mnt/data/picard/build/libs/picard.jar'
  [gatk]='/mnt/data/gatk/gatk' 
)

isok () {
  if [ $1 -ne 0 ]; then
    echo -e "\n$2 wrong compilation!"
    exit 1
  fi
}


# Check files
  file=${id}.bam
  [ -f $file ] || { echo "$file doesn't exist!"; exit 1; }
[ -f ${REF[$refid]} ] || { echo "${REF[$refid]} doesn't exist!"; exit 1; }

#renaming .bam
mv ${id}.bam ./${id}.tmp.bam
mv ${id}.bam.bai ./${id}.tmp.bam.bai

# Start log and show input
cat << EOF | tee $id.log

Sample ID: $id
Reference: ${REF[$refid]}
EOF

# Marking duplicates with picard
echo -e "\n`date '+%T %d/%m/%Y'`: mark duplicates" | tee -a $id.log
java -jar ${path[pc]} MarkDuplicates I=${id}.tmp.bam O=${id}.bam M=${id}.DuplicatesInfo.txt
isok $? "mark duplicates"

#Variant calling
echo -e "\n`date '+%T %d/%m/%Y'`: variant calling by freebayes" | tee -a $id.log
${path[fb]} -f  ${REF[$refid]} -p 1 ${id}.bam > ${id}.tmp.vcf
isok $? "variant calling"

# left-align
echo -e "\n`date '+%T %d/%m/%Y'`: left align" | tee -a $id.log
${path[gatk]}LeftAlignAndTrimVariants -V ${id}.tmp.vcf -R  ${REF[$refid]}  -O ${id}.vcf -no-trim
isok $? "left align"

rm -rf *.tmp.*
exit 0
