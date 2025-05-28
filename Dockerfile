FROM ubuntu:20.04

WORKDIR /home/

RUN apt-get update --fix-missing && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata && \
    apt-get install -y \
        unzip \
        build-essential \
        zlib1g-dev \
        autoconf \
        automake \
        libtool \
        libncurses5-dev \
        make \
        pkg-config \
        libbz2-dev \
        liblzma-dev \
        libcurl4-openssl-dev \
        cmake \
        libssl-dev \
        python3 \
        python3-dev \
        python3-pip \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY htslib-1.21.tar.bz2 .
COPY build_htslib.sh .
RUN ./build_htslib.sh

COPY CMakeLists.txt ./
COPY *.h ./
COPY *.cpp ./
ADD libs ./libs

RUN cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo . && make

RUN pip3 install --no-cache-dir cython && \
    pip3 install --no-cache-dir --verbose \
        "pysam==0.16.0.1" \
        "pyfaidx==0.5.9.1" \
        "numpy==1.21.2" \
        scikit-learn

COPY random_pos_generator.py survindel2.py ./

RUN /bin/echo "#!/bin/bash" > run.sh
RUN /bin/echo "" >> run.sh
RUN /bin/echo "python survindel2.py --threads 8 input/\$1 workdir reference/\$2" >> run.sh
RUN chmod a+x run.sh

ENTRYPOINT ["./run.sh"]
