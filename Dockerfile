FROM ubuntu:22.04 AS pseudo-refmap
RUN apt-get update && apt-get install -y \
    python3 \
    samtools \
    openjdk-17-jre-headless \
    wget \
    g++ \
    zlib1g-dev \
    make \
&& rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/broadinstitute/picard/releases/download/3.2.0/picard.jar && \
    mv picard.jar /usr/local/bin/picard.jar && \
    echo '#!/bin/bash' > picard && \
    echo 'java -jar /usr/local/bin/picard.jar "$@"' >> picard && \
    chmod +x picard && \
    mv picard /usr/local/bin/ && \
    picard SortSam --version || exit 0

RUN wget https://github.com/broadinstitute/gatk/releases/download/4.6.0.0/gatk-4.6.0.0.zip
RUN unzip gatk-4.6.0.0.zip
RUN cd gatk-4.6.0.0
RUN mv gatk-package-4.6.0.0-local.jar /usr/local/bin/
RUN cd ..
RUN rm -r gatk-*
RUN echo '#!/bin/bash' > gatk
RUN echo 'java -jar /usr/local/bin/gatk-package-4.6.0.0-local.jar "$@"' >> gatk
RUN chmod +x gatk
RUN mv gatk /usr/local/bin/
