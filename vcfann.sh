#!/bin/bash
# Annotate VCF file with snpEff using library built on RCRS references.

. ./conf.sh

help=$(cat << EOF

Usage: ./`basename $0` id
        id: sample ID, which is the prefix of input (prefix.vcf) and 
            output files (prefix_ann.vcf). 
     
EOF
)
# Check input
if [ -z $1 ] ; then
  echo "Sample ID is required! $help" && exit 1;
fi

#Initiate
id=$1

isok () {
  if [ $1 -ne 0 ]; then
    echo -e "\n$2 wrong compilation!"
    exit 1
  fi
}

# Check files
  file=${id}.vcf
  [ -f $file ] || { echo "$file doesn't exist!"; exit 1; }

# Start log and show input
cat << EOF | tee $id.log
Sample ID: $id
EOF
#Changing chromosome name in input file
echo -e "\n`date '+%T %d/%m/%Y'`: preparing input vcf" | tee -a $id.log
mv ${id}.vcf ${id}.tmp.vcf 
cat ${id}.tmp.vcf | sed "s/^NC_012920.1/NC_012920/" > ${id}2.tmp.vcf

# Annotating vcf
echo -e "\n`date '+%T %d/%m/%Y'`: annotating vcf with snpEff" | tee -a $id.log
java -jar ${path[snpeff]} RCRS ${id}2.tmp.vcf >${id}.vcf

# Cleaning tmp files
rm -rf *.tmp.*
