FROM condaforge/mambaforge:latest
LABEL authors="akhorgad"

RUN apt-get update

#install dependencies
RUN apt-get install build-essential -y
RUN apt-get install -y curl

# install gsutil
RUN curl https://sdk.cloud.google.com | bash
ENV PATH=/root/google-cloud-sdk/bin:$PATH

# copy downloaded version of IUPred2a
RUN gsutil -m cp gs://mdl-vignettes/functional_annotations/iupred2a.tar.gz .

#install IUPred2a
RUN gzip -dc iupred2a.tar.gz | tar xf -
