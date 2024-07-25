#! /bin/bash

samtools faidx reference/catalog.fa.gz

picard CreateSequenceDictionary \
    -R reference/catalog.fa.gz \
    -O reference/catalog.dict

bowtie2-build reference/catalog.fa.gz reference/catalog.fa.gz

mkdir mapped
mkdir alignment_metrics
mkdir sorted
mkdir mappedSortGroup
mkdir realigned
mkdir ref_map
mkdir populations

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
    
    echo "Adding ReadGroups to $SAMPLE_NAME"
    picard AddOrReplaceReadGroups \
      -I sorted/${SAMPLE_NAME}.bam \
      -O mappedSortGroup/${SAMPLE_NAME}.bam \
      -RGID ${SAMPLE_NAME}.bam \
      -RGLB ${SAMPLE_NAME}.bam \
      -RGPL illumina \
      -RGPU ${SAMPLE_NAME}.bam \
      -RGSM ${SAMPLE_NAME}.bam
    
    echo "Indexing $SAMPLE_NAME"
    samtools index mappedSortGroup/${SAMPLE_NAME}.bam

    echo "Realigning $SAMPLE_NAME"
    gatk LeftAlignIndels \
      -R reference/catalog.fa.gz \
      -I mappedSortGroup/${SAMPLE_NAME}.bam \
      -O realigned/${SAMPLE_NAME}.bam
done < popmap

ref_map.pl --popmap popmap -o ref_map --samples realigned/

cat ref_map/populations.sumstats.tsv | \
  grep -v "^#" | \
  cut -f 1,4 | \
  sort -n | \
  uniq | \
  cut -f 1 | \
  uniq -c | \
  awk '$1 <= 10 {print $2}' > whitelist_refmap

populations --in-path ref_map/ \
  --out-path populations/ \
  --popmap popmap \
  -R 0.5 \
  --min-mac 3 \
  --vcf \
  --write-random-snp \
  -W whitelist_refmap
