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
  software-properties-common \
  locales \
  locales-all

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN cd /usr/local/src && \
    mkdir energyplus && \
	cd energyplus && \
    git clone https://github.com/NREL/EnergyPlus.git .

ADD https://api.github.com/repos/NREL/EnergyPlus/git/refs/heads/$BRANCH version.json

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
