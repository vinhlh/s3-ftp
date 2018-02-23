FROM ubuntu:latest

ARG S3FS_VERSION=v1.82

RUN sudo apt-get install automake \
  autotools-dev \
  fuse \
  g++ \
  git \
  libcurl4-gnutls-dev \
  libfuse-dev \
  libssl-dev \
  libxml2-dev \
  make \
  pkg-config

RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git \
  && cd s3fs-fuse \
  && git checkout tags/${S3FS_VERSION} -b ${S3FS_VERSION} \
  && ./autogen.sh \
  && ./configure \
  && make \
  && sudo make install
