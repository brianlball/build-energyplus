FROM ubuntu:20.04 AS base

MAINTAINER Brian Ball brian.ball@nrel.gov

ARG BRANCH=develop
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  gfortran \
  autoconf \
  libssl-dev \
  libicu-dev \
  python3-dev \
  python3-pip \
  python3-tk \
  sudo \
  wget \
  software-properties-common \
  locales \
  locales-all

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN cd /usr/local/src && \
    wget https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0.tar.gz && \
    tar -zxvf cmake-3.21.0.tar.gz && \
    cd cmake-3.21.0/ && \
    ./configure --prefix=/opt/cmake && \
    make -j$(nproc) && make install && \
    rm /usr/bin/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake && \
    rm ../cmake-3.21.0.tar.gz
    
RUN cd /usr/local/src && \
    mkdir energyplus && \
	cd energyplus && \
    git clone https://github.com/brianlball/EnergyPlus.git .

ADD https://api.github.com/repos/brianlball/EnergyPlus/git/refs/heads/$BRANCH version.json

RUN cd /usr/local/src/energyplus && \
    git checkout $BRANCH && \
    rm -rf build && \
	mkdir build && \
	cd build && \
	cmake ../. -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_FORTRAN=ON -DENABLE_REGRESSION_TESTING=OFF && \
	make -j$(nproc)
    
#RUN cd /usr/local/src/energyplus/build/Products && \
#    ./energyplus_tests
    
RUN cd /usr/local/src && \
    mkdir EnergyPlusRegressionTool && \
    cd EnergyPlusRegressionTool && \
    git clone https://github.com/NREL/EnergyPlusRegressionTool.git . && \
    pip3 install -r requirements.txt
	
CMD [ "/bin/bash" ]
