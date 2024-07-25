#! /bin/bash

samtools faidx catalog.fa.gz

picard CreateSequenceDictionary \
    -R catalog.fa.gz \
    -O catalog.fa.gz.dict

bowtie2-build catalog.fa.gz catalog.fa.gz

mkdir mapped
mkdir alignment_metrics

while IFS= read -r LINE; do
    SAMPLE_NAME=$(echo "$LINE" | cut -f1)

    echo "Mapping $SAMPLE_NAME"
    bowtie2 --omit-sec-seq \
    --met-file alignment_metrics/${SAMPLE_NAME}.log \
    -x reference/catalog.fa.gz \
    -U samples/${SAMPLE_NAME}.fq.gz \
    -S mapped/${SAMPLE_NAME}.sam
done < popmap
