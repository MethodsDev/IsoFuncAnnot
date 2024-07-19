FROM condaforge/mambaforge:latest
LABEL authors="akhorgad"

RUN apt-get update

#install dependencies
RUN apt-get install build-essential -y
RUN conda install conda-forge::biopython

#install deepTMHMM
RUN pip install pybiolib
