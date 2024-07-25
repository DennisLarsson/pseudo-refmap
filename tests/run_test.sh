#! /bin/bash

samtools faidx test_catalog.fa.gz

picard CreateSequenceDictionary \
    -R test_catalog.fa.gz \
    -O test_catalog.fa.gz.dict

bowtie2-build test_catalog.fa.gz test_catalog.fa.gz

mkdir mapped
mkdir alignment_metrics

while IFS= read -r LINE; do
    SAMPLE_NAME=$(echo "$LINE" | cut -f1)

    echo "Mapping \$SAMPLE_NAME"
    "bowtie2 --omit-sec-seq \
    --met-file alignment_metrics/\${SAMPLE_NAME}.log \
    -x reference/catalog.fa.gz \
    -U test_samples/\${SAMPLE_NAME}.fq.gz \
    -S mapped/\${SAMPLE_NAME}.sam
done < popmap_test
