#!/bin/bash
# Map paired end sequences on reference genome (hg19, RCRS or RSRS), sort and index bam file.
# The input files (prefix_{1,2}.fastq.gz) should be in the current folder.
# The output prefix.bam is saved in the the same folder. 

help=$(cat << EOF

Usage: ./`basename $0` id ref
	id: sample ID, which is the prefix of input (prefix_{1,2}.fastq.gz) and 
	    output files (prefix.bam). 
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

cpu=$(nproc --all)

declare -A REF=(
  [hg19]='/mnt/data/ref/hg19.fa'
  [RCRS]='/mnt/data/references/RCRS.fa'
  [RSRS]='/mnt/data/references/RSRS.fa')

isok () {
  if [ $1 -ne 0 ]; then
    echo -e "\n$2 wrong compilation!"
    exit 1
  fi 
}

# Check files
for i in 1 2; do
  file=${id}_${i}.fastq.gz
  [ -f $file ] || { echo "$file doesn't exist!"; exit 1; } 
done

[ -f ${REF[$refid]} ] || { echo "${REF[$refid]} doesn't exist!"; exit 1; }

# Start log and show input
cat << EOF | tee $id.log

Sample ID: $id
Reference: ${REF[$refid]}
EOF

# Align paired end sequences
echo -e "\n`date '+%T %d/%m/%Y'`: align,sort" | tee -a $id.log
bwa mem -M -t $cpu  ${REF[$refid]} ${id}_1.fastq.gz ${id}_2.fastq.gz  | samtools view -b -F 4 | samtools sort  -o  ${id}.bam
isok $? "align, sort bam"
# Index bam
echo -e "\n`date '+%T %d/%m/%Y'`: index bam" | tee -a $id.log
samtools index ${id}.bam
isok $? "index bam"
exit 0
