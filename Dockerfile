FROM ubuntu:18.04 AS base

MAINTAINER Brian Ball brian.ball@nrel.gov

ARG BRANCH=develop

RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  autoconf \
  cmake \
  cmake-curses-gui \
  libssl-dev \
  libicu-dev \
  python3-dev \
  python3-pip \ 
  sudo \
  wget \
  bsdtar \
  software-properties-common

RUN cd /usr/local/src && \
    mkdir energyplus && \
	cd energyplus && \
    git clone https://github.com/NREL/EnergyPlus.git .

RUN cd /usr/local/src/energyplus && \
    git checkout $BRANCH && \
    rm -rf build && \
	mkdir build && \
	cd build && \
	cmake ../. -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Debug && \
	make -j$(nproc)

RUN cd /usr/local/src/energyplus/build/Products  && \
    ./energyplus_tests
	
CMD [ "/bin/bash" ]
