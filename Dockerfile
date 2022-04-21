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

RUN apt purge cmake
RUN ln -s /usr/bin/python3 /usr/bin/python

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN cd /usr/local/src && \
    wget https://github.com/Kitware/CMake/releases/download/v3.21.0/cmake-3.21.0.tar.gz && \
    tar -zxvf cmake-3.21.0.tar.gz && \
    cd cmake-3.21.0/ && \
    ./configure --prefix=/opt/cmake && \
    make -j$(nproc) && make install && \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake && \
    ln -s /opt/cmake/bin/ctest /usr/bin/ctest && \
    rm ../cmake-3.21.0.tar.gz

RUN cd /usr/local/src && \
    mkdir EnergyPlusRegressionTool && \
    cd EnergyPlusRegressionTool && \
    git clone https://github.com/NREL/EnergyPlusRegressionTool.git . && \
    pip3 install -r requirements.txt
    
RUN cd /usr/local/src && \
    mkdir energyplus && \
	cd energyplus && \
    git clone https://github.com/brianlball/EnergyPlus.git . 

RUN cd /usr/local/src/energyplus && \
    rm -rf build && \
	mkdir build && \
	cd build && \
	cmake ../. -DBUILD_TESTING=ON -DBUILD_FORTRAN=ON && \
	make -j$(nproc)

ADD https://api.github.com/repos/brianlball/EnergyPlus/git/refs/heads/$BRANCH version.json

RUN cd /usr/local/src && \
    mkdir energyplus_branch && \
	cd energyplus_branch && \
    git clone https://github.com/brianlball/EnergyPlus.git . 
    
RUN cd /usr/local/src/energyplus_branch && \
    git checkout $BRANCH && \
    rm -rf build && \
	mkdir build && \
	cd build && \
	cmake ../. -DLINK_WITH_PYTHON=ON -DPython_REQUIRED_VERSION:STRING=3.8 -DPython_ROOT_DIR:PATH=/usr/bin/python3 -DBUILD_FORTRAN=ON -DBUILD_TESTING=ON -DENABLE_REGRESSION_TESTING=ON -DREGRESSION_BASELINE_PATH:PATH=/usr/local/src/energyplus_branch/build -DREGRESSION_SCRIPT_PATH:PATH=/usr/local/src/EnergyPlusRegressionTool -DREGRESSION_BASELINE_SHA:STRING=0 -DCOMMIT_SHA:STRING=0 -DDEVICE_ID=0 && \
	make -j$(nproc)

RUN cd /usr/local/src/energyplus_branch/build && \
    ctest -R regression
    
#RUN cd /usr/local/src/energyplus/build/Products && \
#    ./energyplus_tests
	
CMD [ "/bin/bash" ]

