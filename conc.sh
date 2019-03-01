#!/bin/bash
# Concatenate *_{1,2}.fq.gz files in current folder.
# Save the ouput as id_{1,2}.fastq.gz in current folder.

help=$(cat << EOF

Usage: `basename $0` id
        id: output filename prefix

EOF
)

# Check input
[ -z $1 ] && { echo "Missing output filename prefix! $help"; exit 1; }

# Initilize
id=$1

conc(){
  input=`ls *_${1}.fq.gz`
  output=${2}_${1}.fastq.gz
  echo "Concatinating..."
  echo $input
  echo "to"
  echo -e "$output\n"
  cat $input > $output
}

export -f conc

# Show input
cat << EOF

Sample: $id

EOF

# Concatenate in parallel
parallel conc {} $id ::: 1 2

echo "All done!"

