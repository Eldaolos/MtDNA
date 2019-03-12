#!/bin/bash
# Wrapper script to identify haplogroup from vcf file based on HaploGrep. 

help=$(cat << EOF

Usage: ./`basename $0` <in> <out> 
        in: path/to/filename.vcf
	out: path/to/filename.txt to save HaploGrep output

EOF
)

# Check two arguments are provided
if [ "$#" -ne 2 ] ; then
  echo "Wrong number of arguments! $help"
  
fi

# Initiate 
in=$1
out=$2
nc=`nproc --all`

declare -A path=(
  [htslib]='/PIPELINE/SOFTWARE/htslib-1.6/'
  [haplogrep]='/PIPELINE/SOFTWARE/haplogrep/haplogrep-2.1.19.jar'
  [bcftools]='/PIPELINE/SOFTWARE/bcftools-1.8/bin/bcftools'
)


isok () {
  if [ $1 -ne 0 ]; then
    echo -e "$2 wrong compilation!\n"
    exit 1
  fi
}

# Check vcf file exists
[ -f $in ] || { echo "$in doesn't exist!"; exit 1; }

# Compress vcf and index
${path[htslib]}/bgzip -c -@ $nc $in > tmp.vcf.gz
${path[htslib]}/tabix tmp.vcf.gz

# Subset variants at mtDNA
${path[bcftools]} view tmp.vcf.gz --threads $nc -r chrM tmp.vcf.gz > tmp.vcf

# Identify haplogroup
java -jar ${path[haplogrep]} --in tmp.vcf --format vcf --extend-report --hits 3 --out $out
isok $? "haplogrep"

# Clean
rm tmp*

exit 0
