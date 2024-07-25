#! /bin/bash

mkdir reference
samtools faidx reference/catalog.fa.gz

picard CreateSequenceDictionary \
    -R reference/catalog.fa.gz \
    -O reference/catalog.fa.gz.dict

bowtie2-build reference/catalog.fa.gz reference/catalog.fa.gz

mkdir mapped
mkdir alignment_metrics
mkdir sorted

while IFS= read -r LINE; do
    SAMPLE_NAME=$(echo "$LINE" | cut -f1)

    echo "Mapping $SAMPLE_NAME"
    bowtie2 --omit-sec-seq \
      --met-file alignment_metrics/${SAMPLE_NAME}.log \
      -x reference/catalog.fa.gz \
      -U samples/${SAMPLE_NAME}.fq.gz \
      -S mapped/${SAMPLE_NAME}.sam
    
    echo "sorting $SAMPLE_NAME"
    picard SortSam \
      -I mapped/${SAMPLE_NAME}.sam \
      -O sorted/${SAMPLE_NAME}.bam \
      -SO coordinate
done < popmap
