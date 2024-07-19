FROM condaforge/mambaforge:latest
LABEL authors="akhorgad"

RUN apt-get update

#install dependencies
RUN apt-get install build-essential -y
RUN conda install conda-forge::biopython
RUN pip install six

#install cpc2
RUN wget https://github.com/gao-lab/CPC2_standalone/archive/refs/tags/v1.0.1.tar.gz
RUN gzip -dc v1.0.1.tar.gz | tar xf -
RUN export CPC_HOME="/CPC2_standalone-1.0.1"
RUN cd /CPC2_standalone-1.0.1/libs/libsvm && gzip -dc libsvm-3.18.tar.gz | tar xf -
RUN cd /CPC2_standalone-1.0.1/libs/libsvm/libsvm-3.18 &&  make clean && make
