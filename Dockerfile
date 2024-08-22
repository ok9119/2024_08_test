FROM ubuntu:22.04

# install samtools, htslib, bcftools dependencies + libdeflate
RUN apt-get update && apt-get install \
        -y autoconf \
           build-essential \
           libbz2-dev \
           libcurl4-openssl-dev \
           libdeflate-dev \
           libgsl-dev \
           liblzma-dev \
           libncurses-dev \
           libssl-dev \
           perl \
           pkg-config \
           python3-pip \
           wget \
           zlib1g-dev &&\
    apt-get clean && apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV SOFT=/soft

WORKDIR $SOFT
RUN wget https://github.com/samtools/samtools/releases/download/1.20/samtools-1.20.tar.bz2 &&\
    tar jxf samtools-1.20.tar.bz2 && \
	rm samtools-1.20.tar.bz2 && \
	cd samtools-1.20 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=$PATH:$SOFT/samtools-1.20 
ENV SAMTOOLS=$SOFT/samtools-1.20 

RUN wget https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2 &&\
    tar jxf htslib-1.20.tar.bz2 && \
	rm htslib-1.20.tar.bz2 && \
	cd htslib-1.20 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=$PATH:$SOFT/htslib-1.20
ENV HTSLIB=$SOFT/htslib-1.20

RUN wget https://github.com/samtools/bcftools/releases/download/1.20/bcftools-1.20.tar.bz2 &&\
    tar jxf bcftools-1.20.tar.bz2 && \
	rm bcftools-1.20.tar.bz2 && \
	cd bcftools-1.20 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=$PATH:$SOFT/bcftools-1.20
ENV BCFTOOLS=$SOFT/bcftools-1.20

RUN wget https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz &&\
    tar xvzf vcftools-0.1.16.tar.gz && \
	rm vcftools-0.1.16.tar.gz && \
	cd vcftools-0.1.16 && \
	./configure --prefix $(pwd) && \
	make && \
    make clean

ENV PATH=$PATH:$SOFT/vcftools-0.1.16/bin
ENV VCFTOOLS=$SOFT/vcftools-0.1.16/bin

RUN pip3 install -U numpy pandas pysam datetime pathlib argparse

WORKDIR $SOFT/scripts

COPY ./csp3_sep_chrom_ref.py $SOFT/scripts
COPY ./csp3_single_ref.py $SOFT/scripts

RUN chmod +x ./csp3_sep_chrom_ref.py
RUN chmod +x ./csp3_single_ref.py

COPY ./FP_SNPs.txt $SOFT/scripts
COPY ./FP_SNPs_10k_GB38_twoAllelsFormat.tsv $SOFT/scripts

#COPY /mnt/data/ref/GRCh38.d1.vd1_mainChr/sepChrs/ /ref/GRCh38.d1.vd1_mainChr/sepChrs/

EXPOSE 8080
