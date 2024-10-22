FROM ubuntu:22.04 AS pseudo-refmap
RUN apt-get update && apt-get install -y \
    python3 \
    samtools \
    openjdk-17-jre-headless \
    wget \
    g++ \
    zlib1g-dev \
    make \
    unzip \
    perl \
    libsys-hostname-long-perl \
    tabix \
&& rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/broadinstitute/picard/releases/download/3.2.0/picard.jar
RUN mv picard.jar /usr/local/bin/picard.jar && \
    echo '#!/bin/bash' > picard && \
    echo 'java -jar /usr/local/bin/picard.jar "$@"' >> picard && \
    chmod +x picard && \
    mv picard /usr/local/bin/ && \
    picard SortSam --version || exit 0

RUN wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip
RUN unzip gatk-4.6.0.0.zip && \
    mv gatk-4.6.0.0/gatk-package-4.6.0.0-local.jar /usr/local/bin/ && \
    rm -r gatk-* && \
    echo '#!/bin/bash' > gatk && \
    echo 'java -jar /usr/local/bin/gatk-package-4.6.0.0-local.jar "$@"' >> gatk && \
    chmod +x gatk && \
    mv gatk /usr/local/bin/ && \
    gatk --version

RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.2/bowtie2-2.4.2-sra-linux-x86_64.zip/download
RUN unzip download && \
    mv bowtie2-2.4.2-sra-linux-x86_64/bowtie2* /usr/local/bin/ && \
    rm -r bowtie2-2.4.2-sra-linux-x86_64 download && \
    bowtie2 --version

RUN wget https://catchenlab.life.illinois.edu/stacks/source/stacks-2.66.tar.gz
RUN tar xfvz stacks-2.66.tar.gz && \
    cd stacks-2.66 && \
    ./configure && \
    make && \
    make install && \
    cd .. && rm -rf stacks-2.66 stacks-2.66.tar.gz && \
    denovo_map.pl -v || exit 0
