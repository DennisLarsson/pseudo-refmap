#! /bin/bash

samtools faidx test_catalog.fa.gz

picard CreateSequenceDictionary \
    -R test_catalog.fa.gz \
    -O test_catalog.fa.gz.dict

bowtie2-build test_catalog.fa.gz test_catalog.fa.gz
